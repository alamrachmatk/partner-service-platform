class MitraReviewModel {
  final String id;
  final String customerName;
  final String serviceName;
  final String orderId;
  final int rating;
  final String comment;
  final DateTime date;
  final String? mitraReply;
  final DateTime? replyDate;

  const MitraReviewModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.date,
    this.mitraReply,
    this.replyDate,
  });

  MitraReviewModel copyWith({String? mitraReply, DateTime? replyDate}) =>
      MitraReviewModel(
        id: id, customerName: customerName, serviceName: serviceName,
        orderId: orderId, rating: rating, comment: comment, date: date,
        mitraReply: mitraReply ?? this.mitraReply,
        replyDate: replyDate ?? this.replyDate,
      );

  String get formattedDate {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String get initials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.substring(0, 2).toUpperCase();
  }
}

// ── Dummy reviews ──
class DummyReviews {
  static List<MitraReviewModel> get all => [
    MitraReviewModel(
      id: 'RVW-001', customerName: 'Budi Santoso',
      serviceName: 'Servis AC Split', orderId: 'ORD-001',
      rating: 5, date: DateTime.now().subtract(const Duration(days: 1)),
      comment: 'Teknisi sangat profesional dan ramah! AC kembali dingin '
          'seperti baru. Pengerjaan cepat dan bersih. Sangat recommended!',
      mitraReply: 'Terima kasih Pak Budi atas kepercayaannya! '
          'Senang bisa membantu. Jika ada kendala AC kembali, '
          'jangan ragu hubungi kami ya 🙏',
      replyDate: DateTime.now().subtract(const Duration(hours: 20)),
    ),
    MitraReviewModel(
      id: 'RVW-002', customerName: 'Ani Rahayu',
      serviceName: 'Bersih-Bersih Rumah', orderId: 'ORD-002',
      rating: 5, date: DateTime.now().subtract(const Duration(days: 3)),
      comment: 'Luar biasa! Rumah jadi sangat bersih dan wangi. '
          'Tim datang tepat waktu dan bekerja dengan teliti.',
    ),
    MitraReviewModel(
      id: 'RVW-003', customerName: 'Hendra Wijaya',
      serviceName: 'Cuci Karpet', orderId: 'ORD-003',
      rating: 4, date: DateTime.now().subtract(const Duration(days: 5)),
      comment: 'Hasil cuci karpet memuaskan, noda berhasil dibersihkan. '
          'Sedikit terlambat dari jadwal tapi overall oke.',
      mitraReply: 'Mohon maaf atas keterlambatannya Pak Hendra. '
          'Kami akan berusaha lebih tepat waktu ke depannya. '
          'Terima kasih feedbacknya 🙏',
      replyDate: DateTime.now().subtract(const Duration(days: 4)),
    ),
    MitraReviewModel(
      id: 'RVW-004', customerName: 'Dewi Lestari',
      serviceName: 'Bersih-Bersih Rumah', orderId: 'ORD-004',
      rating: 5, date: DateTime.now().subtract(const Duration(days: 7)),
      comment: 'Pelayanan excellent! Sudah langganan 3 bulan dan '
          'tidak pernah kecewa. Selalu bersih dan tepat waktu.',
    ),
    MitraReviewModel(
      id: 'RVW-005', customerName: 'Rudi Pratama',
      serviceName: 'Servis AC Split', orderId: 'ORD-005',
      rating: 4, date: DateTime.now().subtract(const Duration(days: 10)),
      comment: 'Teknisi berpengalaman, tahu masalah AC saya dengan cepat. '
          'Harga sesuai yang dijanjikan. Akan order lagi.',
    ),
    MitraReviewModel(
      id: 'RVW-006', customerName: 'Sari Indah',
      serviceName: 'Cuci Karpet', orderId: 'ORD-006',
      rating: 3, date: DateTime.now().subtract(const Duration(days: 14)),
      comment: 'Hasilnya lumayan tapi ada satu noda yang masih tersisa. '
          'Mungkin perlu dicuci dua kali untuk hasil maksimal.',
    ),
    MitraReviewModel(
      id: 'RVW-007', customerName: 'Ahmad Fauzi',
      serviceName: 'Bersih-Bersih Rumah', orderId: 'ORD-007',
      rating: 5, date: DateTime.now().subtract(const Duration(days: 20)),
      comment: 'Top! Terbaik dari semua jasa bersih yang pernah saya coba. '
          'Detail oriented dan tidak ada area yang terlewat.',
    ),
  ];

  static Map<int, int> get ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in all) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  static double get averageRating {
    if (all.isEmpty) return 0;
    return all.map((r) => r.rating).reduce((a, b) => a + b) / all.length;
  }

  // Data tren rating per bulan (dummy)
  static const trendData = [4.5, 4.6, 4.7, 4.8, 4.7, 4.8];
  static const trendLabels = ['Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov'];
}
