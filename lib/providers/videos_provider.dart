import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';
import 'package:energy_media/models/media/media_models.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// **MODO DEMO - Gestor de Videos 100% Local**
///
/// Este provider funciona completamente offline sin base de datos:
/// - ✅ Videos hardcodeados desde assets/videos/*.mp4
/// - ✅ Permite "subir", "editar" y "eliminar" videos (solo en memoria)
/// - ✅ Funciona 100% offline, sin internet ni Supabase
/// - ⚠️ Todos los cambios se pierden al recargar la aplicación
/// - 🎯 Ideal para demos rápidas y profesionales sin dependencias externas
class VideosProvider extends ChangeNotifier {
  // ========== ORGANIZATION CONSTANT ==========
  static const int organizationId = 17;

  // ========== DEMO MODE ==========
  int _nextMockId = 1000; // IDs para videos simulados

  // ========== STATE MANAGEMENT ==========
  PlutoGridStateManager? stateManager;
  List<PlutoRow> videosRows = [];
  int gridRebuildKey = 0; // Key for forcing PlutoGrid rebuild

  // ========== DATA LISTS ==========
  List<MediaFileModel> mediaFiles = [];
  List<MediaCategoryModel> categories = [];
  List<MediaWithPosterModel> mediaWithPosters = [];

  // ========== CONTROLLERS ==========
  final busquedaVideoController = TextEditingController();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  // ========== VIDEO/IMAGE UPLOAD STATE ==========
  String? videoName;
  String? videoUrl;
  String? videoStoragePath;
  String videoFileExtension = '';
  Uint8List? webVideoBytes;

  String? posterName;
  String? posterUrl;
  String? posterStoragePath;
  String posterFileExtension = '';
  Uint8List? webPosterBytes;
  // ========== HELPERS ==========
  /// Sanitize file name to avoid issues with special characters in URLs
  /// Removes/replaces: brackets [], parentheses (), spaces, special chars
  String _sanitizeFileName(String fileName) {
    // Get extension
    final ext = p.extension(fileName);
    final nameWithoutExt = p.basenameWithoutExtension(fileName);

    // Replace special characters and spaces
    String sanitized = nameWithoutExt
        .replaceAll(RegExp(r'[\[\]\(\){}]'), '') // Remove brackets/parentheses
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),
            '_') // Replace other special chars with underscore
        .replaceAll(
            RegExp(r'_+'), '_') // Replace multiple underscores with single
        .replaceAll(
            RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores

    // If name is empty after sanitization, use generic name
    if (sanitized.isEmpty) {
      sanitized = 'video_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Limit length to avoid excessively long names (max 100 chars + extension)
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return '$sanitized$ext';
  }

  // ========== LOADING STATE ==========
  bool isLoading = false;
  bool isInitialized = false; // Flag para saber si la carga inicial terminó
  String? errorMessage;

  // ========== CONSTRUCTOR ==========
  VideosProvider() {
    // Inicializar datos en el siguiente frame para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHardcodedData();
    });
  }

  // ========== LOAD METHODS ==========

  /// Initialize hardcoded demo data from assets
  Future<void> _initializeHardcodedData() async {
    try {
      isLoading = true;
      notifyListeners();

      // Lista de videos en assets con metadata básica
      final videoConfigs = [
        {
          'fileName': 'black_friday_spot.mp4',
          'title': 'Black Friday - Promoción Especial',
          'description':
              'Video promocional para campaña de Black Friday con ofertas exclusivas',
          'tags': ['promoción', 'black friday', 'ventas'],
          'reproducciones': 1250
        },
        {
          'fileName': 'disney_on_ice_lets_dance.mp4',
          'title': 'Disney On Ice - Let\'s Dance',
          'description':
              'Espectáculo de patinaje artístico sobre hielo con personajes de Disney',
          'tags': ['disney', 'entretenimiento', 'familia'],
          'reproducciones': 3420
        },
        {
          'fileName': 'green_screen.mp4',
          'title': 'Green Screen - Template',
          'description':
              'Plantilla de fondo verde para efectos de edición de video',
          'tags': ['template', 'edición', 'green screen'],
          'reproducciones': 890
        },
        {
          'fileName': 'healthtest.mp4',
          'title': 'Health Test - Diagnóstico',
          'description': 'Video educativo sobre pruebas de salud y bienestar',
          'tags': ['salud', 'educativo', 'medicina'],
          'reproducciones': 567
        },
        {
          'fileName': 'hisp_heritage.mp4',
          'title': 'Hispanic Heritage Month',
          'description': 'Celebración del mes de la herencia hispana',
          'tags': ['cultura', 'hispano', 'celebración'],
          'reproducciones': 2100
        },
        {
          'fileName': 'kimball_holiday.mp4',
          'title': 'Kimball Holiday Special',
          'description':
              'Especial de temporada navideña con promociones exclusivas',
          'tags': ['navidad', 'promoción', 'temporada'],
          'reproducciones': 1840
        },
        {
          'fileName': 'Lost_Medicaid.mp4',
          'title': 'Lost Medicaid - Información',
          'description': 'Guía sobre cómo recuperar beneficios de Medicaid',
          'tags': ['medicaid', 'salud', 'información'],
          'reproducciones': 456
        },
        {
          'fileName': 'Metallic_phone.mp4',
          'title': 'Metallic Phone - Lanzamiento',
          'description':
              'Presentación del nuevo smartphone con acabado metálico premium',
          'tags': ['tecnología', 'smartphone', 'lanzamiento'],
          'reproducciones': 5230
        },
        {
          'fileName': 'sweetwater_authority.mp4',
          'title': 'Sweetwater Authority - Conservación',
          'description': 'Campaña de conservación de agua y recursos naturales',
          'tags': ['agua', 'conservación', 'medio ambiente'],
          'reproducciones': 720
        },
      ];

      // Cargar videos con duración y peso reales (o simulados si falla)
      mediaFiles = [];
      for (int i = 0; i < videoConfigs.length; i++) {
        final config = videoConfigs[i];
        final videoFile = await _createDemoVideoWithRealData(
          id: i + 1,
          fileName: config['fileName'] as String,
          title: config['title'] as String,
          description: config['description'] as String,
          tags: config['tags'] as List<String>,
          reproducciones: config['reproducciones'] as int,
        );
        // ✅ Siempre agregar el video (ya no puede ser null)
        mediaFiles.add(videoFile);
      }

      // Hardcodear categorías
      categories = [
        MediaCategoryModel(
          mediaCategoriesId: 1,
          categoryName: 'Promociones',
          categoryDescription: 'Videos promocionales y de ventas',
        ),
        MediaCategoryModel(
          mediaCategoriesId: 2,
          categoryName: 'Entretenimiento',
          categoryDescription: 'Contenido de entretenimiento y shows',
        ),
        MediaCategoryModel(
          mediaCategoriesId: 3,
          categoryName: 'Educativo',
          categoryDescription: 'Videos educativos e informativos',
        ),
        MediaCategoryModel(
          mediaCategoriesId: 4,
          categoryName: 'Tecnología',
          categoryDescription: 'Lanzamientos y novedades tecnológicas',
        ),
      ];

      _nextMockId = 100; // IDs para nuevos videos empiezan en 100

      await _buildPlutoRows();

      isLoading = false;
      isInitialized = true; // ✅ Marcamos como inicializado
      notifyListeners();

      // Forzar una segunda notificación después de un frame para asegurar que los widgets se actualicen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      errorMessage = 'Error inicializando datos: $e';
      isLoading = false;
      isInitialized =
          true; // Marcamos como inicializado incluso con error para no bloquear UI
      notifyListeners();
      print('Error en _initializeHardcodedData: $e');
    }
  }

  /// Helper para crear videos de demo con datos reales capturados
  Future<MediaFileModel> _createDemoVideoWithRealData({
    required int id,
    required String fileName,
    required String title,
    required String description,
    required List<String> tags,
    required int reproducciones,
  }) async {
    final now = DateTime.now();
    final createdAt = now.subtract(Duration(days: id * 3));
    final assetPath = 'assets/videos/$fileName';

    // Valores por defecto simulados
    int realDuration = 60; // 60 segundos por defecto
    int realFileSize = 30000000; // 30MB por defecto

    try {
      // Intentar capturar duración real del video de assets con timeout corto
      final controller = VideoPlayerController.asset(assetPath);
      await controller.initialize().timeout(
        const Duration(seconds: 3), // Timeout más corto
        onTimeout: () {
          throw TimeoutException('Timeout al inicializar video');
        },
      );
      realDuration = controller.value.duration.inSeconds;
      await controller.dispose();

      // Para el peso, en web no podemos obtenerlo fácilmente de assets
      // Usamos aproximaciones realistas según duración
      realFileSize = (realDuration * 500000); // ~500KB por segundo (aprox)

      print(
          '✅ Asset "$fileName": ${realDuration}s, ${_formatFileSize(realFileSize)}');
    } catch (e) {
      // ⚠️ Si falla la carga, usar valores simulados realistas
      // Asignar duraciones variadas según tipo de video
      if (fileName.contains('spot') || fileName.contains('promo')) {
        realDuration = 30; // Videos cortos
        realFileSize = 15000000; // 15MB
      } else if (fileName.contains('disney') ||
          fileName.contains('entertainment')) {
        realDuration = 120; // Videos medianos
        realFileSize = 60000000; // 60MB
      } else {
        realDuration = 45; // Duración media
        realFileSize = 22000000; // 22MB
      }

      print(
          '⚠️ No se pudo cargar "$fileName", usando valores simulados: ${realDuration}s, ${_formatFileSize(realFileSize)}');
    }

    // ✅ SIEMPRE retornar el video, nunca null
    return MediaFileModel(
      mediaFileId: id,
      fileName: fileName,
      title: title,
      fileDescription: description,
      fileType: 'video',
      mimeType: 'video/mp4',
      fileExtension: '.mp4',
      fileSizeBytes: realFileSize,
      fileUrl: assetPath,
      storagePath: 'videos/$fileName',
      organizationFk: organizationId,
      metadataJson: {
        'uploaded_at': createdAt.toIso8601String(),
        'reproducciones': reproducciones,
        'original_file_name': fileName,
        'duration_seconds': realDuration,
        'file_size_bytes': realFileSize,
        'tags': tags,
      },
      seconds: realDuration,
      isPublicFile: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  /// Build PlutoGrid rows from media files
  Future<void> _buildPlutoRows() async {
    videosRows.clear();

    for (var media in mediaFiles) {
      videosRows.add(
        PlutoRow(
          cells: {
            'video': PlutoCell(value: media), // Objeto completo para renderers
            'thumbnail': PlutoCell(
                value: media.posterUrl ??
                    media.fileUrl), // ✅ Usar poster si existe
            'title': PlutoCell(value: media.title ?? media.fileName),
            'file_description': PlutoCell(value: media.fileDescription),
            'reproducciones': PlutoCell(value: media.reproducciones),
            'duration': PlutoCell(
                value: media.seconds != null
                    ? _formatDuration(media.seconds!)
                    : '-'),
            'file_size': PlutoCell(
                value: media.fileSizeBytes != null
                    ? _formatFileSize(media.fileSizeBytes!)
                    : '-'),
            'createdAt': PlutoCell(
                value: media.createdAt?.toString().split('.')[0] ?? '-'),
            'tags': PlutoCell(value: media.tags.join(', ')),
            'actions': PlutoCell(value: media),
          },
        ),
      );
    }

    // Force rebuild after rows are built (important for release mode)
    scheduleMicrotask(() {
      notifyListeners();
    });
  }

  /// Format duration in seconds to human readable
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Format file size to human readable
  String _formatFileSize(int? bytes) {
    if (bytes == null) return '-';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  // ========== VIDEO UPLOAD ==========

  /// Select video file from device
  Future<bool> selectVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedVideo = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedVideo == null) return false;

      videoName = pickedVideo.name;
      videoFileExtension = p.extension(pickedVideo.name);
      webVideoBytes = await pickedVideo.readAsBytes();

      // Remove extension from name for title
      final nameWithoutExt = videoName!.replaceAll(videoFileExtension, '');
      tituloController.text = nameWithoutExt;

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error seleccionando video: $e';
      notifyListeners();
      return false;
    }
  }

  /// Select poster/thumbnail image
  Future<bool> selectPoster() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) return false;

      posterName = pickedImage.name;
      posterFileExtension = p.extension(pickedImage.name);
      webPosterBytes = await pickedImage.readAsBytes();

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error seleccionando poster: $e';
      notifyListeners();
      return false;
    }
  }

  /// Upload video to local storage
  /// DEMO MODE: Crea video en memoria con duración y peso reales
  Future<bool> uploadVideo({
    required String title,
    String? description,
    int? durationSeconds,
    List<String>? tags,
  }) async {
    if (webVideoBytes == null || videoName == null) {
      errorMessage = 'No hay video seleccionado';
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      // Crear Blob URL del video para reproducción en web
      String videoUrl;
      int? capturedDuration;

      if (kIsWeb) {
        // Crear Blob y Object URL para el video
        final blob =
            html.Blob([webVideoBytes!], _getMimeType(videoFileExtension));
        videoUrl = html.Url.createObjectUrlFromBlob(blob);

        // Capturar duración real del video
        try {
          final controller = VideoPlayerController.network(videoUrl);
          await controller.initialize();
          capturedDuration = controller.value.duration.inSeconds;
          await controller.dispose();
          print('✅ Duración capturada: $capturedDuration segundos');
        } catch (e) {
          print('⚠️ No se pudo capturar duración: $e');
          capturedDuration = durationSeconds;
        }
      } else {
        // Fallback para otras plataformas (usar assets)
        final assetsVideos = [
          'black_friday_spot.mp4',
          'disney_on_ice_lets_dance.mp4',
          'green_screen.mp4',
          'healthtest.mp4',
          'hisp_heritage.mp4',
          'kimball_holiday.mp4',
          'Lost Medicaid.mp4',
          'Metallic phone.mp4',
          'sweetwater_authority.mp4',
        ];
        final randomAsset = assetsVideos[_nextMockId % assetsVideos.length];
        videoUrl = 'assets/videos/$randomAsset';
        capturedDuration = durationSeconds;
      }

      // Crear Blob URL del poster si existe
      String? posterBlobUrl;
      if (kIsWeb && webPosterBytes != null && posterName != null) {
        final posterBlob =
            html.Blob([webPosterBytes!], _getMimeType(posterFileExtension));
        posterBlobUrl = html.Url.createObjectUrlFromBlob(posterBlob);
      }

      // Peso real del archivo
      final realFileSize = webVideoBytes!.length;

      // Crear MediaFileModel con datos reales
      final mockVideo = MediaFileModel(
        mediaFileId: _nextMockId++,
        fileName: videoName!,
        title: title,
        fileDescription: description ?? 'Video subido en modo demo',
        fileType: 'video',
        mimeType: _getMimeType(videoFileExtension),
        fileExtension: videoFileExtension,
        fileSizeBytes: realFileSize, // ✅ Peso real
        fileUrl: videoUrl, // ✅ Blob URL del video real
        storagePath: 'videos/demo_$videoName',
        organizationFk: organizationId,
        metadataJson: {
          'uploaded_at': DateTime.now().toIso8601String(),
          'reproducciones': 0,
          'original_file_name': videoName,
          'duration_seconds': capturedDuration, // ✅ Duración real capturada
          'file_size_bytes': realFileSize, // ✅ Peso real
          if (posterBlobUrl != null) 'poster_url': posterBlobUrl,
          if (posterBlobUrl != null) 'poster_file_name': posterName,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
        },
        seconds: capturedDuration, // ✅ Duración real
        isPublicFile: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Agregar a lista local (al inicio para que sea visible)
      mediaFiles.insert(0, mockVideo);

      // Clean up
      _clearUploadState();

      // Rebuild grid
      await _buildPlutoRows();

      isLoading = false;
      notifyListeners();

      print('✅ Video subido: ${mockVideo.title}');
      print('   - Duración: ${capturedDuration}s');
      print('   - Peso: ${_formatFileSize(realFileSize)}');
      print('   - URL: $videoUrl');

      return true;
    } catch (e) {
      errorMessage = 'Error subiendo video: $e';
      isLoading = false;
      notifyListeners();
      print('Error en uploadVideo: $e');
      return false;
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  /// Clear upload state
  void _clearUploadState() {
    videoName = null;
    videoUrl = null;
    videoStoragePath = null;
    videoFileExtension = '';
    webVideoBytes = null;
    posterName = null;
    posterUrl = null;
    posterStoragePath = null;
    posterFileExtension = '';
    webPosterBytes = null;
    tituloController.clear();
    descripcionController.clear();
  }

  // ========== UPDATE METHODS ==========

  /// Update video title
  /// DEMO MODE: Actualiza objeto local sin persistencia
  Future<bool> updateVideoTitle(int mediaFileId, String title) async {
    try {
      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final index = mediaFiles.indexOf(video);

      mediaFiles[index] = video.copyWith(title: title);

      await _buildPlutoRows();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando título: $e';
      notifyListeners();
      print('Error en updateVideoTitle: $e');
      return false;
    }
  }

  /// Update video description
  /// DEMO MODE: Actualiza objeto local sin persistencia
  Future<bool> updateVideoDescription(
      int mediaFileId, String description) async {
    try {
      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final index = mediaFiles.indexOf(video);

      mediaFiles[index] = video.copyWith(fileDescription: description);

      await _buildPlutoRows();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando descripción: $e';
      notifyListeners();
      print('Error en updateVideoDescription: $e');
      return false;
    }
  }

  /// Update video metadata
  /// DEMO MODE: Actualiza objeto local sin persistencia
  Future<bool> updateVideoMetadata(
    int mediaFileId,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final index = mediaFiles.indexOf(video);

      mediaFiles[index] = video.copyWith(metadataJson: metadata);

      await _buildPlutoRows();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando metadata: $e';
      notifyListeners();
      print('Error en updateVideoMetadata: $e');
      return false;
    }
  }

  /// Update video tags
  /// DEMO MODE: Actualiza objeto local sin persistencia
  Future<bool> updateVideoTags(int mediaFileId, List<String> tags) async {
    try {
      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final metadata = Map<String, dynamic>.from(video.metadataJson ?? {});
      metadata['tags'] = tags;

      await updateVideoMetadata(mediaFileId, metadata);
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando tags: $e';
      notifyListeners();
      print('Error en updateVideoTags: $e');
      return false;
    }
  }

  /// Update video poster
  /// DEMO MODE: Actualiza poster en metadata local sin persistencia
  Future<bool> updateVideoPoster(
      int mediaFileId, Uint8List posterBytes, String posterName) async {
    try {
      isLoading = true;
      notifyListeners();

      // Simular delay
      await Future.delayed(const Duration(milliseconds: 500));

      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final metadata = Map<String, dynamic>.from(video.metadataJson ?? {});

      // Usar URL de un poster existente o placeholder
      final demoPosterUrl = mediaFiles
          .firstWhere(
            (v) => v.posterUrl != null && v.posterUrl!.isNotEmpty,
            orElse: () => video,
          )
          .posterUrl;

      metadata['poster_url'] = demoPosterUrl;
      metadata['poster_file_name'] = posterName;

      await updateVideoMetadata(mediaFileId, metadata);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando poster: $e';
      isLoading = false;
      notifyListeners();
      print('Error en updateVideoPoster: $e');
      return false;
    }
  }

  /// Delete video poster only (not the video itself)
  /// DEMO MODE: Elimina poster de metadata local sin persistencia
  Future<bool> deletePoster(int mediaFileId) async {
    try {
      isLoading = true;
      notifyListeners();

      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final metadata = Map<String, dynamic>.from(video.metadataJson ?? {});

      metadata.remove('poster_url');
      metadata.remove('poster_file_name');

      await updateVideoMetadata(mediaFileId, metadata);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error eliminando portada: $e';
      isLoading = false;
      notifyListeners();
      print('Error en deletePoster: $e');
      return false;
    }
  }

  // ========== DELETE METHODS ==========

  /// Delete video and its storage files
  /// DEMO MODE: Elimina video de lista local sin persistencia
  Future<bool> deleteVideo(int mediaFileId) async {
    try {
      isLoading = true;
      notifyListeners();

      // Simular delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Eliminar de lista local
      mediaFiles.removeWhere((v) => v.mediaFileId == mediaFileId);

      await _buildPlutoRows();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error eliminando video: $e';
      isLoading = false;
      notifyListeners();
      print('Error en deleteVideo: $e');
      return false;
    }
  }

  // ========== ANALYTICS METHODS ==========

  /// Increment view count
  /// DEMO MODE: Incrementa contador local sin persistencia
  Future<bool> incrementReproduccion(int mediaFileId) async {
    try {
      final video = mediaFiles.firstWhere((v) => v.mediaFileId == mediaFileId);
      final metadata = Map<String, dynamic>.from(video.metadataJson ?? {});
      final currentCount = metadata['reproducciones'] ?? 0;

      metadata['reproducciones'] = currentCount + 1;
      metadata['last_viewed_at'] = DateTime.now().toIso8601String();

      await updateVideoMetadata(mediaFileId, metadata);
      return true;
    } catch (e) {
      print('Error en incrementReproduccion: $e');
      return false;
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Total videos
      final totalVideos = mediaFiles.length;

      // Total reproducciones
      int totalReproducciones = 0;
      for (var media in mediaFiles) {
        totalReproducciones += media.reproducciones;
      }

      // Most viewed video
      MediaFileModel? mostViewed;
      if (mediaFiles.isNotEmpty) {
        mostViewed = mediaFiles.reduce((curr, next) =>
            curr.reproducciones > next.reproducciones ? curr : next);
      }

      return {
        'total_videos': totalVideos,
        'total_reproducciones': totalReproducciones,
        'most_viewed_video': mostViewed?.toMap(),
      };
    } catch (e) {
      print('Error en getDashboardStats: $e');
      return {};
    }
  }

  /// Get total reproducciones from all videos
  int getTotalReproducciones() {
    int total = 0;
    for (var media in mediaFiles) {
      total += media.reproducciones;
    }
    return total;
  }

  /// Get promedio diario de reproducciones
  int getPromedioDiario() {
    if (mediaFiles.isEmpty) return 0;

    final total = getTotalReproducciones();
    // Calcular días desde el video más antiguo
    final oldestVideo = mediaFiles.reduce((curr, next) =>
        (curr.createdAt ?? DateTime.now())
                .isBefore(next.createdAt ?? DateTime.now())
            ? curr
            : next);

    final daysSinceOldest = DateTime.now()
        .difference(oldestVideo.createdAt ?? DateTime.now())
        .inDays;

    if (daysSinceOldest <= 0) return total;

    return (total / daysSinceOldest).round();
  }

  /// Get most viewed video
  MediaFileModel? getMostViewedVideo() {
    if (mediaFiles.isEmpty) return null;

    return mediaFiles.reduce((curr, next) =>
        curr.reproducciones > next.reproducciones ? curr : next);
  }

  /// Get top 5 videos by views from local data
  Future<List<Map<String, dynamic>>> getTop5VideosByViews() async {
    try {
      final sortedVideos = List<MediaFileModel>.from(mediaFiles)
        ..sort((a, b) => b.reproducciones.compareTo(a.reproducciones));

      final top5 = sortedVideos
          .take(5)
          .map((video) => {
                'media_file_id': video.mediaFileId,
                'title': video.title ?? video.fileName,
                'file_url': video.fileUrl,
                'storage_path': video.storagePath,
                'reproducciones': video.reproducciones,
                'poster_url': video.posterUrl,
              })
          .toList();

      return top5;
    } catch (e) {
      print('Error en getTop5VideosByViews: $e');
      return [];
    }
  }

  /// Get video metrics from local data
  Future<Map<String, dynamic>?> getVideoMetrics() async {
    try {
      final totalVideos = mediaFiles.length;
      final totalReproducciones = mediaFiles.fold<int>(
        0,
        (sum, video) => sum + video.reproducciones,
      );

      // Calcular promedio por día (simulado)
      final diasActivos = 30; // Simular 30 días de actividad
      final promedioPorDia = totalReproducciones / diasActivos;

      return {
        'total_videos': totalVideos,
        'total_reproducciones': totalReproducciones,
        'promedio_reproducciones_por_dia': promedioPorDia,
      };
    } catch (e) {
      print('Error en getVideoMetrics: $e');
      return null;
    }
  }

  /// Update missing video durations (batch process)
  /// DEMO MODE: Simula actualización sin procesar videos realmente
  Future<Map<String, dynamic>> updateMissingDurations(
    Function(int current, int total) onProgress,
  ) async {
    try {
      final videosWithoutDuration =
          mediaFiles.where((video) => video.seconds == null).toList();

      if (videosWithoutDuration.isEmpty) {
        return {'success': true, 'updated': 0, 'failed': 0};
      }

      // Simular procesamiento
      for (int i = 0; i < videosWithoutDuration.length; i++) {
        onProgress(i + 1, videosWithoutDuration.length);
        await Future.delayed(const Duration(milliseconds: 200));
      }

      return {
        'success': true,
        'updated': 0,
        'failed': 0,
        'total': videosWithoutDuration.length,
      };
    } catch (e) {
      print('Error en updateMissingDurations: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== SEARCH & FILTER ==========

  /// Search videos by title or description
  void searchVideos(String query) {
    if (query.isEmpty) {
      _buildPlutoRows();
      gridRebuildKey++;
      // Force rebuild in release mode
      scheduleMicrotask(() {
        notifyListeners();
      });
      return;
    }

    videosRows.clear();
    final filteredMedia = mediaFiles.where((media) {
      final title = (media.title ?? media.fileName).toLowerCase();
      final description = (media.fileDescription ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery) || description.contains(searchQuery);
    }).toList();

    for (var media in filteredMedia) {
      videosRows.add(
        PlutoRow(
          cells: {
            'video': PlutoCell(value: media),
            'thumbnail': PlutoCell(value: media.fileUrl),
            'title': PlutoCell(value: media.title ?? media.fileName),
            'file_description': PlutoCell(value: media.fileDescription),
            'reproducciones': PlutoCell(value: media.reproducciones),
            'duration': PlutoCell(
                value: media.seconds != null
                    ? _formatDuration(media.seconds!)
                    : '-'),
            'file_size': PlutoCell(
                value: media.fileSizeBytes != null
                    ? _formatFileSize(media.fileSizeBytes!)
                    : '-'),
            'createdAt': PlutoCell(
                value: media.createdAt?.toString().split('.')[0] ?? '-'),
            'tags': PlutoCell(value: media.tags.join(', ')),
            'actions': PlutoCell(value: media),
          },
        ),
      );
    }

    gridRebuildKey++;
    // Force rebuild in release mode using scheduleMicrotask
    scheduleMicrotask(() {
      notifyListeners();
      // Also notify state manager if available
      stateManager?.notifyListeners();
    });
  }

  // ========== CLEANUP ==========

  @override
  void dispose() {
    busquedaVideoController.dispose();
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }
}
