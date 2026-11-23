import 'supabase_service.dart';

/// Kerangka query untuk tabel orders dan order_items.
/// Dipakai modul Keranjang/Checkout, Status Pesanan, dan Riwayat.
///
/// Kolom orders (project 6B): id, buyer_id, tenant_id, courier_id,
/// delivery_address, delivery_notes, payment_method, payment_status,
/// status, subtotal, delivery_fee, total_amount, created_at.
///
/// Kolom order_items: id, order_id, menu_id, menu_name, unit_price,
/// quantity, line_total.
///
/// CATATAN: tabel ini dilindungi RLS, jadi baru bisa diakses setelah
/// pengguna login (supabase.auth.currentUser tidak null).
class OrderService {
  /// ID pengguna yang sedang login. Melempar error jika belum login.
  String get _userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Pengguna belum login.');
    }
    return user.id;
  }

  /// CREATE: buat pesanan beserta item-itemnya (dipanggil saat Checkout).
  /// [items] berisi map: menu_id, menu_name, unit_price, quantity.
  /// Status awal mengikuti default database. Jika tabel tidak punya default,
  /// isi 'status' dan 'payment_status' sesuai kesepakatan kelompok.
  Future<String> createOrder({
    required String tenantId,
    String? deliveryAddress,
    String? deliveryNotes,
    required String paymentMethod,
    required num deliveryFee,
    required List<Map<String, dynamic>> items,
  }) async {
    final subtotal = items.fold<num>(
      0,
      (sum, item) => sum + (item['unit_price'] as num) * (item['quantity'] as int),
    );

    // 1. Simpan data pesanan, lalu ambil id-nya.
    final order = await supabase
        .from(Tables.orders)
        .insert({
          'buyer_id': _userId,
          'tenant_id': tenantId,
          'delivery_address': deliveryAddress,
          'delivery_notes': deliveryNotes,
          'payment_method': paymentMethod,
          'subtotal': subtotal,
          'delivery_fee': deliveryFee,
          'total_amount': subtotal + deliveryFee,
        })
        .select('id')
        .single();

    final orderId = order['id'] as String;

    // 2. Simpan rincian item pesanan.
    final rows = items
        .map((item) => {
              'order_id': orderId,
              'menu_id': item['menu_id'],
              'menu_name': item['menu_name'],
              'unit_price': item['unit_price'],
              'quantity': item['quantity'],
              'line_total':
                  (item['unit_price'] as num) * (item['quantity'] as int),
            })
        .toList();

    await supabase.from(Tables.orderItems).insert(rows);

    return orderId;
  }

  /// READ: daftar pesanan milik pembeli yang login (Aktivitas dan Riwayat).
  /// Ikut mengambil nama warung dan item pesanan lewat relasi foreign key.
  Future<List<Map<String, dynamic>>> getMyOrders() async {
    return await supabase
        .from(Tables.orders)
        .select('*, tenants(name), order_items(*)')
        .eq('buyer_id', _userId)
        .order('created_at', ascending: false);
  }

  /// READ: satu pesanan lengkap (Status Pesanan).
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    return await supabase
        .from(Tables.orders)
        .select('*, tenants(name), order_items(*)')
        .eq('id', orderId)
        .maybeSingle();
  }

  /// READ: pesanan yang masuk ke satu warung (Dashboard Penjual).
  Future<List<Map<String, dynamic>>> getOrdersByTenant(String tenantId) async {
    return await supabase
        .from(Tables.orders)
        .select('*, order_items(*)')
        .eq('tenant_id', tenantId)
        .order('created_at', ascending: false);
  }

  /// UPDATE: ubah status pesanan (oleh penjual dan kurir, atau batal).
  /// Nilai status disepakati kelompok. Pesanan tidak dihapus.
  Future<void> updateStatus(String orderId, String status) async {
    await supabase.from(Tables.orders).update({'status': status}).eq('id', orderId);
  }
}