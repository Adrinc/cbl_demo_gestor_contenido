import 'package:flutter/material.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:gap/gap.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
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
              Icons.construction_rounded,
              size: 80,
              color: AppTheme.of(context).primaryColor,
            ),
          ),
          const Gap(32),
          Text(
            'Configuración',
            style: AppTheme.of(context).title2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
          ),
          const Gap(16),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Esta sección estará disponible próximamente. Aquí podrás personalizar las preferencias de tu plataforma.',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.of(context).primaryColor.withOpacity(0.1),
                  AppTheme.of(context).secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_objects_rounded,
                  color: AppTheme.of(context).secondaryColor,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  'Próximamente: Temas, notificaciones, preferencias y más',
                  style: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).secondaryText,
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
}
