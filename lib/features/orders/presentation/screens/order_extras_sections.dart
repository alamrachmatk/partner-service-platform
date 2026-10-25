import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_order_model.dart';
import '../../../../core/models/order_extras_model.dart';
import '../../../../core/services/order_extras_service.dart';
import '../../../../core/utils/currency_format.dart';

// ═════════════════════════════════════════════
// BIAYA TAMBAHAN
// Tampil saat pesanan "Sedang Dikerjakan" (bisa diajukan) dan "Selesai"
// (hanya baca, itupun jika ada datanya).
// ═════════════════════════════════════════════
class ExtraChargeSection extends StatelessWidget {
  final MitraOrderModel order;
  const ExtraChargeSection({super.key, required this.order});

  bool get _editable => order.status == MitraOrderStatus.inProgress;
  bool get _visibleStatus =>
      order.status == MitraOrderStatus.inProgress ||
      order.status == MitraOrderStatus.completed;

  @override
  Widget build(BuildContext context) {
    if (!_visibleStatus) return const SizedBox.shrink();
    final svc = OrderExtrasService();

    return AnimatedBuilder(
      animation: svc,
      builder: (context, _) {
        final charges = svc.chargesOf(order.id);
        if (!_editable && charges.isEmpty) return const SizedBox.shrink();
        final approved = svc.approvedTotal(order.id);

        return _SectionCard(
          title: 'Biaya Tambahan',
          icon: Icons.add_card_outlined,
          trailing: charges.isEmpty
              ? null
              : _CountBadge(count: charges.length),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (charges.isEmpty)
              const _InfoBox(
                icon: Icons.info_outline_rounded,
                color: AppColors.info,
                text: 'Ada biaya di luar paket (spare part, material, atau '
                    'ongkos tambahan)? Ajukan ke pelanggan dan tunggu '
                    'persetujuannya sebelum melanjutkan pekerjaan.',
              ),
            ...charges.map((c) => _ChargeTile(
              charge: c,
              onCancel: _editable
                  ? () => svc.cancelCharge(order.id, c.id)
                  : null,
            )),

            // Ringkasan total
            if (approved > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  _SummaryRow(label: 'Harga pesanan',
                      value: rupiah(order.price)),
                  const SizedBox(height: 6),
                  _SummaryRow(label: 'Biaya tambahan (disetujui)',
                      value: '+ ${rupiah(approved)}',
                      valueColor: AppColors.success),
                  const Divider(height: 18),
                  _SummaryRow(label: 'Total akhir',
                      value: rupiah(order.price + approved),
                      bold: true, valueColor: AppColors.primary),
                ]),
              ),
            ],

            if (_editable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Ajukan Biaya Tambahan',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ]),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddChargeSheet(orderId: order.id),
    );
  }
}

class _ChargeTile extends StatelessWidget {
  final ExtraCharge charge;
  final VoidCallback? onCancel;
  const _ChargeTile({required this.charge, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final rejected = charge.status == ExtraChargeStatus.rejected;
    final pending = charge.status == ExtraChargeStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(charge.name, style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: rejected
                      ? AppColors.textHint : AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text(charge.reason, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.textSecondary, height: 1.4)),
            ],
          )),
          const SizedBox(width: 10),
          Text(rupiah(charge.amount), style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration:
                  rejected ? TextDecoration.lineThrough : null,
              color: rejected
                  ? AppColors.textHint : AppColors.textPrimary)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatusChip(status: charge.status),
          const Spacer(),
          if (pending && onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: const Text('Batalkan', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.error)),
            ),
        ]),
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ExtraChargeStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case ExtraChargeStatus.pending:  return AppColors.warning;
      case ExtraChargeStatus.approved: return AppColors.success;
      case ExtraChargeStatus.rejected: return AppColors.error;
    }
  }

  String get _label {
    switch (status) {
      case ExtraChargeStatus.pending:  return 'Menunggu pelanggan';
      case ExtraChargeStatus.approved: return 'Disetujui';
      case ExtraChargeStatus.rejected: return 'Ditolak';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (status == ExtraChargeStatus.pending)
          SizedBox(
            width: 10, height: 10,
            child: CircularProgressIndicator(
                strokeWidth: 1.6, color: _color),
          )
        else
          Icon(status == ExtraChargeStatus.approved
              ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 12, color: _color),
        const SizedBox(width: 5),
        Text(_label, style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w700, color: _color)),
      ]),
    );
  }
}

// ── Bottom sheet ajukan biaya ──
class _AddChargeSheet extends StatefulWidget {
  final String orderId;
  const _AddChargeSheet({required this.orderId});

  @override
  State<_AddChargeSheet> createState() => _AddChargeSheetState();
}

class _AddChargeSheetState extends State<_AddChargeSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  static const _suggestions = [
    'Spare part', 'Material tambahan', 'Ongkos tambahan', 'Jam kerja tambahan',
  ];

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;
  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _amount > 0 &&
      _reasonCtrl.text.trim().length >= 5;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_valid) return;
    OrderExtrasService().addCharge(
      orderId: widget.orderId,
      name: _nameCtrl.text.trim(),
      amount: _amount,
      reason: _reasonCtrl.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Diajukan ke pelanggan. Menunggu persetujuan...'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  InputDecoration _deco(String hint, {String? prefix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
    prefixText: prefix,
    filled: true, fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _label(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Text(t, style: const TextStyle(fontSize: 13,
        fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Ajukan Biaya Tambahan', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 18),

          _label('Jenis Biaya *'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(spacing: 8, runSpacing: 8,
              children: _suggestions.map((s) => GestureDetector(
                onTap: () => setState(() => _nameCtrl.text = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _nameCtrl.text == s
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _nameCtrl.text == s
                          ? AppColors.primary : AppColors.border,
                      width: _nameCtrl.text == s ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12,
                      fontWeight: _nameCtrl.text == s
                          ? FontWeight.w700 : FontWeight.w500,
                      color: _nameCtrl.text == s
                          ? AppColors.primary : AppColors.textSecondary)),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14,
                color: AppColors.textPrimary),
            decoration: _deco('cth: Ganti kapasitor AC'),
          ),
          const SizedBox(height: 14),

          _label('Nominal *'),
          const SizedBox(height: 6),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            decoration: _deco('0', prefix: 'Rp '),
          ),
          if (_amount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(rupiah(_amount), style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
              ),
            ),
          const SizedBox(height: 14),

          _label('Alasan / Penjelasan *'),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3, maxLength: 200,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14,
                color: AppColors.textPrimary),
            decoration: _deco(
                'Jelaskan kenapa biaya ini diperlukan, agar pelanggan '
                'paham dan mudah menyetujui...'),
          ),
          const SizedBox(height: 8),

          const _InfoBox(
            icon: Icons.verified_user_outlined,
            color: AppColors.primary,
            text: 'Pelanggan akan menerima notifikasi dan harus menyetujui '
                'dulu sebelum biaya ini ditagihkan.',
          ),
          const SizedBox(height: 6),
          const Text(
            'Mode simulasi: pelanggan merespons otomatis dalam ±5 detik. '
            'Biaya di atas Rp 500.000 akan ditolak.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textHint,
                fontStyle: FontStyle.italic, height: 1.4),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Batal',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: ElevatedButton(
              onPressed: _valid ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Ajukan ke Pelanggan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// FOTO SEBELUM / SESUDAH
// ═════════════════════════════════════════════
class BeforeAfterSection extends StatelessWidget {
  final MitraOrderModel order;
  const BeforeAfterSection({super.key, required this.order});

  bool get _editable => order.status == MitraOrderStatus.inProgress;
  bool get _visibleStatus =>
      order.status == MitraOrderStatus.inProgress ||
      order.status == MitraOrderStatus.completed;

  Future<void> _addPhoto(BuildContext context, bool before) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).padding.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Foto ${before ? 'Sebelum' : 'Sesudah'} Pekerjaan',
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _SourceBtn(
              icon: Icons.photo_library_outlined, label: 'Galeri',
              onTap: () => Navigator.pop(ctx, 'gallery'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _SourceBtn(
              icon: Icons.camera_alt_outlined, label: 'Kamera',
              onTap: () => Navigator.pop(ctx, 'camera'),
            )),
          ]),
        ]),
      ),
    );
    if (source == null) return;

    final path = await _PhotoPickerStub.pick(
        fromCamera: source == 'camera', before: before);
    if (path == null) return;
    OrderExtrasService().addPhoto(order.id, before: before, path: path);
  }

  void _preview(BuildContext context, OrderPhoto photo, String label, int i) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 240, width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              // TODO: tampilkan foto asli setelah image_picker aktif:
              // child: ClipRRect(borderRadius: BorderRadius.circular(14),
              //   child: Image.file(File(photo.path), fit: BoxFit.cover)),
              child: const Icon(Icons.image_rounded,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text('Foto $label #${i + 1}', style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('Diambil pukul ${_hhmm(photo.takenAt)}',
                style: const TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white, elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visibleStatus) return const SizedBox.shrink();
    final svc = OrderExtrasService();

    return AnimatedBuilder(
      animation: svc,
      builder: (context, _) {
        final before = svc.photosOf(order.id, before: true);
        final after = svc.photosOf(order.id, before: false);
        if (!_editable && before.isEmpty && after.isEmpty) {
          return const SizedBox.shrink();
        }

        return _SectionCard(
          title: 'Foto Bukti Pekerjaan',
          icon: Icons.camera_alt_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Foto sebelum & sesudah melindungimu saat ada komplain '
                'dan meningkatkan kepercayaan pelanggan.',
                style: TextStyle(fontSize: 11,
                    color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 14),
            _PhotoRow(
              label: 'Sebelum', photos: before, editable: _editable,
              onAdd: () => _addPhoto(context, true),
              onRemove: (i) => svc.removePhoto(order.id, before: true, index: i),
              onTap: (i) => _preview(context, before[i], 'Sebelum', i),
            ),
            const SizedBox(height: 14),
            _PhotoRow(
              label: 'Sesudah', photos: after, editable: _editable,
              onAdd: () => _addPhoto(context, false),
              onRemove: (i) => svc.removePhoto(order.id, before: false, index: i),
              onTap: (i) => _preview(context, after[i], 'Sesudah', i),
            ),
            if (_editable && after.isEmpty) ...[
              const SizedBox(height: 12),
              const _InfoBox(
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
                text: 'Foto sesudah belum ada. Ambil sebelum menyelesaikan '
                    'pesanan.',
              ),
            ],
          ]),
        );
      },
    );
  }
}

class _PhotoRow extends StatelessWidget {
  final String label;
  final List<OrderPhoto> photos;
  final bool editable;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final void Function(int) onTap;
  const _PhotoRow({required this.label, required this.photos,
      required this.editable, required this.onAdd,
      required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final max = OrderExtrasService.maxPhotosPerSide;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Text('${photos.length}/$max', style: const TextStyle(
            fontSize: 11, color: AppColors.textHint)),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 78,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          ...List.generate(photos.length, (i) => Stack(children: [
            GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: 74, height: 74,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_rounded,
                        color: AppColors.primary, size: 26),
                    const SizedBox(height: 2),
                    Text(_hhmm(photos[i].takenAt), style: const TextStyle(
                        fontSize: 9, color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            if (editable)
              Positioned(top: 2, right: 10,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 12),
                  ),
                )),
          ])),
          if (editable && photos.length < max)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 74, height: 74,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        color: AppColors.primary, size: 22),
                    SizedBox(height: 3),
                    Text('Tambah', style: TextStyle(fontSize: 9,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          if (!editable && photos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text('Tidak ada foto', style: TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
            ),
        ]),
      ),
    ]);
  }
}

// ── Stub pemilih foto ──
// TODO: ganti dengan image_picker nyata saat backend/Firebase siap:
//   final picker = ImagePicker();
//   final x = await picker.pickImage(
//       source: fromCamera ? ImageSource.camera : ImageSource.gallery,
//       imageQuality: 80);
//   return x?.path;
class _PhotoPickerStub {
  static Future<String?> pick(
      {required bool fromCamera, required bool before}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'dummy_${before ? 'before' : 'after'}_'
        '${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ═════════════════════════════════════════════
// SHARED
// ═════════════════════════════════════════════
String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Widget child;
  const _SectionCard({required this.title, required this.icon,
      this.trailing, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        if (trailing != null) trailing!,
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text('$count', style: const TextStyle(fontSize: 11,
        fontWeight: FontWeight.w700, color: AppColors.primary)),
  );
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoBox({required this.icon, required this.color,
      required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(
          fontSize: 11, color: color, height: 1.45))),
    ]),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value,
      this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: bold ? 13 : 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? AppColors.textPrimary : AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: bold ? 15 : 12,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: valueColor ?? AppColors.textPrimary)),
    ],
  );
}

class _SourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceBtn({required this.icon, required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    ),
  );
}
