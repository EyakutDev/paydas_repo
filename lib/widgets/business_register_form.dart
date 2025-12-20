import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/legal_texts.dart';
import '../utils/phone_validator.dart';
import '../services/firebase_service.dart';
import '../screens/business/business_home_screen.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
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
    if (_businessNameController.text.isEmpty) {
      _showError('İşletme adı gerekli');
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
      _showError('Sözleşmeleri onaylamanız gerekiyor');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = PhoneValidator.formatToE164(_phoneController.text);

      final existingBusiness = await FirebaseService.getBusinessByPhone(phone);
      if (existingBusiness != null) {
        _showError('Bu telefon numarası zaten kayıtlı');
        setState(() => _isLoading = false);
        return;
      }

      final businessId = await FirebaseService.createBusiness(
        name: _businessNameController.text,
        phone: phone,
        address: _addressController.text,
        city: _cityController.text,
        district: _districtController.text,
      );

      await FirebaseService.saveRememberMe(
        userType: 'business',
        userId: businessId,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessHomeScreen(
              businessName: _businessNameController.text,
              businessId: businessId,
            ),
          ),
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
            controller: _businessNameController,
            hintText: 'İşletme Adı',
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(Icons.store, color: AppColors.textSecondary),
          ),

          CustomTextField(
            controller: _phoneController,
            hintText: 'Telefon (05XX XXX XX XX)',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondary),
          ),

          CustomTextField(
            controller: _addressController,
            hintText: 'Açık Adres',
            keyboardType: TextInputType.streetAddress,
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppColors.textSecondary,
            ),
          ),

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
                child: Wrap(
                  children: [
                    GestureDetector(
                      onTap: () => _showLegalDialog('KVKK', kvkkText),
                      child: const Text(
                        'KVKK Metni',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLink,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(' ve ', style: TextStyle(fontSize: 12)),
                    GestureDetector(
                      onTap: () =>
                          _showLegalDialog('Gıda Güvenliği', foodSafetyText),
                      child: const Text(
                        'Gıda Güvenlik Sözleşmesi',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLink,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text("'ni okudum.", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
