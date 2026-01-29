import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/providers/videos_provider.dart';

/// Model para los datos del top video
class TopVideoData {
  final int mediaFileId;
  final String title;
  final String? fileUrl;
  final String? storagePath;
  final int reproducciones;
  final String? posterUrl;

  const TopVideoData({
    required this.mediaFileId,
    required this.title,
    this.fileUrl,
    this.storagePath,
    required this.reproducciones,
    this.posterUrl,
  });

  factory TopVideoData.fromMap(Map<String, dynamic> map) {
    return TopVideoData(
      mediaFileId: map['media_file_id'] as int,
      title: map['title'] as String? ?? 'Sin título',
      fileUrl: map['file_url'] as String?,
      storagePath: map['storage_path'] as String?,
      reproducciones: map['reproducciones'] as int? ?? 0,
      posterUrl: map['poster_url'] as String?,
    );
  }
}

/// Widget premium para mostrar el Top 5 de videos más vistos
class Top5VideosWidget extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() loadTopVideos;
  final Function(TopVideoData)? onVideoTap;

  const Top5VideosWidget({
    Key? key,
    required this.loadTopVideos,
    this.onVideoTap,
  }) : super(key: key);

  @override
  State<Top5VideosWidget> createState() => _Top5VideosWidgetState();
}

class _Top5VideosWidgetState extends State<Top5VideosWidget>
    with SingleTickerProviderStateMixin {
  List<TopVideoData> _topVideos = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // ✅ Esperar a que haya un provider disponible y esté inicializado
      if (!mounted) return;

      final provider = Provider.of<VideosProvider>(context, listen: false);

      // ✅ Esperar a que el provider termine su inicialización
      while (!provider.isInitialized && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!mounted) return;

      final result = await widget.loadTopVideos();
      _topVideos = result.map((map) => TopVideoData.fromMap(map)).toList();

      if (!mounted) return;
      setState(() => _isLoading = false);
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar los videos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2F8A).withOpacity(0.08),
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
          _buildHeader(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon con gradiente púrpura
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6B2F8A).withOpacity(0.2),
                  const Color(0xFF6B2F8A).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B2F8A).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFF6B2F8A),
              size: 24,
            ),
          ),
          const Gap(16),
          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 5 Videos',
                  style: AppTheme.of(context).title3.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const Gap(2),
                Text(
                  'Más reproducidos',
                  style: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).tertiaryText,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          // Botón refresh
          IconButton(
            onPressed: _loadData,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppTheme.of(context).tertiaryText,
            ),
            tooltip: 'Actualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_topVideos.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _topVideos.asMap().entries.map((entry) {
          final index = entry.key;
          final video = entry.value;
          final delay = index * 0.1;

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animValue =
                  (_animationController.value - delay).clamp(0.0, 1.0 - delay) /
                      (1.0 - delay);
              return Opacity(
                opacity: animValue,
                child: Transform.translate(
                  offset: Offset(30 * (1 - animValue), 0),
                  child: child,
                ),
              );
            },
            child: _buildVideoItem(index, video),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideoItem(int index, TopVideoData video) {
    // Colores para las medallas/posiciones
    final positionColors = [
      const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)]), // 1st - Gold
      const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF9E9E9E)]), // 2nd - Silver
      const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFF8B4513)]), // 3rd - Bronze
      const LinearGradient(
          colors: [Color(0xFF4EC9F5), Color(0xFF2E8BC0)]), // 4th
      const LinearGradient(
          colors: [Color(0xFF6B2F8A), Color(0xFF4A0E78)]), // 5th
    ];

    final gradient = positionColors[index.clamp(0, 4)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onVideoTap != null
              ? () => widget.onVideoTap!(video)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.of(context).tertiaryBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: index == 0
                    ? const Color(0xFFFFD700).withOpacity(0.3)
                    : AppTheme.of(context).primaryColor.withOpacity(0.05),
                width: index == 0 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Posición con medalla
                _buildPositionBadge(index + 1, gradient),
                const Gap(12),

                // Thumbnail
                _buildThumbnail(video),
                const Gap(12),

                // Info del video
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
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
                            Icons.play_circle_outline_rounded,
                            size: 14,
                            color: AppTheme.of(context).tertiaryText,
                          ),
                          const Gap(4),
                          Text(
                            _formatViews(video.reproducciones),
                            style: AppTheme.of(context).bodyText2.override(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.of(context).tertiaryText,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Badge de reproducciones
                _buildViewsBadge(video.reproducciones),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionBadge(int position, LinearGradient gradient) {
    final isTop3 = position <= 3;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isTop3
            ? Icon(
                position == 1
                    ? Icons.emoji_events
                    : position == 2
                        ? Icons.workspace_premium
                        : Icons.military_tech,
                color: Colors.white,
                size: 20,
              )
            : Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildThumbnail(TopVideoData video) {
    return Container(
      width: 56,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.of(context).tertiaryBackground,
        image: video.posterUrl != null
            ? DecorationImage(
                image: NetworkImage(video.posterUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: video.posterUrl == null
          ? Center(
              child: Icon(
                Icons.video_library_rounded,
                color: AppTheme.of(context).tertiaryText,
                size: 20,
              ),
            )
          : null,
    );
  }

  Widget _buildViewsBadge(int views) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4EC9F5), Color(0xFFFFB733)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatViewsShort(views),
        style: const TextStyle(
          color: Color(0xFF0B0B0D),
          fontWeight: FontWeight.bold,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: AppTheme.of(context).tertiaryBackground,
        highlightColor: AppTheme.of(context).secondaryBackground,
        child: Column(
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.of(context).error,
            ),
            const Gap(16),
            Text(
              _error!,
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).tertiaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 48,
              color: AppTheme.of(context).tertiaryText,
            ),
            const Gap(16),
            Text(
              'No hay videos disponibles',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).tertiaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M reproducciones';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K reproducciones';
    }
    return '$views reproducciones';
  }

  String _formatViewsShort(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }
}
