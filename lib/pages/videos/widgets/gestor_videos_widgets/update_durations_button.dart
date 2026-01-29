import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:energy_media/providers/videos_provider.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/widgets/premium_button.dart';

/// Botón condicional para actualizar duraciones de videos
/// Se muestra solo cuando hay videos sin duración
/// Una vez procesados todos, desaparece automáticamente
class UpdateDurationsButton extends StatelessWidget {
  const UpdateDurationsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VideosProvider>(
      builder: (context, provider, child) {
        final videosWithoutDuration =
            provider.mediaFiles.where((video) => video.seconds == null).length;

        // Si no hay videos sin duración, no mostrar nada
        if (videosWithoutDuration == 0) {
          return const SizedBox.shrink();
        }

        // Mostrar botón con contador
        return PremiumButton(
          text: 'Actualizar duraciones ($videosWithoutDuration)',
          icon: Icons.update_rounded,
          onPressed: () => _showUpdateDialog(context, provider),
        );
      },
    );
  }

  Future<void> _showUpdateDialog(
      BuildContext context, VideosProvider provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdateDurationsDialog(provider: provider),
    );
  }
}

class _UpdateDurationsDialog extends StatefulWidget {
  final VideosProvider provider;

  const _UpdateDurationsDialog({required this.provider});

  @override
  State<_UpdateDurationsDialog> createState() => _UpdateDurationsDialogState();
}

class _UpdateDurationsDialogState extends State<_UpdateDurationsDialog> {
  int current = 0;
  int total = 0;
  bool isProcessing = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    final result = await widget.provider.updateMissingDurations((curr, tot) {
      if (mounted) {
        setState(() {
          current = curr;
          total = tot;
        });
      }
    });

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          isProcessing = false;
        });

        // Esperar un momento para mostrar el resultado
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${result['updated']} videos actualizados correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          isProcessing = false;
          errorMessage = result['error'] ?? 'Error desconocido';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.of(context).primaryColor.withOpacity(0.2),
                    AppTheme.of(context).secondaryColor.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isProcessing ? Icons.update_rounded : Icons.check_circle,
                size: 48,
                color: isProcessing
                    ? AppTheme.of(context).primaryColor
                    : Colors.green,
              ),
            ),
            const Gap(24),
            Text(
              isProcessing
                  ? 'Actualizando duraciones'
                  : errorMessage != null
                      ? 'Error'
                      : '¡Completado!',
              style: AppTheme.of(context).title3.override(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(16),
            if (isProcessing) ...[
              Text(
                'Procesando $current de $total videos...',
                style: AppTheme.of(context).bodyText1.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const Gap(24),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: total > 0 ? current / total : 0,
                  minHeight: 8,
                  backgroundColor: AppTheme.of(context).tertiaryBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.of(context).primaryColor,
                  ),
                ),
              ),
            ] else if (errorMessage != null) ...[
              Text(
                errorMessage!,
                style: AppTheme.of(context).bodyText1.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).error,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ] else ...[
              Text(
                'Todas las duraciones han sido actualizadas',
                style: AppTheme.of(context).bodyText1.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
