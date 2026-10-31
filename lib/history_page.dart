import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'detail_paket_page.dart';
import 'tambah_paket_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const terracotta = Color(0xFFB66E50);
  static const coklat = Color(0xFF302820);
  static const ivory = Color(0xFFFAF5F0);
  static const abu = Color(0xFF92796D);
  static const hijau = Color(0xFF47845C);

  List<Map<String, dynamic>> paketDiterima = [];

  @override
  void initState() {
    super.initState();
    muatHistory();
  }

  Future<void> muatHistory() async {
    final semuaPaket =
    await DatabaseHelper.instance.ambilSemuaPaket();

    if (!mounted) return;

    setState(() {
      paketDiterima = semuaPaket
          .where((paket) => paket['status_pengiriman'] == 'Diterima')
          .toList();
    });
  }

  String formatTanggal(String? nilai) {
    if (nilai == null || nilai.isEmpty) return '-';

    final tanggal = DateTime.tryParse(nilai);
    if (tanggal == null) return nilai;

    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Widget kartuPaket(Map<String, dynamic> paket) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPaketPage(paket: paket),
          ),
        );

        if (mounted) {
          muatHistory();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paket['nama_barang']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: coklat,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${paket['marketplace'] ?? '-'} · '
                            '${paket['status_pembayaran'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: abu,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: abu,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: hijau,
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Diterima',
                      style: TextStyle(
                        color: hijau,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatTanggal(
                    paket['estimasi_sampai']?.toString(),
                  ),
                  style: const TextStyle(
                    color: abu,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),

            // HEADER HISTORY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History Paket',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: coklat,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Paket Yang Sudah Kamu Terima',
                      style: TextStyle(
                        fontSize: 12,
                        color: abu,
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0D9CC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: terracotta,
                    size: 27,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // TOTAL PAKET
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: terracotta,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Paket Diterima',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${paketDiterima.length} Paket',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DAFTAR PAKET DITERIMA
            if (paketDiterima.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 70),
                child: Center(
                  child: Text(
                    'Belum ada paket yang diterima',
                    style: TextStyle(
                      color: abu,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ...paketDiterima.map(
                    (paket) => kartuPaket(paket),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: Colors.white,
        selectedItemColor: terracotta,
        unselectedItemColor: abu,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahPaketPage(),
              ),
            );

            if (mounted) {
              muatHistory();
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}