import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';

class EditProfileMitraScreen extends StatefulWidget {
  final MitraModel mitra;
  const EditProfileMitraScreen({super.key, required this.mitra});

  @override
  State<EditProfileMitraScreen> createState() => _EditProfileMitraScreenState();
}

class _EditProfileMitraScreenState extends State<EditProfileMitraScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _bioCtrl;
  bool _loading = false;
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.mitra.fullName);
    _phoneCtrl = TextEditingController(text: widget.mitra.phone);
    _emailCtrl = TextEditingController(text: widget.mitra.email ?? '');
    _bioCtrl   = TextEditingController(text: widget.mitra.bio ?? '');
    _selectedCategories = Set.from(widget.mitra.categories);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Nama tidak boleh kosong');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    _snack('Profil berhasil disimpan', color: AppColors.success);
    Navigator.pop(context);
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
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 20, 16,
              100 + MediaQuery.of(context).padding.bottom),
          child: Column(children: [
            // ── Avatar ──
            Center(child: Stack(children: [
              Container(
                width: 88, height: 88,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight]),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(widget.mitra.initials,
                    style: const TextStyle(fontSize: 32,
                        fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              Positioned(bottom: 0, right: 0,
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined,
                      size: 14, color: Colors.white),
                )),
            ])),
            const SizedBox(height: 6),
            const Text('Ketuk untuk ubah foto',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // ── Form data diri ──
            _FormCard(children: [
              _FieldItem(ctrl: _nameCtrl, label: 'Nama Lengkap',
                  hint: 'Nama sesuai KTP',
                  icon: Icons.person_outline_rounded),
              const _Div(),
              _FieldItem(ctrl: _phoneCtrl, label: 'Nomor HP/WhatsApp',
                  hint: '08xx-xxxx-xxxx',
                  icon: Icons.phone_android_rounded,
                  type: TextInputType.phone),
              const _Div(),
              _FieldItem(ctrl: _emailCtrl, label: 'Email',
                  hint: 'contoh@email.com',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const _Div(),
              _FieldItem(ctrl: _bioCtrl, label: 'Deskripsi Diri',
                  hint: 'Ceritakan pengalaman dan keahlianmu...',
                  icon: Icons.description_outlined,
                  maxLines: 4),
            ]),
            const SizedBox(height: 16),

            // ── Kategori keahlian ──
            _SectionTitle(title: 'Kategori Keahlian',
                icon: Icons.handyman_outlined),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: mitraCategories.map((cat) {
                final isSel = _selectedCategories.contains(cat.label);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSel
                        ? _selectedCategories.remove(cat.label)
                        : _selectedCategories.add(cat.label);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? AppColors.primary : AppColors.border,
                        width: isSel ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(children: [
                      const SizedBox(width: 10),
                      Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(cat.label, style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                          color: isSel ? AppColors.primary : AppColors.textPrimary))),
                      if (isSel)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 14),
                        ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ]),
        ),

        // ── Tombol simpan ──
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20,
                12 + MediaQuery.of(context).padding.bottom),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
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
                  : const Text('Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; final IconData icon;
  const _SectionTitle({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15,
        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(children: children),
  );
}

class _FieldItem extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint; final IconData icon;
  final TextInputType type; final int maxLines;
  const _FieldItem({required this.ctrl, required this.label,
      required this.hint, required this.icon,
      this.type = TextInputType.text, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, keyboardType: type, maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
          prefixIcon: maxLines == 1
              ? Icon(icon, size: 18, color: AppColors.textHint)
              : null,
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ]),
  );
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0, indent: 14, endIndent: 14);
}
