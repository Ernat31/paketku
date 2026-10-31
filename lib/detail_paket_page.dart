import 'package:flutter/material.dart';
import 'tambah_paket_page.dart';
import 'database_helper.dart';

class DetailPaketPage extends StatelessWidget {
  final Map<String, dynamic> paket;

  const DetailPaketPage({
    super.key,
    required this.paket,
  });

  static const terracotta = Color(0xFFB66E50);
  static const coklat = Color(0xFF302820);
  static const ivory = Color(0xFFFAF5F0);
  static const peach = Color(0xFFF0D9CC);
  static const abu = Color(0xFF92796D);

  String ambilData(String key) {
    final nilai = paket[key]?.toString();
    return nilai == null || nilai.isEmpty ? '-' : nilai;
  }

  String formatTanggal(String key) {
    final nilai = paket[key]?.toString();

    if (nilai == null || nilai.isEmpty) return '-';

    final tanggal = DateTime.tryParse(nilai);
    if (tanggal == null) return nilai;

    const bulan = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Widget barisInfo(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: abu,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: coklat,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ambilData('status_pengiriman');

    return Scaffold(
      backgroundColor: ivory,

      appBar: AppBar(
        title: Text(
          paket['status_pengiriman'] == 'Diterima'
              ? 'Detail Paket Diterima'
              : 'Detail Paket',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: coklat,
          ),
        ),
        centerTitle: true,
        backgroundColor: ivory,
        foregroundColor: coklat,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  // Ilustrasi paket
                  Container(
                    width: double.infinity,
                    height: 115,
                    decoration: BoxDecoration(
                      color: peach,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: terracotta,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nama barang
                  Text(
                    ambilData('nama_barang'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: coklat,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Badge status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'Diterima'
                          ? const Color(0xFFE3F1E7)
                          : status == 'Dikirim'
                          ? const Color(0xFFDBEAFE)
                          : peach,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '• $status',
                      style: TextStyle(
                        fontSize: 11,
                        color: status == 'Diterima'
                            ? const Color(0xFF47845C)
                            : status == 'Dikirim'
                            ? const Color(0xFF2563EB)
                            : terracotta,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  barisInfo(
                    'Marketplace',
                    ambilData('marketplace'),
                  ),

                  const Divider(height: 1, color: ivory),

                  barisInfo(
                    'Tanggal Pemesanan',
                      formatTanggal('tanggal_pemesanan')
                  ),

                  const Divider(height: 1, color: ivory),

                  barisInfo(
                    'Estimasi Sampai',
                    formatTanggal('estimasi_sampai'),
                  ),

                  const Divider(height: 1, color: ivory),

                  barisInfo(
                    'Metode Pembayaran',
                    ambilData('metode_pembayaran'),
                  ),

                  const Divider(height: 1, color: ivory),

                  barisInfo(
                    'Status Pembayaran',
                    ambilData('status_pembayaran'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (paket['status_pengiriman'] != 'Diterima')
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                  onPressed: () async {
                    final berhasil = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahPaketPage(paket: paket),
                      ),
                    );

                    if (context.mounted && berhasil == true) {
                      Navigator.pop(context, true);
                    }
                  },

                style: ElevatedButton.styleFrom(
                  backgroundColor: terracotta,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Paket',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tombol Hapus
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  final konfirmasi = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Hapus Paket?'),
                      content: const Text(
                        'Paket ini akan dihapus secara permanen. '
                            'Yakin ingin melanjutkan?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Color(0xFFB66E50)),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (konfirmasi != true || !context.mounted) return;

                  try {
                    await DatabaseHelper.instance.hapusPaket(
                      paket['id'] as int,
                    );

                    if (!context.mounted) return;

                    Navigator.pop(context, true);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus paket: $e'),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: terracotta,
                  side: const BorderSide(color: terracotta),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hapus Paket',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}