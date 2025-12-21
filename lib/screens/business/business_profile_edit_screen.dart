import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';

class BusinessProfileEditScreen extends StatefulWidget {
  final String businessId;
  final Map<String, dynamic> currentData;

  const BusinessProfileEditScreen({
    super.key,
    required this.businessId,
    required this.currentData,
  });

  @override
  State<BusinessProfileEditScreen> createState() =>
      _BusinessProfileEditScreenState();
}

class _BusinessProfileEditScreenState extends State<BusinessProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _weekdayHoursController;
  late TextEditingController _weekendHoursController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.currentData['phone'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.currentData['address'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.currentData['city'] ?? '',
    );
    _districtController = TextEditingController(
      text: widget.currentData['district'] ?? '',
    );

    final workingHours =
        widget.currentData['workingHours'] as Map<String, dynamic>? ?? {};
    _weekdayHoursController = TextEditingController(
      text: workingHours['weekday'] ?? '09:00 - 22:00',
    );
    _weekendHoursController = TextEditingController(
      text: workingHours['weekend'] ?? '10:00 - 23:00',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _weekdayHoursController.dispose();
    _weekendHoursController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updates = {
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'workingHours': {
          'weekday': _weekdayHoursController.text.trim(),
          'weekend': _weekendHoursController.text.trim(),
        },
      };

      await FirebaseService.updateBusiness(widget.businessId, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil güncellendi'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('İletişim Bilgileri'),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: 'Adres',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'İl',
                      icon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _districtController,
                      label: 'İlçe',
                      icon: Icons.map,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Çalışma Saatleri'),
              _buildTextField(
                controller: _weekdayHoursController,
                label: 'Hafta içi',
                hint: 'Örn: 09:00 - 22:00',
                icon: Icons.access_time,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _weekendHoursController,
                label: 'Hafta sonu',
                hint: 'Örn: 10:00 - 23:00',
                icon: Icons.access_time,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan zorunludur';
        }
        return null;
      },
    );
  }
}
