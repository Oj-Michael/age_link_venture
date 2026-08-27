import 'package:agelink_venture/core/data/mock_data_store.dart';
import 'package:agelink_venture/core/data/models.dart';
import 'package:agelink_venture/sharedwidgets/app_scrollable_data_table.dart';
import 'package:agelink_venture/sharedwidgets/kpi_card.dart';
import 'package:agelink_venture/sharedwidgets/status_badge.dart';
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:agelink_venture/utils/constants.dart';
import 'package:agelink_venture/utils/formatters.dart';
import 'package:agelink_venture/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final store = MockDataStore.instance;
    store.ensureSeeded();

    final customer = store.customerById(customerId);
    if (customer == null) {
      return const Center(child: Text('Customer not found'));
    }

    final loan = store.loanById(customer.activeLoanId);
    final manager = store.managerById(customer.managerId);
    final payments = store.paymentsForCustomer(customerId);
    final transactions = store.transactionsForCustomer(customerId);

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
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: AppTextStyles.pageTitle),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(customer.id, style: AppTextStyles.pageSubtitle),
                          const SizedBox(width: 12),
                          customerStatusBadge(_statusLabel(customer.status)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () =>
                  context.go('/managers/${customer.managerId}/customers'),
              child: Text(
                'Account Manager: ${manager?.name ?? customer.managerId}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            KpiRow(
              metrics: [
                KpiMetric(
                  label: 'Total Borrowed',
                  value: formatCurrency(customer.totalBorrowed),
                  icon: Icons.trending_up,
                ),
                KpiMetric(
                  label: 'Total Repaid',
                  value: formatCurrency(customer.totalRepaid),
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  iconBackground: AppColors.success.withValues(alpha: 0.1),
                ),
                KpiMetric(
                  label: 'Outstanding Principal',
                  value: formatCurrency(customer.outstandingPrincipal),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                KpiMetric(
                  label: 'Interest / Charges',
                  value: formatCurrency(customer.interestCharges),
                  icon: Icons.percent,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            KpiRow(
              metrics: [
                KpiMetric(
                  label: 'Total Outstanding',
                  value: formatCurrency(customer.totalOutstanding),
                  icon: Icons.warning_amber_outlined,
                  valueColor: customer.status == CustomerStatus.overdue
                      ? AppColors.danger
                      : AppColors.textPrimary,
                ),
                KpiMetric(
                  label: 'Next Payment',
                  value: formatDate(customer.nextPaymentDate),
                  icon: Icons.event_outlined,
                ),
                KpiMetric(
                  label: 'Branch',
                  value: customer.branch,
                  icon: Icons.location_on_outlined,
                ),
                KpiMetric(
                  label: 'Phone',
                  value: customer.phone,
                  icon: Icons.phone_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (loan != null) _CurrentLoanCard(loan: loan),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Payment History',
              child: _PaymentHistoryTable(payments: payments),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Transaction Ledger',
              child: _LedgerTable(transactions: transactions),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Customer Profile',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileRow(label: 'Address', value: customer.address),
                  _ProfileRow(label: 'Customer ID', value: customer.id),
                  _ProfileRow(
                    label: 'Status',
                    value: _statusLabel(customer.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTextStyles.formLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.tableCell)),
        ],
      ),
    );
  }
}

class _CurrentLoanCard extends StatelessWidget {
  const _CurrentLoanCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Loan', style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              _LoanField(label: 'Loan ID', value: loan.id),
              _LoanField(
                label: 'Principal',
                value: formatCurrency(loan.principal),
              ),
              _LoanField(
                label: 'Interest Rate',
                value: '${loan.interestRate}%',
              ),
              _LoanField(label: 'Tenure', value: '${loan.tenureMonths} months'),
              _LoanField(label: 'Frequency', value: loan.repaymentFrequency),
              _LoanField(
                label: 'Disbursement',
                value: formatDate(loan.disbursementDate),
              ),
              _LoanField(
                label: 'Installment',
                value: formatCurrency(loan.installmentAmount),
              ),
              _LoanField(
                label: 'Outstanding Principal',
                value: formatCurrency(loan.outstandingPrincipal),
              ),
              _LoanField(
                label: 'Outstanding Interest',
                value: formatCurrency(loan.outstandingInterest),
              ),
              _LoanField(
                label: 'Next Payment',
                value: formatDate(loan.nextPaymentDate),
              ),
              _LoanField(label: 'Status', value: _loanStatusLabel(loan.status)),
            ],
          ),
        ],
      ),
    );
  }

  String _loanStatusLabel(LoanStatus status) {
    switch (status) {
      case LoanStatus.overdue:
        return 'Overdue';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.active:
        return 'Active';
    }
  }
}

class _LoanField extends StatelessWidget {
  const _LoanField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.kpiTrendMuted),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.tableCell),
      ],
    );
  }
}

class _PaymentHistoryTable extends StatelessWidget {
  const _PaymentHistoryTable({required this.payments});

  final List<PaymentRecord> payments;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Text('No payment records.');
    }

    final columns = [
      AppScrollColumn(label: tableHeader('Date'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Amount'), minWidth: 110),
      AppScrollColumn(label: tableHeader('Method'), minWidth: 100),
      AppScrollColumn(label: tableHeader('Reference'), minWidth: 140),
      AppScrollColumn(label: tableHeader('Status'), minWidth: 100),
    ];

    final rows = payments.map((p) {
      return AppScrollRow(
        cells: [
          tableCell(formatDate(p.date)),
          tableCell(formatCurrency(p.amount)),
          tableCell(_methodLabel(p.method)),
          tableCell(p.reference),
          tableCell(p.status),
        ],
      );
    }).toList();

    return AppScrollableDataTable(columns: columns, rows: rows);
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.pos:
        return 'POS';
      case PaymentMethod.cheque:
        return 'Cheque';
    }
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable({required this.transactions});

  final List<LedgerTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Text('No ledger transactions.');
    }

    final columns = [
      AppScrollColumn(label: tableHeader('Date'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Type'), minWidth: 120),
      AppScrollColumn(label: tableHeader('Amount'), minWidth: 110),
      AppScrollColumn(label: tableHeader('Reference'), minWidth: 130),
      AppScrollColumn(label: tableHeader('Description'), minWidth: 180),
    ];

    final rows = transactions.map((t) {
      final isCredit = t.type == TransactionType.disbursement ||
          t.type == TransactionType.bankCredit;
      final prefix = isCredit ? '+' : '−';
      return AppScrollRow(
        cells: [
          tableCell(formatDateTime(t.date)),
          tableCell(_typeLabel(t.type)),
          tableCell(
            '$prefix ${formatCurrency(t.amount)}',
            color: isCredit ? AppColors.success : AppColors.danger,
          ),
          tableCell(t.reference),
          tableCell(t.description),
        ],
      );
    }).toList();

    return AppScrollableDataTable(columns: columns, rows: rows);
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.disbursement:
        return 'Disbursement';
      case TransactionType.repayment:
        return 'Repayment';
      case TransactionType.bankCredit:
        return 'Bank Credit';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }
}
