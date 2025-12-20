import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item.dart';
import '../../models/aski_item.dart';
import 'menu_screen.dart';
import 'aski_screen.dart';
import 'reservations_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  final String businessName;

  const BusinessHomeScreen({super.key, required this.businessName});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  int _currentIndex = 0;

  // Menü verisi (gerçek uygulamada Firebase'den gelecek)
  List<MenuCategory> _menuCategories = [];

  // Askıya eklenen ürünler
  final List<AskiItem> _askiItems = [];

  // Rezerve edilen ürünler
  final List<ReservationItem> _reservations = [];

  void _onMenuUpdated(List<MenuCategory> categories) {
    setState(() {
      _menuCategories = categories;
    });
  }

  void _onItemSentToAski(MenuItem item, int quantity) {
    setState(() {
      _askiItems.add(
        AskiItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          menuItem: item,
          quantity: quantity,
          addedAt: DateTime.now(),
        ),
      );
    });

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
          MenuScreen(
            businessName: widget.businessName,
            categories: _menuCategories,
            onMenuUpdated: _onMenuUpdated,
            onItemSentToAski: _onItemSentToAski,
          ),
          AskiScreen(askiItems: _askiItems),
          ReservationsScreen(reservations: _reservations),
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
                _buildNavItem(
                  1,
                  Icons.shopping_bag_outlined,
                  'Askıya Ekledikleriniz',
                ),
                _buildNavItem(2, Icons.bookmark_border, 'Rezerve Siparişler'),
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
