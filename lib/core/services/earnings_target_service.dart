import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../utils/currency_format.dart';
import 'mitra_notification_service.dart';

enum TargetPeriod { daily, monthly }

class EarningsTargetService extends ChangeNotifier {
  static final EarningsTargetService _instance =
      EarningsTargetService._internal();
  factory EarningsTargetService() => _instance;
  EarningsTargetService._internal();

  double _dailyTarget = 300000;
  double _monthlyTarget = 6000000;

  // TODO: ganti dengan data pendapatan nyata dari backend.
  // Nilai harian sama dengan kartu "Pendapatan Hari Ini" di dashboard.
  double get todayEarned => 220000;
  double get monthEarned => DummyEarnings.thisMonthEarnings;

  bool _notifiedDaily = false;
  bool _notifiedMonthly = false;

  double targetOf(TargetPeriod p) =>
      p == TargetPeriod.daily ? _dailyTarget : _monthlyTarget;

  double earnedOf(TargetPeriod p) =>
      p == TargetPeriod.daily ? todayEarned : monthEarned;

  double progressOf(TargetPeriod p) {
    final t = targetOf(p);
    if (t <= 0) return 0;
    final r = earnedOf(p) / t;
    return r > 1 ? 1 : r;
  }

  bool isAchieved(TargetPeriod p) => earnedOf(p) >= targetOf(p);

  double remainingOf(TargetPeriod p) {
    final r = targetOf(p) - earnedOf(p);
    return r < 0 ? 0 : r;
  }

  void setTarget(TargetPeriod p, double value) {
    if (p == TargetPeriod.daily) {
      _dailyTarget = value;
      _notifiedDaily = false;
    } else {
      _monthlyTarget = value;
      _notifiedMonthly = false;
    }
    notifyListeners();
    if (isAchieved(p)) _notifyAchieved(p);
  }

  void _notifyAchieved(TargetPeriod p) {
    final daily = p == TargetPeriod.daily;
    if (daily ? _notifiedDaily : _notifiedMonthly) return;
    if (daily) {
      _notifiedDaily = true;
    } else {
      _notifiedMonthly = true;
    }
    MitraNotificationService().add(
      title: 'Target ${daily ? 'harian' : 'bulanan'} tercapai 🎉',
      body: 'Pendapatanmu ${rupiah(earnedOf(p))} sudah melewati target '
          '${rupiah(targetOf(p))}. Hebat!',
      type: MitraNotifType.target,
    );
  }
}
