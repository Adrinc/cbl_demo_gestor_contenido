import 'package:flutter/material.dart';
import 'package:countup/countup.dart';
import 'package:gap/gap.dart';
import 'package:energy_media/theme/theme.dart';

/// Model para definir los datos de una StatCard
class StatCardData {
  final String title;
  final int value;
  final String? formattedValue;
  final IconData icon;
  final List<Color> gradientColors;
  final String? trend;
  final bool trendUp;
  final String? subtitle;

  const StatCardData({
    required this.title,
    required this.value,
    this.formattedValue,
    required this.icon,
    required this.gradientColors,
    this.trend,
    this.trendUp = true,
    this.subtitle,
  });
}

/// Widget de tarjeta estadística premium con animaciones y diseño moderno
class PremiumStatCard extends StatefulWidget {
  final StatCardData data;
  final VoidCallback? onTap;
  final bool showSparkline;
  final List<double>? sparklineData;

  const PremiumStatCard({
    Key? key,
    required this.data,
    this.onTap,
    this.showSparkline = false,
    this.sparklineData,
  }) : super(key: key);

  @override
  State<PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<PremiumStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    // En móvil usar versión simplificada sin efectos pesados
    if (isMobile) {
      return _buildMobileCard();
    }

    return _buildDesktopCard();
  }

  /// Versión simplificada para móvil - sin efectos que causan blur
  Widget _buildMobileCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 130),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Color sólido en lugar de gradiente para evitar blur
          color: widget.data.gradientColors.first,
          boxShadow: [
            BoxShadow(
              color: widget.data.gradientColors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header row: Icon + Trend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icono simplificado
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  // Trend badge simplificado
                  if (widget.data.trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.data.trendUp
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const Gap(4),
                          Text(
                            widget.data.trend!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(12),
              // Valor
              Text(
                widget.data.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  height: 1.0,
                ),
              ),
              const Gap(4),
              // Título
              Text(
                widget.data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Versión completa para desktop con todos los efectos
  Widget _buildDesktopCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0)
            ..scale(_isHovered ? 1.02 : 1.0),
          child: Container(
            constraints: const BoxConstraints(minHeight: 140),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.data.gradientColors.first.withOpacity(
                    _isHovered ? 0.4 : 0.25,
                  ),
                  blurRadius: _isHovered ? 30 : 20,
                  offset: Offset(0, _isHovered ? 12 : 8),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
                BoxShadow(
                  color: widget.data.gradientColors.last.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background gradient
                  _buildBackground(),

                  // Glow effect animado
                  _buildAnimatedGlow(),

                  // Pattern overlay
                  _buildPatternOverlay(false),

                  // Content
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.data.gradientColors.first,
            widget.data.gradientColors.last,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildAnimatedGlow() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          right: -50 + (_pulseAnimation.value * 20),
          top: -30 + (_pulseAnimation.value * 10),
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.3 * _pulseAnimation.value),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatternOverlay(bool isMobile) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DotPatternPainter(
          color: Colors.white.withOpacity(isMobile ? 0.02 : 0.05),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header row: Icon + Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconContainer(),
              if (widget.data.trend != null) _buildTrendBadge(),
            ],
          ),

          const Gap(16),

          // Value con animación countup
          _buildAnimatedValue(),

          const Gap(4),

          // Title y subtitle
          _buildTitleSection(),

          // Sparkline opcional
          if (widget.showSparkline && widget.sparklineData != null) ...[
            const Gap(12),
            _buildSparkline(),
          ],
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.data.icon,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _buildTrendBadge() {
    final isUp = widget.data.trendUp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 16,
            color: Colors.white,
          ),
          const Gap(4),
          Text(
            widget.data.trend!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Countup(
          begin: 0,
          end: widget.data.value.toDouble(),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          separator: ',',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            height: 1.0,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        if (widget.data.subtitle != null) ...[
          const Gap(4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.data.subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 32,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSparkline() {
    final data = widget.sparklineData!;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return SizedBox(
      height: 30,
      child: CustomPaint(
        size: const Size(double.infinity, 30),
        painter: _SparklinePainter(
          data: data,
          minValue: minValue,
          range: range == 0 ? 1 : range,
          lineColor: Colors.white.withOpacity(0.6),
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}

/// Painter para el patrón de puntos del fondo
class _DotPatternPainter extends CustomPainter {
  final Color color;

  _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para el sparkline mini-chart
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final double minValue;
  final double range;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter({
    required this.data,
    required this.minValue,
    required this.range,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Widget para mostrar skeleton loading de las stat cards
class StatCardSkeleton extends StatelessWidget {
  final bool isMobile;

  const StatCardSkeleton({Key? key, this.isMobile = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 120 : 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.of(context).tertiaryBackground,
            AppTheme.of(context).secondaryBackground,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Gap(8),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
