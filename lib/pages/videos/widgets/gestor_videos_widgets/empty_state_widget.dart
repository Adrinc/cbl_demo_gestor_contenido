import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:energy_media/theme/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onUploadPressed;

  const EmptyStateWidget({
    Key? key,
    required this.onUploadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.of(context).primaryColor.withOpacity(0.1),
                    AppTheme.of(context).secondaryColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: 80,
                color: AppTheme.of(context).primaryColor,
              ),
            ),
            const Gap(24),
            Text(
              'No hay videos disponibles',
              style: AppTheme.of(context).title3.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
            ),
            const Gap(12),
            Text(
              'Sube tu primer video para comenzar a compartir contenido',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).tertiaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            ElevatedButton.icon(
              onPressed: onUploadPressed,
              icon: const Icon(Icons.cloud_upload_rounded, size: 20),
              label: const Text('Subir Primer Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: AppTheme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
