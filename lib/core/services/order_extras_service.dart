import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order_extras_model.dart';
import '../utils/currency_format.dart';
import 'mitra_notification_service.dart';

/// Menyimpan biaya tambahan & foto bukti per pesanan. Singleton agar data tetap
/// ada saat mitra keluar-masuk halaman detail pesanan.
class OrderExtrasService extends ChangeNotifier {
  static final OrderExtrasService _instance = OrderExtrasService._internal();
  factory OrderExtrasService() => _instance;
  OrderExtrasService._internal();

  /// Batas demo: biaya di atas nilai ini otomatis ditolak "pelanggan" agar
  /// kedua status (disetujui & ditolak) bisa dilihat saat uji coba.
  static const double demoRejectAbove = 500000;
  static const int maxPhotosPerSide = 3;

  final Map<String, List<ExtraCharge>> _charges = {};
  final Map<String, List<OrderPhoto>> _before = {};
  final Map<String, List<OrderPhoto>> _after = {};

  // ── Biaya tambahan ──
  List<ExtraCharge> chargesOf(String orderId) =>
      List.unmodifiable(_charges[orderId] ?? const <ExtraCharge>[]);

  double approvedTotal(String orderId) => chargesOf(orderId)
      .where((c) => c.status == ExtraChargeStatus.approved)
      .fold(0.0, (sum, c) => sum + c.amount);

  int pendingCount(String orderId) => chargesOf(orderId)
      .where((c) => c.status == ExtraChargeStatus.pending)
      .length;

  ExtraCharge addCharge({
    required String orderId,
    required String name,
    required double amount,
    required String reason,
  }) {
    final charge = ExtraCharge(
      id: 'EXT-${DateTime.now().microsecondsSinceEpoch}',
      orderId: orderId,
      name: name,
      reason: reason,
      amount: amount,
      createdAt: DateTime.now(),
    );
    _charges.putIfAbsent(orderId, () => []).add(charge);
    notifyListeners();
    _simulateCustomerResponse(charge);
    return charge;
  }

  /// Hanya biaya yang masih menunggu yang boleh dibatalkan mitra.
  void cancelCharge(String orderId, String chargeId) {
    final list = _charges[orderId];
    if (list == null) return;
    list.removeWhere(
        (c) => c.id == chargeId && c.status == ExtraChargeStatus.pending);
    notifyListeners();
  }

  // TODO: hapus simulasi ini saat backend siap. Respons nyata datang dari
  // aplikasi pelanggan lewat push notification / WebSocket.
  void _simulateCustomerResponse(ExtraCharge charge) {
    Timer(const Duration(seconds: 5), () {
      final stillThere = (_charges[charge.orderId] ?? const <ExtraCharge>[])
          .any((c) => c.id == charge.id);
      if (!stillThere || charge.status != ExtraChargeStatus.pending) return;

      final approve = charge.amount <= demoRejectAbove;
      charge.status =
          approve ? ExtraChargeStatus.approved : ExtraChargeStatus.rejected;
      charge.respondedAt = DateTime.now();
      notifyListeners();

      MitraNotificationService().add(
        title: approve
            ? 'Biaya tambahan disetujui'
            : 'Biaya tambahan ditolak',
        body: '${charge.name} (${rupiah(charge.amount)}) pada pesanan '
            '${charge.orderId} ${approve ? 'disetujui' : 'ditolak'} pelanggan.',
        type: MitraNotifType.order,
        orderId: charge.orderId,
      );
    });
  }

  // ── Foto bukti ──
  List<OrderPhoto> photosOf(String orderId, {required bool before}) =>
      List.unmodifiable(
          (before ? _before : _after)[orderId] ?? const <OrderPhoto>[]);

  bool hasAfterPhoto(String orderId) =>
      photosOf(orderId, before: false).isNotEmpty;

  void addPhoto(String orderId, {required bool before, required String path}) {
    final map = before ? _before : _after;
    final list = map.putIfAbsent(orderId, () => []);
    if (list.length >= maxPhotosPerSide) return;
    list.add(OrderPhoto(path: path, takenAt: DateTime.now()));
    notifyListeners();
  }

  void removePhoto(String orderId, {required bool before, required int index}) {
    final list = (before ? _before : _after)[orderId];
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    notifyListeners();
  }
}
