import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_service_model.dart';
import 'service_detail_edit_screen.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  late List<MitraServiceModel> _services;

  @override
  void initState() {
    super.initState();
    _services = DummyMitraServices.all;
  }

  void _toggleService(int index) {
    setState(() => _services[index].isActive = !_services[index].isActive);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_services[index].isActive
          ? '${_services[index].name} diaktifkan'
          : '${_services[index].name} dinonaktifkan'),
      backgroundColor: _services[index].isActive
          ? AppColors.success : AppColors.textSecondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _addService() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddServiceSheet(
        onSave: (name, category, emoji, desc) {
          setState(() {
            _services.add(MitraServiceModel(
              id: 'SVC-${DateTime.now().millisecondsSinceEpoch}',
              name: name, category: category,
              emoji: emoji, description: desc,
              isActive: true, items: [],
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Layanan "$name" berhasil ditambahkan'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _services.where((s) => s.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kelola Layanan & Harga',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: _addService,
            icon: const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 18),
            label: const Text('Tambah',
                style: TextStyle(color: AppColors.primary,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info ringkasan ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(children: [
              _InfoStat(value: '${_services.length}',
                  label: 'Total\nLayanan', color: AppColors.primary),
              Container(width: 0.5, height: 36, color: AppColors.primary.withOpacity(0.2)),
              _InfoStat(value: '$activeCount',
                  label: 'Layanan\nAktif', color: AppColors.success),
              Container(width: 0.5, height: 36, color: AppColors.primary.withOpacity(0.2)),
              _InfoStat(
                value: '${_services.fold(0, (sum, s) => sum + s.items.length)}',
                label: 'Total\nSub-Layanan', color: AppColors.info,
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── List layanan ──
          ..._services.asMap().entries.map((e) {
            final i = e.key;
            final svc = e.value;
            return _ServiceCard(
              service: svc,
              onToggle: () => _toggleService(i),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ServiceDetailEditScreen(service: svc),
                ));
                setState(() {});
              },
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _InfoStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 20,
        fontWeight: FontWeight.w700, color: color)),
    const SizedBox(height: 2),
    Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10,
            color: AppColors.textSecondary, height: 1.3)),
  ]));
}

// ── Service Card ──
class _ServiceCard extends StatelessWidget {
  final MitraServiceModel service;
  final VoidCallback onToggle, onTap;
  const _ServiceCard({required this.service, required this.onToggle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: service.isActive
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
            width: service.isActive ? 1.5 : 0.5,
          ),
        ),
        child: Column(children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              // Emoji + info
              Text(service.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: service.isActive
                          ? AppColors.textPrimary : AppColors.textHint)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(service.category,
                          style: const TextStyle(fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ],
              )),
              // Toggle aktif
              Switch(
                value: service.isActive,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ]),
          ),

          Container(height: 0.5, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 14)),

          // ── Sub-layanan preview ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.formattedMinPrice,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  Text('${service.activeItemCount} sub-layanan aktif',
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Edit Layanan',
                      style: TextStyle(fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.primary),
                ]),
              ),
            ]),
          ),

          // ── Status nonaktif ──
          if (!service.isActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16)),
              ),
              child: const Center(child: Text('Layanan tidak aktif — '
                  'tidak tampil ke pelanggan',
                  style: TextStyle(fontSize: 11,
                      color: AppColors.textHint))),
            ),
        ]),
      ),
    );
  }
}

// ── Bottom sheet tambah layanan ──
class _AddServiceSheet extends StatefulWidget {
  final void Function(String, String, String, String) onSave;
  const _AddServiceSheet({required this.onSave});

  @override
  State<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<_AddServiceSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Kebersihan';
  String _selectedEmoji = '🧹';

  static const _categoryEmojis = {
    'Kebersihan': '🧹',
    'Elektronik & AC': '❄️',
    'Instalasi': '🔧',
    'Otomotif': '🚗',
    'Bangunan': '🏗️',
    'Kesehatan': '💆',
    'Laundry': '👕',
    'Lainnya': '⚙️',
  };

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

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
          const Text('Tambah Layanan Baru',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // Nama layanan
          _buildLabel('Nama Layanan *'),
          const SizedBox(height: 6),
          _buildTextField(_nameCtrl, 'cth: Servis AC Split'),
          const SizedBox(height: 14),

          // Kategori
          _buildLabel('Kategori *'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: _categoryEmojis.entries.map((e) {
              final sel = _selectedCategory == e.key;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = e.key;
                  _selectedEmoji = e.value;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                      width: sel ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(e.value,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(e.key, style: TextStyle(fontSize: 12,
                        fontWeight: sel
                            ? FontWeight.w700 : FontWeight.w400,
                        color: sel
                            ? AppColors.primary : AppColors.textSecondary)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Deskripsi
          _buildLabel('Deskripsi *'),
          const SizedBox(height: 6),
          _buildTextField(_descCtrl,
              'Jelaskan layanan yang kamu tawarkan...', maxLines: 3),
          const SizedBox(height: 20),

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
            Expanded(child: ElevatedButton(
              onPressed: _isValid ? () {
                Navigator.pop(context);
                widget.onSave(
                  _nameCtrl.text.trim(), _selectedCategory,
                  _selectedEmoji, _descCtrl.text.trim(),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Simpan Layanan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 13,
        fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) => TextField(
    controller: ctrl, maxLines: maxLines,
    onChanged: (_) => setState(() {}),
    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
      filled: true, fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
