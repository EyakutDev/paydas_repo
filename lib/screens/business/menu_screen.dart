import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item.dart';
import '../../widgets/business/category_section.dart';
import 'menu_edit_screen.dart';
import 'business_profile_screen.dart';
import '../../services/firebase_service.dart';
import '../register_screen.dart';

class MenuScreen extends StatelessWidget {
  final String businessName;
  final String businessId;
  final List<MenuCategory> categories;
  final Function(List<MenuCategory>) onMenuUpdated;
  final Function(MenuItem, int) onItemSentToAski;

  const MenuScreen({
    super.key,
    required this.businessName,
    required this.businessId,
    required this.categories,
    required this.onMenuUpdated,
    required this.onItemSentToAski,
  });

  bool get _isMenuEmpty =>
      categories.isEmpty || categories.every((c) => c.items.isEmpty);

  void _openMenuEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MenuEditScreen(categories: categories, onSave: onMenuUpdated),
      ),
    );
  }

  void _showAskiDialog(BuildContext context, MenuItem item) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Askıya Gönder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.name} ürününden kaç adet askıya göndermek istiyorsunuz?',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setDialogState(() => quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.primaryGreen,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(() => quantity++),
                    icon: const Icon(Icons.add_circle),
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onItemSentToAski(item, quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
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
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Menü',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (!_isMenuEmpty)
                  GestureDetector(
                    onTap: () => _openMenuEditor(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusinessProfileScreen(
                          businessName: businessName,
                          businessId: businessId,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.white,
                    child: Text(
                      businessName.isNotEmpty
                          ? businessName[0].toUpperCase()
                          : 'İ',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İçerik
          Expanded(
            child: _isMenuEmpty
                ? _buildEmptyState(context)
                : _buildMenuList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Clipboard ikonu
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 60,
                    color: AppColors.primaryGreen.withOpacity(0.8),
                  ),
                  Positioned(
                    right: 20,
                    top: 25,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Menü Boş',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Buradan yemeklerinizi hemen menünüze\nekleyin, ihtiyaç sahiplerine destek olun.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openMenuEditor(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Menü Ekle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...categories.map(
            (category) => CategorySection(
              category: category,
              isEditMode: false,
              onSendToAski: (item) => _showAskiDialog(context, item),
            ),
          ),
          const SizedBox(height: 100), // Bottom nav için boşluk
        ],
      ),
    );
  }
}
