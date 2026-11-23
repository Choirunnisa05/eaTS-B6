import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _navy = Color(0xFF1A237E);
const _latar = Color(0xFFF1F4FD);

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});
  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _notifPesanan = true;
  bool _notifPromo = false;

  Future<void> _ubahKataSandi() async {
    final c = TextEditingController();
    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Kata Sandi'),
        content: TextField(
          controller: c,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: 'Kata sandi baru (min. 6 karakter)',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (simpan != true) return;
    try {
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: c.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kata sandi berhasil diubah')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Widget _judul(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
      );

  Widget _kartu(List<Widget> anak) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: anak),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _navy),
        title: const Text('Pengaturan',
            style: TextStyle(
                color: _navy, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        children: [
          _judul('NOTIFIKASI'),
          _kartu([
            SwitchListTile(
              activeColor: _navy,
              title: const Text('Status pesanan'),
              subtitle: const Text('Kabar terbaru tentang pesananmu'),
              value: _notifPesanan,
              onChanged: (v) => setState(() => _notifPesanan = v),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            SwitchListTile(
              activeColor: _navy,
              title: const Text('Promo dan voucher'),
              value: _notifPromo,
              onChanged: (v) => setState(() => _notifPromo = v),
            ),
          ]),
          _judul('KEAMANAN'),
          _kartu([
            ListTile(
              leading: const Icon(Icons.lock_outline, color: _navy),
              title: const Text('Ubah kata sandi'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _ubahKataSandi,
            ),
          ]),
          _judul('UMUM'),
          _kartu([
            const ListTile(
              leading: Icon(Icons.language, color: _navy),
              title: Text('Bahasa'),
              trailing: Text('Indonesia', style: TextStyle(color: Colors.grey)),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.info_outline, color: _navy),
              title: const Text('Tentang eaTS'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'eaTS',
                applicationVersion: '1.0',
                children: const [
                  Text('Aplikasi pemesanan makanan kantin ITS.'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}