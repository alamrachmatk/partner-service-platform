import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MitraChatScreen extends StatelessWidget {
  const MitraChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Chat', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border)),
      ),
      body: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('💬', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text('Inbox Chat', style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 6),
        Text('Fitur ini segera hadir', style: TextStyle(fontSize: 13,
            color: AppColors.textSecondary)),
      ])),
    );
  }
}
