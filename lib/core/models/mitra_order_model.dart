// ── Item detail dalam pesanan ──
class MitraOrderItem {
  final String name;
  final int qty;
  final double price;
  const MitraOrderItem({required this.name, required this.qty, required this.price});

  double get subtotal => price * qty;

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000) return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String get formattedSubtotal {
    if (subtotal >= 1000000) return 'Rp ${(subtotal / 1000000).toStringAsFixed(1)}jt';
    if (subtotal >= 1000) return 'Rp ${(subtotal / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${subtotal.toStringAsFixed(0)}';
  }
}

enum MitraOrderStatus {
  pending, confirmed, onTheWay, inProgress, completed, cancelled, rejected,
}

extension MitraOrderStatusX on MitraOrderStatus {
  String get label {
    switch (this) {
      case MitraOrderStatus.pending:    return 'Pesanan Baru';
      case MitraOrderStatus.confirmed:  return 'Dikonfirmasi';
      case MitraOrderStatus.onTheWay:   return 'Dalam Perjalanan';
      case MitraOrderStatus.inProgress: return 'Sedang Dikerjakan';
      case MitraOrderStatus.completed:  return 'Selesai';
      case MitraOrderStatus.cancelled:  return 'Dibatalkan';
      case MitraOrderStatus.rejected:   return 'Ditolak';
    }
  }

  String get emoji {
    switch (this) {
      case MitraOrderStatus.pending:    return '🔔';
      case MitraOrderStatus.confirmed:  return '✅';
      case MitraOrderStatus.onTheWay:   return '🚗';
      case MitraOrderStatus.inProgress: return '🔧';
      case MitraOrderStatus.completed:  return '🎉';
      case MitraOrderStatus.cancelled:  return '❌';
      case MitraOrderStatus.rejected:   return '🚫';
    }
  }

  bool get isActive =>
      this == MitraOrderStatus.pending ||
      this == MitraOrderStatus.confirmed ||
      this == MitraOrderStatus.onTheWay ||
      this == MitraOrderStatus.inProgress;

  bool get canAccept    => this == MitraOrderStatus.pending;
  bool get canReject    => this == MitraOrderStatus.pending;
  bool get canUpdateStatus =>
      this == MitraOrderStatus.confirmed ||
      this == MitraOrderStatus.onTheWay  ||
      this == MitraOrderStatus.inProgress;
}

class MitraOrderModel {
  final String id, serviceName, serviceEmoji;
  final String customerName, customerPhone, address;
  final double price;
  final DateTime scheduledAt;
  final MitraOrderStatus status;
  final String? notes, cancellationReason;
  final List<MitraOrderItem> items;

  const MitraOrderModel({
    required this.id, required this.serviceName, required this.serviceEmoji,
    required this.customerName, required this.customerPhone,
    required this.address, required this.price, required this.scheduledAt,
    this.status = MitraOrderStatus.pending,
    this.notes, this.cancellationReason,
    this.items = const [],
  });

  MitraOrderModel copyWith({MitraOrderStatus? status, String? cancellationReason}) =>
      MitraOrderModel(
        id: id, serviceName: serviceName, serviceEmoji: serviceEmoji,
        customerName: customerName, customerPhone: customerPhone,
        address: address, price: price, scheduledAt: scheduledAt,
        notes: notes, items: items,
        status: status ?? this.status,
        cancellationReason: cancellationReason ?? this.cancellationReason,
      );

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000) return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String get formattedDate {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${scheduledAt.day} ${months[scheduledAt.month]} ${scheduledAt.year}';
  }

  String get formattedTime {
    final h = scheduledAt.hour.toString().padLeft(2, '0');
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  MitraOrderStatus? get nextStatus {
    switch (status) {
      case MitraOrderStatus.confirmed:  return MitraOrderStatus.onTheWay;
      case MitraOrderStatus.onTheWay:   return MitraOrderStatus.inProgress;
      case MitraOrderStatus.inProgress: return MitraOrderStatus.completed;
      default: return null;
    }
  }

  String get nextStatusLabel {
    switch (status) {
      case MitraOrderStatus.confirmed:  return 'Mulai Perjalanan';
      case MitraOrderStatus.onTheWay:   return 'Mulai Pengerjaan';
      case MitraOrderStatus.inProgress: return 'Selesai';
      default: return '';
    }
  }
}

// ── Dummy orders ──
class DummyMitraOrders {
  static List<MitraOrderModel> get all => [
    // ✅ Order AC baru masuk — detail lengkap dengan item
    MitraOrderModel(
      id: 'ORD-001',
      serviceName: 'Servis AC Split',
      serviceEmoji: '❄️',
      customerName: 'Budi Santoso',
      customerPhone: '081234567890',
      address: 'Jl. Merdeka No. 10, RT 02/03, Bogor Tengah',
      price: 350000,
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      status: MitraOrderStatus.pending,
      items: [
        MitraOrderItem(name: 'Cuci AC 0.5–1 PK', qty: 2, price: 85000),
        MitraOrderItem(name: 'Isi Freon R32', qty: 1, price: 120000),
        MitraOrderItem(name: 'Cek & Bersihkan Filter', qty: 2, price: 30000),
      ],
      notes: 'AC kamar utama kurang dingin, mungkin perlu isi freon. '
          'AC ruang tamu sudah 2 tahun tidak diservis. Mohon dicek juga kondisi kompresornya.',
    ),
    MitraOrderModel(
      id: 'ORD-002',
      serviceName: 'Bersih-Bersih Rumah',
      serviceEmoji: '🧹',
      customerName: 'Ani Rahayu',
      customerPhone: '082345678901',
      address: 'Jl. Sudirman No. 45, Bogor Selatan',
      price: 200000,
      scheduledAt: DateTime.now().add(const Duration(hours: 4)),
      status: MitraOrderStatus.confirmed,
      items: [
        MitraOrderItem(name: 'Bersih Rumah Type 36', qty: 1, price: 150000),
        MitraOrderItem(name: 'Cuci Kamar Mandi', qty: 2, price: 25000),
      ],
    ),
    MitraOrderModel(
      id: 'ORD-003',
      serviceName: 'Cuci Karpet',
      serviceEmoji: '🪣',
      customerName: 'Hendra Wijaya',
      customerPhone: '083456789012',
      address: 'Jl. Pahlawan No. 5, Bogor Utara',
      price: 120000,
      scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: MitraOrderStatus.onTheWay,
      items: [
        MitraOrderItem(name: 'Cuci Karpet per m²', qty: 6, price: 20000),
      ],
    ),
    MitraOrderModel(
      id: 'ORD-004',
      serviceName: 'Bersih-Bersih Rumah',
      serviceEmoji: '🧹',
      customerName: 'Dewi Lestari',
      customerPhone: '084567890123',
      address: 'Jl. Ahmad Yani No. 12, Bogor Timur',
      price: 180000,
      scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
      status: MitraOrderStatus.completed,
      items: [
        MitraOrderItem(name: 'Bersih Rumah Type 45', qty: 1, price: 180000),
      ],
    ),
    MitraOrderModel(
      id: 'ORD-005',
      serviceName: 'Servis AC Split',
      serviceEmoji: '❄️',
      customerName: 'Rudi Hartono',
      customerPhone: '085678901234',
      address: 'Jl. Veteran No. 8, Bogor Barat',
      price: 150000,
      scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
      status: MitraOrderStatus.cancelled,
      cancellationReason: 'Pelanggan membatalkan pesanan',
      items: [
        MitraOrderItem(name: 'Cuci AC 1.5–2 PK', qty: 1, price: 100000),
        MitraOrderItem(name: 'Cek Kondisi Kompresor', qty: 1, price: 50000),
      ],
    ),
  ];
}
