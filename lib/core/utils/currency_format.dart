/// Format rupiah lengkap dengan titik pemisah ribuan. Contoh: Rp 1.250.000
String rupiah(double v) {
  final s = v.round().toString();
  final withDots =
      s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  return 'Rp $withDots';
}

/// Format ringkas. Contoh: Rp 220rb, Rp 2.9jt, Rp 6jt
String rupiahShort(double v) {
  if (v >= 1000000) {
    final jt = v / 1000000;
    final txt = jt == jt.roundToDouble()
        ? jt.toStringAsFixed(0)
        : jt.toStringAsFixed(1);
    return 'Rp ${txt}jt';
  }
  if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
  return 'Rp ${v.toStringAsFixed(0)}';
}
