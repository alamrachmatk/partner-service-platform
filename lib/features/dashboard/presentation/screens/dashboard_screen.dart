import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';
import '../../../../core/models/mitra_order_model.dart';
import '../../../../core/widgets/online_status_widget.dart';
import '../../../../core/services/location_service.dart';
import '../../../orders/presentation/screens/mitra_order_detail_screen.dart';

// ── Model & Enum lokal ──
// ── Screen utama ──
class DashboardScreen extends StatefulWidget {
  final MitraModel mitra;
  const DashboardScreen({super.key, required this.mitra});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isAvailableToday = true;

  static const _weeklyData = [85000, 150000, 120000, 200000, 175000, 95000, 220000];
  static const _weekDays   = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  // Pakai DummyMitraOrders — pesanan hari ini
  List<MitraOrderModel> get _recentOrders => DummyMitraOrders.all
      .where((o) => o.status.isActive)
      .toList();

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000)    return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar ──
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primary,
              expandedHeight: 120,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 12, 20, 12),
                  child: Row(children: [
                    // Avatar
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(
                        widget.mitra.initials,
                        style: const TextStyle(fontSize: 17,
                            fontWeight: FontWeight.w700, color: Colors.white),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat datang,',
                            style: TextStyle(fontSize: 12, color: Colors.white70)),
                        Text(widget.mitra.fullName,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    )),
                    // Toggle online/offline — pakai widget baru
                    const OnlineToggleButton(compact: true),
                  ]),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Toggle Online/Offline besar ──
                    const OnlineToggleButton(compact: false),
                    const SizedBox(height: 12),
                    // ── Share lokasi card ──
                    const LocationShareCard(isActiveOrder: true),
                    const SizedBox(height: 16),
                    // ── Stat cards ──
                    Row(children: [
                      _StatCard(label: 'Pendapatan\nHari Ini',
                          value: _fmt(220000),
                          icon: Icons.payments_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      _StatCard(label: 'Pesanan\nAktif',
                          value: '2',
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.info),
                      const SizedBox(width: 10),
                      _StatCard(label: 'Rating\nSaya',
                          value: '4.8 ⭐',
                          icon: Icons.star_outline_rounded,
                          color: AppColors.secondary),
                    ]),
                    const SizedBox(height: 16),

                    // ── Grafik mingguan ──
                    _WeeklyChart(
                        data: _weeklyData, days: _weekDays, fmt: _fmt),
                    const SizedBox(height: 16),

                    // ── Performa bulan ini ──
                    _PerformanceCard(),
                    const SizedBox(height: 16),

                    // ── Pesanan hari ini ──
                    Row(children: [
                      const Text('Pesanan Hari Ini',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const Spacer(),
                      Text('${_recentOrders.length} pesanan',
                          style: const TextStyle(fontSize: 12,
                              color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 10),
                    ..._recentOrders.map((o) =>
                        _DashboardOrderCard(
                          order: o,
                          fmt: _fmt,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => MitraOrderDetailScreen(
                                  order: o,
                                  onUpdate: (_) {},
                                ),
                              )),
                        )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10,
              color: AppColors.textSecondary, height: 1.3)),
        ]),
      ),
    );
  }
}

// ── Grafik mingguan ──
class _WeeklyChart extends StatefulWidget {
  final List<int> data;
  final List<String> days;
  final String Function(double) fmt;
  const _WeeklyChart({required this.data, required this.days, required this.fmt});

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart> {
  bool _isWeekly = true;

  // Data simulasi bulan ini
  static const _monthlyData = [
    1200000, 980000, 1450000, 1100000,
  ];
  static const _monthlyLabels = ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'];

  List<int> get _activeData => _isWeekly ? widget.data : _monthlyData;
  List<String> get _activeLabels => _isWeekly ? widget.days : _monthlyLabels;

  @override
  Widget build(BuildContext context) {
    final maxVal = _activeData.reduce((a, b) => a > b ? a : b).toDouble();
    final total  = _activeData.reduce((a, b) => a + b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header + toggle
        Row(children: [
          const Text('Pendapatan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          // Toggle Minggu / Bulan
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _ToggleBtn(label: 'Minggu', selected: _isWeekly,
                  onTap: () => setState(() => _isWeekly = true)),
              _ToggleBtn(label: 'Bulan', selected: !_isWeekly,
                  onTap: () => setState(() => _isWeekly = false)),
            ]),
          ),
        ]),
        const SizedBox(height: 4),
        Text(widget.fmt(total),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 16),

        // Bar chart — fix: tambah padding top agar tooltip tidak terpotong
        SizedBox(
          height: 130, // ✅ naik dari 110 ke 130 agar cukup ruang
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_activeData.length, (i) {
              final ratio = _activeData[i] / maxVal;
              final isLast = i == _activeData.length - 1;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tooltip nilai
                    if (isLast)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(widget.fmt(_activeData[i].toDouble()),
                            style: const TextStyle(fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      )
                    else
                      const SizedBox(height: 20), // ✅ placeholder agar semua bar sejajar
                    // Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 72 * ratio, // ✅ turun dari 80 ke 72
                      decoration: BoxDecoration(
                        color: isLast
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.25),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Label hari
                    Text(
                      _isWeekly
                          ? _activeLabels[i]
                          : 'M${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isLast ? AppColors.primary : AppColors.textHint,
                        fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [const BoxShadow(color: Color(0x12000000),
                  blurRadius: 4, offset: Offset(0, 1))]
              : [],
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textHint,
        )),
      ),
    );
  }
}

// ── Performa bulan ini ──
class _PerformanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Performa Bulan Ini',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Row(children: [
          _PerfItem(label: 'Total\nOrder', value: '24',
              icon: Icons.receipt_long_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          _PerfItem(label: 'Selesai', value: '22',
              icon: Icons.check_circle_outline_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          _PerfItem(label: 'Dibatalkan', value: '2',
              icon: Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: 10),
          _PerfItem(label: 'Respons', value: '95%',
              icon: Icons.speed_rounded, color: AppColors.info),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Tingkat Penyelesaian',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Text('91.7%', style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: AppColors.success)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: const LinearProgressIndicator(
            value: 0.917,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation(AppColors.success),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }
}

class _PerfItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _PerfItem({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.w700, color: color)),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
    ]));
  }
}

// ── Order card di dashboard ──
class _DashboardOrderCard extends StatelessWidget {
  final MitraOrderModel order;
  final String Function(double) fmt;
  final VoidCallback onTap;
  const _DashboardOrderCard({required this.order, required this.fmt,
      required this.onTap});

  Color get _statusColor {
    switch (order.status) {
      case MitraOrderStatus.pending:    return AppColors.warning;
      case MitraOrderStatus.confirmed:  return AppColors.primary;
      case MitraOrderStatus.onTheWay:   return AppColors.info;
      case MitraOrderStatus.inProgress: return AppColors.primary;
      case MitraOrderStatus.completed:  return AppColors.success;
      default:                          return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(order.serviceEmoji,
                style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.serviceName, style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(order.customerName, style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                const Icon(Icons.access_time_rounded,
                    size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(order.formattedTime, style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
              ]),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(fmt(order.price), style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(order.status.label, style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w600, color: _statusColor)),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textHint),
          ]),
        ]),
      ),
    );
  }
}
