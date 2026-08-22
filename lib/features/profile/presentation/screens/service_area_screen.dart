import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  double _radius = 5.0;
  bool _loading  = false;

  final List<String> _selectedAreas = [
    'Bogor Tengah', 'Bogor Selatan', 'Bogor Utara',
  ];

  static const _availableAreas = [
    'Bogor Tengah', 'Bogor Selatan', 'Bogor Utara',
    'Bogor Timur', 'Bogor Barat', 'Tanah Sareal',
    'Dramaga', 'Cibinong', 'Ciawi', 'Caringin',
    'Ciomas', 'Sukaraja', 'Gunung Putri',
  ];

  Future<void> _save() async {
    if (_selectedAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih minimal 1 area layanan'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Area layanan berhasil disimpan'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    Navigator.pop(context);
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
        title: const Text('Area Layanan', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16,
              100 + MediaQuery.of(context).padding.bottom),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Peta simulasi ──
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Stack(children: [
                // Grid simulasi peta
                CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _MapGridPainter(),
                ),
                Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 12, spreadRadius: 4,
                        )],
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        )],
                      ),
                      child: Text('Radius ${_radius.toStringAsFixed(0)} km',
                          style: const TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Radius layanan ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.radar_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Radius Jangkauan', style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Pelanggan dalam radius ini bisa melihat profilmu',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('1 km', style: TextStyle(fontSize: 11,
                        color: AppColors.textHint)),
                    Expanded(child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        inactiveTrackColor: AppColors.border,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _radius,
                        min: 1, max: 20,
                        divisions: 19,
                        onChanged: (v) => setState(() => _radius = v),
                      ),
                    )),
                    const Text('20 km', style: TextStyle(fontSize: 11,
                        color: AppColors.textHint)),
                  ]),
                  Center(child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Radius: ${_radius.toStringAsFixed(0)} km dari lokasimu',
                      style: const TextStyle(fontSize: 13,
                          color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pilih kecamatan ──
            Row(children: [
              const Icon(Icons.location_city_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Kecamatan yang Dilayani',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
              Text('${_selectedAreas.length} dipilih',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 6),
            const Text('Pilih kecamatan yang bisa kamu jangkau',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: List.generate(_availableAreas.length, (i) {
                  final area = _availableAreas[i];
                  final isSel = _selectedAreas.contains(area);
                  final isLast = i == _availableAreas.length - 1;
                  return GestureDetector(
                    onTap: () => setState(() {
                      isSel
                          ? _selectedAreas.remove(area)
                          : _selectedAreas.add(area);
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withOpacity(0.04)
                            : Colors.transparent,
                        border: !isLast
                            ? const Border(bottom: BorderSide(
                                color: AppColors.border, width: 0.5))
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(children: [
                        Expanded(child: Text(area, style: TextStyle(
                            fontSize: 14,
                            color: isSel
                                ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSel
                                ? FontWeight.w600 : FontWeight.w400))),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: isSel
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ]),
                    ),
                  );
                }),
              ),
            ),

            // ── Selected chips ──
            if (_selectedAreas.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Area dipilih:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _selectedAreas.map((area) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(area, style: const TextStyle(fontSize: 12,
                        color: AppColors.primary, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _selectedAreas.remove(area)),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: AppColors.primary),
                    ),
                  ]),
                )).toList(),
              ),
            ],
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
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
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
                  : const Text('Simpan Area Layanan',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Custom painter grid peta ──
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..strokeWidth = 1;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
