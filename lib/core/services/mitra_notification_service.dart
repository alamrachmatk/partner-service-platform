import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────
// MODEL NOTIFIKASI
// ─────────────────────────────────────────────
enum MitraNotifType { order, payment, review, target, system }

extension MitraNotifTypeX on MitraNotifType {
  String get label {
    switch (this) {
      case MitraNotifType.order:   return 'Pesanan';
      case MitraNotifType.payment: return 'Pembayaran';
      case MitraNotifType.review:  return 'Ulasan';
      case MitraNotifType.target:  return 'Target';
      case MitraNotifType.system:  return 'Sistem';
    }
  }

  IconData get icon {
    switch (this) {
      case MitraNotifType.order:   return Icons.receipt_long_outlined;
      case MitraNotifType.payment: return Icons.account_balance_wallet_outlined;
      case MitraNotifType.review:  return Icons.star_outline_rounded;
      case MitraNotifType.target:  return Icons.emoji_events_outlined;
      case MitraNotifType.system:  return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MitraNotifType.order:   return AppColors.primary;
      case MitraNotifType.payment: return AppColors.success;
      case MitraNotifType.review:  return AppColors.secondary;
      case MitraNotifType.target:  return AppColors.warning;
      case MitraNotifType.system:  return AppColors.info;
    }
  }
}

class MitraNotif {
  final String id, title, body;
  final MitraNotifType type;
  final DateTime time;
  final String? orderId; // jika diisi, notifikasi membuka detail pesanan
  bool isRead;

  MitraNotif({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.orderId,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
// SERVICE — singleton, bisa dipanggil dari mana saja
// ─────────────────────────────────────────────
class MitraNotificationService extends ChangeNotifier {
  static final MitraNotificationService _instance =
      MitraNotificationService._internal();
  factory MitraNotificationService() => _instance;
  MitraNotificationService._internal() {
    _seed();
  }

  final List<MitraNotif> _items = [];

  /// Terbaru di atas.
  List<MitraNotif> get items {
    final list = List<MitraNotif>.from(_items);
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Tambah notifikasi baru (dipanggil dari fitur lain, mis. biaya tambahan,
  /// target tercapai). TODO: saat backend siap, panggil ini dari handler FCM.
  void add({
    required String title,
    required String body,
    required MitraNotifType type,
    String? orderId,
  }) {
    _items.add(MitraNotif(
      id: 'NTF-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      time: DateTime.now(),
      orderId: orderId,
    ));
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1 || _items[idx].isRead) return;
    _items[idx].isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _items) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  // Data awal (dummy) — hapus saat backend siap
  void _seed() {
    final now = DateTime.now();
    _items.addAll([
      MitraNotif(
        id: 'NTF-S1', type: MitraNotifType.order, orderId: 'ORD-001',
        title: 'Pesanan baru masuk',
        body: 'Ada pesanan baru menunggu konfirmasimu. '
            'Segera terima atau tolak dalam 5 menit.',
        time: now.subtract(const Duration(minutes: 5)),
      ),
      MitraNotif(
        id: 'NTF-S2', type: MitraNotifType.payment,
        title: 'Dana masuk ke saldo',
        body: 'Pendapatan dari pesanan ORD-004 sudah masuk ke saldo tersedia.',
        time: now.subtract(const Duration(hours: 2)),
      ),
      MitraNotif(
        id: 'NTF-S3', type: MitraNotifType.review,
        title: 'Ulasan baru ⭐⭐⭐⭐⭐',
        body: 'Pelanggan memberi ulasan 5 bintang. Balas ulasannya sekarang.',
        time: now.subtract(const Duration(days: 1)),
      ),
      MitraNotif(
        id: 'NTF-S4', type: MitraNotifType.system, isRead: true,
        title: 'Progres menuju tier Gold',
        body: 'Tinggal 26 order lagi untuk naik ke tier Gold. Terus semangat!',
        time: now.subtract(const Duration(days: 2)),
      ),
      MitraNotif(
        id: 'NTF-S5', type: MitraNotifType.order, orderId: 'ORD-005',
        isRead: true,
        title: 'Pesanan dibatalkan',
        body: 'Pelanggan membatalkan pesanan ORD-005.',
        time: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }
}
