import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:gap/gap.dart';

// Importar los widgets modulares
import 'package:energy_media/pages/videos/widgets/premium_dashboard_widgets/premium_dashboard_widgets.dart';

class PremiumDashboardPage extends StatefulWidget {
  const PremiumDashboardPage({Key? key}) : super(key: key);

  @override
  State<PremiumDashboardPage> createState() => _PremiumDashboardPageState();
}

class _PremiumDashboardPageState extends State<PremiumDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    // Inicializar con datos hardcodeados
    stats = {
      'total_videos': 9,
      'total_reproducciones': 16473,
      'promedio_reproducciones_por_dia': 549.0,
    };
    isLoading = false;

    // Cargar datos reales en background
    _loadStatsInBackground();
  }

  Future<void> _loadStatsInBackground() async {
    final provider = Provider.of<VideosProvider>(context, listen: false);

    // ✅ Esperar a que el provider termine de inicializar (no solo isLoading)
    if (!provider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        return _loadStatsInBackground();
      }
      return;
    }

    // ✅ Cargar datos reales del provider ya inicializado
    final result = await provider.getDashboardStats();
    if (mounted && result.isNotEmpty) {
      setState(() {
        stats = {
          'total_videos': result['total_videos'] ?? 9,
          'total_reproducciones': result['total_reproducciones'] ?? 16473,
          'promedio_reproducciones_por_dia':
              (result['total_reproducciones'] ?? 16473) / 30.0,
        };
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _loadStatsInBackground,
          color: AppTheme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* _buildWelcomeHeader(),
                const Gap(32), */
                _buildStatsCards(isMobile),
                const Gap(32),
                if (!isMobile) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildViewsChart()),
                      const Gap(24),
                      Expanded(flex: 2, child: _buildTopVideos()),
                    ],
                  ),
                  const Gap(24),
                  _buildRecentActivity(),
                ] else ...[
                  _buildTopVideos(),
                  const Gap(24),
                  _buildViewsChart(),
                  const Gap(24),
                  _buildRecentActivity(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isMobile) {
    // Usar datos hardcodeados o reales según disponibilidad
    final totalVideos = stats['total_videos'] ?? 9;
    final totalViews = stats['total_reproducciones'] ?? 16473;
    final avgViewsPerDay =
        (stats['promedio_reproducciones_por_dia'] ?? 549.0).toDouble();

    // Datos de ejemplo para sparkline (simulados)
    final sparklineData1 = [45.0, 52.0, 48.0, 65.0, 59.0, 72.0, 78.0];
    final sparklineData2 = [120.0, 145.0, 132.0, 168.0, 175.0, 190.0, 210.0];
    final sparklineData3 = [25.0, 28.0, 24.0, 32.0, 30.0, 35.0, 38.0];

    final cards = [
      PremiumStatCard(
        data: StatCardData(
          title: 'Total Videos',
          value: totalVideos,
          icon: Icons.video_library_rounded,
          gradientColors: const [Color(0xFF4EC9F5), Color(0xFF2E8BC0)],
          trend: '+12%',
          trendUp: true,
        ),
        showSparkline: true,
        sparklineData: sparklineData1,
      ),
      PremiumStatCard(
        data: StatCardData(
          title: 'Reproducciones',
          value: totalViews,
          icon: Icons.play_circle_filled_rounded,
          gradientColors: const [Color(0xFFFFB733), Color(0xFFFF8A00)],
          trend: '+23%',
          trendUp: true,
        ),
        showSparkline: true,
        sparklineData: sparklineData2,
      ),
      PremiumStatCard(
        data: StatCardData(
          title: 'Promedio/Día',
          value: avgViewsPerDay is num
              ? avgViewsPerDay.toInt()
              : (avgViewsPerDay as double).toInt(),
          icon: Icons.trending_up_rounded,
          gradientColors: const [Color(0xFF00C9A7), Color(0xFF00B894)],
          trend: '+8%',
          trendUp: true,
        ),
        showSparkline: true,
        sparklineData: sparklineData3,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((card) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: card,
          );
        }).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.4, // Más altura para evitar overflow
      children: cards,
    );
  }

  Widget _buildLoadingSkeleton(bool isMobile) {
    if (isMobile) {
      // En mobile usar Column en lugar de GridView para evitar distorsión
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: AppTheme.of(context).tertiaryBackground,
              highlightColor: AppTheme.of(context).secondaryBackground,
              child: const StatCardSkeleton(isMobile: true),
            ),
          ),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: AppTheme.of(context).tertiaryBackground,
      highlightColor: AppTheme.of(context).secondaryBackground,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
        children: List.generate(
          3,
          (index) => const StatCardSkeleton(),
        ),
      ),
    );
  }

  Widget _buildViewsChart() {
    // Datos de ejemplo - idealmente vendrían de la BD
    final chartData = [
      const ChartDataPoint(label: 'Lun', value: 65),
      const ChartDataPoint(label: 'Mar', value: 80),
      const ChartDataPoint(label: 'Mié', value: 45),
      const ChartDataPoint(label: 'Jue', value: 90),
      const ChartDataPoint(label: 'Vie', value: 75),
      const ChartDataPoint(label: 'Sáb', value: 55),
      const ChartDataPoint(label: 'Dom', value: 40),
    ];

    return PremiumViewsChart(
      data: chartData,
      title: 'Reproducciones Semanales',
      icon: Icons.bar_chart_rounded,
      iconColor: const Color(0xFFFFB733),
    );
  }

  Widget _buildTopVideos() {
    final provider = Provider.of<VideosProvider>(context, listen: false);

    return Top5VideosWidget(
      loadTopVideos: provider.getTop5VideosByViews,
      onVideoTap: (video) {
        // Opcional: navegar al video o mostrar detalles
        debugPrint('Video tapped: ${video.title}');
      },
    );
  }

  Widget _buildRecentActivity() {
    final provider = Provider.of<VideosProvider>(context);
    final recentVideos = provider.mediaFiles.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C9A7).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00C9A7).withOpacity(0.2),
                      const Color(0xFF00C9A7).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C9A7).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF00C9A7),
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actividad Reciente',
                      style: AppTheme.of(context).title3.override(
                            fontFamily: 'Poppins',
                            color: AppTheme.of(context).primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    const Gap(2),
                    Text(
                      'Últimos videos subidos',
                      style: AppTheme.of(context).bodyText2.override(
                            fontFamily: 'Poppins',
                            color: AppTheme.of(context).tertiaryText,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(24),
          ...recentVideos.map((video) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Opcional: navegar al video
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context)
                          .tertiaryBackground
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail
                        Container(
                          width: 56,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4EC9F5).withOpacity(0.8),
                                const Color(0xFFFFB733).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.video_library_rounded,
                            color: Color(0xFF0B0B0D),
                            size: 22,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title ?? video.fileName,
                                style: AppTheme.of(context).bodyText1.override(
                                      fontFamily: 'Poppins',
                                      color: AppTheme.of(context).primaryText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: AppTheme.of(context).tertiaryText,
                                  ),
                                  const Gap(4),
                                  Text(
                                    'Subido ${_getTimeAgo(video.createdAt)}',
                                    style: AppTheme.of(context)
                                        .bodyText2
                                        .override(
                                          fontFamily: 'Poppins',
                                          color:
                                              AppTheme.of(context).tertiaryText,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Badge de reproducciones
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C9A7).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00C9A7).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF00C9A7),
                                size: 14,
                              ),
                              const Gap(4),
                              Text(
                                '${video.reproducciones}',
                                style: const TextStyle(
                                  color: Color(0xFF00C9A7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime? timestamp) {
    if (timestamp == null) return 'hace un momento';

    final difference = DateTime.now().difference(timestamp);

    if (difference.inDays > 30) {
      return 'hace ${(difference.inDays / 30).floor()} meses';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minutos';
    } else {
      return 'hace un momento';
    }
  }
}
