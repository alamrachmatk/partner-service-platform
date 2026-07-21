import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';
import 'auth_mitra_screen.dart';
import '../../../home/presentation/screens/main_mitra_screen.dart';

class VerificationStatusScreen extends StatelessWidget {
  final MitraModel mitra;
  const VerificationStatusScreen({super.key, required this.mitra});

  @override
  Widget build(BuildContext context) {
    final status = mitra.status;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(status.emoji,
                  style: const TextStyle(fontSize: 52))),
            ),
            const SizedBox(height: 24),
            const Text('Pendaftaran Dikirim!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(status.desc, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14,
                    color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 28),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                _InfoRow(label: 'Nama', value: mitra.fullName),
                const Divider(height: 16),
                _InfoRow(label: 'No. HP', value: mitra.phone),
                const Divider(height: 16),
                _InfoRow(label: 'Kategori',
                    value: mitra.categories.isEmpty ? '-' : mitra.categories.join(', ')),
                const Divider(height: 16),
                _InfoRow(label: 'Status',
                    value: '${status.emoji} ${status.label}',
                    valueColor: status.color),
                const Divider(height: 16),
                _InfoRow(label: 'ID Daftar',
                    value: mitra.id, valueColor: AppColors.primary),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Proses Verifikasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                _VerifStep(step: 1, title: 'Pendaftaran diterima',
                    desc: 'Data kamu sudah masuk ke sistem JasaKu',
                    isDone: true, isCurrent: false),
                _VerifStep(step: 2, title: 'Tinjauan dokumen (1-2 hari kerja)',
                    desc: 'Tim kami memeriksa KTP dan data identitas',
                    isDone: false, isCurrent: true),
                _VerifStep(step: 3, title: 'Verifikasi selesai',
                    desc: 'Kamu akan menerima notifikasi via WhatsApp',
                    isDone: false, isCurrent: false, isLast: true),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                SizedBox(width: 10),
                Expanded(child: Text(
                  'Pertanyaan? Hubungi tim mitra kami via WhatsApp:\n+62 812-3456-7890',
                  style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary, height: 1.5),
                )),
              ]),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                // ✅ Fix #1: showModalBottomSheet pakai isScrollControlled
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _StatusDetailSheet(mitra: mitra),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cek Status Verifikasi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthMitraScreen()),
                (_) => false,
              ),
              child: const Text('Kembali ke Halaman Awal',
                  style: TextStyle(fontSize: 14,
                      color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

// ✅ Fix #1: Bottom sheet pakai SingleChildScrollView agar tidak overflow
class _StatusDetailSheet extends StatelessWidget {
  final MitraModel mitra;
  const _StatusDetailSheet({required this.mitra});

  @override
  Widget build(BuildContext context) {
    final status = mitra.status;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // ✅ Kunci fix: pakai SingleChildScrollView + padding bottom dinamis
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle bar
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
                color: status.color.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(status.emoji,
                style: const TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),

          Text('Status: ${status.label}',
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700, color: status.color)),
          const SizedBox(height: 8),
          Text(status.desc, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13,
                  color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),

          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background,
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _InfoRow(label: 'ID Pendaftaran',
                  value: mitra.id, valueColor: AppColors.primary),
              const Divider(height: 14),
              _InfoRow(label: 'Nama', value: mitra.fullName),
              const Divider(height: 14),
              _InfoRow(label: 'Estimasi', value: '1-2 hari kerja'),
            ]),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      Expanded(child: Text(value, style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.textPrimary))),
    ]);
  }
}

class _VerifStep extends StatelessWidget {
  final int step;
  final String title, desc;
  final bool isDone, isCurrent, isLast;
  const _VerifStep({required this.step, required this.title,
      required this.desc, required this.isDone,
      required this.isCurrent, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : isCurrent ? AppColors.primary : AppColors.textHint;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success
                : isCurrent
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : Text('$step', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: color))),
        ),
        if (!isLast) Container(width: 2, height: 36, color: AppColors.border),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11,
              color: AppColors.textSecondary, height: 1.4)),
          if (isCurrent) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('Sedang berjalan', style: TextStyle(
                  fontSize: 10, color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      )),
    ]);
  }
}
