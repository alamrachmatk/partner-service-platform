class MitraServiceItem {
  final String id;
  final String name;
  final String unit;
  double price;
  bool isActive;

  MitraServiceItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.isActive = true,
  });

  String get formattedPrice {
    if (price >= 1000000) return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000) return 'Rp ${(price / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  MitraServiceItem copyWith({
    String? name, String? unit, double? price, bool? isActive,
  }) => MitraServiceItem(
    id: id,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    price: price ?? this.price,
    isActive: isActive ?? this.isActive,
  );
}

class MitraServiceModel {
  final String id;
  String name;
  String category;
  String emoji;
  String description;
  bool isActive;
  List<MitraServiceItem> items;

  MitraServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.description,
    this.isActive = true,
    this.items = const [],
  });

  int get activeItemCount => items.where((i) => i.isActive).length;
  double get minPrice => items.isEmpty ? 0 :
      items.where((i) => i.isActive).isEmpty ? 0 :
      items.where((i) => i.isActive)
          .map((i) => i.price)
          .reduce((a, b) => a < b ? a : b);

  String get formattedMinPrice {
    if (minPrice == 0) return 'Belum ada harga';
    if (minPrice >= 1000000) return 'Mulai Rp ${(minPrice / 1000000).toStringAsFixed(1)}jt';
    if (minPrice >= 1000) return 'Mulai Rp ${(minPrice / 1000).toStringAsFixed(0)}rb';
    return 'Mulai Rp ${minPrice.toStringAsFixed(0)}';
  }
}

// ── Dummy data ──
class DummyMitraServices {
  static List<MitraServiceModel> get all => [
    MitraServiceModel(
      id: 'SVC-001', name: 'Servis AC Split', category: 'Elektronik & AC',
      emoji: '❄️', isActive: true,
      description: 'Servis, cuci, dan isi freon AC split semua merk dan ukuran.',
      items: [
        MitraServiceItem(id: 'ITM-001', name: 'Cuci AC 0.5–1 PK',
            unit: 'unit', price: 85000),
        MitraServiceItem(id: 'ITM-002', name: 'Cuci AC 1.5–2 PK',
            unit: 'unit', price: 100000),
        MitraServiceItem(id: 'ITM-003', name: 'Isi Freon R32',
            unit: 'unit', price: 120000),
        MitraServiceItem(id: 'ITM-004', name: 'Isi Freon R410A',
            unit: 'unit', price: 150000),
        MitraServiceItem(id: 'ITM-005', name: 'Cek & Bersihkan Filter',
            unit: 'unit', price: 30000),
      ],
    ),
    MitraServiceModel(
      id: 'SVC-002', name: 'Bersih-Bersih Rumah', category: 'Kebersihan',
      emoji: '🧹', isActive: true,
      description: 'Pembersihan menyeluruh rumah type 36 hingga 120.',
      items: [
        MitraServiceItem(id: 'ITM-006', name: 'Bersih Rumah Type 36',
            unit: 'sesi', price: 150000),
        MitraServiceItem(id: 'ITM-007', name: 'Bersih Rumah Type 45',
            unit: 'sesi', price: 180000),
        MitraServiceItem(id: 'ITM-008', name: 'Bersih Rumah Type 60',
            unit: 'sesi', price: 220000),
        MitraServiceItem(id: 'ITM-009', name: 'Cuci Kamar Mandi',
            unit: 'unit', price: 25000),
      ],
    ),
    MitraServiceModel(
      id: 'SVC-003', name: 'Cuci Karpet', category: 'Kebersihan',
      emoji: '🪣', isActive: false,
      description: 'Cuci karpet bersih dan harum dengan peralatan profesional.',
      items: [
        MitraServiceItem(id: 'ITM-010', name: 'Cuci Karpet per m²',
            unit: 'm²', price: 20000),
        MitraServiceItem(id: 'ITM-011', name: 'Cuci Karpet Tebal per m²',
            unit: 'm²', price: 30000),
      ],
    ),
  ];
}
