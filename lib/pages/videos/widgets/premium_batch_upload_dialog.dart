import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/widgets/premium_button.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;

/// Modelo para cada video en la cola de subida
class BatchVideoItem {
  final String id;
  String fileName;
  String title;
  String description;
  List<String> tags;
  Uint8List videoBytes;
  Uint8List? posterBytes;
  String? posterFileName;
  String? blobUrl;
  int? durationSeconds;
  BatchUploadStatus status;
  double progress;
  String? errorMessage;

  BatchVideoItem({
    required this.id,
    required this.fileName,
    required this.title,
    required this.videoBytes,
    this.description = '',
    this.tags = const [],
    this.posterBytes,
    this.posterFileName,
    this.blobUrl,
    this.durationSeconds,
    this.status = BatchUploadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
  });
}

enum BatchUploadStatus {
  pending,
  uploading,
  completed,
  error,
}

/// Límite máximo de tamaño de archivo (10MB)
const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

class PremiumBatchUploadDialog extends StatefulWidget {
  final VideosProvider provider;
  final VoidCallback onSuccess;

  const PremiumBatchUploadDialog({
    Key? key,
    required this.provider,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PremiumBatchUploadDialog> createState() =>
      _PremiumBatchUploadDialogState();
}

class _PremiumBatchUploadDialogState extends State<PremiumBatchUploadDialog> {
  List<BatchVideoItem> _videoQueue = [];
  bool _isUploading = false;
  int _currentUploadIndex = 0;
  int _completedCount = 0;
  int _errorCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // Limpiar blob URLs
    for (var video in _videoQueue) {
      if (video.blobUrl != null) {
        html.Url.revokeObjectUrl(video.blobUrl!);
      }
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// Seleccionar múltiples videos
  Future<void> _selectMultipleVideos() async {
    final input = html.FileUploadInputElement()
      ..accept = 'video/*'
      ..multiple = true;

    input.click();

    await input.onChange.first;

    if (input.files == null || input.files!.isEmpty) return;

    List<String> rejectedFiles = [];

    for (var file in input.files!) {
      // Validar tamaño del archivo (máximo 10MB)
      if (file.size > _maxFileSizeBytes) {
        final sizeMB = (file.size / (1024 * 1024)).toStringAsFixed(1);
        rejectedFiles.add('${file.name} (${sizeMB}MB)');
        continue;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final bytes = Uint8List.fromList(reader.result as List<int>);
      final fileName = file.name;
      final nameWithoutExt = p.basenameWithoutExtension(fileName);

      // Crear blob URL para preview
      final blob = html.Blob([bytes]);
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      // Obtener duración del video
      int? duration;
      try {
        final controller = VideoPlayerController.network(blobUrl);
        await controller.initialize();
        duration = controller.value.duration.inSeconds;
        controller.dispose();
      } catch (e) {
        debugPrint('Error obteniendo duración: $e');
      }

      final videoItem = BatchVideoItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_videoQueue.length}',
        fileName: fileName,
        title: nameWithoutExt,
        videoBytes: bytes,
        blobUrl: blobUrl,
        durationSeconds: duration,
        tags: [], // Lista mutable para tags
      );

      setState(() {
        _videoQueue.add(videoItem);
      });

      // Generar thumbnail automáticamente después de agregar
      _generateThumbnail(videoItem);
    }

    // Mostrar mensaje si hubo archivos rechazados por tamaño
    if (rejectedFiles.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                  Gap(8),
                  Text(
                    'Videos rechazados (máx. 10MB):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Gap(4),
              Text(
                rejectedFiles.join(', '),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF7A3D),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// Seleccionar portada para un video específico
  Future<void> _selectPosterForVideo(BatchVideoItem video) async {
    final input = html.FileUploadInputElement()..accept = 'image/*';

    input.click();

    await input.onChange.first;

    if (input.files == null || input.files!.isEmpty) return;

    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final bytes = Uint8List.fromList(reader.result as List<int>);

    setState(() {
      video.posterBytes = bytes;
      video.posterFileName = file.name;
    });
  }

  /// Generar thumbnail automático desde el video
  Future<void> _generateThumbnail(BatchVideoItem video) async {
    if (video.blobUrl == null) return;

    try {
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: video.blobUrl!,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280,
        quality: 85,
      );

      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        setState(() {
          video.posterBytes = thumbnailBytes;
          video.posterFileName = 'thumbnail_${video.fileName}.jpg';
        });
      }
    } catch (e) {
      debugPrint('Error generando thumbnail: $e');
    }
  }

  /// Eliminar video de la cola
  void _removeVideo(BatchVideoItem video) {
    if (video.blobUrl != null) {
      html.Url.revokeObjectUrl(video.blobUrl!);
    }
    setState(() {
      _videoQueue.remove(video);
    });
  }

  /// Iniciar subida de todos los videos
  Future<void> _startBatchUpload() async {
    if (_videoQueue.isEmpty) return;

    setState(() {
      _isUploading = true;
      _currentUploadIndex = 0;
      _completedCount = 0;
      _errorCount = 0;
    });

    for (int i = 0; i < _videoQueue.length; i++) {
      final video = _videoQueue[i];

      setState(() {
        _currentUploadIndex = i;
        video.status = BatchUploadStatus.uploading;
        video.progress = 0.0;
      });

      // Scroll automático al video actual
      _scrollToCurrentVideo(i);

      try {
        // Simular progreso durante la subida
        for (int p = 0; p <= 100; p += 10) {
          await Future.delayed(const Duration(milliseconds: 50));
          if (!mounted) return;
          setState(() {
            video.progress = p / 100;
          });
        }

        // Generar thumbnail si no tiene poster
        if (video.posterBytes == null && video.blobUrl != null) {
          await _generateThumbnailForUpload(video);
        }

        // Subir video
        final success = await _uploadSingleVideo(video);

        setState(() {
          if (success) {
            video.status = BatchUploadStatus.completed;
            video.progress = 1.0;
            _completedCount++;
          } else {
            video.status = BatchUploadStatus.error;
            video.errorMessage = 'Error al subir';
            _errorCount++;
          }
        });
      } catch (e) {
        setState(() {
          video.status = BatchUploadStatus.error;
          video.errorMessage = e.toString();
          _errorCount++;
        });
      }
    }

    setState(() {
      _isUploading = false;
    });

    // Mostrar resumen
    if (mounted) {
      _showUploadSummary();
    }
  }

  Future<void> _generateThumbnailForUpload(BatchVideoItem video) async {
    if (video.blobUrl == null) return;

    try {
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: video.blobUrl!,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280,
        quality: 85,
      );

      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        video.posterBytes = thumbnailBytes;
        video.posterFileName = 'thumbnail_${video.fileName}.jpg';
      }
    } catch (e) {
      debugPrint('Error generando thumbnail para upload: $e');
    }
  }

  Future<bool> _uploadSingleVideo(BatchVideoItem video) async {
    try {
      // Preparar el provider con los datos del video
      widget.provider.webVideoBytes = video.videoBytes;
      widget.provider.videoName = video.fileName;
      widget.provider.videoFileExtension = p.extension(video.fileName);

      if (video.posterBytes != null) {
        widget.provider.webPosterBytes = video.posterBytes;
        widget.provider.posterName = video.posterFileName;
        widget.provider.posterFileExtension =
            p.extension(video.posterFileName ?? '.jpg');
      }

      final success = await widget.provider.uploadVideo(
        title: video.title,
        description: video.description.isEmpty ? null : video.description,
        durationSeconds: video.durationSeconds,
        tags: video.tags.isNotEmpty ? video.tags : null,
      );

      return success;
    } catch (e) {
      debugPrint('Error subiendo video ${video.title}: $e');
      return false;
    }
  }

  void _scrollToCurrentVideo(int index) {
    if (_scrollController.hasClients) {
      final offset = index * 200.0; // Altura aproximada de cada card
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showUploadSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _errorCount == 0
                  ? Icons.check_circle_rounded
                  : Icons.warning_rounded,
              color: _errorCount == 0
                  ? const Color(0xFF00C9A7)
                  : const Color(0xFFFFB733),
              size: 28,
            ),
            const Gap(12),
            Text(
              'Subida Completada',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(
              Icons.check_circle_rounded,
              const Color(0xFF00C9A7),
              'Exitosos: $_completedCount',
            ),
            if (_errorCount > 0) ...[
              const Gap(8),
              _buildSummaryRow(
                Icons.error_rounded,
                const Color(0xFFFF2D2D),
                'Con errores: $_errorCount',
              ),
            ],
            const Gap(8),
            _buildSummaryRow(
              Icons.video_library_rounded,
              const Color(0xFF4EC9F5),
              'Total: ${_videoQueue.length}',
            ),
          ],
        ),
        actions: [
          PremiumButton(
            text: 'Cerrar',
            onPressed: () {
              Navigator.pop(context); // Cerrar resumen
              Navigator.pop(context); // Cerrar diálogo principal
              widget.onSuccess();
            },
            backgroundColor: const Color(0xFF4EC9F5),
            width: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const Gap(8),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        width: isMobile ? double.infinity : 1000,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _videoQueue.isEmpty
                  ? _buildEmptyState()
                  : _buildVideoList(isMobile),
            ),
            if (_isUploading) _buildProgressBar(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B2F8A),
            Color(0xFF4EC9F5),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subir Videos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Gap(4),
                Text(
                  _videoQueue.isEmpty
                      ? 'Selecciona uno o varios videos'
                      : '${_videoQueue.length} video(s) en cola',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isUploading ? null : () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: _isUploading ? Colors.white38 : Colors.white,
            ),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.of(context).tertiaryBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_library_rounded,
              size: 64,
              color: AppTheme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
          const Gap(24),
          Text(
            'No hay videos seleccionados',
            style: AppTheme.of(context).title3.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(8),
          Text(
            'Haz clic en el botón para seleccionar\nmúltiples videos a la vez',
            textAlign: TextAlign.center,
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).tertiaryText,
                ),
          ),
          const Gap(32),
          PremiumButton(
            text: 'Seleccionar Videos',
            icon: Icons.add_rounded,
            onPressed: _selectMultipleVideos,
            backgroundColor: const Color(0xFF4EC9F5),
            width: 220,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botón para agregar más videos
          if (!_isUploading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectMultipleVideos,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar más videos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4EC9F5),
                        side: const BorderSide(color: Color(0xFF4EC9F5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Lista de videos
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _videoQueue.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(_videoQueue[index], isMobile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BatchVideoItem video, bool isMobile) {
    final isCurrentlyUploading =
        _isUploading && _videoQueue.indexOf(video) == _currentUploadIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(video.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? _buildMobileCardContent(video, isCurrentlyUploading)
                : _buildDesktopCardContent(video, isCurrentlyUploading),
          ),
          // Barra de progreso individual
          if (isCurrentlyUploading ||
              video.status == BatchUploadStatus.uploading)
            LinearProgressIndicator(
              value: video.progress,
              backgroundColor: AppTheme.of(context).secondaryBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(video.status),
              ),
              minHeight: 4,
            ),
          // Badge de estado
          if (video.status != BatchUploadStatus.pending)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(video.status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(video.status),
                    color: _getStatusColor(video.status),
                    size: 18,
                  ),
                  const Gap(8),
                  Text(
                    _getStatusText(video.status),
                    style: TextStyle(
                      color: _getStatusColor(video.status),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopCardContent(
      BatchVideoItem video, bool isCurrentlyUploading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        _buildThumbnailSection(video),
        const Gap(16),
        // Campos de edición
        Expanded(
          child: _buildEditFields(video, isCurrentlyUploading),
        ),
        // Acciones
        if (!_isUploading) _buildActionButtons(video),
      ],
    );
  }

  Widget _buildMobileCardContent(
      BatchVideoItem video, bool isCurrentlyUploading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildThumbnailSection(video, isMobile: true),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.fileName,
                    style: TextStyle(
                      color: AppTheme.of(context).primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (video.durationSeconds != null) ...[
                    const Gap(4),
                    Text(
                      _formatDuration(video.durationSeconds!),
                      style: TextStyle(
                        color: AppTheme.of(context).tertiaryText,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!_isUploading)
              IconButton(
                onPressed: () => _removeVideo(video),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: const Color(0xFFFF2D2D),
                tooltip: 'Eliminar',
              ),
          ],
        ),
        const Gap(12),
        _buildEditFields(video, isCurrentlyUploading),
      ],
    );
  }

  Widget _buildThumbnailSection(BatchVideoItem video, {bool isMobile = false}) {
    final size = isMobile ? 70.0 : 120.0;

    return Stack(
      children: [
        Container(
          width: size,
          height: size * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: video.posterBytes != null
                ? Image.memory(
                    video.posterBytes!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      Icons.video_file_rounded,
                      size: isMobile ? 28 : 40,
                      color: AppTheme.of(context).tertiaryText,
                    ),
                  ),
          ),
        ),
        // Botón de play para previsualizar video
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: () => _showVideoPreview(video),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 28,
                ),
              ),
            ),
          ),
        ),
        // Botón para cambiar poster
        if (!_isUploading && !isMobile)
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _selectPosterForVideo(video),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4EC9F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Mostrar preview del video en un dialog
  void _showVideoPreview(BatchVideoItem video) {
    if (video.blobUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => _VideoPreviewDialog(blobUrl: video.blobUrl!),
    );
  }

  Widget _buildEditFields(BatchVideoItem video, bool isCurrentlyUploading) {
    final isEditable = !_isUploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        TextField(
          enabled: isEditable,
          controller: TextEditingController(text: video.title)
            ..selection = TextSelection.collapsed(offset: video.title.length),
          onChanged: (value) => video.title = value,
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Título del video',
            hintStyle: TextStyle(
              color: AppTheme.of(context).tertiaryText,
            ),
            prefixIcon: Icon(
              Icons.title_rounded,
              color: AppTheme.of(context).primaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
        ),
        const Gap(8),
        // Descripción
        TextField(
          enabled: isEditable,
          controller: TextEditingController(text: video.description)
            ..selection =
                TextSelection.collapsed(offset: video.description.length),
          onChanged: (value) => video.description = value,
          maxLines: 2,
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: 'Descripción (opcional)',
            hintStyle: TextStyle(
              color: AppTheme.of(context).tertiaryText,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.description_rounded,
                color: AppTheme.of(context).primaryColor,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
        ),
        const Gap(8),
        // Tags
        _buildTagsField(video, isEditable),
      ],
    );
  }

  Widget _buildTagsField(BatchVideoItem video, bool isEditable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar tags existentes como chips
        if (video.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: video.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4EC9F5).withOpacity(0.2),
                        const Color(0xFFFFB733).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4EC9F5).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isEditable) ...[
                        const Gap(4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              video.tags = List.from(video.tags)..remove(tag);
                            });
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppTheme.of(context).tertiaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        // Campo para agregar nuevo tag
        TextField(
          enabled: isEditable,
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: 'Agregar tag y presiona Enter',
            hintStyle: TextStyle(
              color: AppTheme.of(context).tertiaryText,
            ),
            prefixIcon: Icon(
              Icons.label_rounded,
              color: const Color(0xFFFFB733),
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
          onSubmitted: (value) {
            final tag = value.trim();
            if (tag.isNotEmpty && !video.tags.contains(tag)) {
              setState(() {
                video.tags = List.from(video.tags)..add(tag);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BatchVideoItem video) {
    return Column(
      children: [
        // Reproducir video
        _buildSmallActionButton(
          icon: Icons.play_circle_rounded,
          tooltip: 'Reproducir video',
          color: const Color(0xFF00C9A7),
          onPressed: () => _showVideoPreview(video),
        ),
        const Gap(8),
        // Seleccionar poster
        _buildSmallActionButton(
          icon: Icons.image_rounded,
          tooltip: 'Cambiar portada',
          color: const Color(0xFF4EC9F5),
          onPressed: () => _selectPosterForVideo(video),
        ),
        const Gap(8),
        // Eliminar
        _buildSmallActionButton(
          icon: Icons.delete_rounded,
          tooltip: 'Eliminar',
          color: const Color(0xFFFF2D2D),
          onPressed: () => _removeVideo(video),
        ),
      ],
    );
  }

  Widget _buildSmallActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final totalProgress = _videoQueue.isEmpty
        ? 0.0
        : (_completedCount + _errorCount) / _videoQueue.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subiendo: ${_currentUploadIndex + 1} de ${_videoQueue.length}',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(totalProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF4EC9F5),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalProgress,
              backgroundColor: AppTheme.of(context).secondaryBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4EC9F5),
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_isUploading) ...[
            PremiumButton(
              text: 'Cancelar',
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.grey,
              isOutlined: true,
              width: 120,
            ),
            const Gap(12),
          ],
          PremiumButton(
            text: _isUploading
                ? 'Subiendo...'
                : _videoQueue.length == 1
                    ? 'Subir 1 video'
                    : 'Subir ${_videoQueue.length} videos',
            icon: _isUploading ? null : Icons.cloud_upload_rounded,
            onPressed:
                _isUploading || _videoQueue.isEmpty ? null : _startBatchUpload,
            backgroundColor: const Color(0xFF00C9A7),
            width: 220,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BatchUploadStatus status) {
    switch (status) {
      case BatchUploadStatus.pending:
        return AppTheme.of(context).tertiaryText;
      case BatchUploadStatus.uploading:
        return const Color(0xFF4EC9F5);
      case BatchUploadStatus.completed:
        return const Color(0xFF00C9A7);
      case BatchUploadStatus.error:
        return const Color(0xFFFF2D2D);
    }
  }

  IconData _getStatusIcon(BatchUploadStatus status) {
    switch (status) {
      case BatchUploadStatus.pending:
        return Icons.schedule_rounded;
      case BatchUploadStatus.uploading:
        return Icons.cloud_upload_rounded;
      case BatchUploadStatus.completed:
        return Icons.check_circle_rounded;
      case BatchUploadStatus.error:
        return Icons.error_rounded;
    }
  }

  String _getStatusText(BatchUploadStatus status) {
    switch (status) {
      case BatchUploadStatus.pending:
        return 'Pendiente';
      case BatchUploadStatus.uploading:
        return 'Subiendo...';
      case BatchUploadStatus.completed:
        return 'Completado';
      case BatchUploadStatus.error:
        return 'Error';
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

/// Dialog para previsualizar el video antes de subir
class _VideoPreviewDialog extends StatefulWidget {
  final String blobUrl;

  const _VideoPreviewDialog({required this.blobUrl});

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.blobUrl);
    try {
      await _controller!.initialize();
      setState(() => _isInitialized = true);
      _controller!.addListener(() {
        if (mounted) {
          setState(() => _isPlaying = _controller!.value.isPlaying);
        }
      });
    } catch (e) {
      debugPrint('Error inicializando video preview: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatPosition(Duration position) {
    final minutes = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4EC9F5), Color(0xFFFFB733)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_rounded,
                      color: Colors.white, size: 24),
                  const Gap(12),
                  const Expanded(
                    child: Text(
                      'Vista Previa del Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Video Player
            Flexible(
              child: _isInitialized
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                        // Controls
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Progress bar
                              ValueListenableBuilder(
                                valueListenable: _controller!,
                                builder:
                                    (context, VideoPlayerValue value, child) {
                                  return Column(
                                    children: [
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor:
                                              const Color(0xFF4EC9F5),
                                          inactiveTrackColor:
                                              Colors.grey.shade800,
                                          thumbColor: const Color(0xFFFFB733),
                                          trackHeight: 4,
                                        ),
                                        child: Slider(
                                          value: value.position.inMilliseconds
                                              .toDouble(),
                                          max: value.duration.inMilliseconds
                                              .toDouble(),
                                          onChanged: (newValue) {
                                            _controller!.seekTo(
                                              Duration(
                                                  milliseconds:
                                                      newValue.toInt()),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatPosition(value.position),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            Text(
                                              _formatPosition(value.duration),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const Gap(8),
                              // Play/Pause button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _controller!.seekTo(
                                        _controller!.value.position -
                                            const Duration(seconds: 10),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.replay_10_rounded,
                                      color: Colors.white70,
                                      size: 32,
                                    ),
                                  ),
                                  const Gap(16),
                                  GestureDetector(
                                    onTap: () {
                                      if (_isPlaying) {
                                        _controller!.pause();
                                      } else {
                                        _controller!.play();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF4EC9F5),
                                            Color(0xFFFFB733)
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                  const Gap(16),
                                  IconButton(
                                    onPressed: () {
                                      _controller!.seekTo(
                                        _controller!.value.position +
                                            const Duration(seconds: 10),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.forward_10_rounded,
                                      color: Colors.white70,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4EC9F5),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
