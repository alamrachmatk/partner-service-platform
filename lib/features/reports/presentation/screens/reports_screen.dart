import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ── Model data laporan ──
class _ReportData {
  final String month;
  final double income;
  final int totalOrder, completed, cancelled, rejected;
  final double rating, responseRate;

  const _ReportData({
    required this.month, required this.income,
    required this.totalOrder, required this.completed,
    required this.cancelled, required this.rejected,
    required this.rating, required this.responseRate,
  });

  double get completionRate =>
      totalOrder > 0 ? completed / totalOrder : 0.0;
}

// ── Dummy data per bulan ──
const _monthlyReports = {
  'Januari': _ReportData(month: 'Januari', income: 1800000,
      totalOrder: 18, completed: 17, cancelled: 1, rejected: 0,
      rating: 4.5, responseRate: 92),
  'Februari': _ReportData(month: 'Februari', income: 2100000,
      totalOrder: 21, completed: 20, cancelled: 1, rejected: 0,
      rating: 4.6, responseRate: 94),
  'Maret': _ReportData(month: 'Maret', income: 1650000,
      totalOrder: 16, completed: 14, cancelled: 2, rejected: 0,
      rating: 4.5, responseRate: 90),
  'April': _ReportData(month: 'April', income: 2400000,
      totalOrder: 24, completed: 22, cancelled: 1, rejected: 1,
      rating: 4.7, responseRate: 95),
  'Mei': _ReportData(month: 'Mei', income: 2200000,
      totalOrder: 22, completed: 21, cancelled: 1, rejected: 0,
      rating: 4.8, responseRate: 96),
  'Juni': _ReportData(month: 'Juni', income: 2850000,
      totalOrder: 26, completed: 24, cancelled: 2, rejected: 0,
      rating: 4.8, responseRate: 97),
};

// ── Kategori layanan ──
const _serviceCategories = [
  (name: 'Servis AC', count: 12, color: Color(0xFF1976D2), emoji: '❄️'),
  (name: 'Kebersihan', count: 9,  color: Color(0xFF43A047), emoji: '🧹'),
  (name: 'Cuci Karpet', count: 5, color: Color(0xFFFFA726), emoji: '🪣'),
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedMonth = 'Juni';
  static const _months = ['Januari', 'Februari', 'Maret',
      'April', 'Mei', 'Juni'];

  _ReportData get _current => _monthlyReports[_selectedMonth]!;

  _ReportData? get _prev {
    final idx = _months.indexOf(_selectedMonth);
    if (idx <= 0) return null;
    return _monthlyReports[_months[idx - 1]];
  }

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  double _changePercent(double current, double prev) {
    if (prev == 0) return 0;
    return ((current - prev) / prev) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final prev = _prev;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Laporan & Performa',
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

          // ── Filter bulan ──
          _SectionHeader(title: 'Pilih Periode', icon: Icons.date_range_rounded),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m = _months[i];
                final sel = m == _selectedMonth;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMonth = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.border,
                        width: sel ? 0 : 0.5,
                      ),
                    ),
                    child: Text(m, style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Ringkasan performa ──
          _SectionHeader(title: 'Ringkasan $_selectedMonth',
              icon: Icons.bar_chart_rounded),
          const SizedBox(height: 10),
          Row(children: [
            _StatCard(
              label: 'Pendapatan',
              value: _fmt(_current.income),
              icon: Icons.payments_outlined,
              color: AppColors.primary,
              change: prev != null
                  ? _changePercent(_current.income, prev.income) : null,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Total Order',
              value: '${_current.totalOrder}',
              icon: Icons.receipt_long_outlined,
              color: AppColors.info,
              change: prev != null
                  ? _changePercent(_current.totalOrder.toDouble(),
                      prev.totalOrder.toDouble()) : null,
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _StatCard(
              label: 'Rating',
              value: '${_current.rating} ⭐',
              icon: Icons.star_outline_rounded,
              color: AppColors.secondary,
              change: prev != null
                  ? _changePercent(_current.rating, prev.rating) : null,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Tingkat Respons',
              value: '${_current.responseRate.toInt()}%',
              icon: Icons.speed_rounded,
              color: AppColors.success,
              change: prev != null
                  ? _changePercent(_current.responseRate,
                      prev.responseRate) : null,
            ),
          ]),
          const SizedBox(height: 16),

          // ── Grafik pendapatan ──
          _SectionHeader(title: 'Grafik Pendapatan',
              icon: Icons.show_chart_rounded),
          const SizedBox(height: 10),
          _IncomeChart(
            months: _months,
            data: _months.map((m) =>
                _monthlyReports[m]!.income).toList(),
            selectedMonth: _selectedMonth,
            fmt: _fmt,
          ),
          const SizedBox(height: 16),

          // ── Statistik order detail ──
          _SectionHeader(title: 'Detail Order',
              icon: Icons.receipt_long_outlined),
          const SizedBox(height: 10),
          _OrderDetailCard(data: _current),
          const SizedBox(height: 16),

          // ── Perbandingan bulan lalu ──
          if (prev != null) ...[
            _SectionHeader(title: 'vs Bulan Lalu (${_months[_months.indexOf(_selectedMonth) - 1]})',
                icon: Icons.compare_arrows_rounded),
            const SizedBox(height: 10),
            _ComparisonCard(current: _current, prev: prev, fmt: _fmt),
            const SizedBox(height: 16),
          ],

          // ── Breakdown per kategori ──
          _SectionHeader(title: 'Breakdown Layanan',
              icon: Icons.pie_chart_outline_rounded),
          const SizedBox(height: 10),
          _CategoryBreakdown(
              total: _current.totalOrder),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Stat card dengan % perubahan ──
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final double? change;

  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color, this.change});

  @override
  Widget build(BuildContext context) {
    final isUp = (change ?? 0) >= 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16)),
            const Spacer(),
            if (change != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isUp
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isUp ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                      size: 10,
                      color: isUp ? AppColors.success : AppColors.error),
                  Text('${change!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                          color: isUp ? AppColors.success : AppColors.error)),
                ]),
              ),
          ]),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11,
              color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ── Grafik pendapatan ──
class _IncomeChart extends StatelessWidget {
  final List<String> months;
  final List<double> data;
  final String selectedMonth;
  final String Function(double) fmt;

  const _IncomeChart({required this.months, required this.data,
      required this.selectedMonth, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final total = data.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Total 6 Bulan',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(fmt(total), style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(months.length, (i) {
              final ratio = data[i] / maxVal;
              final isSel = months[i] == selectedMonth;
              return Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 24,
                    child: Center(child: isSel
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(fmt(data[i]),
                                style: const TextStyle(fontSize: 7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)))
                        : Text(fmt(data[i]),
                            style: const TextStyle(fontSize: 7,
                                color: AppColors.textHint))),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 80 * ratio,
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(months[i].substring(0, 3),
                      style: TextStyle(fontSize: 10,
                          color: isSel
                              ? AppColors.primary : AppColors.textHint,
                          fontWeight: isSel
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

// ── Detail order ──
class _OrderDetailCard extends StatelessWidget {
  final _ReportData data;
  const _OrderDetailCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        Row(children: [
          _OrderStat(label: 'Total', value: '${data.totalOrder}',
              color: AppColors.primary),
          _OrderStat(label: 'Selesai', value: '${data.completed}',
              color: AppColors.success),
          _OrderStat(label: 'Batal', value: '${data.cancelled}',
              color: AppColors.error),
          _OrderStat(label: 'Ditolak', value: '${data.rejected}',
              color: AppColors.warning),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Tingkat Penyelesaian',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${(data.completionRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.success)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: data.completionRate,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }
}

class _OrderStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _OrderStat({required this.label, required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 20,
        fontWeight: FontWeight.w700, color: color)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11,
        color: AppColors.textSecondary)),
  ]));
}

// ── Perbandingan bulan ──
class _ComparisonCard extends StatelessWidget {
  final _ReportData current, prev;
  final String Function(double) fmt;
  const _ComparisonCard({required this.current, required this.prev,
      required this.fmt});

  Widget _row(String label, String curVal, String prevVal,
      double change) {
    final isUp = change >= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary))),
        Text(prevVal, style: const TextStyle(fontSize: 13,
            color: AppColors.textHint)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.arrow_forward_rounded,
              size: 14, color: AppColors.textHint),
        ),
        Text(curVal, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isUp
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isUp ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
                size: 10,
                color: isUp ? AppColors.success : AppColors.error),
            Text('${change.abs().toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: isUp ? AppColors.success : AppColors.error)),
          ]),
        ),
      ]),
    );
  }

  double _pct(double cur, double p) =>
      p == 0 ? 0 : ((cur - p) / p) * 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        _row('Pendapatan', fmt(current.income), fmt(prev.income),
            _pct(current.income, prev.income)),
        _row('Total Order', '${current.totalOrder}', '${prev.totalOrder}',
            _pct(current.totalOrder.toDouble(), prev.totalOrder.toDouble())),
        _row('Order Selesai', '${current.completed}', '${prev.completed}',
            _pct(current.completed.toDouble(), prev.completed.toDouble())),
        _row('Rating', '${current.rating}⭐', '${prev.rating}⭐',
            _pct(current.rating, prev.rating)),
        _row('Tingkat Respons', '${current.responseRate.toInt()}%',
            '${prev.responseRate.toInt()}%',
            _pct(current.responseRate, prev.responseRate)),
      ]),
    );
  }
}

// ── Breakdown kategori layanan ──
class _CategoryBreakdown extends StatelessWidget {
  final int total;
  const _CategoryBreakdown({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        ..._serviceCategories.map((cat) {
          final ratio = total > 0 ? cat.count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cat.name, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary))),
                  Text('${cat.count} order',
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Text('${(ratio * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w700, color: cat.color)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation(cat.color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }),
      ]),
    );
  }
}

// ── Section header ──
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
