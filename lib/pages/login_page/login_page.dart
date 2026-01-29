import 'package:flutter/material.dart';

import 'package:energy_media/models/users/token.dart';
import 'package:energy_media/pages/login_page/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
    this.token,
  }) : super(key: key);

  final Token? token;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 768) {
              // Vista móvil - fondo degradado completo con mejoras
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B0B0D), // Negro oscuro principal
                      Color(0xFF1A1A1D), // Gris muy oscuro
                      Color(0xFF6B2F8A), // Purple
                      Color(0xFF4EC9F5), // Cyan
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Efectos de partículas/círculos flotantes (más sutiles en móvil)
                    ...List.generate(
                        4, (index) => _buildFloatingCircle(index, constraints)),
                    // Overlay oscuro con blur para mejor legibilidad
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24, // Padding simétrico
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Centrado horizontal
                            children: [
                              // Logo NetHive para móvil
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 40),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 30,
                                              offset: const Offset(0, 15),
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, -5),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Image.asset(
                                            'assets/images/favicon.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'EnergyMedia',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 3),
                                              blurRadius: 15,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Content Manager',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 0.8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Formulario con contenedor para mejor contraste
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  width: double.infinity,
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: const LoginForm(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Vista desktop - columna izquierda sólida, derecha degradado
              return Row(
                children: [
                  // Lado izquierdo - Formulario (fondo sólido con efectos)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 25, 26, 28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(10, 0),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Patrón de puntos sutil
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DotPatternPainter(),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 40),
                            child: Center(
                              child: SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 420),
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: const LoginForm(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lado derecho - Logo (con degradado mejorado)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF42BCEE),
                            Color(0xFF5865B5),
                            Color(0xFF653093)
                          ],
                          stops: [0.25, 0.5, 1.0],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Efectos de círculos flotantes
                          ...List.generate(
                              8,
                              (index) => _buildFloatingCircle(
                                  index, constraints, true)),
                          // Contenido centrado horizontal y verticalmente
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(60),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo NetHive con animación
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 40,
                                            offset: const Offset(0, 20),
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, -10),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(30),
                                        child: Image.asset(
                                          'assets/images/favicon.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: const Text(
                                      'EnergyMedia',
                                      style: TextStyle(
                                        fontSize: 52,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 4),
                                            blurRadius: 20,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      'Content Manager',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // Línea decorativa
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      width: 100,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.white,
                                            Colors.transparent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFloatingCircle(int index, BoxConstraints constraints,
      [bool isRightSide = false]) {
    final random = [
      {'size': 80.0, 'top': 50.0, 'left': 30.0, 'opacity': 0.1},
      {'size': 120.0, 'top': 200.0, 'right': 50.0, 'opacity': 0.08},
      {'size': 60.0, 'bottom': 150.0, 'left': 80.0, 'opacity': 0.12},
      {'size': 100.0, 'top': 300.0, 'left': 200.0, 'opacity': 0.06},
      {'size': 140.0, 'bottom': 100.0, 'right': 100.0, 'opacity': 0.09},
      {'size': 70.0, 'top': 450.0, 'right': 150.0, 'opacity': 0.11},
      {'size': 90.0, 'top': 100.0, 'left': 150.0, 'opacity': 0.07},
      {'size': 110.0, 'bottom': 200.0, 'left': 50.0, 'opacity': 0.08},
    ];

    if (index >= random.length) return const SizedBox();

    final circle = random[index];

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Positioned(
          top: circle['top'],
          bottom: circle['bottom'],
          left: circle['left'],
          right: circle['right'],
          child: Transform.scale(
            scale: 0.5 + (_fadeAnimation.value * 0.5),
            child: Container(
              width: circle['size'] as double,
              height: circle['size'] as double,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                    (circle['opacity'] as double) * _fadeAnimation.value),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1 * _fadeAnimation.value),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter para patrón de puntos
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    const double spacing = 30;
    const double dotSize = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          dotSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
