import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/models/media/media_models.dart';

class VideosProvider extends ChangeNotifier {
  // ========== ORGANIZATION CONSTANT ==========
  static const int organizationId = 17;

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
  String? errorMessage;

  // ========== CONSTRUCTOR ==========
  VideosProvider() {
    loadMediaFiles();
    loadCategories();
  }

  // ========== LOAD METHODS ==========

  /// Load all media files with organization filter
  Future<void> loadMediaFiles() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await supabaseML
          .from('media_files')
          .select()
          .eq('organization_fk', organizationId)
          .order('created_at_timestamp', ascending: false);

      mediaFiles = (response as List<dynamic>)
          .map((item) => MediaFileModel.fromMap(item))
          .toList();

      await _buildPlutoRows();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error cargando videos: $e';
      isLoading = false;
      notifyListeners();
      print('Error en loadMediaFiles: $e');
    }
  }

  /// Load media files with posters using view
  Future<void> loadMediaWithPosters() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabaseML
          .from('vw_media_files_with_posters')
          .select()
          .eq('organization_fk', organizationId)
          .order('media_created_at', ascending: false);

      mediaWithPosters = (response as List<dynamic>)
          .map((item) => MediaWithPosterModel.fromMap(item))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error cargando videos con posters: $e';
      isLoading = false;
      notifyListeners();
      print('Error en loadMediaWithPosters: $e');
    }
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      final response = await supabaseML
          .from('media_categories')
          .select()
          .order('category_name');

      categories = (response as List<dynamic>)
          .map((item) => MediaCategoryModel.fromMap(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error en loadCategories: $e');
    }
  }

  /// Build PlutoGrid rows from media files
  Future<void> _buildPlutoRows() async {
    videosRows.clear();

    for (var media in mediaFiles) {
      videosRows.add(
        PlutoRow(
          cells: {
            'video': PlutoCell(value: media), // Objeto completo para renderers
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

  /// Upload video to Supabase Storage and create record
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

      // 1. Upload video to storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = _sanitizeFileName(videoName!);
      final fileName = '${timestamp}_$sanitizedName';
      videoStoragePath = 'videos/$fileName';

      await supabaseML.storage.from('energymedia').uploadBinary(
            videoStoragePath!,
            webVideoBytes!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // 2. Get public URL
      videoUrl = supabaseML.storage
          .from('energymedia')
          .getPublicUrl(videoStoragePath!);

      // 3. Upload poster if exists (solo storage, no DB)
      String? posterUrlUploaded;
      if (webPosterBytes != null && posterName != null) {
        posterUrlUploaded = await _uploadPoster();
      }

      // 4. Create media_files record (UN SOLO REGISTRO con poster en metadata_json)
      final metadataJson = {
        'uploaded_at': DateTime.now().toIso8601String(),
        'reproducciones': 0,
        'original_file_name': videoName,
        'duration_seconds': durationSeconds,
        'file_size_bytes': webVideoBytes!.length, // Peso del video
        if (posterUrlUploaded != null) 'poster_url': posterUrlUploaded,
        if (posterUrlUploaded != null) 'poster_file_name': posterName,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      };

      await supabaseML.from('media_files').insert({
        'file_name': fileName,
        'title': title,
        'file_description': description,
        'file_type': 'video',
        'mime_type': _getMimeType(videoFileExtension),
        'file_extension': videoFileExtension,
        'file_size_bytes': webVideoBytes!.length,
        'file_url': videoUrl,
        'storage_path': videoStoragePath,
        'organization_fk': organizationId,
        'metadata_json': metadataJson,
        'seconds': durationSeconds,
        'is_public_file': true,
        'uploaded_by_user_id': currentUser?.id,
      });

      // Clean up
      _clearUploadState();

      // Reload data
      await loadMediaFiles();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error subiendo video: $e';
      isLoading = false;
      notifyListeners();
      print('Error en uploadVideo: $e');
      return false;
    }
  }

  /// Upload poster image to storage only (NO database record)
  /// Returns the public URL of the uploaded poster
  Future<String?> _uploadPoster() async {
    if (webPosterBytes == null || posterName == null) return null;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = _sanitizeFileName(posterName!);
      final fileName = '${timestamp}_$sanitizedName';
      posterStoragePath = 'imagenes/$fileName';

      // Solo subir al storage, NO crear registro en media_files
      await supabaseML.storage.from('energymedia').uploadBinary(
            posterStoragePath!,
            webPosterBytes!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Obtener URL pública del poster
      posterUrl = supabaseML.storage
          .from('energymedia')
          .getPublicUrl(posterStoragePath!);

      return posterUrl; // Retornar solo la URL, no el ID
    } catch (e) {
      print('Error en _uploadPoster: $e');
      return null;
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
  Future<bool> updateVideoTitle(int mediaFileId, String title) async {
    try {
      await supabaseML
          .from('media_files')
          .update({'title': title})
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId);

      await loadMediaFiles();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando título: $e';
      notifyListeners();
      print('Error en updateVideoTitle: $e');
      return false;
    }
  }

  /// Update video description
  Future<bool> updateVideoDescription(
      int mediaFileId, String description) async {
    try {
      await supabaseML
          .from('media_files')
          .update({'file_description': description})
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId);

      await loadMediaFiles();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando descripción: $e';
      notifyListeners();
      print('Error en updateVideoDescription: $e');
      return false;
    }
  }

  /// Update video metadata
  Future<bool> updateVideoMetadata(
    int mediaFileId,
    Map<String, dynamic> metadata,
  ) async {
    try {
      await supabaseML
          .from('media_files')
          .update({'metadata_json': metadata})
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId);

      await loadMediaFiles();
      return true;
    } catch (e) {
      errorMessage = 'Error actualizando metadata: $e';
      notifyListeners();
      print('Error en updateVideoMetadata: $e');
      return false;
    }
  }

  /// Update video tags
  Future<bool> updateVideoTags(int mediaFileId, List<String> tags) async {
    try {
      // Get current metadata
      final response = await supabaseML
          .from('media_files')
          .select('metadata_json')
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId)
          .single();

      final metadata = response['metadata_json'] as Map<String, dynamic>? ?? {};
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
  Future<bool> updateVideoPoster(
      int mediaFileId, Uint8List posterBytes, String posterName) async {
    try {
      isLoading = true;
      notifyListeners();

      // Upload new poster to storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = _sanitizeFileName(posterName);
      final fileName = '${timestamp}_$sanitizedName';
      final posterPath = 'imagenes/$fileName';

      await supabaseML.storage.from('energymedia').uploadBinary(
            posterPath,
            posterBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final newPosterUrl =
          supabaseML.storage.from('energymedia').getPublicUrl(posterPath);

      // Get current metadata and old poster URL
      final response = await supabaseML
          .from('media_files')
          .select('metadata_json')
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId)
          .single();

      final metadata = response['metadata_json'] as Map<String, dynamic>? ?? {};
      final oldPosterUrl = metadata['poster_url'] as String?;

      // Delete old poster from storage if exists
      if (oldPosterUrl != null && oldPosterUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(oldPosterUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('energymedia');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final oldPosterPath =
                pathSegments.sublist(bucketIndex + 1).join('/');
            await supabaseML.storage
                .from('energymedia')
                .remove([oldPosterPath]);
          }
        } catch (e) {
          print('Error eliminando poster antiguo: $e');
        }
      }

      // Update metadata with new poster info
      metadata['poster_url'] = newPosterUrl;
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
  Future<bool> deletePoster(int mediaFileId) async {
    try {
      isLoading = true;
      notifyListeners();

      // Get current metadata
      final response = await supabaseML
          .from('media_files')
          .select('metadata_json')
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId)
          .single();

      final metadata = response['metadata_json'] as Map<String, dynamic>? ?? {};
      final posterUrl = metadata['poster_url'] as String?;

      // Delete poster from storage if exists
      if (posterUrl != null && posterUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(posterUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('energymedia');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final posterPath = pathSegments.sublist(bucketIndex + 1).join('/');
            await supabaseML.storage.from('energymedia').remove([posterPath]);
          }
        } catch (e) {
          print('Error eliminando poster del storage: $e');
        }
      }

      // Remove poster references from metadata
      metadata.remove('poster_url');
      metadata.remove('poster_file_name');

      // Update metadata
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
  Future<bool> deleteVideo(int mediaFileId) async {
    try {
      isLoading = true;
      notifyListeners();

      // Get video info
      final response = await supabaseML
          .from('media_files')
          .select()
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId)
          .single();

      final storagePath = response['storage_path'] as String?;
      final metadataJson = response['metadata_json'] as Map<String, dynamic>?;

      // Delete video from storage if path exists
      if (storagePath != null) {
        await supabaseML.storage.from('energymedia').remove([storagePath]);
      }

      // Delete poster from storage if exists in metadata_json
      if (metadataJson != null && metadataJson['poster_url'] != null) {
        final posterUrl = metadataJson['poster_url'] as String;
        // Extraer el path del storage desde la URL
        // URL format: https://xxx.supabase.co/storage/v1/object/public/energymedia/imagenes/filename.png
        final uri = Uri.parse(posterUrl);
        final pathSegments = uri.pathSegments;

        // Encontrar el índice después de 'energymedia' y construir el path
        final bucketIndex = pathSegments.indexOf('energymedia');
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final posterPath = pathSegments.sublist(bucketIndex + 1).join('/');
          await supabaseML.storage.from('energymedia').remove([posterPath]);
        }
      }

      // Delete database record
      await supabaseML
          .from('media_files')
          .delete()
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId);

      await loadMediaFiles();

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
  Future<bool> incrementReproduccion(int mediaFileId) async {
    try {
      // Get current metadata
      final response = await supabaseML
          .from('media_files')
          .select('metadata_json')
          .eq('media_file_id', mediaFileId)
          .eq('organization_fk', organizationId)
          .single();

      final metadata = response['metadata_json'] as Map<String, dynamic>? ?? {};
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

  /// Get top 5 videos by views using Supabase function
  /// Returns list of maps with: media_file_id, title, file_url, storage_path, reproducciones, poster_url
  Future<List<Map<String, dynamic>>> getTop5VideosByViews() async {
    try {
      final response = await supabaseML.rpc('get_top_5_videos_by_views');

      if (response == null) return [];

      return (response as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      print('Error en getTop5VideosByViews: $e');
      return [];
    }
  }

  /// Get video metrics using Supabase function
  /// Returns: total_videos, total_reproducciones, promedio_reproducciones_por_dia
  Future<Map<String, dynamic>?> getVideoMetrics() async {
    try {
      final response = await supabaseML.rpc('get_video_metrics');

      if (response == null || (response as List).isEmpty) return null;

      // La función retorna un array con un solo objeto
      final data = (response as List).first as Map<String, dynamic>;

      return {
        'total_videos': data['total_videos'] ?? 0,
        'total_reproducciones': data['total_reproducciones'] ?? 0,
        'promedio_reproducciones_por_dia':
            data['promedio_reproducciones_por_dia'] ?? 0.0,
      };
    } catch (e) {
      print('Error en getVideoMetrics: $e');
      return null;
    }
  }

  /// Update missing video durations (batch process)
  Future<Map<String, dynamic>> updateMissingDurations(
    Function(int current, int total) onProgress,
  ) async {
    try {
      // Obtener videos sin duración
      final videosWithoutDuration = mediaFiles
          .where((video) => video.seconds == null && video.fileUrl != null)
          .toList();

      if (videosWithoutDuration.isEmpty) {
        return {'success': true, 'updated': 0, 'failed': 0};
      }

      int updated = 0;
      int failed = 0;

      for (int i = 0; i < videosWithoutDuration.length; i++) {
        final video = videosWithoutDuration[i];
        onProgress(i + 1, videosWithoutDuration.length);

        VideoPlayerController? controller;
        try {
          // Inicializar VideoPlayerController para obtener duración
          controller = VideoPlayerController.network(video.fileUrl!);
          await controller.initialize();

          final durationSeconds = controller.value.duration.inSeconds;

          if (durationSeconds > 0) {
            // Obtener metadata actual
            final response = await supabaseML
                .from('media_files')
                .select('metadata_json')
                .eq('media_file_id', video.mediaFileId)
                .eq('organization_fk', organizationId)
                .single();

            final metadata =
                response['metadata_json'] as Map<String, dynamic>? ?? {};

            // Actualizar metadata con duración
            metadata['duration_seconds'] = durationSeconds;

            // Actualizar tanto seconds como metadata_json
            await supabaseML
                .from('media_files')
                .update({
                  'seconds': durationSeconds,
                  'metadata_json': metadata,
                })
                .eq('media_file_id', video.mediaFileId)
                .eq('organization_fk', organizationId);

            updated++;
            print('✅ Video ${video.mediaFileId}: $durationSeconds segundos');
          } else {
            failed++;
            print('⚠️ Video ${video.mediaFileId}: duración inválida');
          }
        } catch (e) {
          print('❌ Error procesando video ${video.mediaFileId}: $e');
          failed++;
        } finally {
          // Limpiar recursos del controller
          controller?.dispose();
        }
      }

      // Recargar datos
      await loadMediaFiles();

      return {
        'success': true,
        'updated': updated,
        'failed': failed,
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
