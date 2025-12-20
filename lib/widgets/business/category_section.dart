import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item.dart';
import 'menu_item_card.dart';

class CategorySection extends StatelessWidget {
  final MenuCategory category;
  final bool isEditMode;
  final Function(MenuItem)? onDeleteItem;
  final Function(MenuItem)? onSendToAski;
  final Function(MenuItem, int)? onQuantityChanged;
  final VoidCallback? onAddItem;

  const CategorySection({
    super.key,
    required this.category,
    this.isEditMode = false,
    this.onDeleteItem,
    this.onSendToAski,
    this.onQuantityChanged,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
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

        // Ürün listesi
        ...category.items.map(
          (item) => MenuItemCard(
            item: item,
            isEditMode: isEditMode,
            onDelete: onDeleteItem != null ? () => onDeleteItem!(item) : null,
            onSendToAski: onSendToAski != null
                ? () => onSendToAski!(item)
                : null,
            onQuantityChanged: onQuantityChanged != null
                ? (qty) => onQuantityChanged!(item, qty)
                : null,
          ),
        ),

        // Düzenleme modunda: Yeni ürün ekle
        if (isEditMode && onAddItem != null)
          GestureDetector(
            onTap: onAddItem,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.inputBorder.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryGreen),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Yeni Ürün Ekle',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
