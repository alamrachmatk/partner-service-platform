import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/location_service.dart';

// ─────────────────────────────────────────────
// TOGGLE ONLINE/OFFLINE — Bisa dipasang di mana saja
// ─────────────────────────────────────────────
class OnlineToggleButton extends StatefulWidget {
  final bool compact; // true = kecil untuk appbar, false = besar untuk dashboard
  const OnlineToggleButton({super.key, this.compact = false});

  @override
  State<OnlineToggleButton> createState() => _OnlineToggleButtonState();
}

class _OnlineToggleButtonState extends State<OnlineToggleButton>
    with SingleTickerProviderStateMixin {
  final _svc = LocationService();
  bool _loading = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _pulseAnim = Tween(begin: 0.8, end: 1.1).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);

    if (_svc.isOnline) {
      // Konfirmasi go offline
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Go Offline?',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
              'Kamu tidak akan menerima pesanan baru saat offline.',
              style: TextStyle(fontSize: 14,
                  color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, Offline',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _svc.goOffline();
        if (mounted) _snack('Kamu sekarang offline', AppColors.error);
      }
    } else {
      final success = await _svc.goOnline();
      if (success && mounted) {
        _snack('Kamu sekarang online! Siap menerima pesanan 🎉',
            AppColors.success);
      } else if (mounted) {
        _snack('Gagal mengaktifkan lokasi. Cek izin GPS.',
            AppColors.error);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _svc.onlineStatusStream,
      initialData: _svc.isOnline,
      builder: (_, snap) {
        final isOnline = snap.data ?? false;
        return widget.compact
            ? _buildCompact(isOnline)
            : _buildFull(isOnline);
      },
    );
  }

  // ── Versi kecil untuk AppBar ──
  Widget _buildCompact(bool isOnline) {
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isOnline
              ? AppColors.success.withOpacity(0.15)
              : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline
                ? AppColors.success.withOpacity(0.4)
                : AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (_loading)
            const SizedBox(width: 8, height: 8,
              child: CircularProgressIndicator(strokeWidth: 1.5,
                  color: AppColors.success))
          else
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: isOnline ? _pulseAnim.value : 1.0,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 5),
          Text(isOnline ? 'Online' : 'Offline',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: isOnline ? AppColors.success : AppColors.error)),
        ]),
      ),
    );
  }

  // ── Versi besar untuk dashboard ──
  Widget _buildFull(bool isOnline) {
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOnline
                ? [AppColors.success, const Color(0xFF66BB6A)]
                : [AppColors.error, const Color(0xFFEF5350)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: (isOnline ? AppColors.success : AppColors.error)
                .withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Row(children: [
          // Pulse indicator
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                if (isOnline) Transform.scale(
                  scale: _pulseAnim.value * 1.5,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOnline
                        ? Icons.wifi_rounded
                        : Icons.wifi_off_rounded,
                    color: Colors.white, size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isOnline ? 'Kamu Online' : 'Kamu Offline',
                  style: const TextStyle(fontSize: 17,
                      fontWeight: FontWeight.w800, color: Colors.white)),
              Text(
                isOnline
                    ? 'Siap menerima pesanan baru'
                    : 'Ketuk untuk mulai menerima pesanan',
                style: const TextStyle(fontSize: 12,
                    color: Colors.white70),
              ),
            ],
          )),
          // Toggle switch
          if (_loading)
            const SizedBox(width: 24, height: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          else
            Switch(
              value: isOnline,
              onChanged: (_) => _toggle(),
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
            ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BADGE STATUS ONLINE — kecil, untuk profil/list
// ─────────────────────────────────────────────
class OnlineStatusBadge extends StatelessWidget {
  const OnlineStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = LocationService();
    return StreamBuilder<bool>(
      stream: svc.onlineStatusStream,
      initialData: svc.isOnline,
      builder: (_, snap) {
        final isOnline = snap.data ?? false;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isOnline
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(isOnline ? 'Online' : 'Offline',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: isOnline ? AppColors.success : AppColors.error)),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LOCATION SHARE CARD — tampil saat order aktif
// ─────────────────────────────────────────────
class LocationShareCard extends StatefulWidget {
  final bool isActiveOrder;
  const LocationShareCard({super.key, this.isActiveOrder = false});

  @override
  State<LocationShareCard> createState() => _LocationShareCardState();
}

class _LocationShareCardState extends State<LocationShareCard> {
  final _svc = LocationService();

  @override
  Widget build(BuildContext context) {
    if (!_svc.isOnline) return const SizedBox.shrink();

    return StreamBuilder<MitraLocation>(
      stream: _svc.locationStream,
      builder: (_, snap) {
        final loc = snap.data ?? _svc.currentLocation;
        final isSharing = _svc.isSharingLocation;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSharing
                ? AppColors.info.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSharing
                  ? AppColors.info.withOpacity(0.3)
                  : AppColors.border,
              width: isSharing ? 1.5 : 0.5,
            ),
          ),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(
                color: isSharing
                    ? AppColors.info.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSharing
                    ? Icons.location_on_rounded
                    : Icons.location_off_outlined,
                color: isSharing ? AppColors.info : AppColors.textHint,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSharing ? 'Berbagi Lokasi Aktif' : 'Berbagi Lokasi Nonaktif',
                  style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSharing ? AppColors.info : AppColors.textSecondary),
                ),
                if (loc != null && isSharing)
                  Text(loc.formatted, style: const TextStyle(
                      fontSize: 10, color: AppColors.textHint,
                      fontFamily: 'monospace'))
                else
                  Text(
                    isSharing
                        ? 'Pelanggan bisa melihat posisimu'
                        : 'Aktifkan saat mulai perjalanan',
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
              ],
            )),
            Switch(
              value: isSharing,
              onChanged: (v) {
                setState(() {
                  if (v) {
                    _svc.startSharingLocation();
                  } else {
                    _svc.stopSharingLocation();
                  }
                });
              },
              activeColor: AppColors.info,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
        );
      },
    );
  }
}
