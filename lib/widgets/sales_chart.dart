import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SalesChart extends StatelessWidget {
  final List<FlSpot> spots;
  final double maxY;

  const SalesChart({super.key, required this.spots, required this.maxY});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: AppTheme.light, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value < 1 || value > 30) return const SizedBox.shrink();
                return Text(
                  'Dia ${value.toInt()}',
                  style: const TextStyle(color: AppTheme.gray, fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$ ${value.toInt()}',
                  style: const TextStyle(color: AppTheme.gray, fontSize: 10),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 30,
        minY: 0,
        maxY: maxY * 1.2, // Add some buffer
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.secondary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.secondary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
