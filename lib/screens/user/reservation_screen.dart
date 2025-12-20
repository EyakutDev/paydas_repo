import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../widgets/user/qr_code_widget.dart';

class ReservationScreen extends StatefulWidget {
  final Restaurant restaurant;
  final List<MenuItem> askiItems;

  const ReservationScreen({
    super.key,
    required this.restaurant,
    required this.askiItems,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final Map<String, int> _selectedQuantities =
      {}; // item id -> selected quantity
  bool _isReserved = false;
  bool _showQR = true; // QR veya sayısal kod
  late String _reservationCode;
  List<MapEntry<MenuItem, int>> _reservedItems = [];

  @override
  void initState() {
    super.initState();
    _reservationCode = _generateCode();
  }

  String _generateCode() {
    final now = DateTime.now();
    return 'PDS${now.millisecondsSinceEpoch.toString().substring(6)}';
  }

  void _confirmReservation() {
    if (_selectedQuantities.isEmpty ||
        _selectedQuantities.values.every((q) => q == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir ürün seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Seçilen ürünleri kaydet
    _reservedItems = widget.askiItems
        .where((item) => (_selectedQuantities[item.id] ?? 0) > 0)
        .map((item) => MapEntry(item, _selectedQuantities[item.id]!))
        .toList();

    setState(() {
      _isReserved = true;
    });
  }

  int get _totalSelectedItems {
    return _selectedQuantities.values.fold(0, (sum, q) => sum + q);
  }

  @override
  Widget build(BuildContext context) {
    if (_isReserved) {
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
                  'Rezerve Edilecek Ürünler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Almak istediğiniz ürünleri seçin',
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.askiItems.length,
              itemBuilder: (context, index) {
                final item = widget.askiItems[index];
                final selectedQty = _selectedQuantities[item.id] ?? 0;
                final availableQty = item.quantity;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedQty > 0
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedQty > 0
                          ? AppColors.primaryGreen
                          : AppColors.inputBorder.withOpacity(0.3),
                      width: selectedQty > 0 ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Ürün bilgisi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Askıda $availableQty adet mevcut',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Miktar seçici
                      Row(
                        children: [
                          if (selectedQty > 0)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedQuantities[item.id] =
                                      selectedQty - 1;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          if (selectedQty > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '$selectedQty',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: selectedQty < availableQty
                                ? () {
                                    setState(() {
                                      _selectedQuantities[item.id] =
                                          selectedQty + 1;
                                    });
                                  }
                                : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: selectedQty < availableQty
                                    ? AppColors.primaryGreen
                                    : AppColors.textSecondary.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: selectedQty < availableQty
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Öğün hakkı bilgisi
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Günlük 2 öğün hakkınız var (6 saat arayla)',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Rezerve Et ($_totalSelectedItems ürün)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                '${widget.restaurant.name}\'dan $_totalSelectedItems ürün rezerve edildi',
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
                  data: _reservationCode,
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
                    Navigator.pop(context);
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
                _reservationCode,
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
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            // Kopyalama işlemi
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kod kopyalandı'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.copy, size: 18, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Kodu Kopyala',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
