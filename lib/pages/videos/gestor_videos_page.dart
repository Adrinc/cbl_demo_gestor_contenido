import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/models/media/media_models.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/widgets/premium_button.dart';
import 'package:energy_media/pages/videos/widgets/premium_batch_upload_dialog.dart';
import 'package:energy_media/pages/videos/widgets/video_player_dialog.dart';
import 'package:energy_media/pages/videos/widgets/gestor_videos_widgets/empty_state_widget.dart';
import 'package:energy_media/pages/videos/widgets/gestor_videos_widgets/edit_video_dialog.dart';
import 'package:energy_media/pages/videos/widgets/gestor_videos_widgets/delete_video_dialog.dart';

import 'package:energy_media/pages/videos/widgets/video_thumbnail_widget.dart';
import 'package:gap/gap.dart';

class GestorVideosPage extends StatefulWidget {
  const GestorVideosPage({Key? key}) : super(key: key);

  @override
  State<GestorVideosPage> createState() => _GestorVideosPageState();
}

class _GestorVideosPageState extends State<GestorVideosPage> {
  PlutoGridStateManager? _stateManager;
  bool _isLoading = true;

  // Calcular pageSize dinámico según altura de pantalla
  int _calculatePageSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Altura aproximada: toolbar (~140px) + padding (~48px) + row (~80px promedio)
    // Altura disponible para el grid
    final availableHeight = screenHeight - 200;

    // Calcular cuántas filas caben (altura promedio de fila ~80px)
    final rowsVisible = (availableHeight / 80).floor();

    // Ajustar pageSize: mínimo 5, máximo 20
    if (rowsVisible >= 15) return 20;
    if (rowsVisible >= 12) return 15;
    if (rowsVisible >= 8) return 10;
    return 8; // Default para resoluciones pequeñas
  }

  @override
  void initState() {
    super.initState();
    // DEMO MODE: Datos se cargan automáticamente en VideosProvider constructor
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).primaryColor,
        ),
      );
    }

    return Consumer<VideosProvider>(
      builder: (context, provider, child) {
        if (isMobile) {
          return _buildMobileView(provider);
        } else {
          return _buildDesktopView(provider);
        }
      },
    );
  }

  Widget _buildDesktopView(VideosProvider provider) {
    return Column(
      children: [
        _buildToolbar(provider, false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildPlutoGrid(provider),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileView(VideosProvider provider) {
    return Column(
      children: [
        _buildToolbar(provider, true),
        Expanded(
          child: provider.mediaFiles.isEmpty
              ? EmptyStateWidget(
                  onUploadPressed: () => _showBatchUploadDialog(provider),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.mediaFiles.length,
                  itemBuilder: (context, index) {
                    final video = provider.mediaFiles[index];
                    return _buildVideoCard(video, provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildToolbar(VideosProvider provider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryBackground,
            AppTheme.of(context).secondaryBackground,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            // Vista móvil: botón único para subir videos
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4EC9F5),
                      Color(0xFFFFB733),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4EC9F5).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showBatchUploadDialog(provider),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            color: Color(0xFF0B0B0D),
                            size: 24,
                          ),
                          Gap(12),
                          Text(
                            'Subir Videos',
                            style: TextStyle(
                              color: Color(0xFF0B0B0D),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (!isMobile)
            // Vista desktop: contador de videos y botón (sin título redundante)
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4EC9F5).withOpacity(0.15),
                              const Color(0xFFFFB733).withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.video_collection_rounded,
                          color: AppTheme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        '${provider.mediaFiles.length} videos disponibles',
                        style: AppTheme.of(context).bodyText1.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).secondaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                PremiumButton(
                  text: 'Subir Videos',
                  icon: Icons.cloud_upload_rounded,
                  onPressed: () => _showBatchUploadDialog(provider),
                ),
              ],
            ),
          const Gap(16),
          _buildSearchField(provider),
        ],
      ),
    );
  }

  Widget _buildSearchField(VideosProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: provider.busquedaVideoController,
        style: AppTheme.of(context).bodyText1.override(
              fontFamily: 'Poppins',
              color: AppTheme.of(context).primaryText,
            ),
        decoration: InputDecoration(
          hintText: 'Buscar videos por título o descripción...',
          hintStyle: AppTheme.of(context).bodyText1.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).tertiaryText,
              ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.of(context).primaryColor,
          ),
          suffixIcon: provider.busquedaVideoController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.of(context).tertiaryText,
                  ),
                  onPressed: () {
                    provider.busquedaVideoController.clear();
                    provider.searchVideos('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) {
          // Force immediate update in release mode
          provider.searchVideos(value);
          // Additional setState to ensure UI rebuild
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildPlutoGrid(VideosProvider provider) {
    final columns = [
      PlutoColumn(
        title: 'Vista Previa',
        field: 'thumbnail',
        type: PlutoColumnType.text(),
        width: 150,
        enableEditingMode: false,
        enableColumnDrag: false,
        enableSorting: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final video =
              rendererContext.row.cells['video']?.value as MediaFileModel?;
          if (video == null) return const SizedBox();

          // Obtener poster desde metadata_json
          final posterUrl = video.posterUrl;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.of(context).tertiaryBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  posterUrl != null && posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildThumbnailPlaceholder(),
                        )
                      : (video.fileUrl != null && video.fileUrl!.isNotEmpty)
                          ? VideoThumbnailWidget(
                              videoUrl: video.fileUrl!,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : _buildThumbnailPlaceholder(),
                  // Overlay con gradiente
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Título',
        field: 'title',
        type: PlutoColumnType.text(),
        width: 300,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final title = rendererContext.cell.value?.toString() ?? '';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.of(context).primaryText,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Descripción',
        field: 'file_description',
        type: PlutoColumnType.text(),
        width: 400,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final description = rendererContext.cell.value?.toString() ?? '';
          if (description.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                'Sin descripción',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.of(context).tertiaryText,
                ),
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.of(context).secondaryText,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Reproducciones',
        field: 'reproducciones',
        type: PlutoColumnType.number(),
        width: 160,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final count = rendererContext.cell.value ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.of(context).success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.of(context).success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 14,
                    color: AppTheme.of(context).success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: AppTheme.of(context).success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Duración',
        field: 'duration',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final duration = rendererContext.cell.value?.toString() ?? '-';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.of(context).warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.of(context).warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppTheme.of(context).warning,
                  ),
                  const Gap(6),
                  Flexible(
                    child: Text(
                      duration,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.of(context).warning,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Tamaño',
        field: 'file_size',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final fileSize = rendererContext.cell.value?.toString() ?? '-';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.of(context).info.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.of(context).info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storage_rounded,
                    size: 14,
                    color: AppTheme.of(context).info,
                  ),
                  const Gap(6),
                  Flexible(
                    child: Text(
                      fileSize,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.of(context).info,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Fecha de Creación',
        field: 'createdAt',
        type: PlutoColumnType.text(),
        width: 240,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final video =
              rendererContext.row.cells['video']?.value as MediaFileModel?;
          if (video?.createdAt == null) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                'Fecha no disponible',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.of(context).tertiaryText,
                ),
              ),
            );
          }

          final formattedDate = _formatDescriptiveDate(video!.createdAt!);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedDate['date']!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate['time']!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Etiquetas',
        field: 'tags',
        type: PlutoColumnType.text(),
        width: 250,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final video =
              rendererContext.row.cells['video']?.value as MediaFileModel?;
          if (video == null || video.tags.isEmpty) return const SizedBox();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: video.tags.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4EC9F5), Color(0xFFFFB733)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF0B0B0D),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: 200,
        enableEditingMode: false,
        enableColumnDrag: false,
        enableSorting: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final video =
              rendererContext.row.cells['video']?.value as MediaFileModel?;
          if (video == null) return const SizedBox();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.play_arrow_rounded,
                color: AppTheme.of(context).primaryColor,
                tooltip: 'Reproducir',
                onPressed: () => _playVideo(video),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit_rounded,
                color: AppTheme.of(context).secondaryColor,
                tooltip: 'Editar',
                onPressed: () => _editVideoDialog(video, provider),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_rounded,
                color: AppTheme.of(context).error,
                tooltip: 'Eliminar',
                onPressed: () => _deleteVideoDialog(video, provider),
              ),
            ],
          );
        },
      ),
    ];

    return PlutoGrid(
      key: ValueKey('pluto_grid_${provider.gridRebuildKey}'),
      columns: columns,
      rows: provider.videosRows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        _stateManager = event.stateManager;
        _stateManager!.setShowColumnFilter(false);
        // Configurar paginación dinámica según resolución
        final pageSize = _calculatePageSize(context);
        _stateManager!.setPageSize(pageSize, notify: true);
        // Conectar stateManager al provider para actualizaciones directas
        provider.stateManager = _stateManager;

        // Force initial render in release mode
        scheduleMicrotask(() {
          _stateManager?.notifyListeners();
        });
      },
      createFooter: (stateManager) {
        return PlutoPagination(stateManager);
      },
      configuration: PlutoGridConfiguration(
        style: plutoGridStyleConfig(context).copyWith(
          // Scrollbar SIEMPRE visible y más notorio
          enableGridBorderShadow: true,
          gridBorderRadius: BorderRadius.circular(12),
        ),
        scrollbar: const PlutoGridScrollbarConfig(
          // Scrollbar siempre visible
          isAlwaysShown: true,
          // Hacer scrollbar más grueso y notorio
          scrollbarThickness: 10,
          scrollbarThicknessWhileDragging: 14,
          // Radio de borde para scrollbar
          scrollbarRadius: Radius.circular(8),
          scrollbarRadiusWhileDragging: Radius.circular(10),
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
        localeText: const PlutoGridLocaleText.spanish(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
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

  Widget _buildVideoCard(MediaFileModel video, VideosProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail con overlay premium
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: video.posterUrl != null && video.posterUrl!.isNotEmpty
                      ? Image.network(
                          video.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.of(context).tertiaryBackground,
                                  AppTheme.of(context).primaryBackground,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 80,
                              color: AppTheme.of(context).tertiaryText,
                            ),
                          ),
                        )
                      : (video.fileUrl != null && video.fileUrl!.isNotEmpty)
                          ? VideoThumbnailWidget(
                              videoUrl: video.fileUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.of(context).tertiaryBackground,
                                    AppTheme.of(context).primaryBackground,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.video_library_rounded,
                                size: 80,
                                color: AppTheme.of(context).tertiaryText,
                              ),
                            ),
                ),
                // Overlay con gradiente
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Botón de play central
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.of(context).primaryColor,
                            AppTheme.of(context).secondaryColor,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _playVideo(video),
                          customBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Stats en la parte inferior
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AppTheme.of(context).success.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 14,
                              color: AppTheme.of(context).success,
                            ),
                            const Gap(4),
                            Text(
                              '${video.reproducciones}',
                              style: TextStyle(
                                color: AppTheme.of(context).success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      if (video.durationSeconds != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const Gap(4),
                              Text(
                                _formatDuration(video.durationSeconds!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Contenido de la card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    video.title ?? video.fileName,
                    style: AppTheme.of(context).title3.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(12),
                  // Descripción
                  if (video.fileDescription != null &&
                      video.fileDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        video.fileDescription!,
                        style: AppTheme.of(context).bodyText2.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).secondaryText,
                              fontSize: 14,
                              lineHeight: 1.5,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Tags si existen
                  if (video.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: video.tags.take(4).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppTheme.of(context).primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  // Divisor
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.of(context).primaryColor.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  // Botones de acción premium
                  Row(
                    children: [
                      Expanded(
                        child: _buildMobilePremiumButton(
                          icon: Icons.edit_rounded,
                          label: 'Editar',
                          color: AppTheme.of(context).secondaryColor,
                          onPressed: () => _editVideoDialog(video, provider),
                        ),
                      ),
                      const Gap(12),
                      _buildMobileIconButton(
                        icon: Icons.delete_rounded,
                        color: AppTheme.of(context).error,
                        onPressed: () => _deleteVideoDialog(video, provider),
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

  Widget _buildMobilePremiumButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Future<void> _showBatchUploadDialog(VideosProvider provider) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumBatchUploadDialog(
        provider: provider,
        onSuccess: () {
          // DEMO MODE: Datos se actualizan automáticamente en el provider
        },
      ),
    );
  }

  void _playVideo(MediaFileModel video) {
    // Verificar que el video tenga URL
    if (video.fileUrl == null || video.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: El video no tiene URL válida'),
          backgroundColor: Color(0xFFFF2D2D),
        ),
      );
      return;
    }

    // Abrir diálogo con reproductor
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => VideoPlayerDialog(
        video: video,
        onPlaybackCompleted: () {
          // Incrementar reproducciones cuando termine el video
          final provider = Provider.of<VideosProvider>(context, listen: false);
          provider.incrementReproduccion(video.mediaFileId);
        },
        onClose: () {
          // Opcional: realizar alguna acción al cerrar
        },
      ),
    );
  }

  Future<void> _editVideoDialog(
      MediaFileModel video, VideosProvider provider) async {
    final result = await EditVideoDialog.show(context, video, provider);

    // Manejar resultado después de cerrar el diálogo
    if (result == true) {
      // DEMO MODE: Datos se actualizan automáticamente en el provider

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteVideoDialog(
      MediaFileModel video, VideosProvider provider) async {
    final confirm = await DeleteVideoDialog.show(context, video, provider);

    if (confirm == true) {
      final success = await provider.deleteVideo(video.mediaFileId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // DEMO MODE: Datos se actualizan automáticamente en el provider
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el video'),
            backgroundColor: Color(0xFFFF2D2D),
          ),
        );
      }
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

  Map<String, String> _formatDescriptiveDate(DateTime date) {
    // Obtener día de la semana en español
    final diasSemana = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    final diaSemana = diasSemana[date.weekday - 1];

    // Obtener mes en español
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final mes = meses[date.month - 1];

    // Formatear la hora
    final hora = date.hour;
    final minuto = date.minute.toString().padLeft(2, '0');
    final segundo = date.second.toString().padLeft(2, '0');
    final periodo = hora >= 12 ? 'pm' : 'am';
    final hora12 = hora > 12 ? hora - 12 : (hora == 0 ? 12 : hora);

    // Construir las cadenas
    final fechaTexto = '$diaSemana ${date.day} de $mes del ${date.year}';
    final horaTexto = 'a las $hora12:$minuto:$segundo $periodo';

    return {
      'date': fechaTexto,
      'time': horaTexto,
    };
  }
}
