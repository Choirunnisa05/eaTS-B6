import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// Layar sementara untuk membuktikan aplikasi terhubung ke Supabase.
/// Mengecek keenam tabel satu per satu tanpa perlu data di dalamnya.
/// Akan diganti Splash Screen / Halaman Pilih Peran pada week berikutnya.
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

enum _Status { ok, restricted, error }

class _TableResult {
  _TableResult(this.table, this.status, this.message);
  final String table;
  final _Status status;
  final String message;
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  static const List<String> _tables = [
    Tables.users,
    Tables.tenants,
    Tables.menus,
    Tables.orders,
    Tables.orderItems,
    Tables.reviews,
  ];

  bool _isLoading = false;
  List<_TableResult> _results = [];

  @override
  void initState() {
    super.initState();
    _runTest(); // langsung tes saat layar dibuka
  }

  Future<_TableResult> _checkTable(String table) async {
    try {
      final data = await supabase.from(table).select().limit(1);
      return _TableResult(
        table,
        _Status.ok,
        data.isEmpty ? 'Dapat dibaca (tabel kosong)' : 'Dapat dibaca (ada data)',
      );
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        return _TableResult(
          table,
          _Status.restricted,
          'Tabel ada, tetapi akses ditolak (RLS/grant belum dibuka)',
        );
      }
      return _TableResult(table, _Status.error, '${e.message} (kode: ${e.code})');
    } catch (e) {
      return _TableResult(table, _Status.error, 'Gagal terhubung: $e');
    }
  }

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _results = [];
    });

    final results = <_TableResult>[];
    for (final table in _tables) {
      results.add(await _checkTable(table));
    }

    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Color _colorOf(_Status s) {
    switch (s) {
      case _Status.ok:
        return Colors.green;
      case _Status.restricted:
        return Colors.orange;
      case _Status.error:
        return Colors.red;
    }
  }

  IconData _iconOf(_Status s) {
    switch (s) {
      case _Status.ok:
        return Icons.check_circle;
      case _Status.restricted:
        return Icons.lock;
      case _Status.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('eaTS - Tes Koneksi Supabase')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Hijau = dapat dibaca, oranye = tabel ada tetapi akses ditolak, '
              'merah = error.',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runTest,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Tes Ulang'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final r = _results[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(_iconOf(r.status), color: _colorOf(r.status)),
                      title: Text(r.table),
                      subtitle: Text(r.message),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}