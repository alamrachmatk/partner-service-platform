// ── Tipe transaksi ──
enum TransactionType { income, withdrawal, fee }

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:     return 'Pendapatan';
      case TransactionType.withdrawal: return 'Penarikan Dana';
      case TransactionType.fee:        return 'Biaya Platform';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionType.income:     return '💰';
      case TransactionType.withdrawal: return '🏦';
      case TransactionType.fee:        return '📋';
    }
  }
}

// ── Status penarikan ──
enum WithdrawalStatus { pending, processing, success, failed }

extension WithdrawalStatusX on WithdrawalStatus {
  String get label {
    switch (this) {
      case WithdrawalStatus.pending:    return 'Menunggu';
      case WithdrawalStatus.processing: return 'Diproses';
      case WithdrawalStatus.success:    return 'Berhasil';
      case WithdrawalStatus.failed:     return 'Gagal';
    }
  }

  String get color {
    switch (this) {
      case WithdrawalStatus.pending:    return 'warning';
      case WithdrawalStatus.processing: return 'info';
      case WithdrawalStatus.success:    return 'success';
      case WithdrawalStatus.failed:     return 'error';
    }
  }
}

// ── Model transaksi ──
class TransactionModel {
  final String id, description, orderId;
  final double amount;
  final TransactionType type;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.orderId,
    required this.amount,
    required this.type,
    required this.date,
  });

  String get formattedAmount {
    final prefix = type == TransactionType.income ? '+' : '-';
    if (amount >= 1000000) return '$prefix Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000)    return '$prefix Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    return '$prefix Rp ${amount.toStringAsFixed(0)}';
  }

  String get formattedDate {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]} ${date.year} · $h:$m';
  }
}

// ── Model rekening/e-wallet ──
class PaymentAccountModel {
  final String id, name, accountNumber, bankName, type;
  final bool isDefault;

  const PaymentAccountModel({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.bankName,
    required this.type,
    this.isDefault = false,
  });

  String get maskedNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '${'*' * (accountNumber.length - 4)}${accountNumber.substring(accountNumber.length - 4)}';
  }
}

// ── Dummy data ──
class DummyEarnings {
  static double get balance => 850000;
  static double get pendingBalance => 250000;
  static double get totalEarnings => 12450000;
  static double get thisMonthEarnings => 2850000;

  static List<double> get monthlyData =>
      [1800000, 2100000, 1650000, 2400000, 2200000, 2850000];

  static const monthLabels = ['Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov'];

  static List<TransactionModel> get transactions => [
    TransactionModel(id: 'TRX-001', description: 'Servis AC Split — Budi Santoso',
        orderId: 'ORD-001', amount: 350000, type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(hours: 2))),
    TransactionModel(id: 'TRX-002', description: 'Biaya Platform (10%)',
        orderId: 'ORD-001', amount: 35000, type: TransactionType.fee,
        date: DateTime.now().subtract(const Duration(hours: 2))),
    TransactionModel(id: 'TRX-003', description: 'Bersih-Bersih Rumah — Ani Rahayu',
        orderId: 'ORD-002', amount: 200000, type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 1))),
    TransactionModel(id: 'TRX-004', description: 'Penarikan ke BCA ••4521',
        orderId: '-', amount: 500000, type: TransactionType.withdrawal,
        date: DateTime.now().subtract(const Duration(days: 2))),
    TransactionModel(id: 'TRX-005', description: 'Cuci Karpet — Hendra Wijaya',
        orderId: 'ORD-003', amount: 120000, type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 3))),
    TransactionModel(id: 'TRX-006', description: 'Biaya Platform (10%)',
        orderId: 'ORD-003', amount: 12000, type: TransactionType.fee,
        date: DateTime.now().subtract(const Duration(days: 3))),
    TransactionModel(id: 'TRX-007', description: 'Servis AC — Dewi Lestari',
        orderId: 'ORD-004', amount: 180000, type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 5))),
    TransactionModel(id: 'TRX-008', description: 'Penarikan ke GoPay ••8821',
        orderId: '-', amount: 300000, type: TransactionType.withdrawal,
        date: DateTime.now().subtract(const Duration(days: 7))),
  ];

  static List<PaymentAccountModel> get accounts => [
    const PaymentAccountModel(id: 'ACC-001', name: 'BCA', type: 'bank',
        bankName: 'Bank Central Asia', accountNumber: '1234567521',
        isDefault: true),
    const PaymentAccountModel(id: 'ACC-002', name: 'GoPay', type: 'ewallet',
        bankName: 'GoPay', accountNumber: '081234567890'),
    const PaymentAccountModel(id: 'ACC-003', name: 'OVO', type: 'ewallet',
        bankName: 'OVO', accountNumber: '081234567890'),
  ];
}
