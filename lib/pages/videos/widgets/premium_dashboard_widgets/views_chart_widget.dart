import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:gap/gap.dart';
import 'package:energy_media/theme/theme.dart';

/// Model para los datos del chart
class ChartDataPoint {
  final String label;
  final double value;
  final Color? color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Widget de gráfica premium para reproducciones usando la librería Graphic
class PremiumViewsChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool showLegend;
  final ChartType chartType;

  const PremiumViewsChart({
    Key? key,
    required this.data,
    this.title = 'Reproducciones Semanales',
    this.icon = Icons.bar_chart_rounded,
    this.iconColor = const Color(0xFFFFB733),
    this.showLegend = false,
    this.chartType = ChartType.bar,
  }) : super(key: key);

  @override
  State<PremiumViewsChart> createState() => _PremiumViewsChartState();
}

enum ChartType { bar, line, area }

class _PremiumViewsChartState extends State<PremiumViewsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ChartType _currentChartType = ChartType.bar;

  @override
  void initState() {
    super.initState();
    _currentChartType = widget.chartType;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon con gradiente
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.iconColor.withOpacity(0.2),
                  widget.iconColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: widget.iconColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: 24,
            ),
          ),
          const Gap(16),
          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTheme.of(context).title3.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const Gap(2),
                Text(
                  'Últimos 7 días',
                  style: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).tertiaryText,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          // Toggle de tipo de chart
          _buildChartTypeToggle(),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: Icons.bar_chart_rounded,
            isSelected: _currentChartType == ChartType.bar,
            onTap: () => setState(() => _currentChartType = ChartType.bar),
          ),
          _buildToggleButton(
            icon: Icons.show_chart_rounded,
            isSelected: _currentChartType == ChartType.line,
            onTap: () => setState(() => _currentChartType = ChartType.line),
          ),
          _buildToggleButton(
            icon: Icons.area_chart_rounded,
            isSelected: _currentChartType == ChartType.area,
            onTap: () => setState(() => _currentChartType = ChartType.area),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : AppTheme.of(context).tertiaryText,
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    final isMobile = MediaQuery.of(context).size.width <= 800;

    if (isMobile) {
      // Móvil: altura fija
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 24, 24),
        child: SizedBox(
          height: 220,
          child: _buildSimpleBarChart(),
        ),
      );
    } else {
      // Desktop: expandir para llenar espacio disponible
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 24, 24),
          child: _buildSimpleBarChart(),
        ),
      );
    }
  }

  /// Chart simple sin dependencias problemáticas
  Widget _buildSimpleBarChart() {
    final primaryColor = AppTheme.of(context).primaryColor;
    final secondaryColor = AppTheme.of(context).secondaryColor;
    final tertiaryText = AppTheme.of(context).tertiaryText;

    final maxValue =
        widget.data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: widget.data.map((point) {
        final heightPercent = maxValue > 0 ? point.value / maxValue : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tooltip con valor
                Text(
                  point.value.toInt().toString(),
                  style: TextStyle(
                    color: tertiaryText,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                // Barra
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  height: 160 * heightPercent,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                // Label del día
                Text(
                  point.label,
                  style: TextStyle(
                    color: tertiaryText,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGraphicChart(List<Map<String, dynamic>> chartData) {
    final primaryColor = AppTheme.of(context).primaryColor;
    final secondaryColor = AppTheme.of(context).secondaryColor;
    final tertiaryText = AppTheme.of(context).tertiaryText;

    switch (_currentChartType) {
      case ChartType.line:
        return Chart(
          key: const ValueKey('line'),
          data: chartData,
          variables: {
            'day': Variable(
              accessor: (Map datum) => datum['day'] as String,
            ),
            'views': Variable(
              accessor: (Map datum) => datum['views'] as num,
              scale: LinearScale(min: 0),
            ),
          },
          marks: [
            LineMark(
              shape: ShapeEncode(value: BasicLineShape(smooth: true)),
              size: SizeEncode(value: 3),
              color: ColorEncode(value: primaryColor),
            ),
            PointMark(
              size: SizeEncode(value: 8),
              color: ColorEncode(value: primaryColor),
            ),
          ],
          axes: [
            Defaults.horizontalAxis
              ..label = LabelStyle(
                textStyle: TextStyle(
                  color: tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            Defaults.verticalAxis
              ..label = LabelStyle(
                textStyle: TextStyle(
                  color: tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              )
              ..grid = Defaults.strokeStyle,
          ],
          selections: {
            'touchMove': PointSelection(
              on: {
                GestureType.hover,
                GestureType.scaleUpdate,
                GestureType.tapDown,
              },
              dim: Dim.x,
            ),
          },
          tooltip: TooltipGuide(
            backgroundColor: AppTheme.of(context).secondaryBackground,
            elevation: 8,
            textStyle: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          crosshair: CrosshairGuide(
            styles: [
              PaintStyle(strokeColor: primaryColor.withOpacity(0.3)),
            ],
          ),
        );

      case ChartType.area:
        return Chart(
          key: const ValueKey('area'),
          data: chartData,
          variables: {
            'day': Variable(
              accessor: (Map datum) => datum['day'] as String,
            ),
            'views': Variable(
              accessor: (Map datum) => datum['views'] as num,
              scale: LinearScale(min: 0),
            ),
          },
          marks: [
            AreaMark(
              shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
              gradient: GradientEncode(
                value: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.4),
                    secondaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            LineMark(
              shape: ShapeEncode(value: BasicLineShape(smooth: true)),
              size: SizeEncode(value: 2.5),
              color: ColorEncode(value: primaryColor),
            ),
          ],
          axes: [
            Defaults.horizontalAxis
              ..label = LabelStyle(
                textStyle: TextStyle(
                  color: tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            Defaults.verticalAxis
              ..label = LabelStyle(
                textStyle: TextStyle(
                  color: tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              )
              ..grid = Defaults.strokeStyle,
          ],
          selections: {
            'touchMove': PointSelection(
              on: {
                GestureType.hover,
                GestureType.scaleUpdate,
                GestureType.tapDown,
              },
              dim: Dim.x,
            ),
          },
          tooltip: TooltipGuide(
            backgroundColor: AppTheme.of(context).secondaryBackground,
            elevation: 8,
            textStyle: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          crosshair: CrosshairGuide(
            styles: [
              PaintStyle(strokeColor: primaryColor.withOpacity(0.3)),
            ],
          ),
        );

      case ChartType.bar:
      default:
        return Chart(
          key: const ValueKey('bar'),
          data: chartData,
          variables: {
            'day': Variable(
              accessor: (Map datum) => datum['day'] as String,
            ),
            'views': Variable(
              accessor: (Map datum) => datum['views'] as num,
              scale: LinearScale(min: 0),
            ),
          },
          marks: [
            IntervalMark(
              size: SizeEncode(value: 24),
              gradient: GradientEncode(
                value: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                ),
              ),
            ),
          ],
          axes: [
            Defaults.horizontalAxis
              ..label = LabelStyle(
                textStyle: TextStyle(
                  color: tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            Defaults.verticalAxis
              ..label = LabelStyle(
                textStyle: TextStyle(
                  color: tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              )
              ..grid = Defaults.strokeStyle,
          ],
          selections: {
            'tap': PointSelection(
              on: {
                GestureType.hover,
                GestureType.tapDown,
              },
            ),
          },
          tooltip: TooltipGuide(
            backgroundColor: AppTheme.of(context).secondaryBackground,
            elevation: 8,
            textStyle: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: AppTheme.of(context).tertiaryText,
            ),
            const Gap(16),
            Text(
              'No hay datos disponibles',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).tertiaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget alternativo usando FL_Chart si prefieres mantenerlo más simple
class SimpleBarChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color barColor;
  final Color? gradientEndColor;

  const SimpleBarChart({
    Key? key,
    required this.data,
    this.barColor = const Color(0xFF4EC9F5),
    this.gradientEndColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Este es un placeholder simple - podrías implementar con FL_Chart aquí
    return Container(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((point) {
          final maxValue =
              data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
          final heightPercent = maxValue > 0 ? point.value / maxValue : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: 150 * heightPercent,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      barColor,
                      gradientEndColor ?? barColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
              const Gap(8),
              Text(
                point.label,
                style: TextStyle(
                  color: AppTheme.of(context).tertiaryText,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
