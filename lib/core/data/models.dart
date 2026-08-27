enum CustomerStatus { active, overdue, completed }

enum LoanStatus { active, overdue, completed, defaulted }

enum TransactionType {
  disbursement,
  repayment,
  bankCredit,
  adjustment,
}

enum PaymentMethod { cash, transfer, pos, cheque }

class AccountManager {
  AccountManager({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.territory,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String? territory;
  final bool isActive;
}

class Loan {
  Loan({
    required this.id,
    required this.customerId,
    required this.principal,
    required this.interestRate,
    required this.interestAmount,
    required this.processingFee,
    required this.disbursementDate,
    required this.tenureMonths,
    required this.repaymentFrequency,
    required this.installmentAmount,
    required this.installments,
    required this.outstandingPrincipal,
    required this.outstandingInterest,
    required this.status,
    required this.nextPaymentDate,
  });

  final String id;
  final String customerId;
  final double principal;
  final double interestRate;
  final double interestAmount;
  final double processingFee;
  final DateTime disbursementDate;
  final int tenureMonths;
  final String repaymentFrequency;
  final double installmentAmount;
  final int installments;
  final double outstandingPrincipal;
  final double outstandingInterest;
  final LoanStatus status;
  final DateTime nextPaymentDate;

  double get totalOutstanding => outstandingPrincipal + outstandingInterest;
}

class PaymentRecord {
  PaymentRecord({
    required this.id,
    required this.customerId,
    required this.loanId,
    required this.amount,
    required this.date,
    required this.method,
    required this.reference,
    required this.status,
  });

  final String id;
  final String customerId;
  final String loanId;
  final double amount;
  final DateTime date;
  final PaymentMethod method;
  final String reference;
  final String status;
}

class LedgerTransaction {
  LedgerTransaction({
    required this.id,
    required this.customerId,
    required this.loanId,
    required this.type,
    required this.amount,
    required this.date,
    required this.reference,
    required this.description,
  });

  final String id;
  final String customerId;
  final String loanId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String reference;
  final String description;
}

class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.managerId,
    required this.status,
    required this.totalBorrowed,
    required this.totalRepaid,
    required this.outstandingPrincipal,
    required this.interestCharges,
    required this.nextPaymentDate,
    required this.activeLoanId,
    required this.branch,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String managerId;
  final CustomerStatus status;
  final double totalBorrowed;
  final double totalRepaid;
  final double outstandingPrincipal;
  final double interestCharges;
  final DateTime nextPaymentDate;
  final String activeLoanId;
  final String branch;

  double get totalOutstanding => outstandingPrincipal + interestCharges;
}

class ManagerDailyStats {
  ManagerDailyStats({
    required this.managerId,
    required this.expectedToday,
    required this.collectedToday,
    required this.totalOutstanding,
    required this.overdueCount,
    required this.bankCreditsToday,
    required this.unreconciled,
  });

  final String managerId;
  final double expectedToday;
  final double collectedToday;
  final double totalOutstanding;
  final int overdueCount;
  final double bankCreditsToday;
  final double unreconciled;
}

class DashboardKpis {
  DashboardKpis({
    required this.totalActiveLoans,
    required this.expectedToday,
    required this.collectedToday,
    required this.outstandingCollection,
    required this.bankCreditsToday,
    required this.unreconciledAmount,
    required this.overdueLoans,
    required this.activeCustomers,
    required this.accountManagers,
  });

  final double totalActiveLoans;
  final double expectedToday;
  final double collectedToday;
  final double outstandingCollection;
  final double bankCreditsToday;
  final double unreconciledAmount;
  final double overdueLoans;
  final int activeCustomers;
  final int accountManagers;
}

class DailyTrendPoint {
  const DailyTrendPoint({
    required this.date,
    required this.label,
    required this.expected,
    required this.collected,
  });

  final DateTime date;
  final String label;
  final double expected;
  final double collected;
}

class ManagerRankEntry {
  const ManagerRankEntry({
    required this.manager,
    required this.stats,
    required this.collectionRate,
  });

  final AccountManager manager;
  final ManagerDailyStats stats;
  final double collectionRate;
}

class CollectionSnapshot {
  const CollectionSnapshot({
    required this.expected,
    required this.collected,
    required this.outstanding,
    required this.bankCredits,
    required this.unreconciled,
  });

  final double expected;
  final double collected;
  final double outstanding;
  final double bankCredits;
  final double unreconciled;

  double get attainmentRate =>
      expected > 0 ? (collected / expected).clamp(0.0, 1.0) : 0;
}
