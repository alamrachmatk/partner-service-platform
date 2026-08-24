import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/review_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _filterStar = 0; // 0 = semua
  late List<MitraReviewModel> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = DummyReviews.all;
  }

  List<MitraReviewModel> get _filtered => _filterStar == 0
      ? _reviews
      : _reviews.where((r) => r.rating == _filterStar).toList();

  void _replyReview(MitraReviewModel review) {
    final ctrl = TextEditingController(text: review.mitraReply ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(ctx).padding.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(review.mitraReply != null
                  ? 'Edit Balasan' : 'Balas Ulasan',
                  style: const TextStyle(fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Membalas ulasan dari ${review.customerName}',
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 16),

              // Preview ulasan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Row(children: List.generate(5, (i) =>
                      Icon(Icons.star_rounded,
                          size: 14,
                          color: i < review.rating
                              ? AppColors.secondary
                              : AppColors.border))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(review.comment,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic))),
                ]),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: ctrl,
                maxLines: 4,
                maxLength: 300,
                autofocus: true,
                style: const TextStyle(fontSize: 14,
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tulis balasan yang profesional dan ramah...',
                  hintStyle: const TextStyle(fontSize: 13,
                      color: AppColors.textHint),
                  filled: true, fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
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
                  onPressed: () {
                    final reply = ctrl.text.trim();
                    if (reply.isEmpty) return;
                    Navigator.pop(ctx);
                    setState(() {
                      final idx = _reviews.indexWhere(
                              (r) => r.id == review.id);
                      if (idx != -1) {
                        _reviews[idx] = _reviews[idx].copyWith(
                          mitraReply: reply,
                          replyDate: DateTime.now(),
                        );
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Balasan berhasil disimpan'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Kirim Balasan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avg = DummyReviews.averageRating;
    final dist = DummyReviews.ratingDistribution;
    final total = _reviews.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Ulasan & Reputasi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [

                // ── Ringkasan rating ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(children: [
                    // Rating besar
                    Column(children: [
                      Text(avg.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Row(children: List.generate(5, (i) => Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: i < avg.round()
                              ? AppColors.secondary : AppColors.border))),
                      const SizedBox(height: 4),
                      Text('$total ulasan',
                          style: const TextStyle(fontSize: 12,
                              color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(width: 20),

                    // Distribusi bintang
                    Expanded(child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final count = dist[star] ?? 0;
                        final ratio = total > 0 ? count / total : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(children: [
                            Text('$star', style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded,
                                size: 11, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Expanded(child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: AppColors.background,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.secondary),
                                minHeight: 7,
                              ),
                            )),
                            const SizedBox(width: 6),
                            SizedBox(width: 18, child: Text('$count',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11,
                                    color: AppColors.textSecondary))),
                          ]),
                        );
                      }),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),

                // ── Grafik tren rating ──
                _TrendChart(
                    data: DummyReviews.trendData,
                    labels: DummyReviews.trendLabels),
                const SizedBox(height: 16),

                // ── Filter bintang ──
                Row(children: [
                  const Text('Ulasan Pelanggan',
                      style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('${_filtered.length} ulasan',
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(label: 'Semua', selected: _filterStar == 0,
                          onTap: () => setState(() => _filterStar = 0)),
                      const SizedBox(width: 8),
                      ...List.generate(5, (i) {
                        final star = 5 - i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: '$star ⭐',
                            selected: _filterStar == star,
                            onTap: () => setState(() => _filterStar = star),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),

          // ── List ulasan ──
          _filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('😔', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text('Belum ada ulasan $_filterStar bintang',
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ]),
                  )),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ReviewCard(
                        review: _filtered[i],
                        onReply: () => _replyReview(_filtered[i]),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Grafik tren rating ──
class _TrendChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  const _TrendChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final minVal = 4.0;
    final maxVal = 5.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.trending_up_rounded,
              size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Tren Rating 6 Bulan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(data.length, (i) {
              final ratio = (data[i] - minVal) / (maxVal - minVal);
              final isLast = i == data.length - 1;
              return Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Label nilai — pakai SizedBox agar semua bar sejajar
                  SizedBox(
                    height: 20,
                    child: Center(
                      child: isLast
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${data[i]}',
                                  style: const TextStyle(fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            )
                          : Text('${data[i]}', style: const TextStyle(
                              fontSize: 9, color: AppColors.textHint)),
                    ),
                  ),
                  // Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 40 * ratio + 6,
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.secondary
                          : AppColors.secondary.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ),
                  // Label bulan
                  const SizedBox(height: 5),
                  Text(labels[i], style: TextStyle(
                      fontSize: 9,
                      color: isLast
                          ? AppColors.secondary : AppColors.textHint,
                      fontWeight: isLast
                          ? FontWeight.w700 : FontWeight.w400)),
                ],
              ));
            }),
          ),
        ),
      ]),
    );
  }
}

// ── Review card ──
class _ReviewCard extends StatelessWidget {
  final MitraReviewModel review;
  final VoidCallback onReply;
  const _ReviewCard({required this.review, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(review.initials,
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.customerName, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  Row(children: List.generate(5, (i) => Icon(
                      Icons.star_rounded, size: 14,
                      color: i < review.rating
                          ? AppColors.secondary : AppColors.border))),
                  const SizedBox(width: 8),
                  Text(review.serviceName, style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ],
            )),
            Text(review.formattedDate, style: const TextStyle(
                fontSize: 11, color: AppColors.textHint)),
          ]),
        ),

        // ── Komentar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Text(review.comment, style: const TextStyle(
              fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
        ),

        // ── Balasan mitra ──
        if (review.mitraReply != null) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.reply_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Balasan Mitra',
                      style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ]),
                const SizedBox(height: 6),
                Text(review.mitraReply!, style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],

        // ── Tombol balas ──
        Container(height: 0.5, color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 14)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReply,
              icon: Icon(
                review.mitraReply != null
                    ? Icons.edit_outlined
                    : Icons.reply_rounded,
                size: 15,
              ),
              label: Text(
                review.mitraReply != null ? 'Edit Balasan' : 'Balas Ulasan',
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Filter chip ──
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 0 : 0.5,
          ),
        ),
        child: Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
