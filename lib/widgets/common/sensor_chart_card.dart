import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/sensor_reading_model.dart';
import 'loading_shimmer.dart';

enum SensorTipo { temperatura, humedad, humedadGrano }

extension SensorTipoExtension on SensorTipo {
  String get titulo => switch (this) {
        SensorTipo.temperatura => 'Temperatura',
        SensorTipo.humedad => 'Humedad Ambiental',
        SensorTipo.humedadGrano => 'Humedad del Grano',
      };

  String get unidad => switch (this) {
        SensorTipo.temperatura => '°C',
        _ => '%',
      };

  Color get color => switch (this) {
        SensorTipo.temperatura => AppColors.chartTemperatura,
        SensorTipo.humedad => AppColors.chartHumedad,
        SensorTipo.humedadGrano => AppColors.chartHumedadGrano,
      };

  IconData get icono => switch (this) {
        SensorTipo.temperatura => Icons.thermostat_rounded,
        SensorTipo.humedad => Icons.water_drop_outlined,
        SensorTipo.humedadGrano => Icons.grass_rounded,
      };

  double Function(SensorReadingModel) get extractor => switch (this) {
        SensorTipo.temperatura => (r) => r.temperatura,
        SensorTipo.humedad => (r) => r.humedad,
        SensorTipo.humedadGrano => (r) => r.humedadGrano,
      };
}

class SensorChartCard extends StatelessWidget {
  final SensorTipo tipo;
  final List<SensorReadingModel> lecturas;
  final bool estaCargando;
  final double? valorActual;

  const SensorChartCard({
    super.key,
    required this.tipo,
    required this.lecturas,
    this.estaCargando = false,
    this.valorActual,
  });

  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const LoadingShimmer(
          width: double.infinity, height: AppDimensions.chartHeight + 60);
    }

    final color = tipo.color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tipo.icono, size: 16, color: color),
                const SizedBox(width: 6),
                Text(tipo.titulo,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (valorActual != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${valorActual!.toStringAsFixed(1)}${tipo.unidad}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (lecturas.isEmpty)
              SizedBox(
                height: AppDimensions.chartHeight,
                child: Center(
                  child: Text('Sin datos',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              )
            else
              SizedBox(
                height: AppDimensions.chartHeight,
                child: _buildChart(color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(Color color) {
    final spots = _toSpots();
    if (spots.isEmpty) return const SizedBox();

    final values = spots.map((s) => s.y).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();
    final yInterval = ((maxY - minY) / 4).ceilToDouble().clamp(1.0, 50.0);

    final xMin = spots.first.x;
    final xMax = spots.last.x;
    final xInterval = ((xMax - xMin) / 4).floorToDouble();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.borde, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: yInterval,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '${value.toStringAsFixed(0)}${tipo.unidad}',
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textoSecundario),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: xInterval > 0 ? xInterval : null,
              getTitlesWidget: (value, _) {
                final dt =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormatter.hora(dt),
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textoSecundario),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withAlpha(25),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textoPrimario.withAlpha(220),
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}${tipo.unidad}',
                      TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _toSpots() {
    return lecturas
        .map((r) => FlSpot(
              r.timestamp.millisecondsSinceEpoch.toDouble(),
              tipo.extractor(r),
            ))
        .toList();
  }
}
