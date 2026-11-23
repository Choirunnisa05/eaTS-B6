import 'package:flutter/material.dart';

import '../models/tenant.dart';
import '../tenant_menu_colors.dart';

/// Banner bagian atas halaman detail tenant.
class TenantHeader extends StatelessWidget {
  final Tenant tenant;

  const TenantHeader({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Foto banner (atau gambar pengganti kalau kosong)
          _buildImage(),

          // 2. Lapisan gelap tipis supaya teks putih mudah dibaca
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black38, Colors.transparent, Colors.black87],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 3. Tombol kembali dan keranjang di atas
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      // TODO: sambungkan ke halaman keranjang (fitur teman)
                      onPressed: () {},
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Badge, nama, dan alamat di bagian bawah banner
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(),
                const SizedBox(height: 8),
                Text(
                  tenant.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tenant.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = tenant.imageUrl;
    if (url == null || url.isEmpty) return _buildPlaceholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      // Kalau gambar gagal dimuat, tampilkan gambar pengganti
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFD9DBF2),
      child: const Center(
        child: Icon(
          Icons.storefront,
          size: 64,
          color: TenantMenuColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tenant.isOpen ? TenantMenuColors.open : TenantMenuColors.closed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tenant.isOpen ? 'BUKA' : 'TUTUP',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
