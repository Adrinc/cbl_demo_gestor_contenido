import 'package:flutter/material.dart';
//import 'package:cbluna_crm_lu/theme/theme.dart';

class RightImageWidget extends StatelessWidget {
  const RightImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: size.width * 0.55,
          height: size.height - 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            image: const DecorationImage(
              image: AssetImage('assets/images/lu_login.jpeg'),
              filterQuality: FilterQuality.high,
              fit: BoxFit.fill,
            ),
          ),
        ),
        
        /* Positioned(
          left: 51.54,
          bottom: 86,
          child: Text(
            'Control de Visitas',
            style: AppTheme.of(context).title1.override(
                          fontFamily: AppTheme.of(context).title1Family,
                          color: AppTheme.of(context).primaryColor,
                        ),
          ),
        ), */
      ],
    );
  }
}
