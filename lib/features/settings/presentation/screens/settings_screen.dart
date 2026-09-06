import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Notifikasi ──
  bool _notifPesananBaru    = true;
  bool _notifChat           = true;
  bool _notifPembayaran     = true;
  bool _notifUlasan         = true;
  bool _notifPromo          = false;
  bool _notifPengingat      = true;

  // ── Suara & getar ──
  bool _suaraNotif          = true;
  bool _getarNotif          = true;
  bool _suaraPesan          = true;

  // ── Umum ──
  bool _modeMalam           = false;
  String _bahasa            = 'Indonesia';

  static const _bahasaOptions = ['Indonesia', 'English'];

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi & Pengaturan',
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

          // ── Notifikasi ──
          _SectionHeader(title: 'Notifikasi',
              icon: Icons.notifications_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.primary,
              title: 'Pesanan Baru',
              subtitle: 'Notifikasi saat ada pesanan masuk',
              value: _notifPesananBaru,
              onChanged: (v) {
                setState(() => _notifPesananBaru = v);
                _snack(v ? 'Notif pesanan baru aktif' : 'Notif pesanan baru nonaktif');
              },
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: AppColors.info,
              title: 'Pesan Chat',
              subtitle: 'Notifikasi saat ada pesan dari pelanggan',
              value: _notifChat,
              onChanged: (v) => setState(() => _notifChat = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.payments_outlined,
              iconColor: AppColors.success,
              title: 'Pembayaran & Saldo',
              subtitle: 'Notifikasi pencairan dan transaksi',
              value: _notifPembayaran,
              onChanged: (v) => setState(() => _notifPembayaran = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.star_outline_rounded,
              iconColor: AppColors.secondary,
              title: 'Ulasan Baru',
              subtitle: 'Notifikasi saat pelanggan memberi ulasan',
              value: _notifUlasan,
              onChanged: (v) => setState(() => _notifUlasan = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.campaign_outlined,
              iconColor: AppColors.warning,
              title: 'Promo & Info',
              subtitle: 'Informasi promo dan update platform',
              value: _notifPromo,
              onChanged: (v) => setState(() => _notifPromo = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.alarm_outlined,
              iconColor: AppColors.error,
              title: 'Pengingat Jadwal',
              subtitle: 'Pengingat H-1 sebelum jadwal layanan',
              value: _notifPengingat,
              onChanged: (v) => setState(() => _notifPengingat = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Suara & Getar ──
          _SectionHeader(title: 'Suara & Getar',
              icon: Icons.volume_up_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.primary,
              title: 'Suara Notifikasi',
              subtitle: 'Bunyi saat ada notifikasi masuk',
              value: _suaraNotif,
              onChanged: (v) => setState(() => _suaraNotif = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.vibration_rounded,
              iconColor: AppColors.info,
              title: 'Getar',
              subtitle: 'Getaran saat ada notifikasi masuk',
              value: _getarNotif,
              onChanged: (v) => setState(() => _getarNotif = v),
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.chat_outlined,
              iconColor: AppColors.success,
              title: 'Suara Pesan',
              subtitle: 'Bunyi saat menerima pesan chat',
              value: _suaraPesan,
              onChanged: (v) => setState(() => _suaraPesan = v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Pengaturan Umum ──
          _SectionHeader(title: 'Pengaturan Umum',
              icon: Icons.settings_outlined),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFF5C6BC0),
              title: 'Mode Malam',
              subtitle: 'Tampilan gelap untuk menghemat baterai',
              value: _modeMalam,
              onChanged: (v) {
                setState(() => _modeMalam = v);
                _snack('Mode malam ${v ? 'aktif' : 'nonaktif'} '
                    '(tersedia di versi berikutnya)');
              },
            ),
            const _Divider(),
            _SelectTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.primary,
              title: 'Bahasa',
              value: _bahasa,
              options: _bahasaOptions,
              onChanged: (v) => setState(() => _bahasa = v),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.warning,
              title: 'Keamanan Akun',
              subtitle: 'PIN, biometrik, dan sesi login',
              onTap: () => _showSecuritySheet(),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.phone_android_rounded,
              iconColor: AppColors.info,
              title: 'Ubah Nomor HP',
              subtitle: 'Verifikasi OTP diperlukan',
              onTap: () => _snack('Fitur ubah nomor HP segera hadir'),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Info Aplikasi ──
          _SectionHeader(title: 'Info Aplikasi',
              icon: Icons.info_outline_rounded),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _NavTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.primary,
              title: 'Syarat & Ketentuan',
              onTap: () => _showInfoSheet('Syarat & Ketentuan',
                  'Dengan menggunakan aplikasi JasaKu Mitra, kamu menyetujui '
                  'seluruh syarat dan ketentuan yang berlaku. '
                  'JasaKu berhak memperbarui ketentuan sewaktu-waktu.'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.info,
              title: 'Kebijakan Privasi',
              onTap: () => _showInfoSheet('Kebijakan Privasi',
                  'JasaKu berkomitmen melindungi data pribadi mitra. '
                  'Data yang dikumpulkan hanya digunakan untuk '
                  'keperluan operasional platform dan tidak dijual '
                  'kepada pihak ketiga.'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.success,
              title: 'Hubungi CS Mitra',
              subtitle: 'WhatsApp: +62 812-3456-7890',
              onTap: () => _snack('Membuka WhatsApp CS Mitra...'),
            ),
            const _Divider(),
            _NavTile(
              icon: Icons.star_rate_rounded,
              iconColor: AppColors.secondary,
              title: 'Beri Rating Aplikasi',
              subtitle: 'Bantu kami berkembang dengan ulasanmu',
              onTap: () => _snack('Membuka Play Store...'),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Versi app ──
          Center(child: Column(children: [
            const Text('JasaKu Mitra', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            const Text('Versi 1.0.0 (Build 100)',
                style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Versi terbaru ✓',
                  style: TextStyle(fontSize: 10, color: AppColors.success,
                      fontWeight: FontWeight.w600)),
            ),
          ])),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showSecuritySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Keamanan Akun', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _SettingsCard(children: [
            _NavTile(icon: Icons.pin_outlined, iconColor: AppColors.primary,
                title: 'Atur PIN', subtitle: 'PIN 6 digit untuk keamanan',
                onTap: () { Navigator.pop(context); _snack('Fitur PIN segera hadir'); }),
            const _Divider(),
            _NavTile(icon: Icons.fingerprint_rounded, iconColor: AppColors.success,
                title: 'Biometrik', subtitle: 'Login dengan sidik jari/wajah',
                onTap: () { Navigator.pop(context); _snack('Fitur biometrik segera hadir'); }),
            const _Divider(),
            _NavTile(icon: Icons.devices_outlined, iconColor: AppColors.warning,
                title: 'Sesi Aktif', subtitle: 'Kelola perangkat yang login',
                onTap: () { Navigator.pop(context); _snack('Fitur sesi aktif segera hadir'); }),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showInfoSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(content, style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48,
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

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15,
        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0, indent: 56, endIndent: 0);
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTile({required this.icon, required this.iconColor,
      required this.title, this.subtitle, required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
          ],
        )),
        Switch(
          value: value, onChanged: onChanged,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavTile({required this.icon, required this.iconColor,
      required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 18),
        ]),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, value;
  final List<String> options;
  final void Function(String) onChanged;

  const _SelectTile({required this.icon, required this.iconColor,
      required this.title, required this.value, required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textHint, size: 18),
          style: const TextStyle(fontSize: 13,
              color: AppColors.primary, fontWeight: FontWeight.w600),
          items: options.map((o) => DropdownMenuItem(
            value: o,
            child: Text(o),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ]),
    );
  }
}
