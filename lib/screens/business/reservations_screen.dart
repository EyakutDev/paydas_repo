import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/aski_item.dart';
import '../../services/firebase_service.dart';

class ReservationsScreen extends StatelessWidget {
  final List<ReservationItem> reservations;

  const ReservationsScreen({super.key, required this.reservations});

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'Bekliyor';
      case ReservationStatus.confirmed:
        return 'Onaylandı';
      case ReservationStatus.delivered:
        return 'Teslim Edildi';
      case ReservationStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return AppColors.primaryGreen;
      case ReservationStatus.delivered:
        return Colors.blue;
      case ReservationStatus.cancelled:
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
            child: const Row(
              children: [
                Icon(Icons.bookmark_border, color: AppColors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Rezerve Siparişler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İçerik
          Expanded(
            child: reservations.isEmpty
                ? _buildEmptyState()
                : _buildReservationsList(),
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
                Icons.bookmark_border,
                size: 50,
                color: AppColors.primaryGreen.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz Rezervasyon Yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Askıya eklediğiniz ürünler kullanıcılar\ntarafından rezerve edildiğinde burada görünecek.',
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

  Widget _buildReservationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Kullanıcı avatarı
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: Text(
                      reservation.userName.isNotEmpty
                          ? reservation.userName[0].toUpperCase()
                          : 'K',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Kullanıcı bilgisi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.userName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatDate(reservation.reservedAt),
                          style: TextStyle(
                            fontSize: 12,
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
                      color: _getStatusColor(
                        reservation.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(reservation.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(reservation.status),
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),

              // Ürün bilgisi
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.askiItem.menuItem.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${reservation.askiItem.quantity} adet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (reservation.status == ReservationStatus.pending) ...[
                const SizedBox(height: 12),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () =>
                        _showConfirmationDialog(context, reservation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kodu Onayla'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    ReservationItem reservation,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyon Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Lütfen müşteriden aldığınız kodu girin:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Onay Kodu',
                counterText: '',
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 9, // XXXX-XXXX
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().toUpperCase() ==
                  reservation.code?.toUpperCase()) {
                // Kod doğru
                Navigator.pop(context);
                await FirebaseService.confirmReservation(reservation.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rezervasyon onaylandı!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                // Kod yanlış
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hatalı kod!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
