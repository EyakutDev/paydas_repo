import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user/user_home_screen.dart';
import 'business/business_home_screen.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String userType;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her 3 saniyede bir kontrol et
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkVerification(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    // 1. Geçici giriş yapıp kontrol et
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      await credential.user?.reload();

      if (credential.user?.emailVerified == true) {
        _timer?.cancel();
        setState(() => _isVerified = true);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'E-posta başarıyla doğrulandı! Yönlendiriliyorsunuz...',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Verileri getir ve yönlendir
        try {
          final uid = credential.user!.uid;

          if (widget.userType == 'user') {
            // Kullanıcı ana sayfasına git
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const UserHomeScreen()),
              (route) => false,
            );
          } else {
            // İşletme bilgilerini çek ve ana sayfaya git
            final doc = await FirebaseFirestore.instance
                .collection('businesses')
                .doc(uid)
                .get();
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessHomeScreen(
                    businessId: uid,
                    businessName: data['name'] ?? 'İşletme',
                  ),
                ),
                (route) => false,
              );
            } else {
              // Hata durumunda login ekranına dön
              throw Exception('İşletme kaydı bulunamadı');
            }
          }
        } catch (e) {
          debugPrint('Navigation error: $e');
          // Hata olursa güvenli moda geç: Login'e at
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        // Doğrulanmadıysa çıkış yap
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      debugPrint("Verification check error: $e");
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseService.resendVerificationEmail(
        widget.email,
        widget.password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama maili tekrar gönderildi.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRegistration() async {
    setState(() => _isLoading = true);

    try {
      // 1. İşlemi yapmak için auth ol
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      final uid = credential.user!.uid;

      // 2. Firestore kaydını sil
      if (widget.userType == 'user') {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      } else {
        await FirebaseFirestore.instance
            .collection('businesses')
            .doc(uid)
            .delete();
      }

      // 3. Auth kullanıcısını sil
      await credential.user!.delete();

      if (!mounted) return;

      // 4. Register ekranına/Login ekranına dön
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt işlemi iptal edildi.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Cancel error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İptal edilirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        backgroundColor: AppColors.primaryGreen,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 80,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 24),
            Text(
              '${widget.email} adresine doğrulama bağlantısı gönderildi.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lütfen gelen kutunuzu (ve spam klasörünü) kontrol edin ve bağlantıya tıklayın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            if (_isVerified)
              const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Doğrulandı!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(color: AppColors.primaryGreen),

            const SizedBox(height: 16),
            if (!_isVerified)
              const Text(
                'Doğrulama bekleniyor...',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _resendEmail,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  foregroundColor: AppColors.primaryGreen,
                ),
                child: Text(
                  _isLoading ? 'İşlem Yapılıyor...' : 'Tekrar Gönder',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : _cancelRegistration,
              child: const Text(
                'Vazgeç ve Kaydı Sil',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
