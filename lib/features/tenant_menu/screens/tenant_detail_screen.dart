import 'package:flutter/material.dart';

import '../models/tenant.dart';
import '../services/tenant_menu_service.dart';
import '../tenant_menu_colors.dart';
import '../widgets/tenant_header.dart';
import '../widgets/menu_list_section.dart';

/// Halaman detail tenant. Menerima id tenant dari layar sebelumnya.
class TenantDetailScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  final _service = TenantMenuService();
  late Future<Tenant> _tenantFuture;

  @override
  void initState() {
    super.initState();
    _tenantFuture = _service.getTenantById(widget.tenantId);
  }

  // Dipakai tombol "Coba Lagi" untuk mengambil data ulang
  void _reload() {
    setState(() {
      _tenantFuture = _service.getTenantById(widget.tenantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TenantMenuColors.background,
      body: FutureBuilder<Tenant>(
        future: _tenantFuture,
        builder: (context, snapshot) {
          // 1. Sedang memuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Terjadi error
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _reload);
          }

          // 3. Data berhasil didapat
          final tenant = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              TenantHeader(tenant: tenant),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Menu Tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TenantMenuColors.primary,
                  ),
                ),
              ),
              MenuListSection(tenantId: tenant.id),
            ],
          );
        },
      ),
    );
  }
}

/// Tampilan saat data gagal dimuat.
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data warung',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Periksa koneksi internetmu lalu coba lagi.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
