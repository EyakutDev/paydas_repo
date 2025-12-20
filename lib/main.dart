import 'package:flutter/material.dart';
import 'screens/register_screen.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const PaydasApp());
}

class PaydasApp extends StatelessWidget {
  const PaydasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paydaş',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RegisterScreen(),
    );
  }
}
