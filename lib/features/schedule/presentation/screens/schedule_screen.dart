import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_order_model.dart';
import '../../../orders/presentation/screens/mitra_order_detail_screen.dart';

// ── Model jam operasional ──
class _WorkDay {
  final String name, short;
  bool isActive;
  TimeOfDay startTime;
  TimeOfDay endTime;

  _WorkDay({
    required this.name,
    required this.short,
    this.isActive = true,
    this.startTime = const TimeOfDay(hour: 8, minute: 0),
    this.endTime   = const TimeOfDay(hour: 17, minute: 0),
  });
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _isAvailableToday = true;
  int _maxOrderPerDay    = 5;
  bool _loading          = false;

  // Hari libur yang dipilih
  final Set<DateTime> _holidays = {};

  // Bulan yang ditampilkan di kalender
  DateTime _calendarMonth = DateTime.now();

  // Jam operasional per hari
  final List<_WorkDay> _workDays = [
    _WorkDay(name: 'Senin',  short: 'Sen'),
    _WorkDay(name: 'Selasa', short: 'Sel'),
    _WorkDay(name: 'Rabu',   short: 'Rab'),
    _WorkDay(name: 'Kamis',  short: 'Kam'),
    _WorkDay(name: 'Jumat',  short: 'Jum'),
    _WorkDay(name: 'Sabtu',  short: 'Sab',
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 14, minute: 0)),
    _WorkDay(name: 'Minggu', short: 'Min', isActive: false),
  ];

  // Pesanan mendatang (dari dummy)
  List<MitraOrderModel> get _upcomingOrders => DummyMitraOrders.all
      .where((o) => o.status.isActive &&
          o.scheduledAt.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _isHoliday(DateTime date) => _holidays.any((h) =>
      h.year == date.year && h.month == date.month && h.day == date.day);

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _hasOrder(DateTime date) => _upcomingOrders.any((o) =>
      o.scheduledAt.year == date.year &&
      o.scheduledAt.month == date.month &&
      o.scheduledAt.day == date.day);

  Future<void> _save() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Jadwal berhasil disimpan'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Jadwal & Ketersediaan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : const Text('Simpan',
                    style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Jam Kerja'),
            Tab(text: 'Hari Libur'),
            Tab(text: 'Kalender'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _WorkHoursTab(
            isAvailableToday: _isAvailableToday,
            maxOrderPerDay: _maxOrderPerDay,
            workDays: _workDays,
            onToggleToday: (v) => setState(() => _isAvailableToday = v),
            onMaxOrderChange: (v) => setState(() => _maxOrderPerDay = v),
            onToggleDay: (i, v) => setState(() => _workDays[i].isActive = v),
            onChangeTime: (i, isStart) async {
              final picked = await showTimePicker(
                context: context,
                initialTime: isStart
                    ? _workDays[i].startTime
                    : _workDays[i].endTime,
              );
              if (picked != null) {
                setState(() {
                  if (isStart) _workDays[i].startTime = picked;
                  else _workDays[i].endTime = picked;
                });
              }
            },
            fmtTime: _fmtTime,
          ),
          _HolidayTab(
            month: _calendarMonth,
            holidays: _holidays,
            isHoliday: _isHoliday,
            isToday: _isToday,
            hasOrder: _hasOrder,
            onMonthChange: (dir) => setState(() {
              _calendarMonth = DateTime(
                  _calendarMonth.year,
                  _calendarMonth.month + dir);
            }),
            onToggleHoliday: (date) {
              setState(() {
                if (_isHoliday(date)) {
                  _holidays.removeWhere((h) =>
                      h.year == date.year &&
                      h.month == date.month &&
                      h.day == date.day);
                } else {
                  _holidays.add(date);
                }
              });
            },
            upcomingOrders: _upcomingOrders,
          ),
          _CalendarTab(
            month: _calendarMonth,
            isHoliday: _isHoliday,
            isToday: _isToday,
            hasOrder: _hasOrder,
            upcomingOrders: _upcomingOrders,
            onMonthChange: (dir) => setState(() {
              _calendarMonth = DateTime(
                  _calendarMonth.year,
                  _calendarMonth.month + dir);
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1: JAM KERJA
// ─────────────────────────────────────────────
class _WorkHoursTab extends StatelessWidget {
  final bool isAvailableToday;
  final int maxOrderPerDay;
  final List<_WorkDay> workDays;
  final void Function(bool) onToggleToday;
  final void Function(int) onMaxOrderChange;
  final void Function(int, bool) onToggleDay;
  final void Function(int, bool) onChangeTime;
  final String Function(TimeOfDay) fmtTime;

  const _WorkHoursTab({
    required this.isAvailableToday, required this.maxOrderPerDay,
    required this.workDays, required this.onToggleToday,
    required this.onMaxOrderChange, required this.onToggleDay,
    required this.onChangeTime, required this.fmtTime,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [

        // ── Toggle tersedia hari ini ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAvailableToday
                  ? AppColors.success.withOpacity(0.4)
                  : AppColors.border,
              width: isAvailableToday ? 1.5 : 0.5,
            ),
          ),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isAvailableToday
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.bolt_rounded,
                  color: isAvailableToday
                      ? AppColors.success : AppColors.textHint,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tersedia Hari Ini',
                    style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(
                  isAvailableToday
                      ? 'Kamu akan muncul di hasil pencarian same-day'
                      : 'Kamu tidak menerima pesanan hari ini',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ],
            )),
            Switch(
              value: isAvailableToday,
              onChanged: onToggleToday,
              activeColor: AppColors.success,
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Maks order per hari ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.inbox_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Maks. Pesanan per Hari',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 4),
            const Text('Batasi jumlah order agar tidak kewalahan',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _CounterBtn(
                icon: Icons.remove_rounded,
                onTap: maxOrderPerDay > 1
                    ? () => onMaxOrderChange(maxOrderPerDay - 1)
                    : null,
              ),
              const SizedBox(width: 20),
              Column(children: [
                Text('$maxOrderPerDay',
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const Text('pesanan/hari',
                    style: TextStyle(fontSize: 11,
                        color: AppColors.textSecondary)),
              ]),
              const SizedBox(width: 20),
              _CounterBtn(
                icon: Icons.add_rounded,
                onTap: maxOrderPerDay < 20
                    ? () => onMaxOrderChange(maxOrderPerDay + 1)
                    : null,
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Jam kerja per hari ──
        const _SectionHeader(title: 'Jam Operasional',
            icon: Icons.schedule_rounded),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: List.generate(workDays.length, (i) {
              final day = workDays[i];
              final isLast = i == workDays.length - 1;
              return Container(
                decoration: BoxDecoration(
                  border: !isLast
                      ? const Border(bottom: BorderSide(
                          color: AppColors.border, width: 0.5))
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(children: [
                  SizedBox(width: 50,
                    child: Text(day.name, style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: day.isActive
                            ? AppColors.textPrimary
                            : AppColors.textHint)),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: day.isActive,
                    onChanged: (v) => onToggleDay(i, v),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  if (day.isActive) ...[
                    _TimePickerBtn(
                      time: fmtTime(day.startTime),
                      onTap: () => onChangeTime(i, true),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('–', style: TextStyle(
                          fontSize: 14, color: AppColors.textHint)),
                    ),
                    _TimePickerBtn(
                      time: fmtTime(day.endTime),
                      onTap: () => onChangeTime(i, false),
                    ),
                  ] else
                    const Text('Libur',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic)),
                ]),
              );
            }),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2: HARI LIBUR
// ─────────────────────────────────────────────
class _HolidayTab extends StatelessWidget {
  final DateTime month;
  final Set<DateTime> holidays;
  final bool Function(DateTime) isHoliday, isToday, hasOrder;
  final void Function(int) onMonthChange;
  final void Function(DateTime) onToggleHoliday;
  final List<MitraOrderModel> upcomingOrders;

  const _HolidayTab({
    required this.month, required this.holidays,
    required this.isHoliday, required this.isToday, required this.hasOrder,
    required this.onMonthChange, required this.onToggleHoliday,
    required this.upcomingOrders,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Info ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Ketuk tanggal untuk tandai sebagai hari libur. '
              'Kamu tidak akan menerima pesanan di hari libur.',
              style: TextStyle(fontSize: 12,
                  color: AppColors.warning, height: 1.4),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Kalender ──
        _CalendarWidget(
          month: month,
          isHoliday: isHoliday,
          isToday: isToday,
          hasOrder: hasOrder,
          onMonthChange: onMonthChange,
          onDayTap: (date) {
            if (hasOrder(date)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ada pesanan di tanggal ini, tidak bisa dijadikan libur'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ));
              return;
            }
            onToggleHoliday(date);
          },
          showLegend: true,
        ),
        const SizedBox(height: 16),

        // ── List hari libur ──
        if (holidays.isNotEmpty) ...[
          const _SectionHeader(title: 'Hari Libur Dipilih',
              icon: Icons.beach_access_rounded),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: (() {
                final sorted = holidays.toList()..sort((a, b) => a.compareTo(b));
                return List.generate(sorted.length, (i) {
                  final date = sorted[i];
                  final isLast = i == sorted.length - 1;
                  return Container(
                    decoration: BoxDecoration(
                      border: !isLast
                          ? const Border(bottom: BorderSide(
                              color: AppColors.border, width: 0.5))
                          : null,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.beach_access_rounded,
                            color: AppColors.error, size: 18),
                      ),
                      title: Text(_fmtDate(date),
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.error, size: 18),
                        onPressed: () => onToggleHoliday(date),
                      ),
                    ),
                  );
                });
              })(),
            ),
          ),
        ] else
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🏖️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              const Text('Belum ada hari libur',
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Ketuk tanggal di kalender untuk menandainya',
                  style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
            ]),
          )),
        const SizedBox(height: 80),
      ]),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei',
        'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    const days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }
}

// ─────────────────────────────────────────────
// TAB 3: KALENDER PESANAN
// ─────────────────────────────────────────────
class _CalendarTab extends StatelessWidget {
  final DateTime month;
  final bool Function(DateTime) isHoliday, isToday, hasOrder;
  final void Function(int) onMonthChange;
  final List<MitraOrderModel> upcomingOrders;

  const _CalendarTab({
    required this.month, required this.isHoliday,
    required this.isToday, required this.hasOrder,
    required this.onMonthChange, required this.upcomingOrders,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CalendarWidget(
          month: month,
          isHoliday: isHoliday,
          isToday: isToday,
          hasOrder: hasOrder,
          onMonthChange: onMonthChange,
          onDayTap: (_) {},
          showLegend: true,
        ),
        const SizedBox(height: 16),

        const _SectionHeader(title: 'Pesanan Mendatang',
            icon: Icons.event_note_rounded),
        const SizedBox(height: 10),

        upcomingOrders.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Tidak ada pesanan mendatang',
                    style: TextStyle(fontSize: 13,
                        color: AppColors.textSecondary)),
              ))
            : Column(
                children: upcomingOrders.map((o) => GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MitraOrderDetailScreen(
                      order: o,
                      onUpdate: (_) {},
                    ),
                  )),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(o.serviceEmoji,
                            style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.serviceName, style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                          const SizedBox(height: 3),
                          Text(o.customerName, style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      )),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(o.formattedDate, style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                        Text(o.formattedTime, style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Icon(Icons.chevron_right_rounded,
                            size: 16, color: AppColors.textHint),
                      ]),
                    ]),
                  ),
                )).toList(),
              ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED: CALENDAR WIDGET
// ─────────────────────────────────────────────
class _CalendarWidget extends StatelessWidget {
  final DateTime month;
  final bool Function(DateTime) isHoliday, isToday, hasOrder;
  final void Function(int) onMonthChange;
  final void Function(DateTime) onDayTap;
  final bool showLegend;

  const _CalendarWidget({
    required this.month, required this.isHoliday,
    required this.isToday, required this.hasOrder,
    required this.onMonthChange, required this.onDayTap,
    this.showLegend = false,
  });

  @override
  Widget build(BuildContext context) {
    const monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei',
        'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final firstDay  = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Offset (Senin=1, tapi widget starts Mon=0)
    final startOffset = (firstDay.weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        // Header bulan
        Row(children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary),
            onPressed: () => onMonthChange(-1),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
          Expanded(child: Text(
            '${monthNames[month.month]} ${month.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          )),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
            onPressed: () => onMonthChange(1),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ]),
        const SizedBox(height: 12),

        // Header hari
        Row(children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
            .map((d) => Expanded(
              child: Text(d, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint)),
            )).toList()),
        const SizedBox(height: 8),

        // Grid tanggal
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (_, i) {
            if (i < startOffset) return const SizedBox();
            final day = i - startOffset + 1;
            final date = DateTime(month.year, month.month, day);
            final today   = isToday(date);
            final holiday = isHoliday(date);
            final ordered = hasOrder(date);

            return GestureDetector(
              onTap: () => onDayTap(date),
              child: Container(
                decoration: BoxDecoration(
                  color: holiday
                      ? AppColors.error.withOpacity(0.1)
                      : today
                          ? AppColors.primary
                          : ordered
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: today
                      ? null
                      : ordered
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.3))
                          : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day', style: TextStyle(
                      fontSize: 12,
                      fontWeight: today || holiday
                          ? FontWeight.w700 : FontWeight.w400,
                      color: holiday
                          ? AppColors.error
                          : today
                              ? Colors.white
                              : AppColors.textPrimary,
                    )),
                    if (ordered)
                      Container(width: 4, height: 4,
                          decoration: BoxDecoration(
                            color: today ? Colors.white : AppColors.primary,
                            shape: BoxShape.circle,
                          )),
                  ],
                ),
              ),
            );
          },
        ),

        // Legend
        if (showLegend) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Legend(color: AppColors.primary, label: 'Hari Ini'),
            _Legend(color: AppColors.primary.withOpacity(0.08),
                label: 'Ada Pesanan', hasBorder: true),
            _Legend(color: AppColors.error.withOpacity(0.1),
                label: 'Hari Libur'),
          ]),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(icon,
            color: onTap != null ? AppColors.primary : AppColors.textHint,
            size: 20),
      ),
    );
  }
}

class _TimePickerBtn extends StatelessWidget {
  final String time;
  final VoidCallback onTap;
  const _TimePickerBtn({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(time, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.primary)),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasBorder;
  const _Legend({required this.color, required this.label,
      this.hasBorder = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 14, height: 14,
          decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(4),
            border: hasBorder ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
          )),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 10,
          color: AppColors.textSecondary)),
    ]);
  }
}
