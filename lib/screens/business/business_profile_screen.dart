import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class BusinessProfileScreen extends StatelessWidget {
  final String businessName;
  final String phone;
  final String address;
  final String city;
  final String district;

  const BusinessProfileScreen({
    super.key,
    required this.businessName,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.district = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
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
                        // Düzenleme
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
                    phone.isNotEmpty ? phone : '+90 555 123 45 67',
                  ),
                  _buildInfoCard(
                    Icons.location_on,
                    'Adres',
                    address.isNotEmpty
                        ? address
                        : 'Merkez Mah. Atatürk Cad. No:123',
                  ),
                  _buildInfoCard(
                    Icons.location_city,
                    'İl / İlçe',
                    '${city.isNotEmpty ? city : 'İstanbul'} / ${district.isNotEmpty ? district : 'Kadıköy'}',
                  ),

                  const SizedBox(height: 24),

                  // İstatistikler
                  _buildSectionTitle('İstatistikler'),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('156', 'Askıya Eklenen')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('142', 'Teslim Edilen')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('14', 'Bekleyen')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Çalışma saatleri
                  _buildSectionTitle('Çalışma Saatleri'),
                  _buildInfoCard(
                    Icons.access_time,
                    'Hafta içi',
                    '09:00 - 22:00',
                  ),
                  _buildInfoCard(
                    Icons.access_time,
                    'Hafta sonu',
                    '10:00 - 23:00',
                  ),

                  const SizedBox(height: 32),

                  // Çıkış yap
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
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
