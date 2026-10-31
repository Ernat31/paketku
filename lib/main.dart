
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_paket_page.dart';
import 'database_helper.dart';
import 'detail_paket_page.dart';
import 'history_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://smjriihzvsdikeexyrex.supabase.co',
    publishableKey: 'sb_publishable_i1WfYC41nTL97OnevFGZEg_p4PrHmYT',
  );
  final supabase = Supabase.instance.client;


  try {
    if (supabase.auth.currentUser == null) {
      await supabase.auth.signInAnonymously();
    }

    debugPrint(
      'USER ID SEKARANG: ${supabase.auth.currentUser?.id}',
    );
  } catch (e) {
    debugPrint('LOGIN GAGAL: $e');
  }

  try {
    await DatabaseHelper.instance.sinkronkanPaket();
    await DatabaseHelper.instance.sinkronkanPenghapusan();
    debugPrint('SINKRONISASI SAAT START BERHASIL');
  } catch (e) {
    debugPrint('SINKRONISASI SAAT START GAGAL: $e');
  }
  runApp(const PaketKuApp());
}

class PaketKuApp extends StatelessWidget {
  const PaketKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PaketKu',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF5F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB66E50),
        ),
        useMaterial3: true,
      ),
      home: const BerandaPage(),
    );
  }
}
String formatTanggal(String? tanggal) {
  if (tanggal == null || tanggal.isEmpty) return '-';

  final hasil = DateTime.tryParse(tanggal);
  if (hasil == null) return tanggal;

  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  return '${hasil.day} ${bulan[hasil.month - 1]} ${hasil.year}';
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {

  List<Map<String, dynamic>> daftarPaket = [];
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    muatPaket();
  }

  Future<void> muatPaket() async {
    try {
      final hasil = await DatabaseHelper.instance.ambilSemuaPaket();

      if (!mounted) return;

      setState(() {
        daftarPaket = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangMemuat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat paket: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final paketAktif = daftarPaket
        .where((paket) => paket['status_pengiriman'] != 'Diterima')
        .toList();
    const terracotta = Color(0xFFB66E50);
    const coklat = Color(0xFF302820);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF5F0),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PaketKu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: coklat,
              ),
            ),
            Text(
              'Halo, selamat datang!',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92796D),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Color(0xFFF0D9CC),
              child: Icon(Icons.inventory_2_outlined,
                  color: terracotta),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: terracotta,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${daftarPaket.where((paket) => paket['status_pengiriman'] != 'Diterima').length} Paket Aktif',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Semua kirimanmu, satu tempat.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RingkasanCard(
                  icon: Icons.location_on_outlined,
                  jumlah: daftarPaket
                      .where((paket) => paket['status_pengiriman'] == 'Dalam Perjalanan')
                      .length
                      .toString(),
                  label: 'Dalam Perjalanan',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: RingkasanCard(
                  icon: Icons.local_shipping_outlined,
                  jumlah: daftarPaket
                      .where((paket) => paket['status_pengiriman'] == 'Dikirim')
                      .length
                      .toString(),
                  label: 'Dikirim',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Paket Aktif',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: coklat,
            ),
          ),
          const SizedBox(height: 4),
          if (paketAktif.isNotEmpty)
          const Text(
            'Ketuk untuk mengubah status secara manual',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF92796D),
            ),
          ),
          const SizedBox(height: 14),

          if (sedangMemuat)
            const Center(child: CircularProgressIndicator())

          else if (paketAktif.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4ED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 76,
                      color: Color(0xFFB66E50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada paket nih!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF302820),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum ada paket yang kamu catat.\n'
                        'Semua paketmu nanti akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF92796D),
                      height: 1.5,
                    ),
                  ),

                ],
              ),
            )

          else
            ...paketAktif.map((paket) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PaketCard(
                paket: paket,
                onRefresh: muatPaket,
                nama: paket['nama_barang']?.toString() ?? '',
                marketplace: paket['marketplace']?.toString() ?? '',
                status: paket['status_pengiriman']?.toString() ?? '',
                pembayaran: paket['metode_pembayaran']?.toString() ?? '',
                estimasi: formatTanggal(paket['estimasi_sampai']?.toString()),
              ),
            )),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahPaketPage(),
              ),
            ).then((_) {
              debugPrint('BERANDA: memuat ulang paket');
              if (mounted) {
                muatPaket();
              }
            });
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryPage(),
              ),
            ).then((_) {
              if (mounted) {
                muatPaket();
              }
            });
          }
        },
        currentIndex: 0,
        selectedItemColor: terracotta,
        unselectedItemColor: const Color(0xFF92796D),
        backgroundColor: Colors.white,
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

class RingkasanCard extends StatelessWidget {
  final IconData icon;
  final String jumlah;
  final String label;

  const RingkasanCard({
    super.key,
    required this.icon,
    required this.jumlah,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB66E50), size: 20),
          const SizedBox(width: 8),
          Text(
            jumlah,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class PaketCard extends StatelessWidget {
  final Map<String, dynamic> paket;
  final VoidCallback onRefresh;
  final String nama;
  final String marketplace;
  final String status;
  final String pembayaran;
  final String estimasi;

  const PaketCard({
    super.key,
    required this.paket,
    required this.onRefresh,
    required this.nama,
    required this.marketplace,
    required this.status,
    required this.pembayaran,
    required this.estimasi,

  });

  @override
  Widget build(BuildContext context) {
    final bool perjalanan = status == 'Dalam Perjalanan';

    return InkWell(
      onTap: () async {
        final berhasil = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPaketPage(paket: paket),
          ),
        );

        if (berhasil == true) {
          onRefresh();
        }
      },
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                marketplace,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF92796D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: perjalanan
                      ? const Color(0xFFF6E4D9)
                      : const Color(0xFFE6EDFA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: perjalanan
                        ? const Color(0xFFA76246)
                        : const Color(0xFF5474A2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF92796D),
                      ),
                    ),
                    Text(
                      pembayaran,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Estimasi Sampai',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF92796D),
                      ),
                    ),
                    Text(
                      estimasi,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
        ),
    );
  }
}
