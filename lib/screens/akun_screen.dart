import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profil_screen.dart';
import 'pengaturan_screen.dart';
 
const _navy = Color(0xFF1A237E);
const _navyMuda = Color(0xFF283593);
const _latar = Color(0xFFF1F4FD);
 
class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});
  @override
  State<AkunScreen> createState() => _AkunScreenState();
}
 
class _AkunScreenState extends State<AkunScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _data;
  String? _namaTenant;
  String? _lokasiTenant;
  int _total = 0;
  int _selesai = 0;
  int _batal = 0;
  bool _loading = true;
 
  @override
  void initState() {
    super.initState();
    _muat();
  }
 
  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final uid = _supabase.auth.currentUser!.id;
      final data =
          await _supabase.from('profiles').select().eq('id', uid).single();
      _data = data;
      await _muatStatistik(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
 
  Future<void> _muatStatistik(Map<String, dynamic> d) async {
    try {
      final uid = d['id'];
      String kolom;
      dynamic nilai = uid;
      if (d['role'] == 'seller') {
        final t = await _supabase
            .from('tenants')
            .select('id, nama_tenant, lokasi_kantin')
            .eq('owner_id', uid)
            .maybeSingle();
        if (t == null) return;
        _namaTenant = t['nama_tenant'];
        _lokasiTenant = t['lokasi_kantin'];
        kolom = 'tenant_id';
        nilai = t['id'];
      } else if (d['role'] == 'courier') {
        kolom = 'courier_id';
      } else {
        kolom = 'buyer_id';
      }
      final rows =
          await _supabase.from('orders').select('status').eq(kolom, nilai);
      _total = rows.length;
      _selesai = rows.where((r) => r['status'] == 'selesai').length;
      _batal = rows.where((r) => r['status'] == 'dibatalkan').length;
    } catch (_) {
      // statistik opsional, abaikan kalau gagal
    }
  }
 
  Future<void> _keluar() async {
    // Setelah signOut, halaman login ditampilkan oleh main.dart
    // (lewat onAuthStateChange), jadi file ini tidak perlu tahu AuthScreen.
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
 
  void _segera() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Fitur ini segera hadir')));
  }
 
  Future<void> _bukaEditProfil() async {
    final berubah = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfilScreen(data: _data!)),
    );
    if (berubah == true) _muat();
  }
 
  void _bukaPengaturan() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PengaturanScreen()));
  }
 
  List<(IconData, String, VoidCallback)> _menu(String peran) {
    if (peran == 'seller') {
      return [
        (Icons.person_outline, 'Edit Profil', _bukaEditProfil),
        (Icons.storefront_outlined, 'Pengaturan', _bukaPengaturan),
        (Icons.account_balance_wallet_outlined, 'Rekening Bank', _segera),
        (Icons.bar_chart, 'Laporan Penjualan', _segera),
        (Icons.help_outline, 'Bantuan', _segera),
      ];
    }
    return [
      (Icons.person_outline, 'Edit Profil', _bukaEditProfil),
      (Icons.settings_outlined, 'Pengaturan', _bukaPengaturan),
      (Icons.help_outline, 'Bantuan', _segera),
    ];
  }
 
  Widget _header(Map<String, dynamic> d) {
    final peran = d['role'] as String;
    final nama = (d['full_name'] ?? '') as String;
    final foto = d['avatar_url'] as String?;
    String sub;
    if (peran == 'seller') {
      sub = _namaTenant ?? 'Penjual';
    } else {
      sub = [d['departemen'], d['nrp']]
          .where((e) => e != null && e.toString().isNotEmpty)
          .join(' • ');
      if (sub.isEmpty) sub = _supabase.auth.currentUser?.email ?? '';
    }
    final badge = peran == 'seller' ? 'Penjual' : (peran == 'courier' ? 'Kurir' : 'Pembeli');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _navyMuda],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          const Text('Akun',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            backgroundImage:
                (foto != null && foto.isNotEmpty) ? NetworkImage(foto) : null,
            child: (foto == null || foto.isEmpty)
                ? Text(nama.isEmpty ? '?' : nama[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _navy))
                : null,
          ),
          const SizedBox(height: 10),
          Text(nama,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          if (peran == 'seller' && _lokasiTenant != null)
            Text(_lokasiTenant!,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(20)),
            child: Text(badge,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }
 
  Widget _statistik() {
    Widget item(String nilai, String label) => Expanded(
          child: Column(children: [
            Text(nilai,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: _navy)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        );
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          item('$_total', 'Total Pesanan'),
          item('$_selesai', 'Selesai'),
          item('$_batal', 'Dibatalkan'),
        ]),
      ),
    );
  }
 
  Widget _daftarMenu(String peran) {
    final menu = _menu(peran);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        for (var i = 0; i < menu.length; i++) ...[
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _navy, borderRadius: BorderRadius.circular(10)),
              child: Icon(menu[i].$1, color: Colors.white, size: 18),
            ),
            title: Text(menu[i].$2,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: menu[i].$3,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.logout, color: Colors.red, size: 18),
          ),
          title: const Text('Keluar',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: _keluar,
        ),
      ]),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      backgroundColor: _latar,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : d == null
              ? const Center(child: Text('Data akun tidak ditemukan'))
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _header(d),
                    _statistik(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text('PENGATURAN',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                    ),
                    _daftarMenu(d['role']),
                    const SizedBox(height: 16),
                    Center(
                      child: Text('eaTS v2.0 • ${d['role']}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }
}
 
