import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/user/user_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'custom_text_field.dart';

class UserLoginForm extends StatefulWidget {
  const UserLoginForm({super.key});

  @override
  State<UserLoginForm> createState() => _UserLoginFormState();
}

class _UserLoginFormState extends State<UserLoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty) {
      _showError('E-posta adresi gerekli');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Şifre gerekli');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Auth Girişi
      final userCredential = await FirebaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Firestore'dan kullanıcı verisini çek ve doğrula
      final userDoc = await FirebaseService.getUser(userCredential.user!.uid);

      if (!userDoc!.exists) {
        _showError('Kullanıcı profili bulunamadı.');
        await FirebaseService.signOut();
        setState(() => _isLoading = false);
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['role'] != 'user') {
        _showError('Bu hesap bir kullanıcı hesabı değil.');
        await FirebaseService.signOut();
        setState(() => _isLoading = false);
        return;
      }

      // Oturum ID'sini kaydet
      FirebaseService.currentUserId = userCredential.user!.uid;

      if (_rememberMe) {
        await FirebaseService.saveRememberMe(
          userType: 'user',
          userId: userCredential.user!.uid,
        );
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Firebase error: $e');
      if (e is FirebaseAuthException && e.code == 'email-not-verified') {
        _showVerificationError();
      } else {
        _showError('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVerificationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Doğrulanmadı'),
        content: const Text(
          'Giriş yapabilmek için e-posta adresinizi doğrulamanız gerekmektedir. Lütfen gelen kutunuzu kontrol edin.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              if (_emailController.text.isEmpty ||
                  _passwordController.text.isEmpty) {
                // Şifre veya mail yoksa işlem yapamayız (zaten login denemiş olması lazım buraya gelmek için)
                return;
              }

              try {
                // Yükleniyor göster
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Doğrulama maili gönderiliyor...'),
                  ),
                );

                await FirebaseService.resendVerificationEmail(
                  _emailController.text.trim(),
                  _passwordController.text,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Doğrulama maili tekrar gönderildi! Spam klasörünü kontrol etmeyi unutmayın.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint('Resend error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mail gönderilemedi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tekrar Gönder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            hintText: 'E-posta Adresi',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
          ),

          CustomTextField(
            controller: _passwordController,
            hintText: 'Şifre',
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Beni Hatırla',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                disabledBackgroundColor: AppColors.primaryGreen.withOpacity(
                  0.6,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.white),
                      ),
                    )
                  : const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
