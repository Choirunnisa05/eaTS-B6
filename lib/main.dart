import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/connection_test_screen.dart';

/// Titik awal aplikasi eaTS.
/// Urutan: siapkan Flutter -> baca file .env -> inisialisasi Supabase -> jalankan aplikasi.
Future<void> main() async {
  // Wajib dipanggil jika ada proses async sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Baca kredensial dari file .env (tidak ikut ke GitHub).
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

    if (supabaseUrl == null ||
        supabaseUrl.isEmpty ||
        supabasePublishableKey == null ||
        supabasePublishableKey.isEmpty) {
      throw Exception('SUPABASE_URL atau SUPABASE_PUBLISHABLE_KEY belum diisi di file .env');
    }

    // 2. Hubungkan aplikasi ke project Supabase.
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);

    // 3. Jalankan aplikasi.
    runApp(const MyApp());
  } catch (e) {
    // Jika konfigurasi bermasalah, tampilkan pesan yang jelas (bukan layar merah).
    runApp(_StartupErrorApp(message: e.toString()));
  }
}

/// Akar aplikasi eaTS.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eaTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Biru tua sebagai warna utama, sesuai rancangan desain eaTS.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B2A6B)),
        useMaterial3: true,
      ),
      // Sementara: layar uji koneksi. Nanti diganti Splash Screen (Week berikutnya).
      home: const ConnectionTestScreen(),
    );
  }
}

/// Layar sederhana yang tampil bila aplikasi gagal start (mis. .env belum dibuat).
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'eaTS gagal dijalankan.\n\n$message\n\n'
              'Pastikan file .env sudah dibuat dan terdaftar di pubspec.yaml (assets).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
