import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:energy_media/theme/theme.dart';

/// Widget que genera un thumbnail automático desde una URL de video.
/// Se usa como fallback cuando no hay poster/portada subida por el usuario.
/// Usa get_thumbnail_video para compatibilidad con Flutter Web y mejor rendimiento.
class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const VideoThumbnailWidget({
    Key? key,
    required this.videoUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: widget.videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 320,
        quality: 75,
      );

      if (!mounted) return;

      if (thumbnail != null && thumbnail.isNotEmpty) {
        setState(() {
          _thumbnailBytes = thumbnail;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Error generando thumbnail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras genera thumbnail
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppTheme.of(context).tertiaryBackground,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    // Mostrar placeholder si hay error
    if (_hasError || _thumbnailBytes == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppTheme.of(context).tertiaryBackground,
        child: Center(
          child: Icon(
            Icons.video_library_rounded,
            size: 28,
            color: AppTheme.of(context).tertiaryText,
          ),
        ),
      );
    }

    // Mostrar thumbnail generado (imagen estática, no video)
    return Image.memory(
      _thumbnailBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: widget.width,
        height: widget.height,
        color: AppTheme.of(context).tertiaryBackground,
        child: Center(
          child: Icon(
            Icons.video_library_rounded,
            size: 28,
            color: AppTheme.of(context).tertiaryText,
          ),
        ),
      ),
    );
  }
}
