import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'register_mitra_screen.dart';
import 'login_mitra_screen.dart';

class AuthMitraScreen extends StatelessWidget {
  const AuthMitraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🛠️', style: TextStyle(fontSize: 38))),
            ),
            const SizedBox(height: 20),
            const Text('JasaKu Mitra', style: TextStyle(fontSize: 28,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Platform untuk penyedia jasa profesional',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 36),
            _BenefitItem(icon: Icons.payments_outlined,
                text: 'Terima pembayaran aman lewat escrow JasaKu'),
            _BenefitItem(icon: Icons.star_outline_rounded,
                text: 'Bangun reputasi dengan sistem ulasan terverifikasi'),
            _BenefitItem(icon: Icons.people_outline_rounded,
                text: 'Jangkau lebih banyak pelanggan di sekitarmu'),
            _BenefitItem(icon: Icons.trending_up_rounded,
                text: 'Pantau pendapatan & performa real-time'),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterMitraScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Daftar sebagai Mitra',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginMitraScreen())),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Masuk ke Akun Mitra',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Dengan mendaftar, kamu menyetujui Syarat & Ketentuan\ndan Kebijakan Privasi JasaKu Mitra',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textHint, height: 1.5)),
          ]),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
      ]),
    );
  }
}
