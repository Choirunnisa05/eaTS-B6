import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../services/tenant_menu_service.dart';
import '../tenant_menu_colors.dart';
import 'menu_card.dart';

/// Bagian daftar menu milik satu tenant.
/// Punya status loading, kosong, dan error sendiri.
class MenuListSection extends StatefulWidget {
  final String tenantId;

  const MenuListSection({super.key, required this.tenantId});

  @override
  State<MenuListSection> createState() => _MenuListSectionState();
}

class _MenuListSectionState extends State<MenuListSection> {
  final _service = TenantMenuService();
  late Future<List<MenuItem>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _menusFuture = _service.getMenusByTenant(widget.tenantId);
  }

  void _reload() {
    setState(() {
      _menusFuture = _service.getMenusByTenant(widget.tenantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuItem>>(
      future: _menusFuture,
      builder: (context, snapshot) {
        // 1. Sedang memuat
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Terjadi error
        if (snapshot.hasError) {
          return _MessageView(
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
            title: 'Gagal memuat menu',
            subtitle: 'Periksa koneksi internetmu lalu coba lagi.',
            onRetry: _reload,
          );
        }

        // 3. Berhasil, tapi tidak ada menu
        final menus = snapshot.data!;
        if (menus.isEmpty) {
          return const _MessageView(
            icon: Icons.restaurant_menu,
            iconColor: TenantMenuColors.primary,
            title: 'Belum ada menu',
            subtitle: 'Warung ini belum menambahkan menu.',
          );
        }

        // 4. Berhasil dan ada menu
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              for (final menu in menus)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MenuCard(menu: menu),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Tampilan pesan (untuk kondisi kosong dan error).
class _MessageView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _MessageView({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ],
      ),
    );
  }
}
