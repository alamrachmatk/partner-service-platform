enum ExtraChargeStatus { pending, approved, rejected }

/// Biaya di luar paket yang diajukan mitra, menunggu persetujuan pelanggan.
class ExtraCharge {
  final String id, orderId, name, reason;
  final double amount;
  final DateTime createdAt;
  ExtraChargeStatus status;
  DateTime? respondedAt;

  ExtraCharge({
    required this.id,
    required this.orderId,
    required this.name,
    required this.reason,
    required this.amount,
    required this.createdAt,
    this.status = ExtraChargeStatus.pending,
    this.respondedAt,
  });
}

/// Foto bukti pekerjaan (sebelum / sesudah).
class OrderPhoto {
  final String path; // path lokal dari image_picker
  final DateTime takenAt;
  // TODO: tambahkan `url` (Firebase Storage) setelah backend siap.
  const OrderPhoto({required this.path, required this.takenAt});
}
