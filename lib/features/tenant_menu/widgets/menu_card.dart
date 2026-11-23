import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../tenant_menu_colors.dart';

/// Mengubah angka 15000 menjadi teks "Rp 15.000".
String _formatRupiah(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    // Tambahkan titik setiap 3 digit dari belakang
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}

/// Kartu satu menu: foto, nama, deskripsi, harga, stok, dan tombol tambah.
class MenuCard extends StatelessWidget {
  final MenuItem menu;

  const MenuCard({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    // Menu hanya bisa dipesan kalau tersedia DAN stoknya masih ada
    final canOrder = menu.isAvailable && menu.stock > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: TenantMenuColors.primary,
                  ),
                ),
                if (menu.description != null && menu.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      menu.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  _formatRupiah(menu.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: TenantMenuColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  canOrder ? 'Stok Tersedia: ${menu.stock} Porsi' : 'Habis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: canOrder ? Colors.black87 : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol tambah. Kalau onPressed bernilai null, tombol otomatis nonaktif.
          IconButton.filled(
            // TODO: sambungkan ke fitur keranjang (dikerjakan teman)
            onPressed: canOrder ? () {} : null,
            icon: const Icon(Icons.add, size: 18),
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: TenantMenuColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = menu.imageUrl;

    Widget placeholder() => Container(
      width: 72,
      height: 72,
      color: const Color(0xFFD9DBF2),
      child: const Icon(Icons.fastfood, color: TenantMenuColors.primary),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: (url == null || url.isEmpty)
          ? placeholder()
          : Image.network(
              url,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder(),
            ),
    );
  }
}
