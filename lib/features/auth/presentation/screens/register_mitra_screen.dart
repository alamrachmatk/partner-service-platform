import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';
import 'verification_status_screen.dart';

class RegisterMitraScreen extends StatefulWidget {
  const RegisterMitraScreen({super.key});
  @override
  State<RegisterMitraScreen> createState() => _RegisterMitraScreenState();
}

class _RegisterMitraScreenState extends State<RegisterMitraScreen> {
  final _pageCtrl    = PageController();
  int _currentStep   = 0;
  bool _loading      = false;

  // Step 1
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _ktpCtrl     = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Step 2
  final Set<String> _selectedCategories = {};

  // Step 3
  final _bioCtrl    = TextEditingController();
  String _experience = '< 1 tahun';
  int _ktpPhotoCount = 0, _selfieCount = 0, _portfolioCount = 0;

  static const _experiences = ['< 1 tahun','1-2 tahun','3-5 tahun','5-10 tahun','> 10 tahun'];
  static const _steps = ['Data Diri', 'Keahlian', 'Pengalaman'];

  @override
  void dispose() {
    _pageCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _ktpCtrl.dispose(); _addressCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  bool get _step1Valid => _nameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().length >= 10 && _ktpCtrl.text.trim().length >= 16;
  bool get _step2Valid => _selectedCategories.isNotEmpty;
  bool get _step3Valid => _bioCtrl.text.trim().isNotEmpty && _ktpPhotoCount > 0 && _selfieCount > 0;

  void _next() {
    if (_currentStep == 0 && !_step1Valid) { _snack('Lengkapi data diri'); return; }
    if (_currentStep == 1 && !_step2Valid) { _snack('Pilih minimal 1 kategori'); return; }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else Navigator.pop(context);
  }

  Future<void> _submit() async {
    if (!_step3Valid) { _snack('Lengkapi bio dan upload KTP + selfie'); return; }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    if (!mounted) return;
    final mitra = MitraModel(
      id: 'MTR-${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      ktpNumber: _ktpCtrl.text.trim(), address: _addressCtrl.text.trim(),
      categories: _selectedCategories.toList(), experience: _experience,
      bio: _bioCtrl.text.trim(), status: MitraStatus.pending, registeredAt: DateTime.now(),
    );
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => VerificationStatusScreen(mitra: mitra)), (_) => false);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg), backgroundColor: Colors.orange,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: _prev,
        ),
        title: const Text('Daftar sebagai Mitra',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _StepIndicator(current: _currentStep, steps: _steps),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1(nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl, emailCtrl: _emailCtrl,
              ktpCtrl: _ktpCtrl, addressCtrl: _addressCtrl, onChanged: () => setState(() {})),
          _Step2(selected: _selectedCategories,
              onToggle: (c) => setState(() =>
                  _selectedCategories.contains(c) ? _selectedCategories.remove(c) : _selectedCategories.add(c))),
          _Step3(bioCtrl: _bioCtrl, experience: _experience, experiences: _experiences,
              ktpCount: _ktpPhotoCount, selfieCount: _selfieCount, portfolioCount: _portfolioCount,
              onExpChange: (v) => setState(() => _experience = v),
              onAddKtp: () => setState(() => _ktpPhotoCount = 1),
              onAddSelfie: () => setState(() => _selfieCount = 1),
              onAddPortfolio: () { if (_portfolioCount < 5) setState(() => _portfolioCount++); },
              onRemovePortfolio: () { if (_portfolioCount > 0) setState(() => _portfolioCount--); },
              onChanged: () => setState(() {})),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        step: _currentStep, totalSteps: _steps.length, loading: _loading,
        isValid: _currentStep == 0 ? _step1Valid : _currentStep == 1 ? _step2Valid : _step3Valid,
        onNext: _currentStep < 2 ? _next : _submit,
      ),
    );
  }
}

// ── Step Indicator ──
class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> steps;
  const _StepIndicator({required this.current, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(child: Container(height: 2,
              color: i ~/ 2 < current ? AppColors.primary : AppColors.border));
        }
        final idx = i ~/ 2;
        final done = idx < current, active = idx == current;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : active ? AppColors.primary.withOpacity(0.15) : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: (done || active) ? AppColors.primary : AppColors.border,
                  width: active ? 2 : 1),
            ),
            child: Center(child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text('${idx + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: active ? AppColors.primary : AppColors.textHint))),
          ),
          const SizedBox(height: 4),
          Text(steps[idx], style: TextStyle(fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppColors.primary : AppColors.textSecondary)),
        ]);
      })),
    );
  }
}

// ── Step 1: Data Diri ──
class _Step1 extends StatelessWidget {
  final TextEditingController nameCtrl, phoneCtrl, emailCtrl, ktpCtrl, addressCtrl;
  final VoidCallback onChanged;
  const _Step1({required this.nameCtrl, required this.phoneCtrl, required this.emailCtrl,
      required this.ktpCtrl, required this.addressCtrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SecTitle(title: 'Data Diri', icon: Icons.person_outline_rounded),
        const SizedBox(height: 16),
        _FormCard(children: [
          _Field(ctrl: nameCtrl, label: 'Nama Lengkap *', hint: 'Sesuai KTP',
              icon: Icons.person_outline_rounded, onChanged: (_) => onChanged()),
          const _Div(),
          _Field(ctrl: phoneCtrl, label: 'Nomor HP/WhatsApp *', hint: '08xx-xxxx-xxxx',
              icon: Icons.phone_android_rounded, type: TextInputType.phone, onChanged: (_) => onChanged()),
          const _Div(),
          _Field(ctrl: emailCtrl, label: 'Email (opsional)', hint: 'contoh@email.com',
              icon: Icons.email_outlined, type: TextInputType.emailAddress),
        ]),
        const SizedBox(height: 16),
        const _SecTitle(title: 'Data Identitas', icon: Icons.badge_outlined),
        const SizedBox(height: 16),
        _FormCard(children: [
          _Field(ctrl: ktpCtrl, label: 'Nomor KTP *', hint: '16 digit nomor KTP',
              icon: Icons.credit_card_outlined, type: TextInputType.number,
              maxLength: 16, onChanged: (_) => onChanged()),
          const _Div(),
          _Field(ctrl: addressCtrl, label: 'Alamat Lengkap', hint: 'Jl. Nama Jalan No. XX...',
              icon: Icons.location_on_outlined, maxLines: 3),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.info.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.info.withOpacity(0.2))),
          child: const Row(children: [
            Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.info),
            SizedBox(width: 8),
            Expanded(child: Text('Data pribadi kamu aman dan hanya digunakan untuk verifikasi.',
                style: TextStyle(fontSize: 11, color: AppColors.info, height: 1.4))),
          ]),
        ),
      ]),
    );
  }
}

// ── Step 2: Keahlian ──
class _Step2 extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onToggle;
  const _Step2({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SecTitle(title: 'Kategori Keahlian', icon: Icons.handyman_outlined),
        const SizedBox(height: 6),
        const Text('Pilih satu atau lebih kategori layanan yang kamu kuasai',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4,
          children: mitraCategories.map((cat) {
            final isSel = selected.contains(cat.label);
            return GestureDetector(
              onTap: () => onToggle(cat.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.primary.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? AppColors.primary : AppColors.border,
                      width: isSel ? 1.5 : 0.5),
                ),
                child: Row(children: [
                  const SizedBox(width: 14),
                  Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cat.label, style: TextStyle(fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? AppColors.primary : AppColors.textPrimary))),
                  if (isSel) const Padding(padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16)),
                ]),
              ),
            );
          }).toList(),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(child: Text('${selected.length} dipilih: ${selected.join(', ')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.success))),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ── Step 3: Pengalaman & Dokumen ──
class _Step3 extends StatelessWidget {
  final TextEditingController bioCtrl;
  final String experience;
  final List<String> experiences;
  final int ktpCount, selfieCount, portfolioCount;
  final void Function(String) onExpChange;
  final VoidCallback onAddKtp, onAddSelfie, onAddPortfolio, onRemovePortfolio, onChanged;
  const _Step3({required this.bioCtrl, required this.experience, required this.experiences,
      required this.ktpCount, required this.selfieCount, required this.portfolioCount,
      required this.onExpChange, required this.onAddKtp, required this.onAddSelfie,
      required this.onAddPortfolio, required this.onRemovePortfolio, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SecTitle(title: 'Pengalaman Kerja', icon: Icons.work_outline_rounded),
        const SizedBox(height: 12),
        _FormCard(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Lama Pengalaman *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: experiences.map((exp) {
                final sel = experience == exp;
                return GestureDetector(
                  onTap: () => onExpChange(exp),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.border,
                          width: sel ? 1.5 : 0.5),
                    ),
                    child: Text(exp, style: TextStyle(fontSize: 13,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? AppColors.primary : AppColors.textSecondary)),
                  ),
                );
              }).toList()),
            ]),
          ),
          const _Div(),
          _Field(ctrl: bioCtrl, label: 'Deskripsi Diri & Keahlian *',
              hint: 'Ceritakan pengalaman dan keahlianmu...',
              icon: Icons.description_outlined, maxLines: 5, onChanged: (_) => onChanged()),
        ]),
        const SizedBox(height: 16),
        const _SecTitle(title: 'Upload Dokumen', icon: Icons.upload_file_outlined),
        const SizedBox(height: 6),
        const Text('Wajib untuk proses verifikasi akun mitra',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        _UploadCard(title: 'Foto KTP *', subtitle: 'Pastikan tulisan terbaca jelas',
            icon: Icons.credit_card_outlined, color: AppColors.primary,
            count: ktpCount, maxCount: 1, onAdd: onAddKtp),
        const SizedBox(height: 10),
        _UploadCard(title: 'Selfie dengan KTP *', subtitle: 'Foto diri sambil memegang KTP',
            icon: Icons.face_outlined, color: AppColors.info,
            count: selfieCount, maxCount: 1, onAdd: onAddSelfie),
        const SizedBox(height: 10),
        _UploadCard(title: 'Foto Portofolio (opsional)',
            subtitle: 'Tambah maks 5 foto hasil kerja terbaikmu',
            icon: Icons.photo_library_outlined, color: AppColors.success,
            count: portfolioCount, maxCount: 5, onAdd: onAddPortfolio,
            onRemove: onRemovePortfolio, isMultiple: true),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.2))),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, size: 15, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(child: Text('Semua dokumen hanya digunakan untuk verifikasi identitas.',
                style: TextStyle(fontSize: 11, color: AppColors.warning, height: 1.4))),
          ]),
        ),
      ]),
    );
  }
}

// ── Shared Widgets ──
class _SecTitle extends StatelessWidget {
  final String title; final IconData icon;
  const _SecTitle({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary)),
  ]);
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(children: children),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint; final IconData icon;
  final TextInputType type; final int? maxLength, maxLines;
  final void Function(String)? onChanged;
  const _Field({required this.ctrl, required this.label, required this.hint,
      required this.icon, this.type = TextInputType.text,
      this.maxLength, this.maxLines = 1, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, keyboardType: type, maxLength: maxLength,
          maxLines: maxLines, onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
            filled: true, fillColor: AppColors.background, counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          )),
      ]),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) => const Divider(height: 0, indent: 14, endIndent: 14);
}

class _UploadCard extends StatelessWidget {
  final String title, subtitle; final IconData icon; final Color color;
  final int count, maxCount; final VoidCallback onAdd;
  final VoidCallback? onRemove; final bool isMultiple;
  const _UploadCard({required this.title, required this.subtitle, required this.icon,
      required this.color, required this.count, required this.maxCount,
      required this.onAdd, this.onRemove, this.isMultiple = false});
  @override
  Widget build(BuildContext context) {
    final uploaded = count > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: uploaded ? color.withOpacity(0.4) : AppColors.border,
              width: uploaded ? 1.5 : 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          if (uploaded) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('$count/${isMultiple ? maxCount : 1} foto',
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        if (uploaded && isMultiple)
          SizedBox(height: 64, child: Row(children: [
            ...List.generate(count, (i) => Container(width: 60, height: 60,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3))),
                child: Icon(Icons.image_outlined, color: color, size: 24))),
            if (count < maxCount) GestureDetector(onTap: onAdd,
                child: Container(width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.add_rounded, color: AppColors.textHint, size: 24))),
          ]))
        else GestureDetector(
          onTap: uploaded ? null : onAdd,
          child: Container(width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: uploaded ? color.withOpacity(0.06) : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: uploaded ? color.withOpacity(0.3) : AppColors.border)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(uploaded ? Icons.check_circle_outline_rounded : Icons.upload_outlined,
                  color: uploaded ? color : AppColors.textHint, size: 20),
              const SizedBox(width: 8),
              Text(uploaded ? 'Foto berhasil diupload' : 'Ketuk untuk upload',
                  style: TextStyle(fontSize: 13, color: uploaded ? color : AppColors.textHint,
                      fontWeight: uploaded ? FontWeight.w600 : FontWeight.w400)),
            ])),
        ),
      ]),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int step, totalSteps; final bool isValid, loading; final VoidCallback onNext;
  const _BottomBar({required this.step, required this.totalSteps, required this.isValid,
      required this.loading, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final isLast = step == totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(children: [
        Text('Langkah ${step + 1} dari $totalSteps',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        SizedBox(height: 50, width: 200,
          child: ElevatedButton(
            onPressed: (isValid && !loading) ? onNext : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                foregroundColor: Colors.white, disabledBackgroundColor: AppColors.border,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(isLast ? 'Kirim Pendaftaran' : 'Lanjut',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(width: 4),
                    Icon(isLast ? Icons.send_rounded : Icons.arrow_forward_rounded, size: 16),
                  ]),
          ),
        ),
      ]),
    );
  }
}
