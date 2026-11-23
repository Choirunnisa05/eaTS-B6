import 'supabase_service.dart';

/// Kerangka query untuk tabel Tenants (data warung).
/// Dipakai oleh Home Pembeli (daftar warung) dan Halaman Warung.
class TenantService {
  /// READ: ambil daftar warung.
  /// Parameter kategori belum dipakai karena kolom kategori belum ada
  /// di tabel tenants project 6B.
  Future<List<Map<String, dynamic>>> getTenants({String? kategori}) async {
    final query = supabase.from(Tables.tenants).select();

    // if (kategori != null && kategori != 'Semua') {
    //   query = query.eq('kategori_makanan', kategori);
    // }

    return await query.order('name');
  }

  /// READ: ambil satu warung berdasarkan id. Hasil null jika tidak ditemukan.
  Future<Map<String, dynamic>?> getTenantById(String tenantId) async {
    return await supabase
        .from(Tables.tenants)
        .select()
        .eq('id', tenantId)
        .maybeSingle();
  }

  /// UPDATE: ubah status buka/tutup warung (dipakai Dashboard Penjual).
  Future<void> updateStatusBuka(String tenantId, bool statusBuka) async {
    await supabase
        .from(Tables.tenants)
        .update({'is_open': statusBuka}).eq('id', tenantId);
  }
}