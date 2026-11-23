import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../theme/app_colors.dart';
import '../utils/currency.dart';

/// Kartu satu menu: gambar, nama, harga, stok, toggle, tombol edit, dan pengatur stok.
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildImage(),
          const SizedBox(width: 10),
          Expanded(child: _buildInfo()),
          const SizedBox(width: 8),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    const placeholder = ColoredBox(
      color: AppColors.photoPlaceholder,
      child: Center(
        child: Icon(Icons.restaurant, size: 22, color: AppColors.textSecondary),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 44,
        child: item.imageUrl == null
            ? placeholder
            : Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }

  Widget _buildInfo() {
    final statusColor = item.isAvailable ? AppColors.success : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatRupiah(item.price),
          style: const TextStyle(fontSize: 12, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.inventory_2, size: 11, color: AppColors.stockIcon),
            const SizedBox(width: 6),
            const Text(
              'Stok:',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              '${item.stock}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              item.isAvailable ? 'Live' : 'Off',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          child: Transform.scale(
            scale: 0.75,
            child: Switch(
              value: item.isAvailable,
              onChanged: onToggle,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.success
                    : const Color(0xFFD1D5DB),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        _StockStepper(
          value: item.stock,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
      ],
    );
  }
}

class _StockStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _StockStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.stepperBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove, onDecrement),
          SizedBox(
            width: 26,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          _button(Icons.add, onIncrement),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 20,
        height: 24,
        child: Icon(icon, size: 12, color: AppColors.primary),
      ),
    );
  }
}
