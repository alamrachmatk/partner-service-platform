import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_order_model.dart';
import '../../../../core/services/mitra_notification_service.dart';
import '../../../orders/presentation/screens/mitra_order_detail_screen.dart';

class MitraNotificationsScreen extends StatefulWidget {
  const MitraNotificationsScreen({super.key});

  @override
  State<MitraNotificationsScreen> createState() =>
      _MitraNotificationsScreenState();
}

class _MitraNotificationsScreenState extends State<MitraNotificationsScreen> {
  final _svc = MitraNotificationService();
  MitraNotifType? _filter; // null = semua

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Baru saja';
    if (d.inMinutes < 60) return '${d.inMinutes} mnt lalu';
    if (d.inHours < 24) return '${d.inHours} jam lalu';
    if (d.inDays == 1) return 'Kemarin';
    return '${d.inDays} hari lalu';
  }

  void _open(MitraNotif n) {
    _svc.markRead(n.id);
    final orderId = n.orderId;
    if (orderId == null) return;

    final matches = DummyMitraOrders.all.where((o) => o.id == orderId);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pesanan $orderId tidak ditemukan'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MitraOrderDetailScreen(
          order: matches.first, onUpdate: (_) {}),
    ));
  }

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Semua Notifikasi?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Semua notifikasi akan dihapus permanen.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) _svc.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _svc,
      builder: (context, _) {
        final all = _svc.items;
        final list = _filter == null
            ? all
            : all.where((n) => n.type == _filter).toList();
        final unread = _svc.unreadCount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white, elevation: 0, centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 18, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Notifikasi', style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.error,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('$unread', style: const TextStyle(
                      fontSize: 11, color: Colors.white,
                      fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
            actions: [
              if (unread > 0)
                TextButton(
                  onPressed: _svc.markAllRead,
                  child: const Text('Tandai dibaca', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
                ),
              if (all.isNotEmpty)
                IconButton(
                  tooltip: 'Hapus semua',
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: AppColors.textSecondary, size: 22),
                  onPressed: _confirmClearAll,
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: Column(children: [
            // ── Filter ──
            Container(
              color: Colors.white,
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                children: [
                  _FilterChip(label: 'Semua', selected: _filter == null,
                      onTap: () => setState(() => _filter = null)),
                  ...MitraNotifType.values.map((t) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: t.label, selected: _filter == t,
                      onTap: () => setState(() => _filter = t),
                    ),
                  )),
                ],
              ),
            ),
            const Divider(height: 0),

            // ── List ──
            Expanded(
              child: list.isEmpty
                  ? _Empty(isFiltered: _filter != null)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final n = list[i];
                        return Dismissible(
                          key: ValueKey(n.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            _svc.remove(n.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notifikasi dihapus'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ));
                          },
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white),
                          ),
                          child: _NotifTile(
                            notif: n, ago: _ago(n.time),
                            onTap: () => _open(n),
                          ),
                        );
                      },
                    ),
            ),
          ]),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final MitraNotif notif;
  final String ago;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.ago,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = notif.type.color;
    final unread = !notif.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppColors.primary.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unread
                ? AppColors.primary.withOpacity(0.25) : AppColors.border,
            width: unread ? 1 : 0.5,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(notif.type.icon, color: c, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(notif.title, style: TextStyle(
                    fontSize: 13,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textPrimary))),
                if (unread)
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(notif.body, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textSecondary, height: 1.45)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(notif.type.label, style: TextStyle(
                      fontSize: 10, color: c, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(ago, style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint)),
                const Spacer(),
                if (notif.orderId != null)
                  const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Lihat pesanan', style: TextStyle(fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right_rounded,
                        size: 14, color: AppColors.primary),
                  ]),
              ]),
            ],
          )),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Center(child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary))),
    ),
  );
}

class _Empty extends StatelessWidget {
  final bool isFiltered;
  const _Empty({required this.isFiltered});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 84, height: 84,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.notifications_off_outlined,
            size: 40, color: AppColors.primary),
      ),
      const SizedBox(height: 16),
      Text(isFiltered
          ? 'Tidak ada notifikasi di kategori ini'
          : 'Belum ada notifikasi',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('Pesanan, pembayaran, dan ulasan baru\nakan muncul di sini',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13,
              color: AppColors.textSecondary, height: 1.5)),
    ]),
  ));
}
