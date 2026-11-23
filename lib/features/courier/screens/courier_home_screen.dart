
import 'package:flutter/material.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() =>
      _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  bool isOnline = true;

  static const Color primaryColor = Color(0xFF1B207A);
  static const Color backgroundColor = Color(0xFFF4F5FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE3E6F8),
                    child: Icon(
                      Icons.delivery_dining,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Rizky! 👋',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Kamu sedang online',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOnline,
                    activeThumbColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isOnline = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // STATUS KURIR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF4CAF50)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOnline
                      ? '✓ Siap menerima pesanan baru'
                      : 'Sedang offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // STATISTIK
              const Text(
                'Statistik Hari Ini',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _statCard('SELESAI', '12'),
                  const SizedBox(width: 8),
                  _statCard('PENGHASILAN', 'Rp 45k'),
                  const SizedBox(width: 8),
                  _statCard('RATING', '4.8 ⭐'),
                ],
              ),

              const SizedBox(height: 30),

              // PESANAN MASUK
              const Text(
                'Pesanan Masuk',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 55,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      size: 48,
                      color: Color(0xFFBFC5DF),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isOnline
                          ? 'Menunggu pesanan masuk...'
                          : 'Kamu sedang offline',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOnline
                          ? 'Tetaplah berada di dekat area kampus '
                            'untuk mendapatkan pesanan lebih cepat.'
                          : 'Aktifkan status online untuk '
                            'menerima pesanan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
