import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ── Model tier ──
enum MitraTier { reguler, silver, gold, platinum }

extension MitraTierX on MitraTier {
  String get label {
    switch (this) {
      case MitraTier.reguler:  return 'Reguler';
      case MitraTier.silver:   return 'Silver';
      case MitraTier.gold:     return 'Gold';
      case MitraTier.platinum: return 'Platinum';
    }
  }

  String get emoji {
    switch (this) {
      case MitraTier.reguler:  return '🥉';
      case MitraTier.silver:   return '🥈';
      case MitraTier.gold:     return '🥇';
      case MitraTier.platinum: return '💎';
    }
  }

  Color get color {
    switch (this) {
      case MitraTier.reguler:  return const Color(0xFF795548);
      case MitraTier.silver:   return const Color(0xFF78909C);
      case MitraTier.gold:     return const Color(0xFFFFA000);
      case MitraTier.platinum: return const Color(0xFF00897B);
    }
  }

  Color get bgColor {
    switch (this) {
      case MitraTier.reguler:  return const Color(0xFFEFEBE9);
      case MitraTier.silver:   return const Color(0xFFECEFF1);
      case MitraTier.gold:     return const Color(0xFFFFF8E1);
      case MitraTier.platinum: return const Color(0xFFE0F2F1);
    }
  }

  // Syarat minimal untuk tier ini
  int get minOrders {
    switch (this) {
      case MitraTier.reguler:  return 0;
      case MitraTier.silver:   return 50;
      case MitraTier.gold:     return 150;
      case MitraTier.platinum: return 300;
    }
  }

  double get minRating {
    switch (this) {
      case MitraTier.reguler:  return 0;
      case MitraTier.silver:   return 4.5;
      case MitraTier.gold:     return 4.7;
      case MitraTier.platinum: return 4.9;
    }
  }

  double get minCompletion {
    switch (this) {
      case MitraTier.reguler:  return 0;
      case MitraTier.silver:   return 85;
      case MitraTier.gold:     return 90;
      case MitraTier.platinum: return 95;
    }
  }

  List<String> get benefits {
    switch (this) {
      case MitraTier.reguler:
        return [
          'Akses ke semua fitur dasar mitra',
          'Tampil di hasil pencarian standar',
          'Komisi platform 12%',
          'Dukungan CS standar',
        ];
      case MitraTier.silver:
        return [
          'Semua benefit Reguler',
          'Badge Silver di profil',
          'Prioritas tampil di pencarian',
          'Komisi platform 10%',
          'Akses CS prioritas',
          'Notifikasi pesanan lebih cepat',
        ];
      case MitraTier.gold:
        return [
          'Semua benefit Silver',
          'Badge Gold di profil (lebih menonjol)',
          'Prioritas tinggi di pencarian',
          'Komisi platform 8%',
          'CS khusus Gold 24 jam',
          'Fitur promosi gratis 2x/bulan',
          'Laporan performa lanjutan',
        ];
      case MitraTier.platinum:
        return [
          'Semua benefit Gold',
          'Badge Platinum eksklusif 💎',
          'Tampil di halaman utama JasaKu',
          'Komisi platform 5%',
          'Account manager pribadi',
          'Promosi gratis tidak terbatas',
          'Early access fitur baru',
          'Undangan event eksklusif JasaKu',
        ];
    }
  }
}

// ── Dummy data mitra ──
class _MitraStats {
  static const currentTier = MitraTier.silver;
  static const totalOrders = 124;
  static const rating = 4.8;
  static const completionRate = 91.7;
  static const tierHistory = [
    (tier: MitraTier.reguler, date: '12 Jan 2024', note: 'Bergabung sebagai mitra'),
    (tier: MitraTier.silver, date: '5 Apr 2024', note: 'Naik tier setelah 50+ order'),
  ];
}

class TierScreen extends StatelessWidget {
  const TierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final current = _MitraStats.currentTier;
    final tiers = MitraTier.values;
    final currentIdx = tiers.indexOf(current);
    final hasNext = currentIdx < tiers.length - 1;
    final nextTier = hasNext ? tiers[currentIdx + 1] : null;

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
        title: const Text('Program Mitra Unggulan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Tier saat ini ──
          _CurrentTierCard(tier: current),
          const SizedBox(height: 16),

          // ── Progress ke tier berikutnya ──
          if (hasNext && nextTier != null) ...[
            _NextTierProgress(
              current: current,
              next: nextTier,
              orders: _MitraStats.totalOrders,
              rating: _MitraStats.rating,
              completion: _MitraStats.completionRate,
            ),
            const SizedBox(height: 16),
          ],

          // ── Semua tier & benefit ──
          _sectionHeader('Semua Tingkatan', Icons.workspace_premium_rounded),
          const SizedBox(height: 10),
          ...tiers.map((t) => _TierCard(
              tier: t, isCurrent: t == current)),
          const SizedBox(height: 16),

          // ── Riwayat tier ──
          _sectionHeader('Riwayat Tier', Icons.history_rounded),
          const SizedBox(height: 10),
          _TierHistoryCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 15,
        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);
}

// ── Card tier saat ini ──
class _CurrentTierCard extends StatelessWidget {
  final MitraTier tier;
  const _CurrentTierCard({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tier.color, tier.color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Row(children: [
          Text(tier.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tier kamu saat ini',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
              Text(tier.label, style: const TextStyle(fontSize: 28,
                  fontWeight: FontWeight.w800, color: Colors.white)),
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Mitra Terverifikasi ✓',
                    style: TextStyle(fontSize: 11,
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          )),
        ]),
        const SizedBox(height: 16),
        const Divider(color: Colors.white30, height: 1),
        const SizedBox(height: 14),

        // Stats
        Row(children: [
          _StatItem(label: 'Total Order',
              value: '${_MitraStats.totalOrders}'),
          _vDivider(),
          _StatItem(label: 'Rating',
              value: '${_MitraStats.rating}⭐'),
          _vDivider(),
          _StatItem(label: 'Penyelesaian',
              value: '${_MitraStats.completionRate}%'),
        ]),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 16,
        fontWeight: FontWeight.w700, color: Colors.white)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
  ]));
}

Widget _vDivider() => Container(width: 0.5, height: 30,
    color: Colors.white30);

// ── Progress ke tier berikutnya ──
class _NextTierProgress extends StatelessWidget {
  final MitraTier current, next;
  final int orders;
  final double rating, completion;
  const _NextTierProgress({required this.current, required this.next,
      required this.orders, required this.rating, required this.completion});

  double _progress(double val, double target) =>
      target == 0 ? 1.0 : (val / target).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final orderProgress = _progress(
        orders.toDouble(), next.minOrders.toDouble());
    final ratingProgress = _progress(rating, next.minRating);
    final completionProgress = _progress(completion, next.minCompletion);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: next.color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(next.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menuju Tier ${next.label}',
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700, color: next.color)),
              const Text('Penuhi semua syarat untuk naik tier',
                  style: TextStyle(fontSize: 11,
                      color: AppColors.textSecondary)),
            ],
          )),
        ]),
        const SizedBox(height: 16),

        _ProgressRow(
          label: 'Total Order',
          current: '$orders',
          target: '${next.minOrders}',
          progress: orderProgress,
          color: next.color,
          isDone: orders >= next.minOrders,
        ),
        const SizedBox(height: 10),
        _ProgressRow(
          label: 'Rating',
          current: '$rating',
          target: '${next.minRating}',
          progress: ratingProgress,
          color: next.color,
          isDone: rating >= next.minRating,
        ),
        const SizedBox(height: 10),
        _ProgressRow(
          label: 'Tingkat Penyelesaian',
          current: '$completion%',
          target: '${next.minCompletion}%',
          progress: completionProgress,
          color: next.color,
          isDone: completion >= next.minCompletion,
        ),

        if (orderProgress == 1.0 &&
            ratingProgress == 1.0 &&
            completionProgress == 1.0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Selamat! Kamu memenuhi semua syarat. '
                'Kenaikan tier akan diproses otomatis.',
                style: TextStyle(fontSize: 12,
                    color: AppColors.success, height: 1.4),
              )),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label, current, target;
  final double progress;
  final Color color;
  final bool isDone;
  const _ProgressRow({required this.label, required this.current,
      required this.target, required this.progress,
      required this.color, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(isDone ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isDone ? AppColors.success : AppColors.textHint),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDone ? AppColors.success : AppColors.textPrimary))),
        Text('$current / $target', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: isDone ? AppColors.success : AppColors.textSecondary)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.background,
          valueColor: AlwaysStoppedAnimation(
              isDone ? AppColors.success : color),
          minHeight: 7,
        ),
      ),
    ]);
  }
}

// ── Card semua tier ──
class _TierCard extends StatefulWidget {
  final MitraTier tier;
  final bool isCurrent;
  const _TierCard({required this.tier, required this.isCurrent});

  @override
  State<_TierCard> createState() => _TierCardState();
}

class _TierCardState extends State<_TierCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tier;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isCurrent ? t.color : AppColors.border,
          width: widget.isCurrent ? 2 : 0.5,
        ),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isCurrent
                  ? t.bgColor : Colors.transparent,
              borderRadius: _expanded
                  ? const BorderRadius.vertical(top: Radius.circular(14))
                  : BorderRadius.circular(14),
            ),
            child: Row(children: [
              Text(t.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(t.label, style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w700, color: t.color)),
                    if (widget.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Tier Kamu',
                            style: TextStyle(fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    t == MitraTier.reguler
                        ? 'Untuk semua mitra baru'
                        : '${t.minOrders}+ order · Rating ${t.minRating}+ '
                          '· Selesai ${t.minCompletion}%+',
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                ],
              )),
              Icon(_expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textHint),
            ]),
          ),
        ),

        // Benefit list
        if (_expanded) ...[
          Container(height: 0.5, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Benefit ${t.label}',
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...t.benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Icon(Icons.check_rounded, size: 15, color: t.color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(b, style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary,
                        height: 1.4))),
                  ]),
                )),
              ],
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Riwayat tier ──
class _TierHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final history = _MitraStats.tierHistory;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: List.generate(history.length, (i) {
          final h = history[i];
          final isLast = i == history.length - 1;
          return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Column(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: h.tier.bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: h.tier.color, width: 1.5),
                ),
                child: Center(child: Text(h.tier.emoji,
                    style: const TextStyle(fontSize: 14))),
              ),
              if (!isLast) Container(width: 2, height: 36,
                  color: AppColors.border),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(h.tier.label, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: h.tier.color)),
                  const Spacer(),
                  Text(h.date, style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
                ]),
                const SizedBox(height: 2),
                Text(h.note, style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
              ]),
            )),
          ]);
        }),
      ),
    );
  }
}
