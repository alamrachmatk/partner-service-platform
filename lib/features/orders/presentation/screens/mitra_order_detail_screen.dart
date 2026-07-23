import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_order_model.dart';

class MitraOrderDetailScreen extends StatefulWidget {
  final MitraOrderModel order;
  final void Function(MitraOrderModel) onUpdate;

  const MitraOrderDetailScreen({
    super.key,
    required this.order,
    required this.onUpdate,
  });

  @override
  State<MitraOrderDetailScreen> createState() => _MitraOrderDetailScreenState();
}

class _MitraOrderDetailScreenState extends State<MitraOrderDetailScreen> {
  late MitraOrderModel _order;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus() async {
    final next = _order.nextStatus;
    if (next == null) return;

    // Konfirmasi jika status selesai
    if (next == MitraOrderStatus.completed) {
      final confirmed = await _showCompleteDialog();
      if (!confirmed) return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final updated = _order.copyWith(status: next);
    setState(() { _order = updated; _loading = false; });
    widget.onUpdate(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Status diperbarui: ${next.label}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<bool> _showCompleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Selesaikan Pesanan?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'Pastikan semua pekerjaan sudah selesai dan pelanggan sudah puas sebelum menyelesaikan pesanan.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Belum', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Selesai', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ) ?? false;
  }

  Color get _statusColor {
    switch (_order.status) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail ${_order.id}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, _order.status.canUpdateStatus ? 100 : 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Status badge ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Row(children: [
                Text(_order.status.emoji,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_order.status.label,
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w700, color: _statusColor)),
                    const SizedBox(height: 2),
                    Text(_statusDesc,
                        style: const TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Timeline status ──
            _StatusTimeline(currentStatus: _order.status),
            const SizedBox(height: 16),

            // ── Info layanan ──
            _SectionCard(title: 'Layanan', icon: Icons.handyman_outlined,
              child: Column(children: [
                _InfoRow(label: 'Layanan', value: _order.serviceName),
                _InfoRow(label: 'ID Order', value: _order.id,
                    valueColor: AppColors.primary),
                _InfoRow(label: 'Total', value: _order.formattedPrice,
                    valueColor: AppColors.primary, isBold: true),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Info jadwal ──
            _SectionCard(title: 'Jadwal', icon: Icons.calendar_today_outlined,
              child: Column(children: [
                _InfoRow(label: 'Tanggal', value: _order.formattedDate),
                _InfoRow(label: 'Waktu', value: _order.formattedTime),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Info pelanggan ──
            _SectionCard(title: 'Pelanggan', icon: Icons.person_outline_rounded,
              child: Column(children: [
                _InfoRow(label: 'Nama', value: _order.customerName),
                _InfoRow(label: 'No. HP', value: _order.customerPhone),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Alamat ──
            _SectionCard(title: 'Alamat Kunjungan', icon: Icons.location_on_outlined,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_order.address, style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka maps...'),
                          behavior: SnackBarBehavior.floating)),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Buka di Maps'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Catatan ──
            if (_order.notes != null)
              _SectionCard(title: 'Catatan Pelanggan',
                  icon: Icons.sticky_note_2_outlined,
                child: Text(_order.notes!,
                    style: const TextStyle(fontSize: 14,
                        color: AppColors.textSecondary, height: 1.5,
                        fontStyle: FontStyle.italic)),
              ),

            // ── Info penolakan ──
            if (_order.cancellationReason != null)
              _SectionCard(title: 'Alasan Penolakan/Pembatalan',
                  icon: Icons.info_outline_rounded,
                child: Text(_order.cancellationReason!,
                    style: const TextStyle(fontSize: 14,
                        color: AppColors.error, height: 1.5)),
              ),

            // ── Kontak pelanggan ──
            if (_order.status.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _SectionCard(title: 'Kontak Pelanggan',
                    icon: Icons.contact_phone_outlined,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Menghubungi ${_order.customerName}...'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating)),
                      icon: const Icon(Icons.chat_rounded, size: 16),
                      label: const Text('Chat Pelanggan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),

        // ── Bottom bar update status ──
        if (_order.status.canUpdateStatus)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.play_arrow_rounded, size: 20),
                        const SizedBox(width: 6),
                        Text(_order.nextStatusLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
              ),
            ),
          ),
      ]),
    );
  }

  String get _statusDesc {
    switch (_order.status) {
      case MitraOrderStatus.pending:    return 'Menunggu kamu konfirmasi pesanan ini';
      case MitraOrderStatus.confirmed:  return 'Pesanan dikonfirmasi, siapkan diri untuk berangkat';
      case MitraOrderStatus.onTheWay:   return 'Kamu sedang dalam perjalanan ke lokasi pelanggan';
      case MitraOrderStatus.inProgress: return 'Pengerjaan sedang berlangsung di lokasi';
      case MitraOrderStatus.completed:  return 'Pesanan telah selesai dikerjakan';
      case MitraOrderStatus.cancelled:  return 'Pesanan dibatalkan oleh pelanggan';
      case MitraOrderStatus.rejected:   return 'Kamu menolak pesanan ini';
    }
  }
}

// ── Timeline status ──
class _StatusTimeline extends StatelessWidget {
  final MitraOrderStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  static const _steps = [
    (status: MitraOrderStatus.pending,    label: 'Pesanan Masuk'),
    (status: MitraOrderStatus.confirmed,  label: 'Dikonfirmasi'),
    (status: MitraOrderStatus.onTheWay,   label: 'Berangkat'),
    (status: MitraOrderStatus.inProgress, label: 'Dikerjakan'),
    (status: MitraOrderStatus.completed,  label: 'Selesai'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexWhere((s) => s.status == currentStatus);
    final isCancelled = currentStatus == MitraOrderStatus.cancelled ||
        currentStatus == MitraOrderStatus.rejected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Progress Pesanan', style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 14),

        isCancelled
            ? Row(children: [
                Container(width: 28, height: 28,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 16)),
                const SizedBox(width: 10),
                Text(currentStatus.label,
                    style: const TextStyle(fontSize: 13,
                        color: AppColors.error, fontWeight: FontWeight.w600)),
              ])
            : Row(
                children: List.generate(_steps.length * 2 - 1, (i) {
                  if (i.isOdd) {
                    final stepIdx = i ~/ 2;
                    return Expanded(child: Container(height: 2,
                      color: stepIdx < currentIdx
                          ? AppColors.primary
                          : AppColors.border,
                    ));
                  }
                  final idx = i ~/ 2;
                  final done = idx < currentIdx;
                  final active = idx == currentIdx;
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: done ? AppColors.primary
                            : active ? AppColors.primary.withOpacity(0.15)
                            : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (done || active) ? AppColors.primary : AppColors.border,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Center(child: done
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 13)
                          : active
                              ? Container(width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle))
                              : null),
                    ),
                    const SizedBox(height: 4),
                    Text(_steps[idx].label, style: TextStyle(
                      fontSize: 9,
                      color: (done || active) ? AppColors.primary : AppColors.textHint,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ), textAlign: TextAlign.center),
                  ]);
                }),
              ),
      ]),
    );
  }
}

// ── Section card ──
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

// ── Info row ──
class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold;
  const _InfoRow({required this.label, required this.value,
      this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: TextStyle(
            fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary))),
      ]),
    );
  }
}
