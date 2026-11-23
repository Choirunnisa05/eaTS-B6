import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kartu profil warung: foto, nama, lokasi, rating, dan kategori.
class ShopHeaderCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final VoidCallback? onEdit;
  final VoidCallback? onPhotoTap;

  const ShopHeaderCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.categories,
    this.onEdit,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPhoto(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviewCount ulasan)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _buildCategoryChips(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    return InkWell(
      onTap: onPhotoTap,
      child: Container(
        height: 136,
        color: AppColors.photoPlaceholder,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: Color(0xFFD3D8E4),
              child: Icon(Icons.camera_alt, size: 20, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 10),
            Text(
              'Foto Warung',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 2),
            Text(
              'Tap untuk ubah foto',
              style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryChips() {
    final widgets = <Widget>[];
    for (var i = 0; i < categories.length; i++) {
      if (i > 0) {
        widgets.add(const Text('·', style: TextStyle(color: AppColors.textSecondary)));
      }
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.chip,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            categories[i],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
