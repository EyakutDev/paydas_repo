import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_text_field.dart';

class UserRegisterForm extends StatefulWidget {
  const UserRegisterForm({super.key});

  @override
  State<UserRegisterForm> createState() => _UserRegisterFormState();
}

class _UserRegisterFormState extends State<UserRegisterForm> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isAgreementChecked = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Telefon Numarası
          const CustomTextField(
            hintText: 'Telefon Numarası',
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(Icons.phone, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 24),

          // Kayıt Ol Butonu
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Firebase entegrasyonu sonra eklenecek
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
                'Kayıt Ol',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(text: 'KVKK Metni'),
                      TextSpan(text: "'ni"),
                      TextSpan(text: ' ve '),
                      TextSpan(
                        text: 'Kullanıcı Onay Sözleşmesi',
                        style: TextStyle(
                          color: AppColors.textLink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: "'ni okudum, onaylıyorum."),
                    ],
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
