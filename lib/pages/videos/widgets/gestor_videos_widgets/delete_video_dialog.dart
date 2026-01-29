import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/models/media/media_models.dart';
import 'package:energy_media/providers/videos_provider.dart';

class DeleteVideoDialog extends StatelessWidget {
  final MediaFileModel video;
  final VideosProvider provider;

  const DeleteVideoDialog({
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
      builder: (context) => DeleteVideoDialog(
        video: video,
        provider: provider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.of(context).error.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).error.withOpacity(0.2),
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
            // Header con gradiente de error
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.of(context).error,
                    AppTheme.of(context).error.withOpacity(0.8),
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
                      Icons.delete_forever_rounded,
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
                          'Eliminar Video',
                          style: AppTheme.of(context).title3.override(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                        const Gap(4),
                        Text(
                          'Esta acción es irreversible',
                          style: AppTheme.of(context).bodyText2.override(
                                fontFamily: 'Poppins',
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.of(context).error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.of(context).error,
                          size: 24,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            '¿Estás seguro de que deseas eliminar "${video.title ?? video.fileName}"?',
                            style: AppTheme.of(context).bodyText1.override(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.of(context).primaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'El video y todos sus datos asociados se eliminarán permanentemente. Esta acción no se puede deshacer.',
                    style: AppTheme.of(context).bodyText2.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).tertiaryText,
                          fontSize: 13,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Actions
            Container(
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
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.of(context).error,
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
                        Icon(Icons.delete_rounded, size: 18),
                        Gap(8),
                        Text(
                          'Eliminar',
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
            ),
          ],
        ),
      ),
    );
  }
}
