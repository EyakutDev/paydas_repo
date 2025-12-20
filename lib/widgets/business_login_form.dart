import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/business/business_home_screen.dart';
import 'custom_text_field.dart';

class BusinessLoginForm extends StatefulWidget {
  const BusinessLoginForm({super.key});

  @override
  State<BusinessLoginForm> createState() => _BusinessLoginFormState();
}

class _BusinessLoginFormState extends State<BusinessLoginForm> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // İşletme Adı
          CustomTextField(
            controller: _businessNameController,
            hintText: 'İşletme Adı',
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(Icons.store, color: AppColors.textSecondary),
          ),

          // Telefon Numarası
          CustomTextField(
            controller: _phoneController,
            hintText: 'Telefon Numarası',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondary),
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
              onPressed: () {
                // Firebase entegrasyonu sonra eklenecek
                final businessName = _businessNameController.text.isNotEmpty
                    ? _businessNameController.text
                    : 'İşletme';
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BusinessHomeScreen(businessName: businessName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
