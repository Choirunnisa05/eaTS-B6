import 'package:supabase_flutter/supabase_flutter.dart';

/// Klien Supabase yang dipakai di seluruh aplikasi.
/// Aman dipakai setelah Supabase.initialize() di main.dart selesai.
final SupabaseClient supabase = Supabase.instance.client;

/// Nama tabel di database. Disimpan di satu tempat supaya kalau nama tabel
/// di Supabase berbeda, cukup diubah di sini (tidak perlu cari di banyak file).
/// Samakan dengan nama tabel di Table Editor Supabase / ERD kelompok.
class Tables {
  static const String users = 'profiles';
  static const String tenants = 'tenants';
  static const String menus = 'menus';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String reviews = 'reviews';
}