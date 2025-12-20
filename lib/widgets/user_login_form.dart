import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/user/user_home_screen.dart';
import '../utils/phone_validator.dart';
import '../services/firebase_service.dart';
import 'custom_text_field.dart';

class UserLoginForm extends StatefulWidget {
  const UserLoginForm({super.key});

  @override
  State<UserLoginForm> createState() => _UserLoginFormState();
}

class _UserLoginFormState extends State<UserLoginForm> {
  final TextEditingController _phoneController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_phoneController.text.isEmpty) {
      _showError('Telefon numarası gerekli');
      return;
    }

    if (!PhoneValidator.isValid(_phoneController.text)) {
      _showError('Geçerli bir telefon numarası girin (05XX XXX XX XX)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = PhoneValidator.formatToE164(_phoneController.text);
      final user = await FirebaseService.getUserByPhone(phone);

      if (user == null) {
        _showError('Bu telefon numarasıyla kayıtlı kullanıcı bulunamadı');
        setState(() => _isLoading = false);
        return;
      }
      // Oturum ID'sini kaydet
      FirebaseService.currentUserId = user.id;

      if (_rememberMe) {
        await FirebaseService.saveRememberMe(userType: 'user', userId: user.id);
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
      _showError(
        'Hata: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}',
      );
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
          CustomTextField(
            controller: _phoneController,
            hintText: 'Telefon Numarası (05XX XXX XX XX)',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondary),
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
