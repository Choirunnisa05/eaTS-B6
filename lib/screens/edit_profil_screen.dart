import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
const _navy = Color(0xFF1A237E);
const _latar = Color(0xFFF1F4FD);
const _abu = Color(0xFFF3F4F6);
 
/// Edit Profil untuk tabel `profiles`
/// (role: buyer / seller / courier). Tampilan mengikuti Figma.
class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditProfilScreen({super.key, required this.data});
  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}
 
class _EditProfilScreenState extends State<EditProfilScreen> {
  final _sb = Supabase.instance.client;
 
  late final TextEditingController _nama;
  late final TextEditingController _noHp;
  late final TextEditingController _nrp;
  late final TextEditingController _departemen;
  late final TextEditingController _plat;
  final _namaTenant = TextEditingController();
  final _lokasi = TextEditingController();
  final _kategori = TextEditingController();
  late String _kendaraan;
  bool _loading = false;
 
  // Data tenant (khusus seller). Nama kolom dideteksi otomatis.
  Map<String, dynamic>? _tenant;
  String? _kNama, _kLokasi, _kKategori;
 
  static const _jenisKendaraan = ['Sepeda Motor', 'Sepeda', 'Jalan Kaki'];
  static const _ownerKeys = ['owner_id', 'profile_id', 'user_id', 'seller_id'];
  static const _namaKeys = ['nama_tenant', 'name', 'tenant_name'];
  static const _lokasiKeys = [
    'lokasi_kantin',
    'location',
    'canteen_location',
    'lokasi'
  ];
  static const _kategoriKeys = [
    'kategori_makanan',
    'category',
    'food_category',
    'kategori'
  ];
 
  String get _role => widget.data['role'];
 
  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _nama = TextEditingController(text: d['full_name'] ?? '');
    _noHp = TextEditingController(text: d['phone'] ?? '');
    _nrp = TextEditingController(text: d['nrp'] ?? '');
    _departemen = TextEditingController(text: d['departemen'] ?? '');
    _plat = TextEditingController(text: d['vehicle_plate'] ?? '');
    final k = d['vehicle_type'] as String?;
    _kendaraan = _jenisKendaraan.contains(k) ? k! : _jenisKendaraan.first;
    if (_role == 'seller') _muatTenant();
  }
 
  String? _pilih(Map<String, dynamic> row, List<String> kandidat) {
    for (final k in kandidat) {
      if (row.containsKey(k)) return k;
    }
    return null;
  }
 
  Future<void> _muatTenant() async {
    for (final owner in _ownerKeys) {
      try {
        final t = await _sb
            .from('tenants')
            .select()
            .eq(owner, widget.data['id'])
            .maybeSingle();
        if (t == null) continue;
        if (!mounted) return;
        setState(() {
          _tenant = t;
          _kNama = _pilih(t, _namaKeys);
          _kLokasi = _pilih(t, _lokasiKeys);
          _kKategori = _pilih(t, _kategoriKeys);
          if (_kNama != null) _namaTenant.text = '${t[_kNama] ?? ''}';
          if (_kLokasi != null) _lokasi.text = '${t[_kLokasi] ?? ''}';
          if (_kKategori != null) _kategori.text = '${t[_kKategori] ?? ''}';
        });
        return;
      } catch (_) {
        // kolom pemilik bukan ini, coba kandidat berikutnya
      }
    }
  }
 
  Future<void> _simpan() async {
    setState(() => _loading = true);
    try {
      final update = <String, dynamic>{
        'full_name': _nama.text.trim(),
        'phone': _noHp.text.trim(),
      };
      if (_role != 'seller') {
        update['nrp'] = _nrp.text.trim();
        update['departemen'] = _departemen.text.trim();
      }
      if (_role == 'courier') {
        update['vehicle_type'] = _kendaraan;
        update['vehicle_plate'] = _plat.text.trim();
      }
      await _sb.from('profiles').update(update).eq('id', widget.data['id']);
 
      if (_role == 'seller' && _tenant != null) {
        final t = <String, dynamic>{};
        if (_kNama != null) t[_kNama!] = _namaTenant.text.trim();
        if (_kLokasi != null) t[_kLokasi!] = _lokasi.text.trim();
        if (_kKategori != null) t[_kKategori!] = _kategori.text.trim();
        if (t.isNotEmpty) {
          await _sb.from('tenants').update(t).eq('id', _tenant!['id']);
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
 
  // ---------- gaya ----------
  Color get _warnaLatar => _role == 'courier' ? const Color(0xFFF7F8FA) : _latar;
 
  InputDecoration _dekor() {
    Color isi;
    bool garis = false;
    if (_role == 'buyer') {
      isi = Colors.white;
      garis = true;
    } else if (_role == 'seller') {
      isi = _latar;
    } else {
      isi = _abu;
    }
    final b = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
          garis ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
    );
    return InputDecoration(
      filled: true,
      fillColor: isi,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: b,
      enabledBorder: b,
    );
  }
 
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        child: Text(t,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _role == 'courier' ? Colors.grey.shade600 : _navy)),
      );
 
  Widget _field(String label, TextEditingController c,
      {TextInputType? tipe, bool readOnly = false, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: c,
          keyboardType: tipe,
          readOnly: readOnly,
          decoration: _dekor().copyWith(prefixText: prefix),
        ),
      ],
    );
  }
 
  Widget _dua(Widget a, Widget b) => Row(children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ]);
 
  // Judul bagian: buyer/seller pakai garis biru, courier pakai teks abu kapital.
  Widget _judul(String t) {
    if (_role == 'courier') {
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Row(children: [
        Container(width: 4, height: 18, color: _navy),
        const SizedBox(width: 8),
        Text(t,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: _navy)),
      ]),
    );
  }
 
  Widget _kartuPutih(List<Widget> anak) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: anak),
      );
 
  Widget _chip(String t, {Color bg = _latar, Color fg = _navy}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(t, style: TextStyle(fontSize: 11, color: fg)),
      );
 
  Widget _avatar({double radius = 42}) {
    final foto = widget.data['avatar_url'] as String?;
    return Stack(children: [
      CircleAvatar(
        radius: radius,
        backgroundColor: _latar,
        backgroundImage:
            (foto != null && foto.isNotEmpty) ? NetworkImage(foto) : null,
        child: (foto == null || foto.isEmpty)
            ? Icon(Icons.person, size: radius, color: _navy)
            : null,
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ganti foto menyusul'))),
          child: const CircleAvatar(
            radius: 14,
            backgroundColor: _navy,
            child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
 
  String get _info => [widget.data['departemen'], widget.data['nrp']]
      .where((e) => e != null && e.toString().isNotEmpty)
      .join(' • ');
 
  // ---------- header per peran ----------
  Widget _headerBuyer() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _avatar(),
          const SizedBox(height: 10),
          Text(widget.data['full_name'] ?? '',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _chip('Pembeli eaTS'),
          if (_info.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_info,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ]),
      );
 
  Widget _headerCourier() => Column(children: [
        const SizedBox(height: 8),
        _avatar(radius: 40),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(widget.data['full_name'] ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _chip('Kurir eaTS'),
            if (_info.isNotEmpty) ...[
              const Divider(height: 24),
              Text(_info,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ]),
        ),
      ]);
 
  Widget _headerSeller() {
    final nama = _namaTenant.text.isNotEmpty
        ? _namaTenant.text
        : (widget.data['full_name'] ?? '');
    final sub = [_lokasi.text, _kategori.text]
        .where((e) => e.isNotEmpty)
        .join(' • ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: _latar, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.storefront, color: _navy, size: 32),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ganti foto menyusul'))),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: _navy,
                child: Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
            ),
          ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nama,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: _navy)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            _chip('TENANT eaTS', bg: _navy, fg: Colors.white),
          ]),
        ),
      ]),
    );
  }
 
  // ---------- isi per peran ----------
  List<Widget> _isiBuyer(TextEditingController email) => [
        _judul('Informasi Pribadi'),
        _field('Nama Lengkap', _nama),
        _dua(_field('NRP', _nrp), _field('Departemen', _departemen)),
        _field('Email ITS', email, readOnly: true),
        _field('Nomor WhatsApp', _noHp,
            tipe: TextInputType.phone, prefix: '+62  '),
      ];
 
  List<Widget> _isiCourier(TextEditingController email) => [
        _judul('Informasi Pribadi'),
        _kartuPutih([
          _field('Nama Lengkap', _nama),
          _dua(_field('NRP', _nrp), _field('Departemen', _departemen)),
          _field('Email ITS', email, readOnly: true),
          _field('Nomor WhatsApp', _noHp,
              tipe: TextInputType.phone, prefix: '+62  '),
        ]),
        _judul('Informasi Kurir'),
        _kartuPutih([
          _label('Jenis Kendaraan'),
          DropdownButtonFormField<String>(
            value: _kendaraan,
            decoration: _dekor(),
            items: _jenisKendaraan
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _kendaraan = v!),
          ),
          _field('Nomor Kendaraan', _plat),
        ]),
      ];
 
  List<Widget> _isiSeller(TextEditingController email) => [
        _judul('Informasi Tenant'),
        _kartuPutih([
          _field('Nama Tenant', _namaTenant, readOnly: _kNama == null),
          _field('Nama Pemilik', _nama),
          _field('Lokasi Kantin', _lokasi, readOnly: _kLokasi == null),
          _dua(
            _field('Nomor WhatsApp', _noHp, tipe: TextInputType.phone),
            _field('Kategori Makanan', _kategori, readOnly: _kKategori == null),
          ),
        ]),
        if (_tenant == null)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text('Data tenant belum ditemukan untuk akun ini.',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ),
      ];
 
  @override
  Widget build(BuildContext context) {
    final email = TextEditingController(text: _sb.auth.currentUser?.email ?? '');
    final Widget header = _role == 'courier'
        ? _headerCourier()
        : (_role == 'seller' ? _headerSeller() : _headerBuyer());
    final List<Widget> isi = _role == 'courier'
        ? _isiCourier(email)
        : (_role == 'seller' ? _isiSeller(email) : _isiBuyer(email));
 
    return Scaffold(
      backgroundColor: _warnaLatar,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _navy),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: _navy, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _simpan,
            child: const Text('Simpan',
                style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [header, ...isi, const SizedBox(height: 16)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                icon: const Icon(Icons.save, size: 18),
                label: Text(_loading ? 'Menyimpan...' : 'Simpan Perubahan'),
                onPressed: _loading ? null : _simpan,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
 
