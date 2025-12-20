import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'register_screen.dart';
import 'business/business_home_screen.dart';
import 'user/user_home_screen.dart';
import 'muhtar/muhtar_home_screen.dart';
import '../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Biraz bekle (Logo görünsün)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final session = await FirebaseService.getRememberedUser();

      if (session != null) {
        final userType = session['userType'];
        final userId = session['userId'];
        FirebaseService.currentUserId = userId;

        if (userType == 'business' && userId != null) {
          // İşletme adını çek
          final doc = await FirebaseFirestore.instance
              .collection('businesses')
              .doc(userId)
              .get();

          if (doc.exists && mounted) {
            final data = doc.data() as Map<String, dynamic>;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BusinessHomeScreen(
                  businessName: data['name'] ?? 'İşletme',
                  businessId: userId,
                ),
              ),
            );
            return;
          }
        } else if (userType == 'user' && userId != null) {
          // Kullanıcı için direkt geçiş (Şimdilik veri çekmeye gerek yok)
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserHomeScreen()),
            );
            return;
          }
        } else if (userType == 'muhtar' && userId != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MuhtarHomeScreen()),
            );
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Session check error: $e');
    }

    // Oturum yoksa veya hata varsa kayıt ekranına git
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primaryGreen),
          ],
        ),
      ),
    );
  }
}
