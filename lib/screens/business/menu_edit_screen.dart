import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item.dart';
import '../../widgets/business/category_section.dart';

class MenuEditScreen extends StatefulWidget {
  final List<MenuCategory> categories;
  final Function(List<MenuCategory>) onSave;

  const MenuEditScreen({
    super.key,
    required this.categories,
    required this.onSave,
  });

  @override
  State<MenuEditScreen> createState() => _MenuEditScreenState();
}

class _MenuEditScreenState extends State<MenuEditScreen> {
  late List<MenuCategory> _categories;
  final TextEditingController _newItemController = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Derin kopya oluştur
    _categories = widget.categories
        .map(
          (c) => MenuCategory(
            id: c.id,
            name: c.name,
            items: c.items
                .map(
                  (i) => MenuItem(
                    id: i.id,
                    name: i.name,
                    price: i.price,
                    quantity: i.quantity,
                    categoryId: i.categoryId,
                    isOnAski: i.isOnAski,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _newItemController.dispose();
    _newPriceController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addItemToCategory(MenuCategory category) {
    _newItemController.clear();
    _newPriceController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${category.name} - Yeni Ürün'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newItemController,
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fiyat (₺)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
              if (_newItemController.text.isNotEmpty) {
                setState(() {
                  final categoryIndex = _categories.indexWhere(
                    (c) => c.id == category.id,
                  );
                  if (categoryIndex != -1) {
                    _categories[categoryIndex].items.add(
                      MenuItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _newItemController.text,
                        price: double.tryParse(_newPriceController.text) ?? 0,
                        quantity: 1,
                        categoryId: category.id,
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addNewCategory() {
    _newCategoryController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Kategori'),
        content: TextField(
          controller: _newCategoryController,
          decoration: InputDecoration(
            labelText: 'Kategori Adı',
            hintText: 'örn: Tatlılar',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newCategoryController.text.isNotEmpty) {
                setState(() {
                  _categories.add(
                    MenuCategory(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _newCategoryController.text,
                      items: [],
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(MenuCategory category, MenuItem item) {
    setState(() {
      final categoryIndex = _categories.indexWhere((c) => c.id == category.id);
      if (categoryIndex != -1) {
        _categories[categoryIndex].items.removeWhere((i) => i.id == item.id);
      }
    });
  }

  void _updateItemQuantity(
    MenuCategory category,
    MenuItem item,
    int newQuantity,
  ) {
    setState(() {
      final categoryIndex = _categories.indexWhere((c) => c.id == category.id);
      if (categoryIndex != -1) {
        final itemIndex = _categories[categoryIndex].items.indexWhere(
          (i) => i.id == item.id,
        );
        if (itemIndex != -1) {
          _categories[categoryIndex].items[itemIndex].quantity = newQuantity;
        }
      }
    });
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
                const Expanded(
                  child: Text(
                    'Menünüzü Düzenle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Container(
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
              ],
            ),
          ),

          // Başlık ve açıklama
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menünüzü Düzenle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mevcut yemeklerinizi düzenleyin veya yeni yemek ekleyin.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Kategori ve ürün listesi
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._categories.map(
                    (category) => CategorySection(
                      category: category,
                      isEditMode: true,
                      onDeleteItem: (item) => _deleteItem(category, item),
                      onQuantityChanged: (item, qty) =>
                          _updateItemQuantity(category, item, qty),
                      onAddItem: () => _addItemToCategory(category),
                    ),
                  ),

                  // Yeni kategori ekle
                  GestureDetector(
                    onTap: _addNewCategory,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.inputBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Yeni Kategori Ekle',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Alt butonlar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Vazgeç',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_categories);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menü kaydedildi!'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Kaydet',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
}
