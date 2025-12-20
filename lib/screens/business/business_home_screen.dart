import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item.dart';
import '../../models/aski_item.dart';
import '../../services/firebase_service.dart';
import 'menu_screen.dart';
import 'aski_screen.dart';
import 'reservations_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  final String businessName;
  final String businessId;

  const BusinessHomeScreen({
    super.key,
    required this.businessName,
    required this.businessId,
  });

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  int _currentIndex = 0;

  void _onMenuUpdated(List<MenuCategory> categories) {
    FirebaseService.saveMenu(widget.businessId, categories);
  }

  void _onItemSentToAski(MenuItem item, int quantity) {
    FirebaseService.addToAski(widget.businessId, item, quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} askıya eklendi!'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // MENÜ EKRANI (Firebase Stream)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseService.getMenuStream(widget.businessId),
            builder: (context, snapshot) {
              List<MenuCategory> categories = [];
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('menu')) {
                  final menuList = data['menu'] as List;
                  categories = menuList
                      .map(
                        (c) => MenuCategory.fromMap(c as Map<String, dynamic>),
                      )
                      .toList();
                }
              }

              return MenuScreen(
                businessName: widget.businessName,
                businessId: widget.businessId,
                categories: categories,
                onMenuUpdated: _onMenuUpdated,
                onItemSentToAski: _onItemSentToAski,
              );
            },
          ),

          // ASKI EKRANI
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.getAskiItems(widget.businessId),
            builder: (context, snapshot) {
              List<AskiItem> askiItems = [];
              if (snapshot.hasData) {
                askiItems = snapshot.data!.docs.map((doc) {
                  return AskiItem.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();
              }
              return AskiScreen(
                askiItems: askiItems,
                businessId: widget.businessId,
              );
            },
          ),

          // REZERVASYONLAR
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.getBusinessReservations(widget.businessId),
            builder: (context, snapshot) {
              List<ReservationItem> reservations = [];
              if (snapshot.hasData) {
                reservations = snapshot.data!.docs.map((doc) {
                  return ReservationItem.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();
              }
              return ReservationsScreen(reservations: reservations);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.restaurant_menu, 'Menü'),
                _buildNavItem(1, Icons.shopping_bag_outlined, 'Askıdakiler'),
                _buildNavItem(2, Icons.bookmark_border, 'Rezerve'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
