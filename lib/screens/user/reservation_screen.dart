import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../models/restaurant.dart';
import '../../models/aski_item.dart';
import '../../services/firebase_service.dart';
import '../../widgets/user/qr_code_widget.dart';

class ReservationScreen extends StatefulWidget {
  final Restaurant restaurant;

  const ReservationScreen({super.key, required this.restaurant});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  AskiItem? _selectedItem;
  bool _isReserved = false;
  bool _isReserving = false;
  bool _showQR = true; // QR veya sayısal kod
  String? _reservationCode;
  String? _reservedItemName;

  Future<void> _confirmReservation() async {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir ürün seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    userId ??= FirebaseService.currentUserId;

    // Auth null ise, yerel hafızadan kullanıcıyı kontrol et
    if (userId == null) {
      final session = await FirebaseService.getRememberedUser();
      if (session != null && session['userType'] == 'user') {
        userId = session['userId'];
      }
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon için giriş yapmalısınız'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isReserving = true);

    try {
      final code = await FirebaseService.createReservation(
        visitorId: userId!,
        businessId: widget.restaurant.id,
        businessName: widget.restaurant.name,
        item: _selectedItem!.menuItem,
      );

      setState(() {
        _isReserved = true;
        _isReserving = false;
        _reservationCode = code;
        _reservedItemName = _selectedItem!.menuItem.name;
      });
    } catch (e) {
      setState(() => _isReserving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isReserved && _reservationCode != null) {
      return _buildReservationSuccessScreen();
    }

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
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: AppColors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'Askıdaki Ürünler',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Başlık
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rezerve Edilecek Ürün',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Almak istediğiniz ürünü seçin (Sadece 1 adet)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Ürün listesi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getAskiItems(widget.restaurant.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Bir hata oluştu'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                // Sadece stoğu olan ve rezerve edilmemiş ürünleri gösterelim (FirebaseService filtresi yoksa burada yap)
                // Ama service addToAski subcollection kullanıyor. Subcollection askiItems.
                // quantity > 0 olanları göster.
                final askiItems = docs
                    .map(
                      (doc) => AskiItem.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .where((item) => item.quantity > 0)
                    .toList();

                if (askiItems.isEmpty) {
                  return const Center(child: Text('Şu an askıda ürün yok.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: askiItems.length,
                  itemBuilder: (context, index) {
                    final item = askiItems[index];
                    final isSelected = _selectedItem?.id == item.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItem = item;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withOpacity(0.1)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.inputBorder.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: item.id,
                              groupValue: _selectedItem?.id,
                              onChanged: (val) {
                                setState(() {
                                  _selectedItem = item;
                                });
                              },
                              activeColor: AppColors.primaryGreen,
                            ),
                            // Ürün bilgisi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Askıda ${item.quantity} adet mevcut',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Alt buton
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isReserving ? null : _confirmReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isReserving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Rezerve Et (1 Ürün)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Başarı ikonu
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: AppColors.primaryGreen,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Rezervasyon Başarılı!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${widget.restaurant.name}\'dan 1 adet $_reservedItemName rezerve edildi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 24),

              // QR / Kod seçimi
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showQR = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _showQR
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'QR Kod',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _showQR
                                    ? AppColors.primaryGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showQR = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_showQR
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Sayısal Kod',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !_showQR
                                    ? AppColors.primaryGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR veya Sayısal Kod
              if (_showQR)
                QRCodeWidget(
                  data: _reservationCode!,
                  expiresInSeconds: 1800, // 30 dakika
                  onExpired: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rezervasyon süresi doldu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                )
              else
                _buildNumericCode(),

              const SizedBox(height: 24),

              // Uyarı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu kod 30 dakika geçerlidir. Restorana gidip onaylatın.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ana sayfaya dön
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //Navigator.pop(context); // Bu stack'ten çıkarır ama ana sayfaya dönmek için popUntil veya pushReplacement
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ana Sayfaya Dön',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericCode() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Onay Kodunuz',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                _reservationCode!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
