import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/models/media/media_models.dart';
import 'package:gap/gap.dart';

class VideoPlayerDialog extends StatefulWidget {
  final MediaFileModel video;
  final VoidCallback? onPlaybackCompleted;
  final VoidCallback? onClose;

  const VideoPlayerDialog({
    Key? key,
    required this.video,
    this.onPlaybackCompleted,
    this.onClose,
  }) : super(key: key);

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Inicializar video player con URL del video
      _videoPlayerController = VideoPlayerController.network(
        widget.video.fileUrl!,
      );

      await _videoPlayerController.initialize();

      // Configurar Chewie (controles de video)
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF4EC9F5),
          handleColor: const Color(0xFFFFB733),
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF2D2D),
                  size: 60,
                ),
                const Gap(16),
                Text(
                  'Error al cargar el video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Listener para detectar fin del video
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position ==
            _videoPlayerController.value.duration) {
          widget.onPlaybackCompleted?.call();
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el video: $e';
      });
      print('Error inicializando video player: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 8 : 40),
      child: Container(
        width: isMobile ? screenSize.width : screenSize.width * 0.8,
        constraints: BoxConstraints(
          maxWidth: 1200,
          maxHeight: screenSize.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, isMobile),

            // Video Player
            Flexible(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: _buildVideoPlayer(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryBackground,
            AppTheme.of(context).secondaryBackground,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4EC9F5),
                  Color(0xFFFFB733),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: Color(0xFF0B0B0D),
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title ?? widget.video.fileName,
                  style: AppTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.video.fileDescription != null &&
                    widget.video.fileDescription!.isNotEmpty &&
                    !isMobile)
                  Text(
                    widget.video.fileDescription!,
                    style: AppTheme.of(context).bodyText2.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).tertiaryText,
                          fontSize: 12,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppTheme.of(context).primaryText,
            ),
            onPressed: () {
              widget.onClose?.call();
              Navigator.of(context).pop();
            },
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.of(context).primaryColor,
            ),
            const Gap(16),
            Text(
              'Cargando video...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF2D2D),
                size: 60,
              ),
              const Gap(16),
              Text(
                'Error al cargar el video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D2D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return Center(
        child: Text(
          'No se pudo inicializar el reproductor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
