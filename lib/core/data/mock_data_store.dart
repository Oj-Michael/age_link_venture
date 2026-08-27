import 'dart:math';

import 'package:agelink_venture/core/data/models.dart';

/// In-memory mock data store — single source for UI-only phase.
class MockDataStore {
  MockDataStore._();
  static final MockDataStore instance = MockDataStore._();

  final List<AccountManager> managers = [];
  final List<Customer> customers = [];
  final List<Loan> loans = [];
  final List<PaymentRecord> payments = [];
  final List<LedgerTransaction> transactions = [];

  bool _seeded = false;
  final _random = Random(42);

  void ensureSeeded() {
    if (_seeded) return;
    _seeded = true;
    _seed();
  }

  void _seed() {
    final firstNames = [
      'Adaeze', 'Chukwu', 'Ngozi', 'Emeka', 'Fatima', 'Ibrahim', 'Yusuf',
      'Amina', 'Oluwaseun', 'Blessing', 'Kelechi', 'Zainab', 'Tunde', 'Grace',
      'Hassan', 'Chioma', 'Bola', 'Musa', 'Funke', 'Peter',
    ];
    final lastNames = [
      'Okonkwo', 'Bello', 'Adeyemi', 'Eze', 'Mohammed', 'Okafor', 'Danjuma',
      'Nwosu', 'Abubakar', 'Ibrahim', 'Obi', 'Sule', 'Akinola', 'Garba',
      'Uche', 'Yakubu', 'Ogunleye', 'Aliyu', 'Chidi', 'Bakare',
    ];
    final territories = [
      'Lagos Main', 'Ikeja', 'Abuja Central', 'Kano North', 'Port Harcourt',
      'Benin City', 'Kaduna', 'Enugu', 'Ibadan', 'Abeokuta',
    ];
    final branches = [
      'Lagos', 'Abuja', 'Kano', 'Rivers', 'Ogun', 'Edo', 'Kaduna', 'Enugu',
    ];

    for (var i = 1; i <= 16; i++) {
      final id = 'AM-${i.toString().padLeft(3, '0')}';
      managers.add(
        AccountManager(
          id: id,
          name: '${firstNames[i % firstNames.length]} ${lastNames[i % lastNames.length]}',
          phone: '+23480${_random.nextInt(90000000) + 10000000}',
          email: 'am${i}@agelink.ng',
          territory: territories[i % territories.length],
          isActive: i != 15,
        ),
      );
    }

    var customerIndex = 1;
    for (final manager in managers) {
      final customerCount = 10 + _random.nextInt(6);
      for (var c = 0; c < customerCount; c++) {
        final custId = 'CUS-${customerIndex.toString().padLeft(8, '0')}';
        final loanId = 'LN-2026-${customerIndex.toString().padLeft(7, '0')}';
        final principal = (50000 + _random.nextInt(450000)).toDouble();
        final interestRate = 5 + _random.nextInt(15);
        final interestAmount = principal * interestRate / 100;
        final tenure = 6 + _random.nextInt(18);
        final installments = tenure;
        final installmentAmount = (principal + interestAmount) / installments;
        final repaidCount = _random.nextInt(installments ~/ 2);
        final outstandingPrincipal =
            principal - (installmentAmount * repaidCount * 0.7);
        final outstandingInterest =
            interestAmount - (installmentAmount * repaidCount * 0.3);
        final isOverdue = _random.nextDouble() < 0.15;
        final status = isOverdue
            ? CustomerStatus.overdue
            : (repaidCount >= installments
                ? CustomerStatus.completed
                : CustomerStatus.active);
        final loanStatus = isOverdue
            ? LoanStatus.overdue
            : (status == CustomerStatus.completed
                ? LoanStatus.completed
                : LoanStatus.active);

        final totalRepaid = installmentAmount * repaidCount;
        final nextPayment = DateTime.now().add(
          Duration(days: isOverdue ? -_random.nextInt(14) : _random.nextInt(7)),
        );

        loans.add(
          Loan(
            id: loanId,
            customerId: custId,
            principal: principal,
            interestRate: interestRate.toDouble(),
            interestAmount: interestAmount,
            processingFee: 2500,
            disbursementDate: DateTime(2025, 1 + _random.nextInt(11), 1 + _random.nextInt(28)),
            tenureMonths: tenure,
            repaymentFrequency: 'Weekly',
            installmentAmount: installmentAmount,
            installments: installments,
            outstandingPrincipal: outstandingPrincipal.clamp(0, principal),
            outstandingInterest: outstandingInterest.clamp(0, interestAmount),
            status: loanStatus,
            nextPaymentDate: nextPayment,
          ),
        );

        customers.add(
          Customer(
            id: custId,
            name:
                '${firstNames[(customerIndex + c) % firstNames.length]} ${lastNames[(customerIndex + c) % lastNames.length]}',
            phone: '+23470${_random.nextInt(90000000) + 10000000}',
            address: '${_random.nextInt(200) + 1} Market St, ${branches[c % branches.length]}',
            managerId: manager.id,
            status: status,
            totalBorrowed: principal,
            totalRepaid: totalRepaid,
            outstandingPrincipal: outstandingPrincipal.clamp(0, principal),
            interestCharges: outstandingInterest.clamp(0, interestAmount),
            nextPaymentDate: nextPayment,
            activeLoanId: loanId,
            branch: branches[c % branches.length],
          ),
        );

        for (var p = 0; p < repaidCount; p++) {
          final payId = 'PAY-${customerIndex.toString().padLeft(6, '0')}-$p';
          final payDate = DateTime.now().subtract(Duration(days: 7 * (repaidCount - p)));
          payments.add(
            PaymentRecord(
              id: payId,
              customerId: custId,
              loanId: loanId,
              amount: installmentAmount,
              date: payDate,
              method: PaymentMethod.values[_random.nextInt(3)],
              reference: 'REF-${payId}',
              status: 'Confirmed',
            ),
          );
          transactions.add(
            LedgerTransaction(
              id: 'TXN-${payId}',
              customerId: custId,
              loanId: loanId,
              type: TransactionType.repayment,
              amount: installmentAmount,
              date: payDate,
              reference: 'REF-${payId}',
              description: 'Customer repayment',
            ),
          );
        }

        transactions.add(
          LedgerTransaction(
            id: 'TXN-DIS-$custId',
            customerId: custId,
            loanId: loanId,
            type: TransactionType.disbursement,
            amount: principal,
            date: loans.last.disbursementDate,
            reference: loanId,
            description: 'Loan disbursement',
          ),
        );

        if (_random.nextDouble() < 0.3) {
          transactions.add(
            LedgerTransaction(
              id: 'TXN-BNK-$custId',
              customerId: custId,
              loanId: loanId,
              type: TransactionType.bankCredit,
              amount: installmentAmount,
              date: DateTime.now(),
              reference: 'BNK-${custId}',
              description: 'Bank credit alert',
            ),
          );
        }

        customerIndex++;
      }
    }
  }

  AccountManager? managerById(String id) {
    ensureSeeded();
    try {
      return managers.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Customer? customerById(String id) {
    ensureSeeded();
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Loan? loanById(String id) {
    ensureSeeded();
    try {
      return loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Customer> customersForManager(String managerId) {
    ensureSeeded();
    return customers.where((c) => c.managerId == managerId).toList();
  }

  List<PaymentRecord> paymentsForCustomer(String customerId) {
    ensureSeeded();
    return payments
        .where((p) => p.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<LedgerTransaction> transactionsForCustomer(String customerId) {
    ensureSeeded();
    return transactions
        .where((t) => t.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  ManagerDailyStats statsForManager(String managerId) {
    ensureSeeded();
    final mgrCustomers = customersForManager(managerId);
    final expectedToday = mgrCustomers.fold<double>(
      0,
      (sum, c) => sum + _expectedTodayForCustomer(c),
    );
    final collectedToday = expectedToday * (0.75 + _random.nextDouble() * 0.2);
    final totalOutstanding = mgrCustomers.fold<double>(
      0,
      (sum, c) => sum + c.totalOutstanding,
    );
    final overdueCount =
        mgrCustomers.where((c) => c.status == CustomerStatus.overdue).length;
    final bankCredits = collectedToday * 0.92;
    final unreconciled = collectedToday - bankCredits;

    return ManagerDailyStats(
      managerId: managerId,
      expectedToday: expectedToday,
      collectedToday: collectedToday,
      totalOutstanding: totalOutstanding,
      overdueCount: overdueCount,
      bankCreditsToday: bankCredits,
      unreconciled: unreconciled.abs(),
    );
  }

  double _expectedTodayForCustomer(Customer c) {
    final loan = loanById(c.activeLoanId);
    if (loan == null) return 0;
    if (c.status == CustomerStatus.completed) return 0;
    return loan.installmentAmount;
  }

  DashboardKpis dashboardKpis({String? managerId, String? branch}) {
    ensureSeeded();
    var filtered = customers.where((c) {
      if (managerId != null && c.managerId != managerId) return false;
      if (branch != null && c.branch != branch) return false;
      return c.status != CustomerStatus.completed;
    }).toList();

    final activeCustomers = customers
        .where((c) {
          if (managerId != null && c.managerId != managerId) return false;
          if (branch != null && c.branch != branch) return false;
          return c.status != CustomerStatus.completed;
        })
        .length;

    final totalActiveLoans = filtered.fold<double>(
      0,
      (sum, c) => sum + c.outstandingPrincipal,
    );

    final expectedToday = filtered.fold<double>(
      0,
      (sum, c) => sum + _expectedTodayForCustomer(c),
    );
    final collectedToday = expectedToday * 0.84;
    final outstandingCollection = expectedToday - collectedToday;

    final overdueLoans = filtered
        .where((c) => c.status == CustomerStatus.overdue)
        .fold<double>(0, (sum, c) => sum + c.totalOutstanding);

    final bankCreditsToday = collectedToday * 0.95;
    final unreconciled = collectedToday - bankCreditsToday;

    final managerCount = managerId != null
        ? 1
        : managers.where((m) => m.isActive).length;

    return DashboardKpis(
      totalActiveLoans: totalActiveLoans,
      expectedToday: expectedToday,
      collectedToday: collectedToday,
      outstandingCollection: outstandingCollection,
      bankCreditsToday: bankCreditsToday,
      unreconciledAmount: unreconciled,
      overdueLoans: overdueLoans,
      activeCustomers: activeCustomers,
      accountManagers: managerCount,
    );
  }

  List<Customer> overdueCustomers({int limit = 5, String? managerId}) {
    ensureSeeded();
    final overdue = customers
        .where((c) {
          if (c.status != CustomerStatus.overdue) return false;
          if (managerId != null && c.managerId != managerId) return false;
          return true;
        })
        .toList()
      ..sort((a, b) => b.totalOutstanding.compareTo(a.totalOutstanding));
    return overdue.take(limit).toList();
  }

  List<String> branches() {
    ensureSeeded();
    return customers.map((c) => c.branch).toSet().toList()..sort();
  }

  AccountManager addManager({
    required String name,
    required String phone,
    required String email,
    String? territory,
  }) {
    ensureSeeded();
    final nextId = managers.length + 1;
    final manager = AccountManager(
      id: 'AM-${nextId.toString().padLeft(3, '0')}',
      name: name,
      phone: phone,
      email: email,
      territory: territory,
    );
    managers.add(manager);
    return manager;
  }

  CollectionSnapshot collectionSnapshot({
    String? managerId,
    String? branch,
  }) {
    final k = dashboardKpis(managerId: managerId, branch: branch);
    return CollectionSnapshot(
      expected: k.expectedToday,
      collected: k.collectedToday,
      outstanding: k.outstandingCollection,
      bankCredits: k.bankCreditsToday,
      unreconciled: k.unreconciledAmount,
    );
  }

  List<DailyTrendPoint> dailyCollectionTrend({
    int days = 14,
    String? managerId,
    String? branch,
  }) {
    ensureSeeded();
    final baseKpis = dashboardKpis(managerId: managerId, branch: branch);
    final baseExpected = baseKpis.expectedToday;
    final points = <DailyTrendPoint>[];

    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final daySeed = date.day + date.month * 31;
      final wave = 0.82 + (_random.nextDouble() * 0.16);
      final weekdayBoost = date.weekday <= 5 ? 1.0 : 0.72;
      final expected = baseExpected * weekdayBoost * (0.88 + (daySeed % 7) * 0.03);
      final collected = expected * wave * (0.9 + (daySeed % 5) * 0.02);
      final label = i == 0
          ? 'Today'
          : i == 1
              ? 'Yesterday'
              : _shortDayLabel(date);

      points.add(
        DailyTrendPoint(
          date: date,
          label: label,
          expected: expected,
          collected: collected,
        ),
      );
    }
    return points;
  }

  String _shortDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  List<ManagerRankEntry> topPerformingManagers({
    int limit = 5,
    String? branch,
  }) {
    ensureSeeded();
    final entries = managers
        .where((m) => m.isActive)
        .map((m) {
          final stats = statsForManager(m.id);
          final rate = stats.expectedToday > 0
              ? stats.collectedToday / stats.expectedToday
              : 0.0;
          return ManagerRankEntry(
            manager: m,
            stats: stats,
            collectionRate: rate,
          );
        })
        .toList()
      ..sort((a, b) => b.collectionRate.compareTo(a.collectionRate));

    if (branch != null) {
      // Filter managers who have customers in branch
      entries.retainWhere((e) {
        return customersForManager(e.manager.id).any((c) => c.branch == branch);
      });
    }

    return entries.take(limit).toList();
  }

  List<ManagerRankEntry> allManagerRankings({String? branch}) {
    return topPerformingManagers(limit: managers.length, branch: branch);
  }
}
