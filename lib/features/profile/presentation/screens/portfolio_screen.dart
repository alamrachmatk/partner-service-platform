import 'dart:io';
import 'package:flutter/material.dart';
// TODO: Uncomment saat image_picker sudah ditambah ke pubspec.yaml
// import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────
// MODEL PORTFOLIO
// ─────────────────────────────────────────────
class PortfolioItem {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final String desc;
  final List<String> photoPaths; // path lokal dari image_picker
  final List<String> photoUrls;  // TODO: URL Firebase Storage (nanti)
  final bool isUploaded;         // false = masih lokal, true = sudah di server

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.desc,
    this.photoPaths = const [],
    this.photoUrls  = const [],
    this.isUploaded = false,
  });

  PortfolioItem copyWith({
    String? title, String? category, String? emoji, String? desc,
    List<String>? photoPaths, List<String>? photoUrls, bool? isUploaded,
  }) => PortfolioItem(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    emoji: emoji ?? this.emoji,
    desc: desc ?? this.desc,
    photoPaths: photoPaths ?? this.photoPaths,
    photoUrls:  photoUrls  ?? this.photoUrls,
    isUploaded: isUploaded ?? this.isUploaded,
  );
}

// ─────────────────────────────────────────────
// DUMMY IMAGE PICKER STUB
// Hapus class ini & ganti dengan image_picker nyata saat siap
// ─────────────────────────────────────────────
class _ImagePickerStub {
  // TODO: Ganti dengan:
  // final _picker = ImagePicker();
  // final picked = await _picker.pickMultiImage();
  // return picked.map((x) => x.path).toList();

  static Future<List<String>> pickImages() async {
    // Simulasi delay seperti membuka galeri
    await Future.delayed(const Duration(milliseconds: 600));
    // Return dummy paths — nanti diganti path nyata dari image_picker
    return [
      'dummy_photo_${DateTime.now().millisecondsSinceEpoch}_1',
      'dummy_photo_${DateTime.now().millisecondsSinceEpoch}_2',
    ];
  }

  static Future<String?> pickSingle({bool fromCamera = false}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'dummy_photo_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ─────────────────────────────────────────────
// UPLOAD SERVICE STUB
// Ganti implementasi ini saat Firebase Storage siap
// ─────────────────────────────────────────────
class _UploadService {
  // TODO: Ganti dengan Firebase Storage upload:
  // final ref = FirebaseStorage.instance
  //     .ref('portfolio/${mitraid}/${filename}');
  // final task = await ref.putFile(File(localPath));
  // return await task.ref.getDownloadURL();

  static Future<String> uploadPhoto(String localPath) async {
    // Simulasi upload (nanti diganti Firebase Storage)
    await Future.delayed(const Duration(seconds: 1));
    // Return dummy URL — nanti diganti URL dari Firebase
    return 'https://storage.jasaku.id/portfolio/$localPath.jpg';
  }

  static Future<List<String>> uploadMultiple(List<String> paths,
      {void Function(int done, int total)? onProgress}) async {
    final urls = <String>[];
    for (var i = 0; i < paths.length; i++) {
      final url = await uploadPhoto(paths[i]);
      urls.add(url);
      onProgress?.call(i + 1, paths.length);
    }
    return urls;
  }
}

// ─────────────────────────────────────────────
// SCREEN UTAMA
// ─────────────────────────────────────────────
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final List<PortfolioItem> _items = [
    const PortfolioItem(
      id: '1', title: 'Servis AC Split 1.5 PK',
      category: 'Elektronik & AC', emoji: '❄️',
      desc: 'AC kembali dingin optimal setelah isi freon dan bersihkan filter',
      photoUrls: ['uploaded_1', 'uploaded_2', 'uploaded_3'],
      isUploaded: true,
    ),
    const PortfolioItem(
      id: '2', title: 'Bersih-Bersih Rumah Type 45',
      category: 'Kebersihan', emoji: '🧹',
      desc: 'Pembersihan menyeluruh 3 kamar tidur, 2 kamar mandi, ruang tamu',
      photoUrls: ['uploaded_4', 'uploaded_5'],
      isUploaded: true,
    ),
  ];

  void _addPortfolio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPortfolioSheet(
        onSave: (item) {
          setState(() => _items.add(item));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Portofolio berhasil ditambahkan'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        },
      ),
    );
  }

  void _editPortfolio(PortfolioItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPortfolioSheet(
        existing: item,
        onSave: (updated) {
          setState(() {
            final idx = _items.indexWhere((i) => i.id == item.id);
            if (idx != -1) _items[idx] = updated;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Portofolio berhasil diperbarui'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        },
      ),
    );
  }

  void _deletePortfolio(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Portofolio?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Foto ini akan dihapus permanen.',
            style: TextStyle(fontSize: 14,
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
              setState(() => _items.removeWhere((i) => i.id == id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Portofolio dihapus'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white, elevation: 0,
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
            onPressed: _addPortfolio,
            icon: const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 18),
            label: const Text('Tambah', style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600,
                fontSize: 13)),
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
                // Info dummy mode
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'Mode simulasi: foto dipilih dari galeri tapi '
                      'belum diupload ke server. Akan aktif setelah '
                      'backend Firebase siap.',
                      style: TextStyle(fontSize: 11,
                          color: AppColors.warning, height: 1.4),
                    )),
                  ]),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12,
                    mainAxisSpacing: 12, childAspectRatio: 0.78,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _PortfolioCard(
                    item: _items[i],
                    onEdit: () => _editPortfolio(_items[i]),
                    onDelete: () => _deletePortfolio(_items[i].id),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
// PORTFOLIO CARD
// ─────────────────────────────────────────────
class _PortfolioCard extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback onEdit, onDelete;
  const _PortfolioCard({required this.item, required this.onEdit,
      required this.onDelete});

  int get _photoCount =>
      item.photoPaths.length + item.photoUrls.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Foto thumbnail ──
          Stack(children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: _photoCount > 0
                  ? _PhotoThumbnail(item: item)
                  : Center(child: Text(item.emoji,
                      style: const TextStyle(fontSize: 40))),
            ),
            // Badge jumlah foto
            if (_photoCount > 0)
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.photo_library_outlined,
                        size: 11, color: Colors.white),
                    const SizedBox(width: 3),
                    Text('$_photoCount', style: const TextStyle(
                        fontSize: 10, color: Colors.white,
                        fontWeight: FontWeight.w700)),
                  ]),
                )),
            // Upload status badge
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isUploaded
                      ? AppColors.success : AppColors.warning,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(item.isUploaded
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_upload_outlined,
                      size: 10, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(item.isUploaded ? 'Tersimpan' : 'Lokal',
                      style: const TextStyle(fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ]),
              )),
            // Tombol edit & hapus
            Positioned(bottom: 8, right: 8,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _IconBtn(icon: Icons.edit_outlined,
                    color: AppColors.primary, onTap: onEdit),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.delete_outline_rounded,
                    color: AppColors.error, onTap: onDelete),
              ])),
          ]),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(item.desc, style: const TextStyle(fontSize: 10,
                    color: AppColors.textSecondary, height: 1.3),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final PortfolioItem item;
  const _PhotoThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    // Cek apakah ada path lokal yang valid
    final hasLocal = item.photoPaths.isNotEmpty &&
        item.photoPaths.first.isNotEmpty &&
        !item.photoPaths.first.startsWith('dummy');

    if (hasLocal) {
      // TODO: Tampilkan foto asli dari galeri saat image_picker aktif
      // return Image.file(File(item.photoPaths.first),
      //     fit: BoxFit.cover, width: double.infinity, height: 100);
    }

    // Fallback: tampilkan emoji + indikator
    return Container(
      width: double.infinity, height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(item.emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        const Text('Foto tersimpan',
            style: TextStyle(fontSize: 9,
                color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: color,
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Colors.white, size: 14),
    ),
  );
}

// ─────────────────────────────────────────────
// BOTTOM SHEET TAMBAH/EDIT PORTOFOLIO
// ─────────────────────────────────────────────
class _AddPortfolioSheet extends StatefulWidget {
  final PortfolioItem? existing;
  final void Function(PortfolioItem) onSave;
  const _AddPortfolioSheet({this.existing, required this.onSave});

  @override
  State<_AddPortfolioSheet> createState() => _AddPortfolioSheetState();
}

class _AddPortfolioSheetState extends State<_AddPortfolioSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedCategory;
  late List<String> _localPaths;
  bool _uploading = false;
  int _uploadProgress = 0;

  static const _categories = [
    'Kebersihan', 'Elektronik & AC', 'Instalasi',
    'Otomotif', 'Bangunan', 'Lainnya',
  ];

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

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _descCtrl  = TextEditingController(text: widget.existing?.desc ?? '');
    _selectedCategory = widget.existing?.category ?? 'Kebersihan';
    _localPaths = List.from(widget.existing?.photoPaths ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_localPaths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Maksimal 5 foto per portofolio'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Tampilkan pilihan sumber foto
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Pilih Sumber Foto', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _SourceBtn(
              icon: Icons.photo_library_outlined,
              label: 'Galeri',
              onTap: () => Navigator.pop(context, 'gallery'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _SourceBtn(
              icon: Icons.camera_alt_outlined,
              label: 'Kamera',
              onTap: () => Navigator.pop(context, 'camera'),
            )),
          ]),
        ]),
      ),
    );

    if (source == null) return;

    // TODO: Ganti stub ini dengan image_picker nyata:
    // final picker = ImagePicker();
    // if (source == 'gallery') {
    //   final images = await picker.pickMultiImage(imageQuality: 80);
    //   final paths = images.map((x) => x.path).toList();
    //   setState(() => _localPaths.addAll(paths.take(5 - _localPaths.length)));
    // } else {
    //   final image = await picker.pickImage(
    //       source: ImageSource.camera, imageQuality: 80);
    //   if (image != null) setState(() => _localPaths.add(image.path));
    // }

    // Simulasi untuk sekarang:
    setState(() => _uploading = true);
    final picked = source == 'gallery'
        ? await _ImagePickerStub.pickImages()
        : [await _ImagePickerStub.pickSingle(fromCamera: true) ?? ''];
    setState(() {
      _localPaths.addAll(
          picked.where((p) => p.isNotEmpty)
              .take(5 - _localPaths.length));
      _uploading = false;
    });
  }

  void _removePhoto(int index) {
    setState(() => _localPaths.removeAt(index));
  }

  bool get _isValid =>
      _titleCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() { _uploading = true; _uploadProgress = 0; });

    // TODO: Ganti dengan upload nyata ke Firebase:
    // final urls = await _UploadService.uploadMultiple(
    //   _localPaths,
    //   onProgress: (done, total) =>
    //       setState(() => _uploadProgress = (done / total * 100).round()),
    // );

    // Simulasi upload sekarang:
    for (var i = 0; i < _localPaths.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _uploadProgress =
          ((i + 1) / _localPaths.length * 100).round());
    }

    if (!mounted) return;
    setState(() => _uploading = false);
    Navigator.pop(context);

    final item = PortfolioItem(
      id: widget.existing?.id ??
          'PF-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      emoji: _categoryEmoji(_selectedCategory),
      desc: _descCtrl.text.trim(),
      photoPaths: _localPaths,
      // TODO: Ganti dengan URLs dari Firebase Storage
      photoUrls: [],
      isUploaded: false, // true setelah Firebase aktif
    );
    widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    final isEdit = widget.existing != null;

    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(isEdit ? 'Edit Portofolio' : 'Tambah Portofolio',
              style: const TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // ── Foto section ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Foto Hasil Kerja *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              // Foto yang sudah dipilih
              ..._localPaths.asMap().entries.map((e) => Stack(children: [
                Container(
                  width: 80, height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_rounded,
                          color: AppColors.primary, size: 28),
                      Text('Foto ${e.key + 1}',
                          style: const TextStyle(fontSize: 9,
                              color: AppColors.primary)),
                    ],
                  )),
                  // TODO: Tampilkan foto nyata:
                  // child: ClipRRect(borderRadius: BorderRadius.circular(12),
                  //   child: Image.file(File(e.value), fit: BoxFit.cover)),
                ),
                Positioned(top: 2, right: 10,
                  child: GestureDetector(
                    onTap: () => _removePhoto(e.key),
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 12),
                    ),
                  )),
              ])),
              // Tombol tambah foto
              if (_localPaths.length < 5)
                GestureDetector(
                  onTap: _uploading ? null : _pickPhotos,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.primary, size: 26),
                        const SizedBox(height: 2),
                        Text(_uploading ? 'Loading...' : 'Tambah',
                            style: const TextStyle(fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
          Text('${_localPaths.length}/5 foto',
              style: const TextStyle(fontSize: 11,
                  color: AppColors.textHint)),
          const SizedBox(height: 14),

          // ── Upload progress ──
          if (_uploading && _uploadProgress > 0) ...[
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _uploadProgress / 100,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              )),
              const SizedBox(width: 10),
              Text('$_uploadProgress%', style: const TextStyle(
                  fontSize: 11, color: AppColors.primary,
                  fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
          ],

          // ── Judul ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Judul Pekerjaan *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary))),
          const SizedBox(height: 6),
          _buildField(_titleCtrl, 'cth: Servis AC Split 1.5 PK'),
          const SizedBox(height: 14),

          // ── Kategori ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Kategori *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: _categories.map((cat) {
              final sel = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                      width: sel ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(cat, style: TextStyle(fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      color: sel ? AppColors.primary
                          : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Deskripsi ──
          const Align(alignment: Alignment.centerLeft,
            child: Text('Deskripsi *', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary))),
          const SizedBox(height: 6),
          _buildField(_descCtrl,
              'Ceritakan detail pekerjaan yang dilakukan...',
              maxLines: 3),
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
              onPressed: (_isValid && !_uploading) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: _uploading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? 'Simpan' : 'Tambahkan',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint,
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
          borderSide: const BorderSide(
              color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

class _SourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 30),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    ),
  );
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 80, height: 80,
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
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
