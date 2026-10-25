import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/mitra_notification_service.dart';

/// Ikon lonceng dengan badge jumlah notifikasi belum dibaca.
/// Dipakai di header dashboard (latar gradient, jadi ikon berwarna putih).
class NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  const NotificationBell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final svc = MitraNotificationService();
    return AnimatedBuilder(
      animation: svc,
      builder: (_, __) {
        final unread = svc.unreadCount;
        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 42, height: 42,
            child: Stack(clipBehavior: Clip.none, children: [
              Center(child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 21),
              )),
              if (unread > 0)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 17, minHeight: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(fontSize: 9,
                          color: Colors.white, fontWeight: FontWeight.w700),
                    )),
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }
}
