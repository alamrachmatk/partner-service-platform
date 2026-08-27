import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_service_model.dart';

class ServiceDetailEditScreen extends StatefulWidget {
  final MitraServiceModel service;
  const ServiceDetailEditScreen({super.key, required this.service});

  @override
  State<ServiceDetailEditScreen> createState() =>
      _ServiceDetailEditScreenState();
}

class _ServiceDetailEditScreenState extends State<ServiceDetailEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.service.name);
    _descCtrl = TextEditingController(text: widget.service.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Nama layanan tidak boleh kosong');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    widget.service.name = _nameCtrl.text.trim();
    widget.service.description = _descCtrl.text.trim();
    setState(() => _loading = false);
    if (!mounted) return;
    _snack('Layanan berhasil disimpan', color: AppColors.success);
    Navigator.pop(context);
  }

  void _snack(String msg, {Color color = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        onSave: (name, unit, price) {
          setState(() {
            widget.service.items.add(MitraServiceItem(
              id: 'ITM-${DateTime.now().millisecondsSinceEpoch}',
              name: name, unit: unit, price: price,
            ));
          });
          _snack('Sub-layanan berhasil ditambahkan',
              color: AppColors.success);
        },
      ),
    );
  }

  void _editItem(MitraServiceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        item: item,
        onSave: (name, unit, price) {
          setState(() {
            final idx = widget.service.items.indexWhere(
                (i) => i.id == item.id);
            if (idx != -1) {
              widget.service.items[idx] =
                  item.copyWith(name: name, unit: unit, price: price);
            }
          });
          _snack('Sub-layanan berhasil diperbarui',
              color: AppColors.success);
        },
      ),
    );
  }

  void _deleteItem(MitraServiceItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Sub-Layanan?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${item.name}" akan dihapus permanen.',
            style: const TextStyle(fontSize: 14,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => widget.service.items
                  .removeWhere((i) => i.id == item.id));
              _snack('Sub-layanan dihapus',
                  color: AppColors.error);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
        title: Text(widget.service.name,
            style: const TextStyle(fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16,
              100 + MediaQuery.of(context).padding.bottom),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            // ── Info layanan ──
            _SectionHeader(title: 'Info Layanan',
                icon: Icons.info_outline_rounded),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(children: [
                _FieldItem(ctrl: _nameCtrl, label: 'Nama Layanan',
                    hint: 'cth: Servis AC Split',
                    icon: Icons.handyman_outlined,
                    onChanged: (_) => setState(() {})),
                const Divider(height: 0, indent: 14, endIndent: 14),
                _FieldItem(ctrl: _descCtrl, label: 'Deskripsi',
                    hint: 'Jelaskan detail layanan kamu...',
                    icon: Icons.description_outlined, maxLines: 3),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Sub-layanan & harga ──
            Row(children: [
              const Expanded(child: _SectionHeader(
                  title: 'Sub-Layanan & Harga',
                  icon: Icons.price_change_outlined)),
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Tambah', style: TextStyle(fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                    ]),
                ),
              ),
            ]),
            const SizedBox(height: 10),

            widget.service.items.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: const Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.price_change_outlined,
                            size: 36, color: AppColors.textHint),
                        SizedBox(height: 8),
                        Text('Belum ada sub-layanan',
                            style: TextStyle(fontSize: 14,
                                color: AppColors.textHint)),
                        SizedBox(height: 4),
                        Text('Ketuk tombol Tambah untuk menambahkan',
                            style: TextStyle(fontSize: 12,
                                color: AppColors.textHint)),
                      ],
                    )),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      children: List.generate(
                          widget.service.items.length, (i) {
                        final item = widget.service.items[i];
                        final isLast =
                            i == widget.service.items.length - 1;
                        return Container(
                          decoration: BoxDecoration(
                            border: !isLast
                                ? const Border(bottom: BorderSide(
                                    color: AppColors.border, width: 0.5))
                                : null,
                          ),
                          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                          child: Row(children: [
                            // Toggle aktif
                            Switch(
                              value: item.isActive,
                              onChanged: (v) =>
                                  setState(() => item.isActive = v),
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: item.isActive
                                        ? AppColors.textPrimary
                                        : AppColors.textHint)),
                                const SizedBox(height: 3),
                                Row(children: [
                                  Text(item.formattedPrice,
                                      style: TextStyle(fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: item.isActive
                                              ? AppColors.primary
                                              : AppColors.textHint)),
                                  Text(' / ${item.unit}',
                                      style: const TextStyle(fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ]),
                              ],
                            )),
                            // Edit & hapus
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.primary),
                              onPressed: () => _editItem(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              onPressed: () => _deleteItem(item),
                            ),
                          ]),
                        );
                      }),
                    ),
                  ),
          ]),
        ),

        // ── Tombol simpan ──
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20,
                12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(
                  color: AppColors.border, width: 0.5)),
            ),
            child: ElevatedButton(
              onPressed: (_loading ||
                  _nameCtrl.text.trim().isEmpty) ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
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
                      style: TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Bottom sheet tambah/edit sub-layanan ──
class _AddItemSheet extends StatefulWidget {
  final MitraServiceItem? item;
  final void Function(String, String, double) onSave;
  const _AddItemSheet({this.item, required this.onSave});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late String _selectedUnit;
  static const _units = ['unit', 'sesi', 'kg', 'm²', 'jam', 'item'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name ?? '');
    _priceCtrl = TextEditingController(
        text: widget.item != null
            ? widget.item!.price.toInt().toString() : '');
    _selectedUnit = widget.item?.unit ?? 'unit';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _priceCtrl.text.trim().isNotEmpty &&
      (double.tryParse(_priceCtrl.text) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    final isEdit = widget.item != null;

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
          Text(isEdit ? 'Edit Sub-Layanan' : 'Tambah Sub-Layanan',
              style: const TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // Nama sub-layanan
          _label('Nama Sub-Layanan *'),
          const SizedBox(height: 6),
          _field(_nameCtrl, 'cth: Cuci AC 0.5–1 PK'),
          const SizedBox(height: 14),

          // Harga
          _label('Harga *'),
          const SizedBox(height: 6),
          Row(children: [
            const Text('Rp ', style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            Expanded(child: _field(_priceCtrl, '0',
                type: TextInputType.number)),
          ]),
          const SizedBox(height: 14),

          // Satuan
          _label('Satuan *'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: _units.map((u) {
              final sel = _selectedUnit == u;
              return GestureDetector(
                onTap: () => setState(() => _selectedUnit = u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
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
                  child: Text(u, style: TextStyle(fontSize: 13,
                      fontWeight: sel
                          ? FontWeight.w700 : FontWeight.w400,
                      color: sel
                          ? AppColors.primary : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Preview harga
          if (_isValid)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    '${_nameCtrl.text} — '
                    'Rp ${double.tryParse(_priceCtrl.text)?.toInt() ?? 0} '
                    '/ $_selectedUnit',
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
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
            Expanded(child: ElevatedButton(
              onPressed: _isValid ? () {
                Navigator.pop(context);
                widget.onSave(
                  _nameCtrl.text.trim(), _selectedUnit,
                  double.parse(_priceCtrl.text),
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
              child: Text(isEdit ? 'Simpan' : 'Tambahkan',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontSize: 13,
        fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl, keyboardType: type,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ── Shared widgets ──
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

class _FieldItem extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final int maxLines;
  final void Function(String)? onChanged;
  const _FieldItem({required this.ctrl, required this.label,
      required this.hint, required this.icon,
      this.maxLines = 1, this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, maxLines: maxLines, onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
          prefixIcon: maxLines == 1
              ? Icon(icon, size: 18, color: AppColors.textHint) : null,
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
        ),
      ),
    ]),
  );
}
