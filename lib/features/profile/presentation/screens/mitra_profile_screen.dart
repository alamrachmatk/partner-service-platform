import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';
import 'edit_profile_mitra_screen.dart';
import 'portfolio_screen.dart';
import 'service_area_screen.dart';
import '../../../auth/presentation/screens/auth_mitra_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';

class MitraProfileScreen extends StatelessWidget {
  final MitraModel mitra;
  const MitraProfileScreen({super.key, required this.mitra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Kartu profil utama ──
          _ProfileCard(mitra: mitra),
          const SizedBox(height: 12),

          // ── Statistik ──
          _StatsCard(),
          const SizedBox(height: 16),

          // ── Menu ──
          _MenuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Pendapatan & Saldo',
            subtitle: 'Lihat saldo dan tarik dana',
            color: AppColors.success,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const EarningsScreen())),
          ),
          _MenuItem(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profil',
            subtitle: 'Ubah nama, bio, dan kontak',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => EditProfileMitraScreen(mitra: mitra))),
          ),
          _MenuItem(
            icon: Icons.photo_library_outlined,
            label: 'Portofolio',
            subtitle: 'Kelola foto hasil kerja',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PortfolioScreen())),
          ),
          _MenuItem(
            icon: Icons.location_on_outlined,
            label: 'Area Layanan',
            subtitle: 'Atur jangkauan dan wilayah',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const ServiceAreaScreen())),
          ),
          const SizedBox(height: 8),

          // ── Keluar ──
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.2), width: 0.5),
              ),
              child: const Row(children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                SizedBox(width: 14),
                Text('Keluar dari Akun', style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: AppColors.error)),
              ]),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Akun?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Kamu perlu login kembali untuk mengakses aplikasi.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthMitraScreen()),
              (_) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final MitraModel mitra;
  const _ProfileCard({required this.mitra});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        // Avatar + badge verified
        Stack(children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(mitra.initials,
                style: const TextStyle(fontSize: 30,
                    fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          if (mitra.status == MitraStatus.verified)
            Positioned(bottom: 0, right: 0,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 13),
              )),
        ]),
        const SizedBox(height: 12),
        Text(mitra.fullName, style: const TextStyle(fontSize: 18,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        if (mitra.categories.isNotEmpty)
          Text(mitra.categories.join(' · '),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: mitra.status == MitraStatus.verified
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              mitra.status == MitraStatus.verified
                  ? Icons.verified_rounded
                  : Icons.pending_outlined,
              size: 14,
              color: mitra.status == MitraStatus.verified
                  ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: 5),
            Text(mitra.status.label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: mitra.status == MitraStatus.verified
                    ? AppColors.success : AppColors.warning)),
          ]),
        ),
        const SizedBox(height: 10),
        // Rating
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.star_rounded, color: AppColors.secondary, size: 18),
          const SizedBox(width: 4),
          const Text('4.8', style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          const Text('(94 ulasan)', style: TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        _StatItem(value: '124', label: 'Order\nSelesai',
            color: AppColors.primary),
        _Divider(),
        _StatItem(value: '4.8⭐', label: 'Rating\nRata-rata',
            color: AppColors.secondary),
        _Divider(),
        _StatItem(value: '95%', label: 'Tingkat\nRespons',
            color: AppColors.success),
        _Divider(),
        _StatItem(value: '2 thn', label: 'Bergabung\nSejak',
            color: AppColors.info),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: TextStyle(fontSize: 15,
          fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10,
              color: AppColors.textSecondary, height: 1.3)),
    ]));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: AppColors.border);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label,
      required this.subtitle, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ]),
      ),
    );
  }
}
