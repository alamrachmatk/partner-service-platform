import 'package:flutter/material.dart';

enum MitraStatus { pending, verifying, verified, rejected }

extension MitraStatusX on MitraStatus {
  String get label {
    switch (this) {
      case MitraStatus.pending:    return 'Menunggu Verifikasi';
      case MitraStatus.verifying:  return 'Sedang Diverifikasi';
      case MitraStatus.verified:   return 'Terverifikasi';
      case MitraStatus.rejected:   return 'Ditolak';
    }
  }

  String get desc {
    switch (this) {
      case MitraStatus.pending:   return 'Data kamu sedang menunggu ditinjau oleh tim JasaKu.';
      case MitraStatus.verifying: return 'Tim JasaKu sedang memverifikasi data kamu. Proses ini membutuhkan 1-2 hari kerja.';
      case MitraStatus.verified:  return 'Selamat! Akunmu sudah terverifikasi dan siap menerima pesanan.';
      case MitraStatus.rejected:  return 'Verifikasi ditolak. Silakan periksa catatan dari tim dan ajukan ulang.';
    }
  }

  String get emoji {
    switch (this) {
      case MitraStatus.pending:    return '⏳';
      case MitraStatus.verifying:  return '🔍';
      case MitraStatus.verified:   return '✅';
      case MitraStatus.rejected:   return '❌';
    }
  }

  Color get color {
    switch (this) {
      case MitraStatus.pending:    return const Color(0xFFFFA726);
      case MitraStatus.verifying:  return const Color(0xFF1976D2);
      case MitraStatus.verified:   return const Color(0xFF43A047);
      case MitraStatus.rejected:   return const Color(0xFFE53935);
    }
  }
}

const mitraCategories = [
  (emoji: '👕', label: 'Laundry'),
  (emoji: '🧹', label: 'Kebersihan'),
  (emoji: '❄️', label: 'Elektronik & AC'),
  (emoji: '🔧', label: 'Instalasi'),
  (emoji: '💆', label: 'Kesehatan & Pijat'),
  (emoji: '🚗', label: 'Otomotif'),
  (emoji: '🏗️', label: 'Bangunan & Renovasi'),
  (emoji: '🌿', label: 'Taman & Landscaping'),
];

class MitraModel {
  final String id, fullName, phone;
  final String? email, ktpNumber, address, experience, bio, rejectionNote;
  final List<String> categories;
  final MitraStatus status;
  final DateTime? registeredAt;

  const MitraModel({
    required this.id, required this.fullName, required this.phone,
    this.email, this.ktpNumber, this.address, this.experience, this.bio,
    this.rejectionNote, this.categories = const [],
    this.status = MitraStatus.pending, this.registeredAt,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.substring(0, 2).toUpperCase();
  }
}
