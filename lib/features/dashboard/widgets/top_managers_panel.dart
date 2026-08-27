import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:flutter/material.dart';

class TopManagersPanel extends StatelessWidget {
  const TopManagersPanel({
    super.key,
    required this.entries,
    required this.onManagerTap,
    this.onViewAll,
  });

  final List<ManagerRankEntry> entries;
  final ValueChanged<String> onManagerTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text('No manager data', style: AppTextStyles.dashboardSubtitle);
    }

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _ManagerRankTile(
            rank: i + 1,
            entry: entries[i],
            onTap: () => onManagerTap(entries[i].manager.id),
          ),
          if (i < entries.length - 1) const SizedBox(height: 12),
        ],
        if (onViewAll != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onViewAll, child: const Text('View all managers →')),
          ),
        ],
      ],
    );
  }
}

class _ManagerRankTile extends StatelessWidget {
  const _ManagerRankTile({
    required this.rank,
    required this.entry,
    required this.onTap,
  });

  final int rank;
  final ManagerRankEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rate = entry.collectionRate.clamp(0.0, 1.0);
    final rateLabel = '${(rate * 100).round()}%';
    final isTop = rank == 1;

    return Material(
      color: isTop
          ? AppColors.badgePink.withValues(alpha: 0.5)
          : AppColors.pageBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _RankBadge(rank: rank, isTop: isTop),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.manager.name,
                            style: AppTextStyles.tableCell.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          rateLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isTop ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatCurrency(entry.stats.collectedToday)} collected · ${entry.stats.overdueCount} overdue',
                      style: AppTextStyles.kpiTrendMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: isTop ? AppColors.primary : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.isTop});

  final int rank;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isTop ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isTop ? AppColors.primary : AppColors.border,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: isTop ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class ReconciliationPanel extends StatelessWidget {
  const ReconciliationPanel({super.key, required this.snapshot});

  final CollectionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final hasIssue = snapshot.unreconciled > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ReconMetric(
                label: 'AM collections',
                value: formatCurrency(snapshot.collected),
                color: AppColors.primary,
                fraction: 1.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ReconMetric(
                label: 'Bank credits',
                value: formatCurrency(snapshot.bankCredits),
                color: AppColors.success,
                fraction: snapshot.collected > 0
                    ? snapshot.bankCredits / snapshot.collected
                    : 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ReconMetric(
                label: 'Unreconciled',
                value: formatCurrency(snapshot.unreconciled),
                color: AppColors.danger,
                fraction: snapshot.collected > 0
                    ? snapshot.unreconciled / snapshot.collected
                    : 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasIssue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${formatCurrency(snapshot.unreconciled)} needs reconciliation review.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text(
                'Collections aligned with bank credits',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ReconMetric extends StatelessWidget {
  const _ReconMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.fraction,
  });

  final String label;
  final String value;
  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.chartAxisLabel),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.tableCell.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 6,
            backgroundColor: AppColors.border,
            color: color,
          ),
        ),
      ],
    );
  }
}
