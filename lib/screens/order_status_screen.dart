import 'package:flutter/material.dart';

const _navy = Color(0xFF1B2A6B);
const _grey = Color(0xFFE3E5EC);
const _red = Color(0xFFE5484D);

/// Format angka ke rupiah, contoh: 15000 -> Rp 15.000
String _rupiah(num value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEDEEF3)),
      boxShadow: const [
        BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 3)),
      ],
    );

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  // ===== Data dummy, nanti diganti data dari Supabase (OrderService) =====
  static const String _orderCode = 'eaTS-0042';
  static const int _currentStep = 1; // 0 = Pesanan Masuk ... 3 = Tiba di Titik
  static const String _estimasi = '~12 Menit lagi';
  static const String _courierName = 'Rizky';
  static const String _courierPlate = 'L 1234 AB';
  static const double _courierRating = 4.9;
  static const String _dropPoint = 'Lobby Gedung Informatika';
  static const String _dropNote = 'Harap standby di lokasi agar mudah ditemui';
  static const num _deliveryFee = 5000;
  static const List<Map<String, dynamic>> _items = [
    {'name': 'Nasi Ayam Geprek', 'qty': 1, 'price': 15000},
    {'name': 'Es Teh', 'qty': 2, 'price': 2500},
  ];

  num get _subtotal => _items.fold<num>(
      0, (sum, i) => sum + (i['price'] as num) * (i['qty'] as int));
  num get _total => _subtotal + _deliveryFee;
  int get _itemCount => _items.fold<int>(0, (sum, i) => sum + (i['qty'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          // Dibatasi lebarnya supaya di Chrome tampil seperti layar HP.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(orderCode: _orderCode),
                  const SizedBox(height: 20),
                  const _OrderStepper(currentStep: _currentStep),
                  const SizedBox(height: 24),
                  const _EstimateCard(text: _estimasi),
                  const SizedBox(height: 14),
                  const _CourierCard(
                    name: _courierName,
                    plate: _courierPlate,
                    rating: _courierRating,
                  ),
                  const SizedBox(height: 14),
                  const _DropPointCard(point: _dropPoint, note: _dropNote),
                  const SizedBox(height: 14),
                  _OrderDetailCard(
                    items: _items,
                    deliveryFee: _deliveryFee,
                  ),
                  const SizedBox(height: 28),
                  _CancelSection(canCancel: _currentStep == 0),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: _TotalPill(total: _total, itemCount: _itemCount),
        ),
      ),
    );
  }
}

/// Judul pesanan + tombol share.
class _Header extends StatelessWidget {
  const _Header({required this.orderCode});
  final String orderCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Pesanan #$orderCode',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: _navy, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

/// Stepper 4 tahap.
class _OrderStepper extends StatelessWidget {
  const _OrderStepper({required this.currentStep});
  final int currentStep;

  static const _labels = [
    'Pesanan Masuk',
    'Diproses Penjual',
    'Dijemput Kurir',
    'Tiba di Titik',
  ];

  Widget _circle(int i) {
    final done = i < currentStep;
    final active = i == currentStep;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (done || active) ? _navy : _grey,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? Colors.white : const Color(0xFFB0B4C3),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isFirst = i == 0;
        final isLast = i == _labels.length - 1;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isFirst
                          ? Colors.transparent
                          : (i <= currentStep ? _navy : _grey),
                    ),
                  ),
                  _circle(i),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isLast
                          ? Colors.transparent
                          : (i < currentStep ? _navy : _grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: i <= currentStep ? FontWeight.w600 : FontWeight.w400,
                  color: i <= currentStep ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Kartu "Estimasi Tiba".
class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMASI TIBA',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.hourglass_bottom, color: _navy),
          ),
        ],
      ),
    );
  }
}

/// Kartu kurir: avatar, nama, plat, rating, tombol chat dan telepon.
class _CourierCard extends StatelessWidget {
  const _CourierCard({
    required this.name,
    required this.plate,
    required this.rating,
  });
  final String name;
  final String plate;
  final double rating;

  Widget _roundButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEEF1FB),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: _navy),
        onPressed: () {}, // TODO: buka chat / telepon kurir
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8EBF7),
                child: Icon(Icons.person, size: 32, color: _navy),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plate,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 14, color: Color(0xFFF5B400)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _roundButton(Icons.chat_bubble),
          _roundButton(Icons.phone),
        ],
      ),
    );
  }
}

/// Kartu "Titik Antar" (latar merah muda).
class _DropPointCard extends StatelessWidget {
  const _DropPointCard({required this.point, required this.note});
  final String point;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF1F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF6D5D5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFBE0E0),
            ),
            child: const Icon(Icons.my_location, color: _red, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TITIK ANTAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: _red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  point,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '"$note"',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu "Lihat Detail Pesanan" yang bisa dibuka dan ditutup.
class _OrderDetailCard extends StatefulWidget {
  const _OrderDetailCard({required this.items, required this.deliveryFee});
  final List<Map<String, dynamic>> items;
  final num deliveryFee;

  @override
  State<_OrderDetailCard> createState() => _OrderDetailCardState();
}

class _OrderDetailCardState extends State<_OrderDetailCard> {
  bool _open = true;

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontSize: 13)),
          Text(
            right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lihat Detail Pesanan',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(
                  _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 6),
            const Divider(),
            for (final item in widget.items)
              _row(
                '${item['qty']}x ${item['name']}',
                _rupiah((item['price'] as num) * (item['qty'] as int)),
              ),
            _row('Biaya Pengantaran', _rupiah(widget.deliveryFee)),
          ],
        ],
      ),
    );
  }
}

/// Tombol "Batalkan Pesanan" + keterangan.
class _CancelSection extends StatelessWidget {
  const _CancelSection({required this.canCancel});
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    final color = canCancel ? _red : const Color(0xFFF1B8BA);
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: canCancel ? () {} : null, // TODO: OrderService.updateStatus(..., 'Dibatalkan')
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(
                    'Batalkan Pesanan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!canCancel) ...[
            const SizedBox(height: 4),
            const Text(
              'Pesanan tidak dapat dibatalkan karena penjual sedang menyiapkan pesananmu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pil total di bagian bawah layar.
class _TotalPill extends StatelessWidget {
  const _TotalPill({required this.total, required this.itemCount});
  final num total;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1, // <-- perbaikan: tinggi hanya sebesar pil
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: ${_rupiah(total)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Container(
              width: 1,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.white38,
            ),
            Text(
              '$itemCount Items',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}