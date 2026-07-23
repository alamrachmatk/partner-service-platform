import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';
import '../../../../core/models/mitra_order_model.dart';
import 'mitra_order_detail_screen.dart';

class MitraOrdersScreen extends StatefulWidget {
  final MitraModel mitra;
  const MitraOrdersScreen({super.key, required this.mitra});

  @override
  State<MitraOrdersScreen> createState() => _MitraOrdersScreenState();
}

class _MitraOrdersScreenState extends State<MitraOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late List<MitraOrderModel> _orders;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _orders = DummyMitraOrders.all;
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<MitraOrderModel> get _newOrders =>
      _orders.where((o) => o.status == MitraOrderStatus.pending).toList();
  List<MitraOrderModel> get _activeOrders =>
      _orders.where((o) => o.status.isActive && o.status != MitraOrderStatus.pending).toList();
  List<MitraOrderModel> get _historyOrders =>
      _orders.where((o) => !o.status.isActive).toList();

  void _updateOrder(MitraOrderModel updated) {
    setState(() {
      final idx = _orders.indexWhere((o) => o.id == updated.id);
      if (idx != -1) _orders[idx] = updated;
    });
  }

  void _accept(MitraOrderModel order) {
    _updateOrder(order.copyWith(status: MitraOrderStatus.confirmed));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pesanan ${order.id} diterima!'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    _tab.animateTo(1);
  }

  Future<void> _rejectDialog(MitraOrderModel order) async {
    final reasons = ['Jadwal sudah penuh', 'Lokasi terlalu jauh',
        'Keahlian tidak sesuai', 'Ada keperluan mendadak', 'Alasan lainnya'];
    String? selected;
    String? reason;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).padding.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Tolak Pesanan', style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Pilih alasan penolakan',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ...reasons.map((r) => GestureDetector(
              onTap: () => setLocal(() => selected = r),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: selected == r ? AppColors.error.withOpacity(0.05) : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == r ? AppColors.error.withOpacity(0.4) : AppColors.border,
                    width: selected == r ? 1.5 : 0.5,
                  ),
                ),
                child: Row(children: [
                  Expanded(child: Text(r, style: TextStyle(fontSize: 14,
                      color: selected == r ? AppColors.error : AppColors.textPrimary,
                      fontWeight: selected == r ? FontWeight.w600 : FontWeight.w400))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18, height: 18,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(
                        color: selected == r ? AppColors.error : AppColors.border,
                        width: selected == r ? 5 : 1.5,
                      )),
                  ),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: selected == null ? null : () { reason = selected; Navigator.pop(ctx, true); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
                    foregroundColor: Colors.white, disabledBackgroundColor: AppColors.border,
                    elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Tolak Pesanan', style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ]),
        ),
      ),
    );

    if (confirmed == true) {
      _updateOrder(order.copyWith(status: MitraOrderStatus.rejected, cancellationReason: reason));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pesanan ditolak'), backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _openDetail(MitraOrderModel order) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => MitraOrderDetailScreen(order: order, onUpdate: _updateOrder),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Pesanan', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Baru (${_newOrders.length})'),
            Tab(text: 'Aktif (${_activeOrders.length})'),
            const Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _newOrders.isEmpty
              ? const _EmptyState(emoji: '🔔', title: 'Belum ada pesanan baru',
                  subtitle: 'Pesanan baru dari pelanggan akan muncul di sini')
              : _OrderList(orders: _newOrders, onTap: _openDetail, showActions: true,
                  onAccept: _accept, onReject: _rejectDialog),
          _activeOrders.isEmpty
              ? const _EmptyState(emoji: '🔧', title: 'Tidak ada pesanan aktif',
                  subtitle: 'Pesanan yang sedang berjalan akan tampil di sini')
              : _OrderList(orders: _activeOrders, onTap: _openDetail, showActions: false),
          _historyOrders.isEmpty
              ? const _EmptyState(emoji: '📋', title: 'Belum ada riwayat',
                  subtitle: 'Pesanan selesai & dibatalkan akan muncul di sini')
              : _OrderList(orders: _historyOrders, onTap: _openDetail, showActions: false),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<MitraOrderModel> orders;
  final void Function(MitraOrderModel) onTap;
  final bool showActions;
  final void Function(MitraOrderModel)? onAccept;
  final void Function(MitraOrderModel)? onReject;
  const _OrderList({required this.orders, required this.onTap,
      required this.showActions, this.onAccept, this.onReject});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(
        order: orders[i], onTap: () => onTap(orders[i]),
        showActions: showActions,
        onAccept: onAccept != null ? () => onAccept!(orders[i]) : null,
        onReject: onReject != null ? () => onReject!(orders[i]) : null,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final MitraOrderModel order;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onAccept, onReject;
  const _OrderCard({required this.order, required this.onTap,
      required this.showActions, this.onAccept, this.onReject});

  Color get _statusColor {
    switch (order.status) {
      case MitraOrderStatus.pending:    return AppColors.warning;
      case MitraOrderStatus.confirmed:  return AppColors.primary;
      case MitraOrderStatus.onTheWay:   return AppColors.info;
      case MitraOrderStatus.inProgress: return AppColors.primary;
      case MitraOrderStatus.completed:  return AppColors.success;
      default:                          return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == MitraOrderStatus.pending;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending ? AppColors.warning.withOpacity(0.5) : AppColors.border,
            width: isPending ? 1.5 : 0.5,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Text(order.serviceEmoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.serviceName, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(order.customerName, style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${order.status.emoji} ${order.status.label}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: _statusColor)),
              ),
            ]),
          ),
          Container(height: 0.5, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 14)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text('${order.formattedDate} · ${order.formattedTime}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                Text(order.formattedPrice, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(child: Text(order.address, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ]),
              if (order.notes != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Expanded(child: Text(order.notes!, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint,
                          fontStyle: FontStyle.italic))),
                ]),
              ],
            ]),
          ),
          if (showActions) ...[
            Container(height: 0.5, color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: const Text('Tolak', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success,
                      foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: const Text('Terima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                )),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
  const _EmptyState({required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ]),
    ));
  }
}
