import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:gap/gap.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Consumer<VideosProvider>(
      builder: (context, provider, child) {
        // Valores hardcodeados por defecto (mostrar mientras carga o si no hay datos)
        final useHardcodedData =
            provider.isLoading || provider.mediaFiles.isEmpty;

        final totalVideos = useHardcodedData ? 9 : provider.mediaFiles.length;
        final totalReproducciones =
            useHardcodedData ? 16473 : provider.getTotalReproducciones();
        final promedioDia =
            useHardcodedData ? 549 : provider.getPromedioDiario();

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Gap(24),
                _buildStatsCards(
                    isMobile, totalVideos, totalReproducciones, promedioDia),
                const Gap(24),
                _buildRecentActivity(provider, useHardcodedData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4EC9F5),
            const Color(0xFF6B2F8A),
            const Color(0xFFFFB733),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4EC9F5).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFFFB733).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const Gap(24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Premium',
                  style: AppTheme.of(context).title1.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
                const Gap(8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Panel de control de contenido multimedia',
                    style: AppTheme.of(context).bodyText1.override(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isMobile, int totalVideos,
      int totalReproducciones, int promedioDia) {
    return isMobile
        ? Column(
            children: [
              _buildStatCard(
                'Total Videos',
                totalVideos.toString(),
                Icons.video_library,
                const Color(0xFF4EC9F5),
                '+12%',
              ),
              const Gap(16),
              _buildStatCard(
                'Reproducciones',
                totalReproducciones.toString(),
                Icons.play_circle_filled,
                const Color(0xFFFFB733),
                '+23%',
              ),
              const Gap(16),
              _buildStatCard(
                'Promedio/Día',
                promedioDia.toString(),
                Icons.trending_up,
                const Color(0xFF00C896),
                '+18%',
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Videos',
                  totalVideos.toString(),
                  Icons.video_library,
                  const Color(0xFF4EC9F5),
                  '+12%',
                ),
              ),
              const Gap(16),
              Expanded(
                child: _buildStatCard(
                  'Reproducciones',
                  totalReproducciones.toString(),
                  Icons.play_circle_filled,
                  const Color(0xFFFFB733),
                  '+23%',
                ),
              ),
              const Gap(16),
              Expanded(
                child: _buildStatCard(
                  'Promedio/Día',
                  promedioDia.toString(),
                  Icons.trending_up,
                  const Color(0xFF00C896),
                  '+18%',
                ),
              ),
            ],
          );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      String percentage) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).secondaryBackground,
            AppTheme.of(context).tertiaryBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Efecto de brillo sutil en la esquina
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 28,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          percentage,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Text(
                    value,
                    style: AppTheme.of(context).title1.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).primaryText,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.of(context).bodyText1.override(
                                fontFamily: 'Poppins',
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(VideosProvider provider, bool useHardcodedData) {
    // Datos hardcodeados para Top 5 Videos (los mismos de la imagen)
    final hardcodedTop5 = [
      {
        'title': 'Metallic Phone - Lanzamiento',
        'views': 5230,
        'icon': Icons.emoji_events,
        'color': Color(0xFFFFB733)
      },
      {
        'title': 'Disney On Ice - Let\'s Dance',
        'views': 3420,
        'icon': Icons.workspace_premium,
        'color': Color(0xFF9E9E9E)
      },
      {
        'title': 'Hispanic Heritage Month',
        'views': 2100,
        'icon': Icons.military_tech,
        'color': Color(0xFFCD7F32)
      },
      {
        'title': 'Kimball Holiday Special',
        'views': 1840,
        'icon': Icons.looks_4,
        'color': Color(0xFF4EC9F5)
      },
      {
        'title': 'Black Friday - Promoción Especial',
        'views': 1250,
        'icon': Icons.looks_5,
        'color': Color(0xFF6B2F8A)
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).secondaryBackground,
            AppTheme.of(context).tertiaryBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(28),
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
                          AppTheme.of(context).secondaryColor.withOpacity(0.2),
                          AppTheme.of(context).secondaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.of(context)
                            .secondaryColor
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: AppTheme.of(context).secondaryColor,
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
                        const Gap(4),
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
              // Mostrar Top 5 Videos (hardcoded o real según estado)
              useHardcodedData
                  ? Column(
                      children: hardcodedTop5.asMap().entries.map((entry) {
                        final index = entry.key;
                        final video = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .primaryBackground
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: video['color'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (video['color'] as Color)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  video['icon'] as IconData,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video['title'] as String,
                                      style: AppTheme.of(context)
                                          .bodyText1
                                          .override(
                                            fontFamily: 'Poppins',
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Gap(6),
                                    Text(
                                      '${_formatNumber(video['views'] as int)} reproducciones',
                                      style: AppTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Poppins',
                                            color: AppTheme.of(context)
                                                .tertiaryText,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      video['color'] as Color,
                                      (video['color'] as Color)
                                          .withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (video['color'] as Color)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${_formatNumber(video['views'] as int)}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Consumer<VideosProvider>(
                      builder: (context, provider, child) {
                        if (provider.mediaFiles.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.video_library_outlined,
                                    size: 64,
                                    color: AppTheme.of(context).tertiaryText,
                                  ),
                                  const Gap(16),
                                  Text(
                                    'No hay actividad reciente',
                                    style: AppTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Poppins',
                                          color:
                                              AppTheme.of(context).tertiaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Obtener top 5 por reproducciones
                        final sortedVideos = List.from(provider.mediaFiles)
                          ..sort((a, b) =>
                              b.reproducciones.compareTo(a.reproducciones));
                        final top5Videos = sortedVideos.take(5).toList();

                        return Column(
                          children: top5Videos.map((video) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.of(context)
                                    .primaryBackground
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.of(context).primaryColor,
                                          AppTheme.of(context).secondaryColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title ?? video.fileName,
                                          style: AppTheme.of(context)
                                              .bodyText1
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Gap(6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 14,
                                              color: AppTheme.of(context)
                                                  .tertiaryText,
                                            ),
                                            const Gap(4),
                                            Text(
                                              'Hace ${_getTimeAgo(video.createdAt)}',
                                              style: AppTheme.of(context)
                                                  .bodyText2
                                                  .override(
                                                    fontFamily: 'Poppins',
                                                    color: AppTheme.of(context)
                                                        .tertiaryText,
                                                    fontSize: 12,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.of(context).success,
                                          AppTheme.of(context)
                                              .success
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.of(context)
                                              .success
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.visibility_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const Gap(6),
                                        Text(
                                          '${video.reproducciones}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'desconocido';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} semanas';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos';
    } else {
      return 'hace un momento';
    }
  }
}
