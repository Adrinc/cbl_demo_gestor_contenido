import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:gap/gap.dart';

/// Widget de gráfico moderno usando Syncfusion para métricas del dashboard
class ModernChartWidget extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final ChartType chartType;

  const ModernChartWidget({
    Key? key,
    required this.title,
    required this.data,
    this.chartType = ChartType.area,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.of(context).hintText,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.of(context).subtitle2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const Gap(20),
          SizedBox(
            height: 250,
            child: _buildChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (chartType) {
      case ChartType.area:
        return _buildAreaChart(context);
      case ChartType.line:
        return _buildLineChart(context);
      case ChartType.column:
        return _buildColumnChart(context);
      case ChartType.spline:
        return _buildSplineChart(context);
      default:
        return _buildAreaChart(context);
    }
  }

  Widget _buildAreaChart(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppTheme.of(context).hintText.withOpacity(0.3),
        ),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      series: <CartesianSeries>[
        SplineAreaSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          onCreateShader: (ShaderDetails details) {
            return LinearGradient(
              colors: [
                AppTheme.of(context).primaryColor.withOpacity(0.5),
                AppTheme.of(context).primaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(details.rect);
          },
          borderColor: AppTheme.of(context).primaryColor,
          borderWidth: 3,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppTheme.of(context).secondaryBackground,
        textStyle: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppTheme.of(context).hintText.withOpacity(0.3),
        ),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      series: <CartesianSeries>[
        SplineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: AppTheme.of(context).primaryColor,
          width: 3,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: AppTheme.of(context).primaryColor,
            borderColor: Colors.white,
            borderWidth: 2,
            height: 8,
            width: 8,
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppTheme.of(context).secondaryBackground,
        textStyle: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildColumnChart(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppTheme.of(context).hintText.withOpacity(0.3),
        ),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          onCreateShader: (ShaderDetails details) {
            return LinearGradient(
              colors: [
                AppTheme.of(context).primaryColor,
                AppTheme.of(context).tertiaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(details.rect);
          },
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppTheme.of(context).secondaryBackground,
        textStyle: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSplineChart(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppTheme.of(context).hintText.withOpacity(0.3),
        ),
        labelStyle: TextStyle(
          color: AppTheme.of(context).secondaryText,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
      series: <CartesianSeries>[
        SplineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          onCreateShader: (ShaderDetails details) {
            return LinearGradient(
              colors: [
                AppTheme.of(context).primaryColor,
                AppTheme.of(context).secondaryColor,
              ],
            ).createShader(details.rect);
          },
          width: 4,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: AppTheme.of(context).secondaryColor,
            borderColor: Colors.white,
            borderWidth: 2,
            height: 10,
            width: 10,
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppTheme.of(context).secondaryBackground,
        textStyle: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Modelo de datos para los gráficos
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

/// Tipos de gráfico disponibles
enum ChartType {
  area,
  line,
  column,
  spline,
}
