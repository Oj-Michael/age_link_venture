import 'dart:math' as math;

import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyCollectionChart extends StatelessWidget {
  const DailyCollectionChart({super.key, required this.points});

  final List<DailyTrendPoint> points;

  static const _legendHeight = 24.0;

  String _formatAxisY(double value) {
    if (value <= 0) return '0';
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m >= 10 ? m.round() : m.toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return '${k >= 10 ? k.round() : k.toStringAsFixed(1)}K';
    }
    return value.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
        child: Text('No trend data', style: AppTextStyles.dashboardSubtitle),
      );
    }

    final maxVal = points
        .map((p) => math.max(p.expected, p.collected))
        .reduce(math.max);
    final interval = _niceInterval(maxVal);
    final maxY = (interval * ((maxVal / interval).ceil() + 1))
        .clamp(interval, double.infinity)
        .toDouble();

    LineChartBarData buildLineBar({
      required List<FlSpot> spots,
      required Color color,
      bool dashed = false,
    }) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: color,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            );
          },
        ),
        dashArray: dashed ? [6, 4] : null,
        belowBarData: BarAreaData(
          show: !dashed,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.02),
            ],
          ),
        ),
      );
    }

    final collectedSpots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].collected),
    ];
    final expectedSpots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].expected),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _legendHeight,
          child: Row(
            children: [
              _LegendDot(color: AppColors.primary, label: 'Collected'),
              const SizedBox(width: 20),
              _LegendDot(
                color: AppColors.textMuted,
                label: 'Expected',
                dashed: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble().clamp(1, double.infinity),
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 1,
                checkToShowVerticalLine: (value) {
                  if (value != value.roundToDouble()) return false;
                  final index = value.toInt();
                  return index >= 0 && index < points.length;
                },
                getDrawingVerticalLine: (value) => FlLine(
                  color: AppColors.border.withValues(alpha: 0.6),
                  strokeWidth: 1,
                ),
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      if (value != index.toDouble()) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 4,
                        child: Text(
                          points[index].label,
                          style: AppTextStyles.chartAxisLabel.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: AppLayout.chartYAxisReservedSize,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      if ((value / interval - (value / interval).round()).abs() >
                          0.001) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          _formatAxisY(value),
                          style: AppTextStyles.chartAxisLabel,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchSpotThreshold: 24,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, i) =>
                            FlDotCirclePainter(
                          radius: 5,
                          color: bar.color ?? AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.textPrimary,
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isExpected = spot.barIndex == 1;
                      final label = isExpected ? 'Expected' : 'Collected';
                      final color = isExpected
                          ? AppColors.textMuted
                          : AppColors.success;
                      return LineTooltipItem(
                        '$label  ${formatCurrency(spot.y)}',
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                buildLineBar(spots: collectedSpots, color: AppColors.primary),
                buildLineBar(
                  spots: expectedSpots,
                  color: AppColors.textMuted,
                  dashed: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static double _niceInterval(double maxValue) {
    if (maxValue <= 0) return 250;
    final rough = maxValue / 4;
    final exp = (math.log(rough) / math.ln10).floor();
    final magnitude = math.pow(10, exp).toDouble();
    final residual = rough / magnitude;
    final nice = residual <= 1
        ? 1.0
        : residual <= 2
            ? 2.0
            : residual <= 5
                ? 5.0
                : 10.0;
    return nice * magnitude;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            borderRadius: BorderRadius.circular(1),
            border: dashed
                ? Border(bottom: BorderSide(color: color, width: 2))
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.chartAxisLabel.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
