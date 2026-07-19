import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'register_mitra_screen.dart';

class LoginMitraScreen extends StatefulWidget {
  const LoginMitraScreen({super.key});
  @override
  State<LoginMitraScreen> createState() => _LoginMitraScreenState();
}

class _LoginMitraScreenState extends State<LoginMitraScreen> {
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(4, (_) => FocusNode());
  bool _loading = false, _otpSent = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().length < 10) {
      _snack('Masukkan nomor HP yang valid'); return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _loading = false; _otpSent = true; });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 4) { _snack('Masukkan 4 digit kode OTP'); return; }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    _snack('Login berhasil! Dashboard segera hadir.', color: AppColors.success);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Masuk Akun Mitra',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Center(child: Text('🛠️', style: TextStyle(fontSize: 38))))),
          const SizedBox(height: 20),
          Text(_otpSent ? 'Masukkan Kode OTP' : 'Masuk dengan WhatsApp',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(_otpSent
              ? 'Kode OTP dikirim ke WhatsApp\n${_phoneCtrl.text}'
              : 'Masukkan nomor HP yang terdaftar sebagai mitra JasaKu',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 28),

          if (!_otpSent) ...[
            Container(
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.5)),
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '08xx-xxxx-xxxx',
                  hintStyle: const TextStyle(fontSize: 15, color: AppColors.textHint),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🇮🇩', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      const Text('+62', style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Container(width: 1, height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: AppColors.border),
                    ]),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: (_phoneCtrl.text.length >= 10 && !_loading) ? _sendOtp : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white, disabledBackgroundColor: AppColors.border,
                    elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Kode OTP via WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ] else ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) => SizedBox(width: 64, height: 64,
                child: TextField(
                  controller: _otpCtrls[i], focusNode: _otpFocus[i],
                  keyboardType: TextInputType.number, maxLength: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    counterText: '', filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 3) _otpFocus[i + 1].requestFocus();
                    setState(() {});
                  },
                ),
              )),
            ),
            const SizedBox(height: 16),
            Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Tidak menerima kode? ',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              GestureDetector(onTap: _sendOtp,
                child: const Text('Kirim ulang',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700))),
            ])),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: (!_loading && _otpCtrls.every((c) => c.text.isNotEmpty)) ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white, disabledBackgroundColor: AppColors.border,
                    elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verifikasi & Masuk',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            Center(child: TextButton(
              onPressed: () => setState(() { _otpSent = false; for (final c in _otpCtrls) c.clear(); }),
              child: const Text('Ubah nomor HP',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            )),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('Belum punya akun mitra? ',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const RegisterMitraScreen())),
              child: const Text('Daftar sekarang',
                  style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ])),
        ]),
      ),
    );
  }
}
