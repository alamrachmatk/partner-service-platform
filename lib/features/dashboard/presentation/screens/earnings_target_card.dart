import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/earnings_target_service.dart';
import '../../../../core/utils/currency_format.dart';

class EarningsTargetCard extends StatefulWidget {
  const EarningsTargetCard({super.key});

  @override
  State<EarningsTargetCard> createState() => _EarningsTargetCardState();
}

class _EarningsTargetCardState extends State<EarningsTargetCard> {
  final _svc = EarningsTargetService();
  TargetPeriod _period = TargetPeriod.daily;

  Future<void> _editTarget() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TargetSheet(
          period: _period, current: _svc.targetOf(_period)),
    );
    if (result == null) return;
    _svc.setTarget(_period, result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Target ${_period == TargetPeriod.daily ? 'harian' : 'bulanan'} '
          'diatur ke ${rupiah(result)}'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _svc,
      builder: (_, __) {
        final target = _svc.targetOf(_period);
        final earned = _svc.earnedOf(_period);
        final progress = _svc.progressOf(_period);
        final achieved = _svc.isAchieved(_period);
        final remaining = _svc.remainingOf(_period);
        final color = achieved ? AppColors.success : AppColors.primary;

        // Untuk target bulanan: berapa per hari yang dibutuhkan sampai akhir bulan
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final daysLeft = daysInMonth - now.day + 1;
        final perDay = daysLeft > 0 ? remaining / daysLeft : remaining;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: achieved
                  ? AppColors.success.withOpacity(0.4) : AppColors.border,
              width: achieved ? 1.5 : 0.5,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header ──
            Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.flag_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Target Pendapatan',
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
              GestureDetector(
                onTap: _editTarget,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined,
                        size: 13, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Atur', style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ── Toggle periode ──
            _PeriodToggle(
              selected: _period,
              onChanged: (p) => setState(() => _period = p),
            ),
            const SizedBox(height: 16),

            // ── Nominal ──
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(rupiahShort(earned), style: TextStyle(fontSize: 26,
                  fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('/ ${rupiahShort(target)}',
                    style: const TextStyle(fontSize: 13,
                        color: AppColors.textSecondary)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w800, color: color)),
              ),
            ]),
            const SizedBox(height: 10),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Keterangan ──
            if (achieved)
              const Text('🎉 Target tercapai! Kerja bagus.',
                  style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600, color: AppColors.success))
            else
              Text('Sisa ${rupiah(remaining)} lagi untuk capai target',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),

            if (_period == TargetPeriod.monthly && !achieved) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 15, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Sisa $daysLeft hari bulan ini · rata-rata '
                    '${rupiahShort(perDay)} per hari agar target tercapai',
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.info, height: 1.4),
                  )),
                ]),
              ),
            ],
          ]),
        );
      },
    );
  }
}

// ── Toggle Harian / Bulanan ──
class _PeriodToggle extends StatelessWidget {
  final TargetPeriod selected;
  final void Function(TargetPeriod) onChanged;
  const _PeriodToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget item(TargetPeriod p, String label) {
      final sel = p == selected;
      return Expanded(child: GestureDetector(
        onTap: () => onChanged(p),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: sel
                ? [BoxShadow(
                    color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                : null,
          ),
          child: Center(child: Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              color: sel ? AppColors.primary : AppColors.textSecondary))),
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        item(TargetPeriod.daily, 'Harian'),
        item(TargetPeriod.monthly, 'Bulanan'),
      ]),
    );
  }
}

// ── Bottom sheet atur target ──
class _TargetSheet extends StatefulWidget {
  final TargetPeriod period;
  final double current;
  const _TargetSheet({required this.period, required this.current});

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late final TextEditingController _ctrl;

  bool get _daily => widget.period == TargetPeriod.daily;
  double get _min => _daily ? 50000 : 500000;
  double get _value => double.tryParse(_ctrl.text) ?? 0;
  bool get _valid => _value >= _min;

  List<double> get _quick => _daily
      ? [200000, 300000, 500000, 750000]
      : [3000000, 5000000, 7500000, 10000000];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.current.round().toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Atur Target ${_daily ? 'Harian' : 'Bulanan'}',
              style: const TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(_daily
              ? 'Berapa pendapatan yang ingin kamu capai setiap hari?'
              : 'Berapa pendapatan yang ingin kamu capai bulan ini?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Input nominal
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 22,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _valid ? rupiah(_value) : 'Minimal ${rupiah(_min)}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: _valid ? AppColors.primary : AppColors.error),
            ),
          ),
          const SizedBox(height: 14),

          // Pilihan cepat
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(spacing: 8, runSpacing: 8,
              children: _quick.map((q) {
                final sel = _value == q;
                return GestureDetector(
                  onTap: () => setState(
                      () => _ctrl.text = q.round().toString()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.border,
                        width: sel ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(rupiahShort(q), style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel
                            ? AppColors.primary : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 15, color: AppColors.warning),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Pilih target yang menantang tapi realistis agar kamu tetap '
                'termotivasi.',
                style: TextStyle(fontSize: 11,
                    color: AppColors.warning, height: 1.4),
              )),
            ]),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
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
              onPressed: _valid ? () => Navigator.pop(context, _value) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Simpan Target',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }
}
