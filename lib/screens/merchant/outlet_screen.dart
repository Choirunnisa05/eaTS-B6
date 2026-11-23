import 'package:flutter/material.dart';

import '../../models/menu_item.dart';
import '../../theme/app_colors.dart';
import '../../widgets/menu_item_card.dart';
import '../../widgets/shop_header_card.dart';

/// Halaman "Outlet" untuk merchant: profil warung + daftar menu.
class OutletScreen extends StatefulWidget {
  const OutletScreen({super.key});

  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen> {
  int _navIndex = 1; // 0 = Pesanan, 1 = Outlet, 2 = Akun

  // Data contoh. Nanti bisa diganti dengan data dari Supabase.
  final List<MenuItem> _menus = [
    MenuItem(id: '1', name: 'Nasi Goreng Spesial', price: 15000, stock: 20),
    MenuItem(id: '2', name: 'Es Teh Manis', price: 3000, stock: 50),
    MenuItem(id: '3', name: 'Es Jeruk', price: 5000, stock: 40),
    MenuItem(id: '4', name: 'Nasi Ayam Geprek', price: 18000, stock: 45),
  ];

  void _changeStock(MenuItem item, int delta) {
    setState(() => item.stock = (item.stock + delta).clamp(0, 999));
  }

  void _toggleAvailability(MenuItem item, bool value) {
    setState(() => item.isAvailable = value);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature belum tersedia')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 22),
            SizedBox(width: 10),
            Text(
              'eaTS Merchant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showComingSoon('Notifikasi'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ShopHeaderCard(
              name: 'Warung Bu Kris',
              location: 'Kantin Pusat, ITS Sukolilo',
              rating: 4.8,
              reviewCount: 127,
              categories: const ['Nasi', 'Mie', 'Minuman'],
              onEdit: () => _showComingSoon('Edit warung'),
              onPhotoTap: () => _showComingSoon('Ubah foto'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daftar Menu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Kelola ketersediaan menu outlet Anda',
            style: TextStyle(fontSize: 12, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 16),
          for (final menu in _menus)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MenuItemCard(
                item: menu,
                onToggle: (value) => _toggleAvailability(menu, value),
                onEdit: () => _showComingSoon('Edit ${menu.name}'),
                onIncrement: () => _changeStock(menu, 1),
                onDecrement: () => _changeStock(menu, -1),
              ),
            ),
        ],
      ),
      floatingActionButton: _AddMenuButton(
        onPressed: () => _showComingSoon('Tambah menu'),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

/// Tombol "Tambah Menu" (pill) + tombol bulat "+".
class _AddMenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddMenuButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.primary,
          shape: const StadiumBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                'Tambah Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30),
        ),
      ],
    );
  }
}

/// Bottom navigation dengan garis indikator di bawah menu yang aktif.
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.receipt_long, label: 'Pesanan'),
    (icon: Icons.storefront, label: 'Outlet'),
    (icon: Icons.person, label: 'Akun'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: _navItem(_items[i].icon, _items[i].label, i == currentIndex),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    final color = selected ? AppColors.primary : const Color(0xFFB0B5C3);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
