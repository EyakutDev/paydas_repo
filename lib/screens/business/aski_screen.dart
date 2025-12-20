import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/aski_item.dart';
import 'code_verification_screen.dart';

class AskiScreen extends StatelessWidget {
  final List<AskiItem> askiItems;
  final String businessId;

  const AskiScreen({
    super.key,
    required this.askiItems,
    required this.businessId,
  });

  String _getStatusText(AskiStatus status) {
    switch (status) {
      case AskiStatus.available:
        return 'Bekliyor';
      case AskiStatus.reserved:
        return 'Rezerve Edildi';
      case AskiStatus.delivered:
        return 'Teslim Edildi';
      case AskiStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  Color _getStatusColor(AskiStatus status) {
    switch (status) {
      case AskiStatus.available:
        return Colors.orange;
      case AskiStatus.reserved:
        return AppColors.primaryGreen;
      case AskiStatus.delivered:
        return Colors.blue;
      case AskiStatus.cancelled:
        return Colors.red;
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
                const Icon(Icons.shopping_bag_outlined, color: AppColors.white),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Askıya Ekledikleriniz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CodeVerificationScreen(businessId: businessId),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Onayla',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İçerik
          Expanded(
            child: askiItems.isEmpty ? _buildEmptyState() : _buildAskiList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: AppColors.primaryGreen.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz Askıya Ürün Eklemediniz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Menünüzden ürünleri askıya ekleyerek\nihtiyaç sahiplerine ulaştırabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskiList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: askiItems.length,
      itemBuilder: (context, index) {
        final item = askiItems[index];
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
              // Ürün ikonu
              Container(
                width: 50,
                height: 50,
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

              // Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuItem.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} adet • ₺${item.menuItem.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Durum
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(item.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(item.status),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
