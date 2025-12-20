import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item.dart';
import 'quantity_selector.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool isEditMode;
  final VoidCallback? onDelete;
  final VoidCallback? onSendToAski;
  final Function(int)? onQuantityChanged;

  const MenuItemCard({
    super.key,
    required this.item,
    this.isEditMode = false,
    this.onDelete,
    this.onSendToAski,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Ürün ismi
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          if (isEditMode) ...[
            // Düzenleme modunda: miktar seçici + silme
            QuantitySelector(
              quantity: item.quantity,
              onIncrement: () => onQuantityChanged?.call(item.quantity + 1),
              onDecrement: () {
                if (item.quantity > 1) {
                  onQuantityChanged?.call(item.quantity - 1);
                }
              },
            ),
            const SizedBox(width: 12),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary.withOpacity(0.6),
                  size: 22,
                ),
              ),
          ] else ...[
            // Normal modda: fiyat + miktar + askıya gönder
            Text(
              '₺${item.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),

            if (onSendToAski != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSendToAski,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Askıya Gönder',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
