import 'package:agelink_venture/core/data/mock_data_store.dart';
import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/features/dashboard/widgets/collection_rate_chart.dart';
import 'package:agelink_venture/features/dashboard/widgets/dashboard_card.dart';
import 'package:agelink_venture/features/dashboard/widgets/dashboard_header.dart';
import 'package:agelink_venture/features/dashboard/widgets/daily_collection_chart.dart';
import 'package:agelink_venture/features/dashboard/widgets/top_managers_panel.dart';
import 'package:agelink_venture/sharedwidgets/kpi_card.dart';
import 'package:agelink_venture/sharedwidgets/status_badge.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:agelink_venture/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _store = MockDataStore.instance;
  DateTime _selectedDate = DateTime.now();
  String? _selectedManagerId;

  @override
  void initState() {
    super.initState();
    _store.ensureSeeded();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  List<KpiMetric> _primaryKpis(DashboardKpis k) => [
        KpiMetric(
          label: 'Total Active Loans',
          value: formatCurrency(k.totalActiveLoans),
          icon: Icons.account_balance_wallet_outlined,
        ),
        KpiMetric(
          label: "Today's Expected",
          value: formatCurrency(k.expectedToday),
          icon: Icons.event_outlined,
        ),
        KpiMetric(
          label: "Today's Collection",
          value: formatCurrency(k.collectedToday),
          icon: Icons.payments_outlined,
          iconColor: AppColors.success,
          iconBackground: AppColors.success.withValues(alpha: 0.1),
        ),
        KpiMetric(
          label: 'Outstanding Collection',
          value: formatCurrency(k.outstandingCollection),
          icon: Icons.timelapse_outlined,
          iconColor: AppColors.warning,
          iconBackground: AppColors.warning.withValues(alpha: 0.1),
        ),
      ];

  List<KpiMetric> _secondaryKpis(DashboardKpis k) => [
        KpiMetric(
          label: 'Bank Credits Today',
          value: formatCurrency(k.bankCreditsToday),
          icon: Icons.account_balance_outlined,
        ),
        KpiMetric(
          label: 'Unreconciled',
          value: formatCurrency(k.unreconciledAmount),
          icon: Icons.compare_arrows,
          iconColor: AppColors.danger,
          iconBackground: AppColors.danger.withValues(alpha: 0.1),
          valueColor: AppColors.danger,
        ),
        KpiMetric(
          label: 'Overdue Loans',
          value: formatCurrency(k.overdueLoans),
          icon: Icons.error_outline,
          iconColor: AppColors.danger,
          iconBackground: AppColors.danger.withValues(alpha: 0.1),
          valueColor: AppColors.danger,
        ),
        KpiMetric(
          label: 'Customers / Managers',
          value: '${k.activeCustomers} / ${k.accountManagers}',
          icon: Icons.people_outline,
          caption: 'Active portfolio',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final kpis = _store.dashboardKpis(managerId: _selectedManagerId);
    final snapshot = _store.collectionSnapshot(managerId: _selectedManagerId);
    final trend = _store.dailyCollectionTrend(managerId: _selectedManagerId);
    final topManagers = _store.topPerformingManagers(limit: 5);
    final overdue = _store.overdueCustomers(
      limit: 5,
      managerId: _selectedManagerId,
    );
    final managers = _store.managers.where((m) => m.isActive).toList();
    final isCompact = Responsive.isCompact(context);
    final horizontalPadding = MediaQuery.sizeOf(context).width > 1400
        ? AppSpacing.xl
        : AppSpacing.lg;

    return Container(
      color: AppColors.pageBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.lg,
          horizontalPadding,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(
              dateLabel: formatDate(_selectedDate),
              onPickDate: _pickDate,
              managers: managers,
              selectedManagerId: _selectedManagerId,
              onManagerChanged: (v) => setState(() => _selectedManagerId = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            CollectionHeroStrip(
              snapshot: snapshot,
              dateLabel: formatDate(_selectedDate),
            ),
            const SizedBox(height: AppSpacing.md),
            KpiRow(metrics: _primaryKpis(kpis)),
            const SizedBox(height: AppSpacing.sm),
            KpiRow(metrics: _secondaryKpis(kpis)),
            const SizedBox(height: AppSpacing.md),
            if (isCompact)
              _ChartsColumn(
                trend: trend,
                snapshot: snapshot,
                topManagers: topManagers,
                onManagerTap: (id) => context.go('/managers/$id/customers'),
                onViewAllManagers: () => context.go('/managers'),
              )
            else
              SizedBox(
                height: 380,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DashboardCard(
                        title: 'Daily Collection Trend',
                        subtitle: 'Collected vs expected · last 14 days',
                        contentGap: AppLayout.chartCardHeaderGap,
                        expandContent: true,
                        child: DailyCollectionChart(points: trend),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              title: "Today's Breakdown",
                              subtitle: 'Collection attainment',
                              expandContent: true,
                              child: CollectionRateChart(snapshot: snapshot),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: DashboardCard(
                              title: 'Reconciliation',
                              subtitle: 'Collections vs bank',
                              expandContent: true,
                              child: ReconciliationPanel(snapshot: snapshot),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (!isCompact)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Top Performing Managers',
                        subtitle: 'Ranked by today\'s collection rate',
                        actionLabel: 'View all',
                        onActionTap: () => context.go('/managers'),
                        child: TopManagersPanel(
                          entries: topManagers,
                          onManagerTap: (id) =>
                              context.go('/managers/$id/customers'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DashboardCard(
                        title: 'Overdue Customers',
                        subtitle: 'Highest outstanding balances',
                        actionLabel: 'View managers',
                        onActionTap: () => context.go('/managers'),
                        child: overdue.isEmpty
                            ? Text(
                                'No overdue customers in current filter.',
                                style: AppTextStyles.dashboardSubtitle,
                              )
                            : _OverdueList(
                                customers: overdue,
                                store: _store,
                                onCustomerTap: (id) =>
                                    context.go('/customers/$id'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isCompact) ...[
              DashboardCard(
                title: 'Top Performing Managers',
                subtitle: 'Ranked by today\'s collection rate',
                child: TopManagersPanel(
                  entries: topManagers,
                  onManagerTap: (id) => context.go('/managers/$id/customers'),
                  onViewAll: () => context.go('/managers'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartsColumn extends StatelessWidget {
  const _ChartsColumn({
    required this.trend,
    required this.snapshot,
    required this.topManagers,
    required this.onManagerTap,
    required this.onViewAllManagers,
  });

  final List<DailyTrendPoint> trend;
  final CollectionSnapshot snapshot;
  final List<ManagerRankEntry> topManagers;
  final ValueChanged<String> onManagerTap;
  final VoidCallback onViewAllManagers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardCard(
          title: 'Daily Collection Trend',
          subtitle: 'Collected vs expected · last 14 days',
          contentHeight: AppLayout.chartContentHeight,
          contentGap: AppLayout.chartCardHeaderGap,
          child: DailyCollectionChart(points: trend),
        ),
        const SizedBox(height: AppSpacing.md),
        DashboardCard(
          title: "Today's Breakdown",
          child: SizedBox(
            height: 220,
            child: CollectionRateChart(snapshot: snapshot),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DashboardCard(
          title: 'Reconciliation',
          child: ReconciliationPanel(snapshot: snapshot),
        ),
        const SizedBox(height: AppSpacing.md),
        DashboardCard(
          title: 'Top Performing Managers',
          child: TopManagersPanel(
            entries: topManagers,
            onManagerTap: onManagerTap,
            onViewAll: onViewAllManagers,
          ),
        ),
      ],
    );
  }
}

class _OverdueList extends StatelessWidget {
  const _OverdueList({
    required this.customers,
    required this.store,
    required this.onCustomerTap,
  });

  final List<Customer> customers;
  final MockDataStore store;
  final ValueChanged<String> onCustomerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: customers.map((c) {
        final manager = store.managerById(c.managerId);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCustomerTap(c.id),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: AppTextStyles.tableCell.copyWith(fontSize: 14),
                        ),
                        Text(
                          '${manager?.name ?? c.managerId} · ${c.id}',
                          style: AppTextStyles.kpiTrendMuted,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(c.totalOutstanding),
                    style: AppTextStyles.tableCell.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 8),
                  customerStatusBadge('Overdue'),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
