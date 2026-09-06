import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class _FaqItem {
  final String question, answer;
  bool isExpanded;
  _FaqItem({required this.question, required this.answer, this.isExpanded = false});
}

class _FaqCategory {
  final String title, emoji;
  final List<_FaqItem> items;
  const _FaqCategory({required this.title, required this.emoji, required this.items});
}

final _faqData = [
  _FaqCategory(title: 'Pesanan', emoji: '📋', items: [
    _FaqItem(question: 'Bagaimana cara menerima pesanan baru?',
        answer: 'Saat ada pesanan baru, kamu akan mendapat notifikasi. Buka tab Pesanan → Baru, lalu klik Terima atau Tolak dalam 5 menit. Jika tidak direspons, pesanan otomatis dibatalkan.'),
    _FaqItem(question: 'Apa yang terjadi jika saya menolak pesanan?',
        answer: 'Pesanan akan dibatalkan dan pelanggan mendapat refund. Penolakan terlalu sering dapat mempengaruhi peringkat dan tier akunmu.'),
    _FaqItem(question: 'Bagaimana cara update status pesanan?',
        answer: 'Buka detail pesanan → tekan tombol di bawah untuk update: Mulai Perjalanan → Mulai Pengerjaan → Selesai. Pastikan update sesuai kondisi nyata.'),
    _FaqItem(question: 'Pelanggan membatalkan, apakah saya tetap dibayar?',
        answer: 'Jika pembatalan setelah kamu konfirmasi dan sudah dalam perjalanan, kamu berhak mendapat kompensasi sesuai kebijakan JasaKu.'),
  ]),
  _FaqCategory(title: 'Pembayaran', emoji: '💰', items: [
    _FaqItem(question: 'Kapan pendapatan masuk ke saldo saya?',
        answer: 'Pendapatan masuk setelah pesanan Selesai dan melewati masa konfirmasi 24 jam. Dana aman di sistem escrow JasaKu.'),
    _FaqItem(question: 'Berapa biaya platform yang dipotong?',
        answer: 'Biaya platform sesuai tier:\n• Reguler: 12%\n• Silver: 10%\n• Gold: 8%\n• Platinum: 5%'),
    _FaqItem(question: 'Berapa lama proses penarikan dana?',
        answer: 'Penarikan diproses 1x24 jam hari kerja. Pengajuan sebelum 15:00 WIB diproses hari yang sama.'),
    _FaqItem(question: 'Apakah ada biaya penarikan?',
        answer: 'Penarikan ke semua rekening dan e-wallet GRATIS. Minimum penarikan Rp 50.000.'),
  ]),
  _FaqCategory(title: 'Akun & Profil', emoji: '👤', items: [
    _FaqItem(question: 'Berapa lama proses verifikasi akun?',
        answer: 'Verifikasi membutuhkan 1-2 hari kerja. Tim kami memeriksa KTP dan foto selfie. Hasil dikirim via WhatsApp dan notifikasi.'),
    _FaqItem(question: 'Bagaimana cara naik tier?',
        answer: 'Tier naik otomatis saat kamu memenuhi syarat: jumlah order, rating minimum, dan tingkat penyelesaian. Sistem cek setiap awal bulan.'),
    _FaqItem(question: 'Bagaimana jika akun saya diblokir?',
        answer: 'Akun bisa diblokir karena pelanggaran kebijakan atau laporan pelanggan. Hubungi CS Mitra via WhatsApp untuk proses banding.'),
  ]),
  _FaqCategory(title: 'Teknis', emoji: '⚙️', items: [
    _FaqItem(question: 'Notifikasi pesanan tidak muncul?',
        answer: 'Coba:\n1. Aktifkan notifikasi aplikasi di pengaturan HP\n2. Periksa Pengaturan → Notifikasi di aplikasi\n3. Restart aplikasi\n4. Jika masih bermasalah, hubungi CS.'),
    _FaqItem(question: 'Aplikasi sering force close?',
        answer: 'Hapus cache aplikasi, pastikan versi terbaru, restart HP. Jika masih bermasalah, screenshot error dan kirim ke CS Mitra.'),
    _FaqItem(question: 'Lokasi GPS tidak akurat?',
        answer: 'Aktifkan lokasi ke mode "Akurasi Tinggi". Pastikan aplikasi memiliki izin lokasi "Selalu". Atau input alamat manual.'),
  ]),
];

const _guideSteps = [
  (icon: '📝', title: 'Daftar & Verifikasi', desc: 'Isi formulir, upload KTP dan selfie. Verifikasi 1-2 hari kerja.'),
  (icon: '⚙️', title: 'Lengkapi Profil', desc: 'Isi bio, portofolio, atur layanan dan harga agar lebih dipercaya pelanggan.'),
  (icon: '📍', title: 'Atur Area & Jadwal', desc: 'Set radius jangkauan, pilih kecamatan, dan atur jam operasional harian.'),
  (icon: '🔔', title: 'Terima Pesanan', desc: 'Aktifkan notifikasi. Kamu punya 5 menit untuk terima atau tolak pesanan.'),
  (icon: '🚗', title: 'Kerjakan Layanan', desc: 'Update status real-time. Pelanggan bisa pantau progress kamu di aplikasi mereka.'),
  (icon: '⭐', title: 'Dapatkan Ulasan', desc: 'Ulasan baik meningkatkan peringkatmu di hasil pencarian pelanggan.'),
  (icon: '💰', title: 'Tarik Pendapatan', desc: 'Saldo masuk 24 jam setelah selesai. Tarik ke bank atau e-wallet, gratis biaya.'),
  (icon: '🏆', title: 'Naik Tier', desc: 'Kumpulkan order dan jaga rating untuk naik Silver → Gold → Platinum.'),
];

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose(); _searchCtrl.dispose();
    _subjectCtrl.dispose(); _msgCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color color = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty ? _faqData
        : _faqData.map((cat) => _FaqCategory(
            title: cat.title, emoji: cat.emoji,
            items: cat.items.where((i) =>
                i.question.toLowerCase().contains(_query.toLowerCase()) ||
                i.answer.toLowerCase().contains(_query.toLowerCase())).toList(),
          )).where((c) => c.items.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pusat Bantuan Mitra', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary, indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [Tab(text: 'FAQ'), Tab(text: 'Panduan'), Tab(text: 'Kontak CS')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [

        // ── Tab FAQ ──
        ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Cari pertanyaan...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
              suffixIcon: _query.isNotEmpty ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); }) : null,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('🔍', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text('Pertanyaan tidak ditemukan', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(height: 4),
                Text('Coba kata kunci lain atau hubungi CS',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])))
          else ...filtered.map((cat) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(cat.title, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                child: Column(children: List.generate(cat.items.length, (i) {
                  final item = cat.items[i];
                  final isLast = i == cat.items.length - 1;
                  return Column(children: [
                    InkWell(
                      onTap: () => setState(() => item.isExpanded = !item.isExpanded),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(padding: const EdgeInsets.all(14),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Text(item.question, style: TextStyle(fontSize: 13,
                              fontWeight: item.isExpanded ? FontWeight.w700 : FontWeight.w500,
                              color: item.isExpanded ? AppColors.primary : AppColors.textPrimary))),
                          const SizedBox(width: 8),
                          Icon(item.isExpanded ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textHint, size: 20),
                        ])),
                    ),
                    if (item.isExpanded)
                      Container(width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.03),
                          borderRadius: isLast ? const BorderRadius.vertical(
                              bottom: Radius.circular(14)) : null),
                        child: Text(item.answer, style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary, height: 1.6))),
                    if (!isLast && !item.isExpanded)
                      const Divider(height: 0, indent: 14, endIndent: 14),
                  ]);
                })),
              ),
              const SizedBox(height: 14),
            ],
          )),
          const SizedBox(height: 60),
        ]),

        // ── Tab Panduan ──
        ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Panduan lengkap untuk mitra baru JasaKu. '
                  'Ikuti langkah berikut untuk mulai menerima pesanan.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 16),
          ...List.generate(_guideSteps.length, (i) {
            final s = _guideSteps[i];
            final isLast = i == _guideSteps.length - 1;
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text(s.icon, style: const TextStyle(fontSize: 20)))),
                if (!isLast) Container(width: 2, height: 40, color: AppColors.border),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 20, height: 20,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(child: Text('${i + 1}', style: const TextStyle(
                          fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)))),
                    const SizedBox(width: 8),
                    Text(s.title, style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5)),
                    child: Text(s.desc, style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ),
                ]),
              )),
            ]);
          }),
          const SizedBox(height: 80),
        ]),

        // ── Tab Kontak CS ──
        ListView(padding: const EdgeInsets.all(16), children: [
          const _SecHeader(title: 'Hubungi Kami', icon: Icons.support_agent_rounded),
          const SizedBox(height: 10),
          _ContactCard(icon: Icons.chat_rounded, iconColor: const Color(0xFF25D366),
              title: 'WhatsApp CS Mitra', subtitle: '+62 812-3456-7890',
              badge: 'Respons < 5 menit', badgeColor: AppColors.success,
              onTap: () => _snack('Membuka WhatsApp...')),
          const SizedBox(height: 10),
          _ContactCard(icon: Icons.email_outlined, iconColor: AppColors.info,
              title: 'Email Mitra', subtitle: 'mitra@jasaku.id',
              badge: 'Respons 1-2 jam', badgeColor: AppColors.info,
              onTap: () => _snack('Membuka email...')),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Jam Operasional CS', style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 10),
              _hourRow('Senin – Jumat', '07:00 – 22:00 WIB'),
              _hourRow('Sabtu', '08:00 – 20:00 WIB'),
              _hourRow('Minggu & Hari Libur', '09:00 – 17:00 WIB'),
            ]),
          ),
          const SizedBox(height: 16),

          const _SecHeader(title: 'Kirim Laporan / Keluhan', icon: Icons.flag_outlined),
          const SizedBox(height: 4),
          const Text('Laporkan masalah teknis atau keluhan layanan',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Subjek *', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(controller: _subjectCtrl,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: _inputDeco('cth: Notifikasi tidak muncul')),
              const SizedBox(height: 14),
              const Text('Detail Masalah *', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(controller: _msgCtrl, maxLines: 5,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: _inputDeco('Jelaskan masalah secara detail...')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_subjectCtrl.text.trim().isEmpty ||
                        _msgCtrl.text.trim().isEmpty) {
                      _snack('Lengkapi subjek dan detail masalah');
                      return;
                    }
                    _subjectCtrl.clear(); _msgCtrl.clear();
                    _snack('Laporan berhasil dikirim! CS akan merespons segera.',
                        color: AppColors.success);
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Kirim Laporan',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ]),
    );
  }

  Widget _hourRow(String day, String hours) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Expanded(child: Text(day, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      Text(hours, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
    filled: true, fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

class _ContactCard extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, subtitle, badge; final Color badgeColor;
  final VoidCallback onTap;
  const _ContactCard({required this.icon, required this.iconColor,
      required this.title, required this.subtitle, required this.badge,
      required this.badgeColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(badge, style: TextStyle(fontSize: 10,
                color: badgeColor, fontWeight: FontWeight.w600))),
          const SizedBox(height: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 16),
        ]),
      ]),
    ),
  );
}

class _SecHeader extends StatelessWidget {
  final String title; final IconData icon;
  const _SecHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15,
        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);
}
