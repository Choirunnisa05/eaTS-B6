import 'package:flutter/material.dart';

import 'order_status_screen.dart';

const _navy = Color(0xFF1B2A6B);

/// Format angka ke rupiah, contoh: 25000 -> Rp 25.000
String _rupiah(num value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

enum _OrderState { diproses, selesai, dibatalkan }

enum _Filter { semua, aktif, selesai, dibatalkan }

class _OrderSummary {
  const _OrderSummary({
    required this.tenantName,
    required this.date,
    required this.itemsText,
    required this.total,
    required this.state,
  });

  final String tenantName;
  final String date;
  final String itemsText;
  final num total;
  final _OrderState state;
}

class OrderActivityScreen extends StatefulWidget {
  const OrderActivityScreen({super.key});

  @override
  State<OrderActivityScreen> createState() => _OrderActivityScreenState();
}

class _OrderActivityScreenState extends State<OrderActivityScreen> {
  // ===== Data dummy, nanti diganti OrderService.getMyOrders() =====
  static const List<_OrderSummary> _orders = [
    _OrderSummary(
      tenantName: 'Warung Ibu Siti',
      date: '12 Jun 2024 • 12:30',
      itemsText: '1× Nasi Goreng Spesial, 1× Es Teh',
      total: 25000,
      state: _OrderState.diproses,
    ),
    _OrderSummary(
      tenantName: 'Ayam Geprek ITS',
      date: '10 Jun 2024 • 18:15',
      itemsText: '1× Paket Geprek Blarr Level 5',
      total: 18000,
      state: _OrderState.selesai,
    ),
    _OrderSummary(
      tenantName: 'Kopi Kampus',
      date: '08 Jun 2024 • 09:00',
      itemsText: '2× Caramel Macchiato',
      total: 44000,
      state: _OrderState.dibatalkan,
    ),
    _OrderSummary(
      tenantName: 'Mie Ayam Pak Kumis',
      date: '06 Jun 2024 • 12:10',
      itemsText: '1× Mie Ayam Bakso, 1× Es Jeruk',
      total: 22000,
      state: _OrderState.selesai,
    ),
    _OrderSummary(
      tenantName: 'Warung Bu Kris',
      date: '04 Jun 2024 • 13:05',
      itemsText: '1× Nasi Ayam Geprek, 2× Es Teh',
      total: 25000,
      state: _OrderState.selesai,
    ),
    _OrderSummary(
      tenantName: 'Kantin Teknik',
      date: '02 Jun 2024 • 11:40',
      itemsText: '1× Soto Ayam',
      total: 15000,
      state: _OrderState.dibatalkan,
    ),
  ];

  _Filter _filter = _Filter.semua;

  static const _filterLabels = {
    _Filter.semua: 'Semua',
    _Filter.aktif: 'Aktif',
    _Filter.selesai: 'Selesai',
    _Filter.dibatalkan: 'Dibatalkan',
  };

  List<_OrderSummary> get _current {
    if (_filter == _Filter.semua || _filter == _Filter.aktif) {
      return _orders.where((o) => o.state == _OrderState.diproses).toList();
    }
    return [];
  }

  List<_OrderSummary> get _history {
    return _orders.where((o) {
      if (o.state == _OrderState.diproses) return false;
      switch (_filter) {
        case _Filter.semua:
          return true;
        case _Filter.aktif:
          return false;
        case _Filter.selesai:
          return o.state == _OrderState.selesai;
        case _Filter.dibatalkan:
          return o.state == _OrderState.dibatalkan;
      }
    }).toList();
  }

  void _openStatus() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderStatusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final history = _history;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ActivityHeader(),
                _FilterChips(
                  labels: _filterLabels,
                  selected: _filter,
                  onSelected: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: (current.isEmpty && history.isEmpty)
                      ? const Center(
                          child: Text(
                            'Belum ada pesanan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          children: [
                            if (current.isNotEmpty) ...[
                              const _SectionLabel('PESANAN SAAT INI'),
                              for (final o in current)
                                _OrderCard(order: o, onDetail: _openStatus),
                            ],
                            if (history.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const _SectionLabel('RIWAYAT PESANAN'),
                              for (final o in history)
                                _OrderCard(
                                  order: o,
                                  onDetail: () {
                                    // TODO: buka detail riwayat / halaman ulasan
                                  },
                                ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Navbar placeholder, nanti dipindah ke kerangka navigasi bersama.
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

/// Judul + ikon cari dan titik tiga.
class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Aktivitas Pesanan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {}, // TODO: pencarian pesanan
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Chip filter yang bisa digeser ke samping.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final Map<_Filter, String> labels;
  final _Filter selected;
  final ValueChanged<_Filter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final entry in labels.entries)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onSelected(entry.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: entry.key == selected
                        ? _navy
                        : const Color(0xFFEDEEF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: entry.key == selected
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// Badge status (DIPROSES / SELESAI / DIBATALKAN).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.state);
  final _OrderState state;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (state) {
      case _OrderState.diproses:
        label = 'DIPROSES';
        bg = const Color(0xFFFFF4D6);
        fg = const Color(0xFFB7791F);
      case _OrderState.selesai:
        label = 'SELESAI';
        bg = const Color(0xFFE3F5E8);
        fg = const Color(0xFF2E7D4F);
      case _OrderState.dibatalkan:
        label = 'DIBATALKAN';
        bg = const Color(0xFFFDE8E8);
        fg = const Color(0xFFD64545);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: fg,
        ),
      ),
    );
  }
}

/// Satu kartu pesanan. Tombol di bawah menyesuaikan status.
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onDetail});

  final _OrderSummary order;
  final VoidCallback onDetail;

  Widget _buttons() {
    switch (order.state) {
      case _OrderState.diproses:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDetail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _navy),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lihat Detail',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble,
                    color: Colors.white, size: 20),
                onPressed: () {}, // TODO: chat dengan penjual / kurir
              ),
            ),
          ],
        );
      case _OrderState.selesai:
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onDetail,
                style: TextButton.styleFrom(
                  foregroundColor: _navy,
                  backgroundColor: const Color(0xFFEDEEF5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lihat Detail',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                onPressed: () {}, // TODO: isi ulang keranjang dari pesanan ini
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Pesan Lagi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      case _OrderState.dibatalkan:
        return SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: null, // nonaktif
            style: TextButton.styleFrom(
              disabledForegroundColor: Colors.grey,
              disabledBackgroundColor: const Color(0xFFF0F1F5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Lihat Detail',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = order.state == _OrderState.diproses;
    final isCancelled = order.state == _OrderState.dibatalkan;

    final priceText = Text(
      _rupiah(order.total),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isCancelled ? Colors.grey : Colors.black,
        decoration: isCancelled ? TextDecoration.lineThrough : null,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEEF3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront, color: _navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.tenantName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.date,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _StatusBadge(order.state),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          if (isActive)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(order.itemsText,
                      style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                priceText,
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.itemsText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCancelled ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  priceText,
                ],
              ),
            ),
          const SizedBox(height: 14),
          _buttons(),
        ],
      ),
    );
  }
}

/// Navbar bawah: ikon terisi, tab aktif ditandai warna, label tebal, dan garis.
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _active = 1; // 0 Jelajahi, 1 Aktivitas, 2 Promo, 3 Akun
  static const _items = [
    (Icons.home_rounded, 'Jelajahi'),
    (Icons.receipt_long_rounded, 'Aktivitas'),
    (Icons.confirmation_number_rounded, 'Promo'),
    (Icons.person_rounded, 'Akun'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () {}, // TODO: pindah tab lewat kerangka bersama
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _items[i].$1,
                              size: 26,
                              color: i == _active
                                  ? _navy
                                  : const Color(0xFFB8BCC9),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _items[i].$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: i == _active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: i == _active
                                    ? _navy
                                    : const Color(0xFFB8BCC9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 22,
                              height: 3,
                              decoration: BoxDecoration(
                                color: i == _active
                                    ? _navy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}