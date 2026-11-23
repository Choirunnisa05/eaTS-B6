import 'supabase_service.dart';

/// Kerangka CRUD lengkap untuk tabel menus (sesuai Bab 2.3.3 laporan).
/// Dikelola penjual lewat modul Kelola Menu, dibaca pembeli di Halaman Warung.
///
/// Nama kolom mengikuti tabel menus di project Supabase 6B:
/// id, tenant_id, name, description, category, price, stock,
/// image_url, is_available, created_at.
class MenuService {
  /// READ: daftar menu milik satu tenant.
  /// [hanyaTersedia] = true untuk pembeli (hanya menu yang ditampilkan).
  Future<List<Map<String, dynamic>>> getMenusByTenant(
    String tenantId, {
    bool hanyaTersedia = false,
  }) async {
    var query = supabase.from(Tables.menus).select().eq('tenant_id', tenantId);

    if (hanyaTersedia) {
      query = query.eq('is_available', true);
    }

    return await query.order('name');
  }

  /// CREATE: tambah menu baru.
  Future<void> addMenu({
    required String tenantId,
    required String name,
    String? description,
    required num price,
    String? category,
    int stock = 0,
    String? imageUrl,
  }) async {
    await supabase.from(Tables.menus).insert({
      'tenant_id': tenantId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'image_url': imageUrl,
      'is_available': true,
    });
  }

  /// UPDATE: ubah data menu (name, description, price, category, dll).
  Future<void> updateMenu(String menuId, Map<String, dynamic> data) async {
    await supabase.from(Tables.menus).update(data).eq('id', menuId);
  }

  /// UPDATE: ubah stok menu (tombol +, -, +5, +10, +20, Reset ke 0).
  Future<void> updateStok(String menuId, int stokBaru) async {
    await supabase
        .from(Tables.menus)
        .update({'stock': stokBaru < 0 ? 0 : stokBaru}).eq('id', menuId);
  }

  /// UPDATE: tampilkan atau sembunyikan menu (toggle Tampilkan Menu).
  Future<void> setTersedia(String menuId, bool tersedia) async {
    await supabase
        .from(Tables.menus)
        .update({'is_available': tersedia}).eq('id', menuId);
  }

  /// DELETE: hapus menu.
  Future<void> deleteMenu(String menuId) async {
    await supabase.from(Tables.menus).delete().eq('id', menuId);
  }
}