import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import '../../widgets/user/qr_code_widget.dart';
import '../register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<DocumentSnapshot?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  void _loadUser() {
    final userId =
        FirebaseService.currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _userFuture = FirebaseService.getUser(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    GestureDetector(
                      onTap: () async {
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
                      child: const Icon(Icons.logout, color: AppColors.white),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.person_outline, color: AppColors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kullanıcı bilgisi
                FutureBuilder<DocumentSnapshot?>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    final phone = data?['phone'] ?? '+90 555 123 45 67';

                    // Şifrelemesiz telefon numarası

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kullanıcı',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                phone, // Şifresiz numara
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
                              if (data != null &&
                                  (data.containsKey('address') ||
                                      data.containsKey('district') ||
                                      data.containsKey('city')))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${data['address'] ?? ''}\n${data['district'] ?? ''} / ${data['city'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.white.withOpacity(0.8),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(height: 40, text: 'Rezervasyonlar'),
                  Tab(height: 40, text: 'Bağışlarım'),
                  Tab(height: 40, text: 'QR Kod'),
                ],
              ),
            ),
          ),

          // Tab içerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveReservationsTab(),
                _buildDonationHistoryTab(),
                _buildQRCodeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveReservationsTab() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    userId ??= FirebaseService.currentUserId;

    if (userId == null) return const Center(child: Text('Giriş yapılmamış'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getUserReservations(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        // Client-side sıralama (Tarihe göre yeniden eskiye)
        try {
          docs.sort((a, b) {
            final dateA =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
            final dateB =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
            return dateB.compareTo(dateA);
          });
        } catch (e) {
          // Sıralama hatası olursa olduğu gibi bırak
        }

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 60,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aktif rezervasyonunuz yok',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Askıdaki ürünlerden rezerve edebilirsiniz',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final expires = (data['expiresAt'] as Timestamp).toDate();
            final status = data['status'] ?? 'pending';

            Color statusColor = Colors.orange;
            String statusText = 'Bekliyor';
            IconData statusIcon = Icons.access_time;

            if (status == 'confirmed') {
              statusColor = AppColors.primaryGreen;
              statusText = 'Onaylandı';
              statusIcon = Icons.check_circle;
            } else if (status == 'delivered' || status == 'completed') {
              statusColor = Colors.blue;
              statusText = 'Teslim Edildi';
              statusIcon = Icons.task_alt;
            } else if (status == 'cancelled') {
              statusColor = Colors.red;
              statusText = 'İptal Edildi';
              statusIcon = Icons.cancel;
            } else if (status == 'expired') {
              statusColor = Colors.grey;
              statusText = 'Süresi Doldu';
              statusIcon = Icons.timer_off;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restoran bilgisi ve Durum
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sipariş: ${data['itemName'] ?? 'Ürün'}', // "c ürünü eklendi" formatı
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              data['businessName'] ?? 'Restoran',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status != 'pending')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duruma göre içerik değişimi
                  if (status == 'pending') ...[
                    // QR Kod
                    Center(
                      child: QRCodeWidget(
                        data: data['code'] ?? '',
                        expiresInSeconds: expires
                            .difference(DateTime.now())
                            .inSeconds,
                        onExpired: () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Kod Text
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Kod: ${data['code']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Son Kullanma: ${expires.hour}:${expires.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // İptal Butonu
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Rezervasyonu İptal Et'),
                              content: const Text(
                                'Bu rezervasyonu iptal etmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Vazgeç'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await FirebaseService.cancelReservation(
                                      doc.id,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Rezervasyon iptal edildi',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'İptal Et',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Rezervasyonu İptal Et'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Geçmiş Sipariş Detayı
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'İşlem Tarihi: ${_formatDate((data['createdAt'] as Timestamp).toDate())}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (status == 'confirmed' ||
                              status == 'delivered' ||
                              status == 'completed')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Afiyet olsun!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDonationHistoryTab() {
    final userId =
        FirebaseService.currentUserId ?? FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Giriş yapılmamış'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getUserDonations(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Client-side sıralama (Tarihe göre yeniden eskiye)
        try {
          docs.sort((a, b) {
            final dateA =
                (a.data() as Map<String, dynamic>)['date'] as Timestamp;
            final dateB =
                (b.data() as Map<String, dynamic>)['date'] as Timestamp;
            return dateB.compareTo(dateA);
          });
        } catch (e) {
          // Sıralama hatası olursa olduğu gibi bırak
        }

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 60,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Henüz bağış yapmadınız',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date =
                (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['restaurant'] ?? 'Restoran',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data['totalItemsCount'] ?? 0} ürün • ${_formatDate(date)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₺${(data['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQRCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          const Text(
            'Genel Onay Kodu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Askıdan ürün alırken bu kodu\nrestorana gösterin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // QR Kod
          QRCodeWidget(
            data: 'PAYDAS-USER-${DateTime.now().millisecondsSinceEpoch}',
            expiresInSeconds: 300, // 5 dakika
            onExpired: () {},
          ),

          const SizedBox(height: 32),

          // Uyarı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu genel QR kod 5 dakika geçerlidir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
