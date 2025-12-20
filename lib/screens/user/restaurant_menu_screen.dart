import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../services/firebase_service.dart';
import 'payment_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final Map<String, int> _selectedItems = {};

  // Helper to find item by ID from the loaded categories
  MenuItem? _findItemInCategories(String id, List<MenuCategory> categories) {
    for (final cat in categories) {
      for (final item in cat.items) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  double _calculateTotalPrice(List<MenuCategory> categories) {
    double total = 0;
    _selectedItems.forEach((id, count) {
      final item = _findItemInCategories(id, categories);
      if (item != null) {
        total += item.price * count;
      }
    });
    return total;
  }

  List<MapEntry<MenuItem, int>> _getSelectedItemsList(
    List<MenuCategory> categories,
  ) {
    final List<MapEntry<MenuItem, int>> list = [];
    _selectedItems.forEach((id, count) {
      if (count > 0) {
        final item = _findItemInCategories(id, categories);
        if (item != null) {
          list.add(MapEntry(item, count));
        }
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<List<MenuCategory>>(
        stream: FirebaseService.getMenu(widget.restaurant.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text('Menü yüklenirken hata oluştu: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];
          final double totalPrice = _calculateTotalPrice(categories);
          final int totalItems = _selectedItems.values.fold(
            0,
            (sum, count) => sum + count,
          );

          return Column(
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
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
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
                            widget.restaurant.distance,
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
                      'Menü',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Askıya eklemek istediğiniz ürünleri seçin',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Menü Listesi
              Expanded(
                child: categories.isEmpty
                    ? const Center(
                        child: Text('Bu restoranın menüsü henüz yok.'),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: categories.length,
                        itemBuilder: (context, categoryIndex) {
                          final category = categories[categoryIndex];
                          if (category.items.isEmpty)
                            return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              ...category.items.map(
                                (item) => _buildMenuItem(item),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Alt Bar
              if (totalItems > 0)
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalItems ürün seçildi',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₺${totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                restaurant: widget.restaurant,
                                items: _getSelectedItemsList(categories),
                                totalPrice: totalPrice,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Askıya Ekle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final count = _selectedItems[item.id] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: count > 0
            ? AppColors.primaryGreen.withOpacity(0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: count > 0
              ? AppColors.primaryGreen.withOpacity(0.3)
              : AppColors.inputBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
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
                  '₺${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // Miktar seçici
          Row(
            children: [
              if (count > 0)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (count > 1) {
                        _selectedItems[item.id] = count - 1;
                      } else {
                        _selectedItems.remove(item.id);
                      }
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedItems[item.id] = count + 1;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
