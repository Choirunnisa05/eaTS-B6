import 'supabase_service.dart';

/// Kerangka query untuk tabel reviews (ulasan pesanan).
///
/// Kolom reviews (project 6B): id, order_id, buyer_id, tenant_id,
/// rating (1-5), comment, created_at.
class ReviewService {
  /// CREATE: kirim ulasan untuk satu pesanan.
  Future<void> addReview({
    required String orderId,
    required String tenantId,
    required int rating,
    String? comment,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    await supabase.from(Tables.reviews).insert({
      'order_id': orderId,
      'buyer_id': user.id,
      'tenant_id': tenantId,
      'rating': rating,
      'comment': comment,
    });
  }

  /// READ: semua ulasan satu warung (Halaman Warung).
  Future<List<Map<String, dynamic>>> getReviewsByTenant(String tenantId) async {
    return await supabase
        .from(Tables.reviews)
        .select()
        .eq('tenant_id', tenantId)
        .order('created_at', ascending: false);
  }

  /// READ: ulasan untuk satu pesanan. Null jika belum diulas.
  Future<Map<String, dynamic>?> getReviewByOrder(String orderId) async {
    return await supabase
        .from(Tables.reviews)
        .select()
        .eq('order_id', orderId)
        .maybeSingle();
  }
}