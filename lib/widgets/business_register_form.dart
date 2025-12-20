import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_text_field.dart';

class BusinessRegisterForm extends StatefulWidget {
  const BusinessRegisterForm({super.key});

  @override
  State<BusinessRegisterForm> createState() => _BusinessRegisterFormState();
}

class _BusinessRegisterFormState extends State<BusinessRegisterForm> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  bool _isAgreementChecked = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
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

          // Adres
          CustomTextField(
            controller: _addressController,
            hintText: 'Açık Adres',
            keyboardType: TextInputType.streetAddress,
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppColors.textSecondary,
            ),
          ),

          // İl ve İlçe satırı
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
                        text: 'Gıda Güvenlik Sözleşmesi',
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
