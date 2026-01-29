import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:energy_media/models/media/media_models.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/widgets/premium_button.dart';
import 'package:gap/gap.dart';

class PremiumUploadDialog extends StatefulWidget {
  final VideosProvider provider;
  final VoidCallback onSuccess;

  const PremiumUploadDialog({
    Key? key,
    required this.provider,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PremiumUploadDialog> createState() => _PremiumUploadDialogState();
}

class _PremiumUploadDialogState extends State<PremiumUploadDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagsController = TextEditingController();
  Uint8List? selectedVideo;
  String? videoFileName;
  Uint8List? selectedPoster;
  String? posterFileName;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool isUploading = false;
  bool _isVideoLoading = false;
  String? _videoBlobUrl;
  int? _videoDurationSeconds; // Duración capturada del video

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    // Limpiar blob URL
    if (_videoBlobUrl != null) {
      html.Url.revokeObjectUrl(_videoBlobUrl!);
    }
    super.dispose();
  }

  Future<void> _selectVideo() async {
    final result = await widget.provider.selectVideo();
    if (result) {
      setState(() {
        selectedVideo = widget.provider.webVideoBytes;
        videoFileName = widget.provider.videoName;
        titleController.text = widget.provider.tituloController.text;
      });

      // Crear video player para preview en web
      await _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (selectedVideo == null) return;

    setState(() => _isVideoLoading = true);

    try {
      // Limpiar blob URL anterior si existe
      if (_videoBlobUrl != null) {
        html.Url.revokeObjectUrl(_videoBlobUrl!);
      }

      // Crear Blob desde bytes
      final blob = html.Blob([selectedVideo!]);
      _videoBlobUrl = html.Url.createObjectUrlFromBlob(blob);

      // Inicializar video player
      _videoController = VideoPlayerController.network(_videoBlobUrl!);
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        aspectRatio: _videoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF4EC9F5),
          handleColor: const Color(0xFFFFB733),
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4EC9F5),
            ),
          ),
        ),
      );

      // Capturar duración del video
      _videoDurationSeconds = _videoController!.value.duration.inSeconds;
      debugPrint(
          '🕒 Duración del video capturada: $_videoDurationSeconds segundos');

      setState(() => _isVideoLoading = false);
    } catch (e) {
      setState(() => _isVideoLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar preview: $e'),
            backgroundColor: const Color(0xFFFF2D2D),
          ),
        );
      }
    }
  }

  Future<void> _selectPoster() async {
    final result = await widget.provider.selectPoster();
    if (result) {
      setState(() {
        selectedPoster = widget.provider.webPosterBytes;
        posterFileName = widget.provider.posterName;
      });
    }
  }

  /// Genera un thumbnail automáticamente desde el video si no se seleccionó poster
  Future<void> _generateThumbnailFromVideo() async {
    if (_videoBlobUrl == null || selectedVideo == null) return;

    try {
      // Generar thumbnail desde el video
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: _videoBlobUrl!,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280, // Alta calidad para poster
        quality: 85,
      );

      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        // Actualizar el provider con el thumbnail generado (sin mostrar en UI)
        widget.provider.webPosterBytes = thumbnailBytes;
        widget.provider.posterName =
            'thumbnail_${videoFileName ?? 'video'}.jpg';
        widget.provider.posterFileExtension = '.jpg';

        // NO actualizar selectedPoster ni posterFileName para que no se muestre en UI
        // El thumbnail está disponible en el provider para subir automáticamente

        debugPrint('✅ Thumbnail generado automáticamente (oculto en UI)');
      }
    } catch (e) {
      debugPrint('⚠️ Error generando thumbnail automático: $e');
      // No es crítico, el video se subirá sin poster
    }
  }

  Future<void> _uploadVideo() async {
    if (titleController.text.isEmpty ||
        selectedVideo == null ||
        videoFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa los campos requeridos'),
          backgroundColor: const Color(0xFFFF2D2D),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => isUploading = true);

    // Si no hay poster seleccionado, generar thumbnail automáticamente desde el video
    if (selectedPoster == null && _videoBlobUrl != null) {
      await _generateThumbnailFromVideo();
    }

    // Procesar tags: separar por comas o espacios
    List<String>? tags;
    if (tagsController.text.isNotEmpty) {
      tags = tagsController.text
          .split(RegExp(r'[,\s]+')) // Separar por comas o espacios
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    final success = await widget.provider.uploadVideo(
      title: titleController.text,
      description: descriptionController.text.isEmpty
          ? null
          : descriptionController.text,
      tags: tags,
      durationSeconds: _videoDurationSeconds,
    );

    if (!mounted) return;

    setState(() => isUploading = false);
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              Gap(12),
              Text('Video subido exitosamente'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              Gap(12),
              Text('Error al subir el video'),
            ],
          ),
          backgroundColor: const Color(0xFFFF2D2D),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 900,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).primaryColor.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child:
                    isMobile ? _buildMobileContent() : _buildDesktopContent(),
              ),
            ),
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
            Color(0xFF4EC9F5),
            Color(0xFFFFB733),
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
              Icons.cloud_upload,
              color: Color(0xFF0B0B0D),
              size: 28,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subir Nuevo Video',
                  style: AppTheme.of(context).title2.override(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF0B0B0D),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                const Gap(4),
                Text(
                  'Comparte tu contenido con el mundo',
                  style: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF0B0B0D).withOpacity(0.7),
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF0B0B0D)),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildFormFields()),
        const Gap(24),
        Expanded(flex: 2, child: _buildPreviewSection()),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        _buildFormFields(),
        const Gap(24),
        _buildPreviewSection(),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Título del Video *'),
        const Gap(8),
        _buildTextField(
          controller: titleController,
          hintText: 'Ej: Tutorial de energía solar',
          prefixIcon: Icons.title,
        ),
        const Gap(20),
        _buildLabel('Descripción'),
        const Gap(8),
        _buildTextField(
          controller: descriptionController,
          hintText: 'Describe el contenido del video...',
          prefixIcon: Icons.description,
          maxLines: 4,
        ),
        const Gap(20),
        _buildLabel('Etiquetas (Tags)'),
        const Gap(4),
        Text(
          'Separa las etiquetas con comas o espacios',
          style: AppTheme.of(context).bodyText2.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).tertiaryText,
                fontSize: 12,
              ),
        ),
        const Gap(8),
        _buildTextField(
          controller: tagsController,
          hintText: 'Ej: deportes, fútbol, entrenamiento',
          prefixIcon: Icons.label,
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Vista Previa'),
        const Gap(12),
        _buildVideoSelector(),
        const Gap(16),
        _buildPosterSelector(),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTheme.of(context).bodyText1.override(
            fontFamily: 'Poppins',
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTheme.of(context).bodyText1.override(
              fontFamily: 'Poppins',
              color: AppTheme.of(context).primaryText,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.of(context).bodyText1.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).tertiaryText,
              ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppTheme.of(context).primaryColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildVideoSelector() {
    return GestureDetector(
      onTap: _selectVideo,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.of(context).tertiaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: videoFileName != null
                ? Colors.green.withOpacity(0.5)
                : AppTheme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: selectedVideo != null
            ? _buildVideoPreview()
            : _buildUploadPlaceholder(
                icon: Icons.video_file,
                title: 'Seleccionar Video',
                subtitle: 'Click para elegir archivo',
              ),
      ),
    );
  }

  Widget _buildPosterSelector() {
    return GestureDetector(
      onTap: _selectPoster,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.of(context).tertiaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: posterFileName != null
                ? Colors.green.withOpacity(0.5)
                : AppTheme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: selectedPoster != null
            ? _buildPosterPreview()
            : _buildUploadPlaceholder(
                icon: Icons.image,
                title: 'Miniatura (Opcional)',
                subtitle: 'Click para elegir imagen',
              ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_isVideoLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF4EC9F5),
              ),
              Gap(12),
              Text(
                'Cargando preview...',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null && _videoController != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: Colors.black,
              child: Chewie(
                controller: _chewieController!,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.white),
                  Gap(4),
                  Text(
                    'Listo para subir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const Gap(12),
                  Text(
                    videoFileName ?? 'Video seleccionado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.white),
                Gap(4),
                Text(
                  'Cargado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPosterPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            selectedPoster!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.white),
                Gap(4),
                Text(
                  'Cargado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppTheme.of(context).primaryColor,
            ),
          ),
          const Gap(12),
          Text(
            title,
            style: AppTheme.of(context).bodyText1.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).tertiaryText,
                  fontSize: 12,
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
          PremiumButton(
            text: 'Cancelar',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
          const Gap(12),
          PremiumButton(
            text: 'Subir Video',
            icon: Icons.cloud_upload,
            onPressed: _uploadVideo,
            isLoading: isUploading,
            width: 160,
          ),
        ],
      ),
    );
  }
}
