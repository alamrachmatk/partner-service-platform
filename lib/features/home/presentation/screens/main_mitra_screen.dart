import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_model.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../orders/presentation/screens/mitra_orders_screen.dart';
import '../../../chat/presentation/screens/mitra_chat_screen.dart';
import '../../../profile/presentation/screens/mitra_profile_screen.dart';

class MainMitraScreen extends StatefulWidget {
  final MitraModel mitra;
  static final globalKey = GlobalKey<_MainMitraScreenState>();
  const MainMitraScreen({Key? key, required this.mitra}) : super(key: key);

  @override
  State<MainMitraScreen> createState() => _MainMitraScreenState();
}

class _MainMitraScreenState extends State<MainMitraScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(mitra: widget.mitra),
      MitraOrdersScreen(mitra: widget.mitra),
      const MitraChatScreen(),
      MitraProfileScreen(mitra: widget.mitra),
    ];
  }

  void switchTab(int index) {
    if (mounted) setState(() => _currentIndex = index);
  }

  static const _navItems = [
    (icon: Icons.dashboard_rounded,           label: 'Dashboard'),
    (icon: Icons.receipt_long_rounded,        label: 'Pesanan'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    (icon: Icons.person_outline_rounded,      label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x18000000),
              blurRadius: 16, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final selected = i == _currentIndex;
                return GestureDetector(
                  onTap: () => switchTab(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_navItems[i].icon,
                          color: selected ? AppColors.primary : AppColors.textHint,
                          size: 24),
                      const SizedBox(height: 3),
                      Text(_navItems[i].label,
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textHint)),
                    ]),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
