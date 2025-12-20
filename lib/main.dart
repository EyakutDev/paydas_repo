import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: const SplashScreen(),
    );
  }
}
