import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:flutter/material.dart';

class CollectionRateChart extends StatelessWidget {
  const CollectionRateChart({super.key, required this.snapshot});

  final CollectionSnapshot snapshot;

  static int _percentOf(double value, double total) {
    if (total <= 0) return 0;
    return (value / total * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final expected = snapshot.expected;
    final ratePercent = (snapshot.attainmentRate * 100).round();

    if (expected <= 0) {
      return Center(
        child: Text(
          'No collection data for today',
          style: AppTextStyles.dashboardSubtitle,
        ),
      );
    }

    final collected =
        snapshot.collected.clamp(0, expected).toDouble();
    final outstanding =
        snapshot.outstanding.clamp(0, expected).toDouble();
    final unreconciled =
        snapshot.unreconciled.clamp(0, collected).toDouble();
    final verifiedCollected = collected - unreconciled;

    final rows = <_ValueRowData>[
      _ValueRowData(
        label: 'Collected',
        value: formatCurrency(collected),
        color: AppColors.success,
        sharePercent: _percentOf(collected, expected),
      ),
      _ValueRowData(
        label: 'Outstanding',
        value: formatCurrency(outstanding),
        color: AppColors.warning,
        sharePercent: _percentOf(outstanding, expected),
      ),
      if (unreconciled > 0)
        _ValueRowData(
          label: 'Unreconciled',
          value: formatCurrency(unreconciled),
          color: AppColors.danger,
          sharePercent: _percentOf(unreconciled, expected),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$ratePercent%',
                  style: AppTextStyles.chartCenterTotal.copyWith(fontSize: 36),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'attained today',
                    style: AppTextStyles.chartCenterLabel.copyWith(fontSize: 12),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Expected', style: AppTextStyles.chartAxisLabel),
                    Text(
                      formatCurrency(expected),
                      style: AppTextStyles.tableCell.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AttainmentBar(
              width: constraints.maxWidth,
              expected: expected,
              verifiedCollected: verifiedCollected,
              unreconciled: unreconciled,
              outstanding: outstanding,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final row in rows)
                  _StackLegendDot(color: row.color, label: row.label),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final row in rows)
                    _ValueRow(
                      color: row.color,
                      value: row.value,
                      sharePercent: row.sharePercent,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AttainmentBar extends StatelessWidget {
  const _AttainmentBar({
    required this.width,
    required this.expected,
    required this.verifiedCollected,
    required this.unreconciled,
    required this.outstanding,
  });

  final double width;
  final double expected;
  final double verifiedCollected;
  final double unreconciled;
  final double outstanding;

  double _segmentWidth(double value) {
    if (expected <= 0 || value <= 0 || width <= 0) return 0;
    return width * (value / expected);
  }

  @override
  Widget build(BuildContext context) {
    final greenW = _segmentWidth(verifiedCollected);
    final redW = _segmentWidth(unreconciled);
    final orangeW = _segmentWidth(outstanding);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 24,
        width: width,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (greenW > 0)
              Positioned(
                left: 0,
                width: greenW,
                top: 0,
                bottom: 0,
                child: const ColoredBox(color: AppColors.success),
              ),
            if (redW > 0)
              Positioned(
                left: greenW,
                width: redW,
                top: 0,
                bottom: 0,
                child: const ColoredBox(color: AppColors.danger),
              ),
            if (orangeW > 0)
              Positioned(
                left: greenW + redW,
                width: orangeW,
                top: 0,
                bottom: 0,
                child: const ColoredBox(color: AppColors.warning),
              ),
          ],
        ),
      ),
    );
  }
}

class _ValueRowData {
  const _ValueRowData({
    required this.label,
    required this.value,
    required this.color,
    required this.sharePercent,
  });

  final String label;
  final String value;
  final Color color;
  final int sharePercent;
}

class _StackLegendDot extends StatelessWidget {
  const _StackLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.chartAxisLabel.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.color,
    required this.value,
    required this.sharePercent,
  });

  final Color color;
  final String value;
  final int sharePercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.tableCell.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$sharePercent%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
