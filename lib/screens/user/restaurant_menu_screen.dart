import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import 'payment_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final Map<String, int> _selectedItems = {};

  // Demo menü
  final List<MenuCategory> _menuCategories = [
    MenuCategory(
      id: '1',
      name: 'Çorbalar',
      items: [
        MenuItem(
          id: '1',
          name: 'Mercimek Çorbası',
          price: 45,
          quantity: 1,
          categoryId: '1',
        ),
        MenuItem(
          id: '2',
          name: 'Ezogelin Çorbası',
          price: 45,
          quantity: 1,
          categoryId: '1',
        ),
        MenuItem(
          id: '3',
          name: 'Tavuk Çorbası',
          price: 50,
          quantity: 1,
          categoryId: '1',
        ),
      ],
    ),
    MenuCategory(
      id: '2',
      name: 'Ana Yemekler',
      items: [
        MenuItem(
          id: '4',
          name: 'Döner Porsiyon',
          price: 120,
          quantity: 1,
          categoryId: '2',
        ),
        MenuItem(
          id: '5',
          name: 'Köfte Ekmek',
          price: 80,
          quantity: 1,
          categoryId: '2',
        ),
        MenuItem(
          id: '6',
          name: 'Lahmacun',
          price: 60,
          quantity: 1,
          categoryId: '2',
        ),
      ],
    ),
    MenuCategory(
      id: '3',
      name: 'İçecekler',
      items: [
        MenuItem(
          id: '7',
          name: 'Ayran',
          price: 20,
          quantity: 1,
          categoryId: '3',
        ),
        MenuItem(
          id: '8',
          name: 'Şalgam',
          price: 25,
          quantity: 1,
          categoryId: '3',
        ),
        MenuItem(id: '9', name: 'Çay', price: 15, quantity: 1, categoryId: '3'),
      ],
    ),
  ];

  double get _totalPrice {
    double total = 0;
    for (final category in _menuCategories) {
      for (final item in category.items) {
        final count = _selectedItems[item.id] ?? 0;
        total += item.price * count;
      }
    }
    return total;
  }

  int get _totalItems {
    return _selectedItems.values.fold(0, (sum, count) => sum + count);
  }

  List<MapEntry<MenuItem, int>> get _selectedItemsList {
    final List<MapEntry<MenuItem, int>> items = [];
    for (final category in _menuCategories) {
      for (final item in category.items) {
        final count = _selectedItems[item.id] ?? 0;
        if (count > 0) {
          items.add(MapEntry(item, count));
        }
      }
    }
    return items;
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

          // Menü listesi
          Expanded(
            child: ListView.builder(
              itemCount: _menuCategories.length,
              itemBuilder: (context, categoryIndex) {
                final category = _menuCategories[categoryIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori başlığı
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Ürünler
                    ...category.items.map((item) => _buildMenuItem(item)),
                  ],
                );
              },
            ),
          ),

          // Alt bar - Sepet özeti
          if (_totalItems > 0)
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
                          '$_totalItems ürün seçildi',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₺${_totalPrice.toStringAsFixed(0)}',
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
                            items: _selectedItemsList,
                            totalPrice: _totalPrice,
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
