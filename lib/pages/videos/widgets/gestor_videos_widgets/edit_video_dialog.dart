import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:gap/gap.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/models/media/media_models.dart';
import 'package:energy_media/providers/videos_provider.dart';
// import 'package:energy_media/helpers/globals.dart'; // DEMO MODE: No usado

class EditVideoDialog extends StatefulWidget {
  final MediaFileModel video;
  final VideosProvider provider;

  const EditVideoDialog({
    Key? key,
    required this.video,
    required this.provider,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context,
    MediaFileModel video,
    VideosProvider provider,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditVideoDialog(
        video: video,
        provider: provider,
      ),
    );
  }

  @override
  State<EditVideoDialog> createState() => _EditVideoDialogState();
}

class _EditVideoDialogState extends State<EditVideoDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController tagsController;
  Uint8List? newPosterBytes;
  String? newPosterFileName;
  bool _deletePoster = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.video.title);
    descriptionController =
        TextEditingController(text: widget.video.fileDescription);
    tagsController = TextEditingController(text: widget.video.tags.join(', '));
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.video.fileUrl == null || widget.video.fileUrl!.isEmpty) return;

    setState(() => _isVideoLoading = true);

    try {
      _videoPlayerController = VideoPlayerController.network(
        widget.video.fileUrl!,
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
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

      // Capturar duración automáticamente si no existe
      if (widget.video.seconds == null) {
        final durationSeconds =
            _videoPlayerController!.value.duration.inSeconds;
        if (durationSeconds > 0) {
          await _saveDurationToDatabase(durationSeconds);
          debugPrint(
              '✅ Duración capturada automáticamente: $durationSeconds segundos');
        }
      }

      setState(() => _isVideoLoading = false);
    } catch (e) {
      setState(() => _isVideoLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar video: $e'),
            backgroundColor: const Color(0xFFFF2D2D),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _selectPoster() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        newPosterBytes = bytes;
        newPosterFileName = image.name;
      });
    }
  }

  /// Genera un thumbnail automáticamente desde el video si no hay poster
  Future<void> _generateThumbnailFromVideo() async {
    if (widget.video.fileUrl == null || widget.video.fileUrl!.isEmpty) return;

    try {
      // Generar thumbnail desde el video
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: widget.video.fileUrl!,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280, // Alta calidad para poster
        quality: 85,
      );

      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        // Guardar el thumbnail generado como nueva portada (sin mostrar en UI)
        newPosterBytes = thumbnailBytes;
        newPosterFileName = 'thumbnail_${widget.video.fileName}.jpg';

        debugPrint('✅ Thumbnail generado automáticamente para edición');
      }
    } catch (e) {
      debugPrint('⚠️ Error generando thumbnail automático: $e');
      // No es crítico, el video se guardará sin poster
    }
  }

  /// Guardar duración capturada en la base de datos
  /// DEMO MODE: Actualiza solo el modelo local, sin base de datos
  Future<void> _saveDurationToDatabase(int durationSeconds) async {
    try {
      // DEMO MODE: Solo actualiza localmente a través del provider
      await widget.provider.updateVideoMetadata(
        widget.video.mediaFileId,
        {'duration_seconds': durationSeconds},
      );
    } catch (e) {
      debugPrint('Error guardando duración: $e');
    }
  }

  Future<void> _saveChanges() async {
    // Actualizar título
    if (titleController.text != widget.video.title) {
      await widget.provider.updateVideoTitle(
        widget.video.mediaFileId,
        titleController.text,
      );
    }

    // Actualizar descripción
    if (descriptionController.text != widget.video.fileDescription) {
      await widget.provider.updateVideoDescription(
        widget.video.mediaFileId,
        descriptionController.text,
      );
    }

    // Actualizar tags
    final newTags = tagsController.text
        .split(RegExp(r'[,\s]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (newTags.join(',') != widget.video.tags.join(',')) {
      await widget.provider.updateVideoTags(
        widget.video.mediaFileId,
        newTags,
      );
    }

    // Eliminar portada si se solicitó
    if (_deletePoster) {
      await widget.provider.deletePoster(widget.video.mediaFileId);
    }
    // Actualizar portada si se seleccionó una nueva (solo si no se eliminó)
    else if (newPosterBytes != null && newPosterFileName != null) {
      await widget.provider.updateVideoPoster(
        widget.video.mediaFileId,
        newPosterBytes!,
        newPosterFileName!,
      );
    }
    // Si no hay poster existente y no se seleccionó/eliminó uno, generar automáticamente
    else if (widget.video.posterUrl == null ||
        widget.video.posterUrl!.isEmpty) {
      await _generateThumbnailFromVideo();
      // Si se generó thumbnail, subirlo
      if (newPosterBytes != null && newPosterFileName != null) {
        await widget.provider.updateVideoPoster(
          widget.video.mediaFileId,
          newPosterBytes!,
          newPosterFileName!,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 1000,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).primaryColor.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryColor,
            AppTheme.of(context).secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
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
              Icons.edit_rounded,
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
                  'Editar Video',
                  style: AppTheme.of(context).title3.override(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF0B0B0D),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                const Gap(4),
                Text(
                  'Actualiza la información y configuración',
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
            onPressed: () => Navigator.pop(context, false),
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
        _buildPreviewSection(),
        const Gap(24),
        _buildFormFields(),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Título del Video'),
        const Gap(8),
        _buildTextField(
          controller: titleController,
          hintText: 'Título del video',
          prefixIcon: Icons.title,
        ),
        const Gap(20),
        _buildLabel('Descripción'),
        const Gap(8),
        _buildTextField(
          controller: descriptionController,
          hintText: 'Descripción del contenido',
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
        _buildLabel('Vista Previa del Video'),
        const Gap(12),
        _buildVideoPreview(),
        const Gap(16),
        _buildLabel('Portada'),
        const Gap(12),
        _buildPosterSection(),
      ],
    );
  }

  Widget _buildVideoPreview() {
    if (_isVideoLoading) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4EC9F5),
          ),
        ),
      );
    }

    if (_chewieController != null && _videoPlayerController != null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Chewie(
            controller: _chewieController!,
          ),
        ),
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_rounded,
              size: 64,
              color: AppTheme.of(context).tertiaryText,
            ),
            const Gap(12),
            Text(
              'Video no disponible',
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

  Widget _buildPosterSection() {
    final hasPoster = widget.video.posterUrl != null && !_deletePoster;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_deletePoster)
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).tertiaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF2D2D).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 48,
                    color: const Color(0xFFFF2D2D).withOpacity(0.7),
                  ),
                  const Gap(8),
                  Text(
                    'Portada marcada para eliminar',
                    style: AppTheme.of(context).bodyText2.override(
                          fontFamily: 'Poppins',
                          color: const Color(0xFFFF2D2D),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          )
        else if (newPosterBytes != null)
          // Mostrar preview de nueva portada seleccionada
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  newPosterBytes!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).success,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fiber_new,
                        size: 14,
                        color: Colors.white,
                      ),
                      const Gap(4),
                      Text(
                        'Nueva',
                        style: AppTheme.of(context).bodyText2.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else if (hasPoster)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.video.posterUrl!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).tertiaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library,
                  size: 48,
                  color: AppTheme.of(context).tertiaryText,
                ),
                const Gap(8),
                Text(
                  'Sin portada',
                  style: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).tertiaryText,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deletePoster ? null : _selectPoster,
                icon: const Icon(Icons.image, size: 18),
                label: Text(
                  newPosterBytes != null
                      ? 'Portada Seleccionada'
                      : 'Cambiar Portada',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: newPosterBytes != null
                      ? AppTheme.of(context).success
                      : AppTheme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  disabledBackgroundColor:
                      AppTheme.of(context).tertiaryText.withOpacity(0.3),
                ),
              ),
            ),
            if (hasPoster || _deletePoster) ...[
              const Gap(8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _deletePoster = !_deletePoster;
                    if (_deletePoster) {
                      // Si se marca para eliminar, limpiar nueva portada seleccionada
                      newPosterBytes = null;
                      newPosterFileName = null;
                    }
                  });
                },
                icon: Icon(
                  _deletePoster ? Icons.undo : Icons.delete_outline,
                  size: 18,
                ),
                label: Text(
                  _deletePoster ? 'Deshacer' : 'Eliminar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deletePoster
                      ? AppTheme.of(context).warning
                      : const Color(0xFFFF2D2D),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
        if (newPosterBytes != null) ...[
          const Gap(8),
          Text(
            'Nueva: $newPosterFileName',
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).success,
                  fontSize: 11,
                ),
          ),
        ],
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(12),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Icon(Icons.save_rounded, size: 18),
                Gap(8),
                Text(
                  'Guardar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
