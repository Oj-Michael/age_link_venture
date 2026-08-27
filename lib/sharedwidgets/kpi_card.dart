import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:flutter/material.dart';

class KpiMetric {
  const KpiMetric({
    required this.label,
    required this.value,
    this.icon = Icons.analytics_outlined,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.badgePink,
    this.valueColor = AppColors.textPrimary,
    this.caption,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color valueColor;
  final String? caption;
  final bool isLoading;
}

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.metric});

  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppLayout.kpiCardMinHeight),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.kpiCardPaddingH,
            vertical: AppLayout.kpiCardPaddingV,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: metric.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, color: metric.iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.label,
                      style: AppTextStyles.kpiLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (metric.isLoading)
                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    else
                      Text(
                        metric.value,
                        style: AppTextStyles.kpiValue.copyWith(
                          color: metric.valueColor,
                        ),
                      ),
                    if (metric.caption != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        metric.caption!,
                        style: AppTextStyles.kpiTrendMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.metrics});

  final List<KpiMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < metrics.length; i += 2) ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KpiCard(metric: metrics[i]),
                      if (i + 1 < metrics.length) ...[
                        const SizedBox(width: AppSpacing.sm),
                        KpiCard(metric: metrics[i + 1]),
                      ],
                    ],
                  ),
                ),
                if (i + 2 < metrics.length) const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                KpiCard(metric: metrics[i]),
                if (i < metrics.length - 1) const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }
}
