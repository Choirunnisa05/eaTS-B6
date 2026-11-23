/// Model data satu tenant (warung) dari tabel `tenants` di Supabase.
class Tenant {
  final String id;
  final String name;
  final String? description;
  final String address;
  final String? phone;
  final String? imageUrl;
  final bool isOpen;

  const Tenant({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.phone,
    this.imageUrl,
    required this.isOpen,
  });

  /// Mengubah data mentah (Map) dari Supabase menjadi objek Tenant.
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      imageUrl: json['image_url'] as String?,
      isOpen: json['is_open'] as bool,
    );
  }
}
