import 'package:agelink_venture/core/data/mock_data_store.dart';
import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/features/managers/widgets/add_manager_dialog.dart';
import 'package:agelink_venture/sharedwidgets/app_scrollable_data_table.dart';
import 'package:agelink_venture/sharedwidgets/kpi_card.dart';
import 'package:agelink_venture/sharedwidgets/pagination_bar.dart';
import 'package:agelink_venture/sharedwidgets/status_badge.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:agelink_venture/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagersScreen extends StatefulWidget {
  const ManagersScreen({super.key});

  @override
  State<ManagersScreen> createState() => _ManagersScreenState();
}

class _ManagersScreenState extends State<ManagersScreen> {
  static const _pageSize = 8;

  final _store = MockDataStore.instance;
  int _page = 0;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _store.ensureSeeded();
  }

  List<AccountManager> _filteredManagers() {
    final all = _store.managers;
    if (_search.isEmpty) return all;
    final q = _search.toLowerCase();
    return all
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.id.toLowerCase().contains(q) ||
              m.email.toLowerCase().contains(q) ||
              m.phone.contains(q),
        )
        .toList();
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const AddManagerDialog(),
    );
    if (created == true && mounted) {
      setState(() => _page = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account manager created successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredManagers();
    final totalPages =
        filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    if (_page >= totalPages) _page = totalPages - 1;

    final start = _page * _pageSize;
    final pageItems = filtered
        .skip(start)
        .take(_pageSize)
        .toList();

    final activeCount = filtered.where((m) => m.isActive).length;
    final totalCustomers = filtered.fold<int>(
      0,
      (sum, m) => sum + _store.customersForManager(m.id).length,
    );
    final collectedToday = filtered.fold<double>(
      0,
      (sum, m) => sum + _store.statsForManager(m.id).collectedToday,
    );

    return Container(
      color: AppColors.pageBackground,
      padding: Responsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Managers', style: AppTextStyles.pageTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Manage account managers and view customer portfolios',
                      style: AppTextStyles.pageSubtitle,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Manager'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          KpiRow(
            metrics: [
              KpiMetric(
                label: 'Total Managers',
                value: '${filtered.length}',
                icon: Icons.people_outline,
              ),
              KpiMetric(
                label: 'Active',
                value: '$activeCount',
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                iconBackground: AppColors.success.withValues(alpha: 0.1),
              ),
              KpiMetric(
                label: 'Customers',
                value: '$totalCustomers',
                icon: Icons.groups_outlined,
              ),
              KpiMetric(
                label: "Today's Collected",
                value: formatCurrency(collectedToday),
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, ID, email or phone',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() {
                        _search = '';
                        _page = 0;
                      }),
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() {
              _search = v;
              _page = 0;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: pageItems.isEmpty
                          ? Center(
                              child: Text(
                                _search.isEmpty
                                    ? 'No account managers yet.'
                                    : 'No managers match your search.',
                                style: AppTextStyles.dashboardSubtitle,
                              ),
                            )
                          : _ManagersTable(
                              managers: pageItems,
                              store: _store,
                              onViewCustomers: (id) =>
                                  context.go('/managers/$id/customers'),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: PaginationBar(
                      page: _page,
                      pageSize: _pageSize,
                      totalItems: filtered.length,
                      onPageChanged: (p) => setState(() => _page = p),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagersTable extends StatelessWidget {
  const _ManagersTable({
    required this.managers,
    required this.store,
    required this.onViewCustomers,
  });

  final List<AccountManager> managers;
  final MockDataStore store;
  final ValueChanged<String> onViewCustomers;

  @override
  Widget build(BuildContext context) {
    final columns = [
      AppScrollColumn(label: tableHeader('ID'), minWidth: 90),
      AppScrollColumn(label: tableHeader('Name'), minWidth: 150),
      AppScrollColumn(label: tableHeader('Email'), minWidth: 160),
      AppScrollColumn(label: tableHeader('Customers'), minWidth: 90),
      AppScrollColumn(label: tableHeader('Collected'), minWidth: 110),
      AppScrollColumn(label: tableHeader('Rate'), minWidth: 70),
      AppScrollColumn(label: tableHeader('Outstanding'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Status'), minWidth: 90),
      AppScrollColumn(label: tableHeader(''), minWidth: 110),
    ];

    final rows = managers.map((m) {
      final stats = store.statsForManager(m.id);
      final customerCount = store.customersForManager(m.id).length;
      final rate = stats.expectedToday > 0
          ? (stats.collectedToday / stats.expectedToday * 100).round()
          : 0;

      return AppScrollRow(
        onTap: () => onViewCustomers(m.id),
        cells: [
          tableCell(m.id),
          tableCell(m.name),
          tableCell(m.email),
          tableCell('$customerCount'),
          tableCell(formatCurrency(stats.collectedToday)),
          tableCell('$rate%'),
          tableCell(formatCurrency(stats.totalOutstanding)),
          customerStatusBadge(m.isActive ? 'Active' : 'Inactive'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onViewCustomers(m.id),
              child: const Text('Customers →'),
            ),
          ),
        ],
      );
    }).toList();

    return AppScrollableDataTable(columns: columns, rows: rows);
  }
}

class ManagerCustomersScreen extends StatefulWidget {
  const ManagerCustomersScreen({super.key, required this.managerId});

  final String managerId;

  @override
  State<ManagerCustomersScreen> createState() => _ManagerCustomersScreenState();
}

class _ManagerCustomersScreenState extends State<ManagerCustomersScreen> {
  final _store = MockDataStore.instance;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _store.ensureSeeded();
  }

  @override
  Widget build(BuildContext context) {
    final manager = _store.managerById(widget.managerId);
    if (manager == null) {
      return const Center(child: Text('Manager not found'));
    }

    final stats = _store.statsForManager(widget.managerId);
    var customers = _store.customersForManager(widget.managerId);
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      customers = customers
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.id.toLowerCase().contains(q),
          )
          .toList();
    }

    return Container(
      color: AppColors.pageBackground,
      child: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/managers'),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manager.name, style: AppTextStyles.pageTitle),
                      Text(
                        '${manager.id} · ${manager.territory ?? "No territory"}',
                        style: AppTextStyles.pageSubtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            KpiRow(
              metrics: [
                KpiMetric(
                  label: "Today's Expected",
                  value: formatCurrency(stats.expectedToday),
                  icon: Icons.event_outlined,
                ),
                KpiMetric(
                  label: "Today's Collected",
                  value: formatCurrency(stats.collectedToday),
                  icon: Icons.payments_outlined,
                ),
                KpiMetric(
                  label: 'Total Outstanding',
                  value: formatCurrency(stats.totalOutstanding),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                KpiMetric(
                  label: 'Overdue Customers',
                  value: '${stats.overdueCount}',
                  icon: Icons.warning_amber_outlined,
                  iconColor: AppColors.danger,
                  iconBackground: AppColors.danger.withValues(alpha: 0.1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or customer ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: 'Customers (${customers.length})',
              child: _CustomerTable(
                customers: customers,
                store: _store,
                onCustomerTap: (id) => context.go('/customers/$id'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerTable extends StatelessWidget {
  const _CustomerTable({
    required this.customers,
    required this.store,
    required this.onCustomerTap,
  });

  final List<Customer> customers;
  final MockDataStore store;
  final ValueChanged<String> onCustomerTap;

  @override
  Widget build(BuildContext context) {
    final columns = [
      AppScrollColumn(label: tableHeader('ID'), minWidth: 130),
      AppScrollColumn(label: tableHeader('Name'), minWidth: 140),
      AppScrollColumn(label: tableHeader('Phone'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Active Loan'), minWidth: 130),
      AppScrollColumn(label: tableHeader('Outstanding'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Next Payment'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Status'), minWidth: 100),
    ];

    final rows = customers.map((c) {
      return AppScrollRow(
        onTap: () => onCustomerTap(c.id),
        cells: [
          tableCell(c.id),
          tableCell(c.name),
          tableCell(c.phone),
          tableCell(c.activeLoanId),
          tableCell(formatCurrency(c.totalOutstanding)),
          tableCell(formatDate(c.nextPaymentDate)),
          customerStatusBadge(_statusLabel(c.status)),
        ],
      );
    }).toList();

    if (rows.isEmpty) {
      return const Text('No customers match your search.');
    }

    return AppScrollableDataTable(columns: columns, rows: rows);
  }

  String _statusLabel(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.overdue:
        return 'Overdue';
      case CustomerStatus.completed:
        return 'Completed';
      case CustomerStatus.active:
        return 'Active';
    }
  }
}
