import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/auth_mitra_screen.dart';
import 'core/constants/app_colors.dart';

void main() => runApp(const JasaKuMitraApp());

class JasaKuMitraApp extends StatelessWidget {
  const JasaKuMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JasaKu Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, elevation: 0, centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
      ),
      home: const AuthMitraScreen(),
    );
  }
}
