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
  Stream<List<MenuCategory>>? _menuStream;

  @override
  void initState() {
    super.initState();
    _menuStream = FirebaseService.getMenu(widget.restaurant.id);
  }

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
    // Hot reload safe initialization
    _menuStream ??= FirebaseService.getMenu(widget.restaurant.id);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<List<MenuCategory>>(
        stream: _menuStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;
          if (categories.isEmpty) {
            return const Center(child: Text('Menü bulunamadı'));
          }

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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    if (category.items.isEmpty) return const SizedBox.shrink();

                    return _CategoryAccordion(
                      key: ValueKey(category.id),
                      category: category,
                      defaultExpanded: index == 0,
                      icon: _getCategoryIcon(category.name),
                      itemBuilder: (item) => _buildMenuItem(item),
                    );
                  },
                ),
              ),

              // Checkout Bar
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

  // Helper helper to get icon based on category name
  IconData _getCategoryIcon(String categoryName) {
    // Dynamic Icon Logic removed to prevent "Ready-made" confusion.
    // Using a generic icon for all categories ensures the user knows these are THEIR categories.
    return Icons.restaurant_menu;
  }

  // Custom Accordion Widget to match the design (Green header, white body)
  Widget _buildMenuItem(MenuItem item) {
    final count = _selectedItems[item.id] ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '₺${item.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),

          // Action Button or Quantity Control
          if (count == 0)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedItems[item.id] = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Askıya Gönder',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (count > 1) {
                          _selectedItems[item.id] = count - 1;
                        } else {
                          _selectedItems.remove(item.id);
                        }
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Icon(Icons.remove, size: 16, color: Colors.white),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedItems[item.id] = count + 1;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // This needs to be passed to _CategoryAccordion builder in the main build method,
  // but _CategoryAccordion expects a simple builder.
  // We need to update _CategoryAccordion to accept an icon as well.
}

class _CategoryAccordion extends StatefulWidget {
  final MenuCategory category;
  final Widget Function(MenuItem) itemBuilder;
  final bool defaultExpanded;
  final IconData icon; // Icon added

  const _CategoryAccordion({
    super.key,
    required this.category,
    required this.itemBuilder,
    this.defaultExpanded = false,
    this.icon = Icons.fastfood,
  });

  @override
  State<_CategoryAccordion> createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<_CategoryAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.defaultExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Spacing between accordions
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          12,
        ), // Rounded corners for valid card look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: _isExpanded
            ? null
            : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _isExpanded ? const Color(0xFF3E7C4B) : AppColors.white,
                // Only round top corners if expanded, otherwise all corners are handled by parent
              ),
              child: Row(
                children: [
                  // Category Icon
                  Icon(
                    widget.icon,
                    color: _isExpanded
                        ? AppColors.white
                        : const Color(
                            0xFFC59F60,
                          ), // Gold/Brown icon color from image
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isExpanded
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0, // 180 degree rotation
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down, // Rotate to up
                      color: _isExpanded ? AppColors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body with Animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Container(
                    color: AppColors.white,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      itemCount: widget.category.items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        return widget.itemBuilder(widget.category.items[index]);
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
