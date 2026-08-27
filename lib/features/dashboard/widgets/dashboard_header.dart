import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.dateLabel,
    required this.onPickDate,
    required this.managers,
    required this.selectedManagerId,
    required this.onManagerChanged,
  });

  final String dateLabel;
  final VoidCallback onPickDate;
  final List<AccountManager> managers;
  final String? selectedManagerId;
  final ValueChanged<String?> onManagerChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Owner Dashboard', style: AppTextStyles.dashboardTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Real-time financial position across lending & collections',
                style: AppTextStyles.dashboardSubtitle,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _FilterCluster(
          dateLabel: dateLabel,
          onPickDate: onPickDate,
          managers: managers,
          selectedManagerId: selectedManagerId,
          onManagerChanged: onManagerChanged,
        ),
      ],
    );
  }
}

class _FilterCluster extends StatelessWidget {
  const _FilterCluster({
    required this.dateLabel,
    required this.onPickDate,
    required this.managers,
    required this.selectedManagerId,
    required this.onManagerChanged,
  });

  final String dateLabel;
  final VoidCallback onPickDate;
  final List<AccountManager> managers;
  final String? selectedManagerId;
  final ValueChanged<String?> onManagerChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(dateLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String?>(
              initialValue: selectedManagerId,
              isDense: true,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Account Manager',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All managers', overflow: TextOverflow.ellipsis),
                ),
                ...managers.map(
                  (m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: onManagerChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionHeroStrip extends StatelessWidget {
  const CollectionHeroStrip({
    super.key,
    required this.snapshot,
    required this.dateLabel,
  });

  final CollectionSnapshot snapshot;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final rate = snapshot.attainmentRate;
    final ratePercent = (rate * 100).round();
    final isNarrow = MediaQuery.sizeOf(context).width < 900;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.primary, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 20 : 28,
        vertical: 20,
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroMain(snapshot: snapshot, dateLabel: dateLabel),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeroMetric(
                      label: 'Outstanding',
                      value: formatCurrency(snapshot.outstanding),
                    ),
                    const SizedBox(width: 24),
                    _HeroMetric(
                      label: 'Bank Credits',
                      value: formatCurrency(snapshot.bankCredits),
                    ),
                    const Spacer(),
                    _AttainmentRing(rate: rate, ratePercent: ratePercent),
                  ],
                ),
              ],
            )
          : SizedBox(
              height: AppLayout.heroStripHeight,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _HeroMain(snapshot: snapshot, dateLabel: dateLabel),
                  ),
                  _HeroMetric(
                    label: 'Outstanding',
                    value: formatCurrency(snapshot.outstanding),
                  ),
                  const SizedBox(width: 24),
                  _HeroMetric(
                    label: 'Bank Credits',
                    value: formatCurrency(snapshot.bankCredits),
                  ),
                  const SizedBox(width: 32),
                  _AttainmentRing(rate: rate, ratePercent: ratePercent),
                ],
              ),
            ),
    );
  }
}

class _HeroMain extends StatelessWidget {
  const _HeroMain({required this.snapshot, required this.dateLabel});

  final CollectionSnapshot snapshot;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Today's Collection",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatCurrency(snapshot.collected),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Expected ${formatCurrency(snapshot.expected)} · $dateLabel',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _AttainmentRing extends StatelessWidget {
  const _AttainmentRing({required this.rate, required this.ratePercent});

  final double rate;
  final int ratePercent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: rate,
              strokeWidth: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$ratePercent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'attained',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
