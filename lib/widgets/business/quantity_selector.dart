import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double size;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eksi butonu
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.remove,
              size: size * 0.6,
              color: AppColors.primaryGreen,
            ),
          ),
        ),

        // Adet
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Artı butonu
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, size: size * 0.6, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
