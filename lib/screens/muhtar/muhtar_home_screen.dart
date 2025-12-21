import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../widgets/custom_text_field.dart';
import '../register_screen.dart';

class MuhtarHomeScreen extends StatefulWidget {
  final String muhtarName;

  const MuhtarHomeScreen({super.key, this.muhtarName = 'Muhtar'});

  @override
  State<MuhtarHomeScreen> createState() => _MuhtarHomeScreenState();
}

class _MuhtarHomeScreenState extends State<MuhtarHomeScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _addApplicant() async {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen zorunlu alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseService.addApplication({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      if (mounted) {
        // Formu temizle
        _nameController.clear();
        _surnameController.clear();
        _phoneController.clear();
        _addressController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Başvuru kaydedildi'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseService.signOut();
    if (mounted) {
      // Kayıt ol / Giriş yap ekranına (RegisterScreen) yönlendir
      // MainScreen'e gidip oradan Login/Register seçileceği varsayımı ile:
      // Veya direkt RegisterScreen'e:
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // AppBar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 45,
                        height: 45,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'P',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Muhtar Paneli',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            widget.muhtarName,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: AppColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  const Text(
                    'Yardım Başvurusu Ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Muhtarlığa başvuran kişilerin bilgilerini girin',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Ad
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Ad *',
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        // Soyad
                        CustomTextField(
                          controller: _surnameController,
                          hintText: 'Soyad *',
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        // Telefon
                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Telefon Numarası *',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: AppColors.textSecondary,
                          ),
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

                        const SizedBox(height: 16),

                        // Kaydet butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addApplicant,
                            icon: const Icon(Icons.add),
                            label: const Text('Başvuru Ekle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Kayıtlı başvurular (Firestore Stream)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kayıtlı Başvurular',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Stream ile sayıyı alabiliriz ama şimdilik statik
                    ],
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.applications
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: List.generate(docs.length, (index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          return _buildApplicantCard(data);
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    // Tarih formatı (Simple)
    String dateStr = '';
    if (applicant['createdAt'] != null) {
      // Timestamp ise
      if (applicant['createdAt'] is Timestamp) {
        final date = (applicant['createdAt'] as Timestamp).toDate();
        dateStr = "${date.day}/${date.month}/${date.year}";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${(applicant['name'] as String? ?? '').isNotEmpty ? applicant['name'][0] : '?'}${(applicant['surname'] as String? ?? '').isNotEmpty ? applicant['surname'][0] : '?'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${applicant['name']} ${applicant['surname']}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      applicant['phone'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                if ((applicant['address'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          applicant['address']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Tarih
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz başvuru yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yukarıdaki formu kullanarak\nyardım başvurusu ekleyebilirsiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
