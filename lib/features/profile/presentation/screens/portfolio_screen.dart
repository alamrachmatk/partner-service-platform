import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  // Dummy portfolio items
  final List<_PortfolioItem> _items = [
    _PortfolioItem(id: '1', title: 'Servis AC Split 1.5 PK',
        category: 'Elektronik & AC', emoji: '❄️', photoCount: 3,
        desc: 'AC kembali dingin optimal setelah isi freon dan bersihkan filter'),
    _PortfolioItem(id: '2', title: 'Bersih-Bersih Rumah Type 45',
        category: 'Kebersihan', emoji: '🧹', photoCount: 2,
        desc: 'Pembersihan menyeluruh 3 kamar tidur, 2 kamar mandi, ruang tamu'),
    _PortfolioItem(id: '3', title: 'Cuci Karpet 6m²',
        category: 'Kebersihan', emoji: '🪣', photoCount: 1,
        desc: 'Karpet bersih dan harum, noda membandel berhasil dihilangkan'),
  ];

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPortfolioSheet(
        onSave: (title, category, desc, photoCount) {
          setState(() {
            _items.add(_PortfolioItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              category: category,
              emoji: _categoryEmoji(category),
              desc: desc,
              photoCount: photoCount,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Portofolio berhasil ditambahkan'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        },
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'Elektronik & AC': return '❄️';
      case 'Kebersihan':      return '🧹';
      case 'Instalasi':       return '🔧';
      case 'Otomotif':        return '🚗';
      case 'Bangunan':        return '🏗️';
      default:                return '⚙️';
    }
  }

  void _deleteItem(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Portofolio?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Foto ini akan dihapus permanen dari profilmu.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _items.removeWhere((i) => i.id == id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Portofolio dihapus'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
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
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Portofolio', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 18),
            label: const Text('Tambah',
                style: TextStyle(color: AppColors.primary,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: _items.isEmpty
          ? const _EmptyPortfolio()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.info),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'Portofolio membantu pelanggan menilai kualitas kerjamu. '
                      'Tambahkan foto hasil terbaikmu!',
                      style: TextStyle(fontSize: 12,
                          color: AppColors.info, height: 1.4),
                    )),
                  ]),
                ),
                const SizedBox(height: 16),

                // Grid portofolio
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _PortfolioCard(
                    item: _items[i],
                    onDelete: () => _deleteItem(_items[i].id),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _PortfolioItem {
  final String id, title, category, emoji, desc;
  final int photoCount;
  const _PortfolioItem({required this.id, required this.title,
      required this.category, required this.emoji,
      required this.desc, this.photoCount = 1});
}

class _PortfolioCard extends StatelessWidget {
  final _PortfolioItem item;
  final VoidCallback onDelete;
  const _PortfolioCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Foto placeholder
        Stack(children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Center(child: Text(item.emoji,
                style: const TextStyle(fontSize: 44))),
          ),
          Positioned(top: 8, right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 15),
              ),
            )),
        ]),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.category, style: const TextStyle(
                    fontSize: 9, color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              Text(item.title, style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(item.desc, style: const TextStyle(fontSize: 10,
                  color: AppColors.textSecondary, height: 1.3),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle),
            child: const Icon(Icons.photo_library_outlined,
                size: 40, color: AppColors.primary)),
        const SizedBox(height: 16),
        const Text('Belum ada portofolio', style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Tambahkan foto hasil kerjamu untuk\nmenarik lebih banyak pelanggan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13,
                color: AppColors.textSecondary, height: 1.5)),
      ]),
    ));
  }
}

// ─────────────────────────────────────────────
// BOTTOM SHEET TAMBAH PORTOFOLIO
// ─────────────────────────────────────────────
class _AddPortfolioSheet extends StatefulWidget {
  final void Function(String title, String category, String desc, int photoCount) onSave;
  const _AddPortfolioSheet({required this.onSave});

  @override
  State<_AddPortfolioSheet> createState() => _AddPortfolioSheetState();
}

class _AddPortfolioSheetState extends State<_AddPortfolioSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _selectedCategory = 'Kebersihan';
  int _photoCount = 0;

  static const _categories = [
    'Kebersihan', 'Elektronik & AC', 'Instalasi',
    'Otomotif', 'Bangunan', 'Lainnya',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty &&
      _photoCount > 0;

  void _submit() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi semua isian dan minimal 1 foto'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    Navigator.pop(context);
    widget.onSave(
      _titleCtrl.text.trim(),
      _selectedCategory,
      _descCtrl.text.trim(),
      _photoCount,
    );
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
          // Handle
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Tambah Portofolio', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // ── Upload foto ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Foto Hasil Kerja *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: Row(children: [
              ...List.generate(_photoCount, (i) => Stack(children: [
                Container(
                  width: 72, height: 72,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.primary, size: 28),
                ),
                Positioned(top: 2, right: 10,
                  child: GestureDetector(
                    onTap: () => setState(() => _photoCount--),
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 11),
                    ),
                  )),
              ])),
              if (_photoCount < 5)
                GestureDetector(
                  onTap: () => setState(() => _photoCount++),
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.primary, size: 24),
                        SizedBox(height: 2),
                        Text('Tambah', style: TextStyle(fontSize: 9,
                            color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 4),
          Text('$_photoCount/5 foto',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          const SizedBox(height: 16),

          // ── Judul ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Judul Pekerjaan *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'cth: Servis AC Split 1.5 PK',
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
          ),
          const SizedBox(height: 14),

          // ── Kategori ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Kategori *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: _categories.map((cat) {
              final isSel = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.border,
                      width: isSel ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(cat, style: TextStyle(fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                      color: isSel ? AppColors.primary : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Deskripsi ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Deskripsi Pekerjaan *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ceritakan detail pekerjaan yang dilakukan...',
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
          ),
          const SizedBox(height: 20),

          // ── Tombol simpan ──
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _isValid ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Simpan Portofolio',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}
