import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/legal_texts.dart';
import '../utils/phone_validator.dart';
import '../services/firebase_service.dart';
import '../screens/email_verification_screen.dart';
import 'custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRegisterForm extends StatefulWidget {
  const UserRegisterForm({super.key});

  @override
  State<UserRegisterForm> createState() => _UserRegisterFormState();
}

class _UserRegisterFormState extends State<UserRegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  bool _isAgreementChecked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _showKvkkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KVKK Aydınlatma Metni'),
        content: SingleChildScrollView(
          child: Text(
            kvkkText,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    // Validasyon
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Geçerli bir e-posta adresi girin');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Şifre en az 6 karakter olmalıdır');
      return;
    }

    if (_phoneController.text.isEmpty) {
      _showError('Telefon numarası gerekli');
      return;
    }

    if (!PhoneValidator.isValid(_phoneController.text)) {
      _showError('Geçerli bir telefon numarası girin (05XX XXX XX XX)');
      return;
    }

    if (!_isAgreementChecked) {
      _showError('KVKK metnini onaylamanız gerekiyor');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Auth + Firestore Kaydı
      final userId = await FirebaseService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: PhoneValidator.formatToE164(_phoneController.text),
        address: _addressController.text,
        city: _cityController.text,
        district: _districtController.text,
      );

      // Oturum ID'sini kaydet
      FirebaseService.currentUserId = userId;

      // Beni hatırla kaydet
      await FirebaseService.saveRememberMe(userType: 'user', userId: userId);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              userType: 'user',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Registration error: $e');

      String errorMessage = 'Kayıt işlemi başarısız.';

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta adresi zaten kullanımda.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Şifre çok zayıf.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz e-posta adresi.';
        } else {
          errorMessage = 'Hata: ${e.message}';
        }
      } else {
        // Custom exceptionlardan gelen mesajı göster (Telefon kullanımda vs.)
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          // E-posta
          CustomTextField(
            controller: _emailController,
            hintText: 'E-posta Adresi',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
          ),

          // Şifre
          CustomTextField(
            controller: _passwordController,
            hintText: 'Şifre (Min 6 karakter)',
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondary),
          ),

          // Telefon Numarası
          CustomTextField(
            controller: _phoneController,
            hintText: 'Telefon Numarası (05XX XXX XX XX)',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondary),
          ),

          // Adres
          CustomTextField(
            controller: _addressController,
            hintText: 'Adres',
            keyboardType: TextInputType.streetAddress,
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppColors.textSecondary,
            ),
          ),

          // İl ve İlçe
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cityController,
                  hintText: 'İl',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.location_city,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _districtController,
                  hintText: 'İlçe',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.map,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Kayıt Ol Butonu
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
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
                      'Kayıt Ol',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // KVKK ve Sözleşme Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _isAgreementChecked,
                  onChanged: (value) {
                    setState(() {
                      _isAgreementChecked = value ?? false;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showKvkkDialog,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: 'KVKK Metni',
                          style: TextStyle(
                            color: AppColors.textLink,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: "'ni okudum, onaylıyorum."),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
