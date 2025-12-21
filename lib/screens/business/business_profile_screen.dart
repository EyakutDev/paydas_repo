import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import 'business_profile_edit_screen.dart';
import '../register_screen.dart';

class BusinessProfileScreen extends StatelessWidget {
  final String businessName;
  final String businessId;

  const BusinessProfileScreen({
    super.key,
    required this.businessName,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.businesses.doc(businessId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final stats = data['stats'] as Map<String, dynamic>? ?? {};

          final phone = data['phone'] as String? ?? '';
          final address = data['address'] as String? ?? '';
          final city = data['city'] as String? ?? '';
          final district = data['district'] as String? ?? '';

          final totalAski = stats['totalAski'] ?? 0;

          return Column(
            children: [
              // AppBar
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 24,
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusinessProfileEditScreen(
                                  businessId: businessId,
                                  currentData: data,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, color: AppColors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // İşletme logosu
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      child: Text(
                        businessName.isNotEmpty
                            ? businessName[0].toUpperCase()
                            : 'İ',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      businessName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Restoran',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.8),
                      ),
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
                      const SizedBox(height: 8),

                      // İletişim bilgileri
                      _buildSectionTitle('İletişim Bilgileri'),
                      _buildInfoCard(
                        Icons.phone,
                        'Telefon',
                        phone.isNotEmpty ? phone : '-',
                      ),
                      _buildInfoCard(
                        Icons.location_on,
                        'Adres',
                        address.isNotEmpty ? address : '-',
                      ),
                      _buildInfoCard(
                        Icons.location_city,
                        'İl / İlçe',
                        '${city.isNotEmpty ? city : '-'} / ${district.isNotEmpty ? district : '-'}',
                      ),

                      const SizedBox(height: 24),

                      // İstatistikler
                      _buildSectionTitle('İstatistikler'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              totalAski.toString(),
                              'Askıya Eklenen',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Çalışma saatleri (Dinamik)
                      _buildSectionTitle('Çalışma Saatleri'),
                      _buildInfoCard(
                        Icons.access_time,
                        'Hafta içi',
                        (data['workingHours']
                                as Map<String, dynamic>?)?['weekday'] ??
                            '09:00 - 22:00',
                      ),
                      _buildInfoCard(
                        Icons.access_time,
                        'Hafta sonu',
                        (data['workingHours']
                                as Map<String, dynamic>?)?['weekend'] ??
                            '10:00 - 23:00',
                      ),

                      const SizedBox(height: 32),

                      // Çıkış yap
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await FirebaseService.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Çıkış Yap'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              // ignore: deprecated_member_use
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
