import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/muhtar/muhtar_home_screen.dart';
import 'custom_text_field.dart';

class MuhtarLoginForm extends StatefulWidget {
  const MuhtarLoginForm({super.key});

  @override
  State<MuhtarLoginForm> createState() => _MuhtarLoginFormState();
}

class _MuhtarLoginFormState extends State<MuhtarLoginForm> {
  final TextEditingController _codeController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  // Demo geçerli kodlar
  final List<String> _validCodes = ['MUHTAR2024', 'PAYDAS123', 'YARDIM456'];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _login() {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen özel kodu girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simüle giriş
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_validCodes.contains(_codeController.text.toUpperCase())) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MuhtarHomeScreen(muhtarName: 'Kadıköy Muhtarlığı'),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçersiz kod'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Özel Kod
          CustomTextField(
            controller: _codeController,
            hintText: 'Özel Kod',
            obscureText: true,
            prefixIcon: const Icon(Icons.key, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Beni Hatırla
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

          // Giriş Yap Butonu
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

          const SizedBox(height: 24),

          // Bilgi notu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Muhtar girişi için size verilen özel kodu kullanın',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
