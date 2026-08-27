import 'dart:math' as math;

import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CollectionRateChart extends StatefulWidget {
  const CollectionRateChart({super.key, required this.snapshot});

  final CollectionSnapshot snapshot;

  @override
  State<CollectionRateChart> createState() => _CollectionRateChartState();
}

class _CollectionRateChartState extends State<CollectionRateChart> {
  int? _hoveredIndex;

  List<_Segment> _segments() {
    final list = <_Segment>[
      _Segment('Collected', widget.snapshot.collected, AppColors.success),
      _Segment('Outstanding', widget.snapshot.outstanding, AppColors.warning),
    ];
    if (widget.snapshot.unreconciled > 0) {
      list.add(
        _Segment('Unreconciled', widget.snapshot.unreconciled, AppColors.danger),
      );
    }
    return list.where((s) => s.value > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final segments = _segments();
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    final ratePercent = (widget.snapshot.attainmentRate * 100).round();
    final hovered = _safeHoveredIndex(segments);

    if (segments.isEmpty || total <= 0) {
      return Center(
        child: Text(
          'No collection data for today',
          style: AppTextStyles.dashboardSubtitle,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDim = math.max(constraints.maxHeight, 0);
        final chartSize = math
            .min(maxDim > 48 ? maxDim - 8 : maxDim, constraints.maxWidth * 0.45)
            .clamp(72.0, 200.0)
            .toDouble();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 48,
              child: Center(
                child: SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 2,
                          centerSpaceRadius: chartSize * 0.36,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response?.touchedSection == null) {
                                setState(() => _hoveredIndex = null);
                                return;
                              }
                              final index =
                                  response!.touchedSection!.touchedSectionIndex;
                              if (index < 0 || index >= segments.length) {
                                setState(() => _hoveredIndex = null);
                                return;
                              }
                              setState(() => _hoveredIndex = index);
                            },
                          ),
                          sections: [
                            for (var i = 0; i < segments.length; i++)
                              PieChartSectionData(
                                value: segments[i].value,
                                color: segments[i].color,
                                radius: hovered == i
                                    ? chartSize * 0.38
                                    : chartSize * 0.34,
                                title: '',
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hovered != null
                                ? formatCurrency(segments[hovered].value)
                                : '$ratePercent%',
                            style: AppTextStyles.chartCenterTotal.copyWith(
                              fontSize: hovered != null ? 20 : 26,
                            ),
                          ),
                          Text(
                            hovered != null
                                ? segments[hovered].label
                                : 'attained',
                            style: AppTextStyles.chartCenterLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final seg in segments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LegendRow(
                        color: seg.color,
                        label: seg.label,
                        value: formatCurrency(seg.value),
                        percent: total > 0 ? seg.value / total : 0,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  int? _safeHoveredIndex(List<_Segment> segments) {
    if (_hoveredIndex == null) return null;
    if (_hoveredIndex! < 0 || _hoveredIndex! >= segments.length) return null;
    return _hoveredIndex;
  }
}

class _Segment {
  _Segment(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  final Color color;
  final String label;
  final String value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: AppTextStyles.chartAxisLabel),
            ),
            Text(value, style: AppTextStyles.tableCell),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percent.clamp(0, 1),
            minHeight: 4,
            backgroundColor: AppColors.border,
            color: color,
          ),
        ),
      ],
    );
  }
}
