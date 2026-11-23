/// Data satu menu di outlet.
class MenuItem {
  final String id;
  final String name;
  final int price;

  /// URL gambar (misalnya dari Supabase Storage). Kosongkan jika belum ada.
  final String? imageUrl;

  int stock;
  bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.stock = 0,
    this.isAvailable = true,
  });
}
