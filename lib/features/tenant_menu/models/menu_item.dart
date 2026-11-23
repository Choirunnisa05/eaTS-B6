/// Model data satu menu dari tabel `menus` di Supabase.
class MenuItem {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String? category;
  final double price;
  final int stock;
  final String? imageUrl;
  final bool isAvailable;

  const MenuItem({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.isAvailable,
  });

  /// Mengubah data mentah (Map) dari Supabase menjadi objek MenuItem.
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      // kolom `price` bertipe numeric, jadi diubah dulu lewat `num`
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool,
    );
  }
}
