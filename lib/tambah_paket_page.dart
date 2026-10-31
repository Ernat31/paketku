
import 'package:flutter/material.dart';
import 'database_helper.dart';

class TambahPaketPage extends StatefulWidget {
  final Map<String, dynamic>? paket;

  const TambahPaketPage({
    super.key,
    this.paket,
  });

  @override
  State<TambahPaketPage> createState() => _TambahPaketPageState();
}

class _TambahPaketPageState extends State<TambahPaketPage> {
  static const terracotta = Color(0xFFB66E50);
  static const coklat = Color(0xFF302820);
  static const ivory = Color(0xFFFAF5F0);

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  String? marketplace;
  String? statusPengiriman;
  String? metodePembayaran;
  String? statusPembayaran;
  DateTime? tanggalPemesanan;
  DateTime? estimasiSampai;

  @override
  void initState() {
    super.initState();

    final paket = widget.paket;

    if (paket != null) {
      _namaController.text = paket['nama_barang']?.toString() ?? '';
      marketplace = paket['marketplace']?.toString();
      statusPengiriman = paket['status_pengiriman']?.toString();
      metodePembayaran = paket['metode_pembayaran']?.toString();
      statusPembayaran = paket['status_pembayaran']?.toString();

      tanggalPemesanan = DateTime.tryParse(
        paket['tanggal_pemesanan']?.toString() ?? '',
      );

      estimasiSampai = DateTime.tryParse(
        paket['estimasi_sampai']?.toString() ?? '',
      );
    }
  }
  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  String formatTanggal(DateTime? tanggal) {
    if (tanggal == null) return 'Pilih tanggal';
    return '${tanggal.day.toString().padLeft(2, '0')}/'
        '${tanggal.month.toString().padLeft(2, '0')}/'
        '${tanggal.year}';
  }

  Future<void> pilihTanggal(bool pemesanan) async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: pemesanan
          ? (tanggalPemesanan ?? DateTime.now())
          : (estimasiSampai ?? tanggalPemesanan ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (hasil != null) {
      setState(() {
        if (pemesanan) {
          tanggalPemesanan = hasil;
        } else {
          estimasiSampai = hasil;
        }
      });
    }
  }

  Widget judulField(String judul) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        judul,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: coklat,
        ),
      ),
    );
  }

  InputDecoration dekorasi(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFB3A49B),
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget dropdownField(
      String judul,
      String? nilai,
      List<String> pilihan,
      ValueChanged<String?> onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        judulField(judul),
        DropdownButtonFormField<String>(
          initialValue: nilai,
          isExpanded: true,
          decoration: dekorasi('Pilih $judul'),
          items: pilihan.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) =>
          value == null ? '$judul wajib dipilih' : null,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget tanggalField(String judul, DateTime? nilai, bool pemesanan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        judulField(judul),
        InkWell(
          onTap: () => pilihTanggal(pemesanan),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTanggal(nilai),
                  style: TextStyle(
                    fontSize: 13,
                    color: nilai == null
                        ? const Color(0xFFB3A49B)
                        : coklat,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: terracotta,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }


  Future<void> simpanPaket() async {
    if (!_formKey.currentState!.validate()) return;

    if (tanggalPemesanan == null || estimasiSampai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi kedua tanggal dahulu'),
        ),
      );
      return;
    }

    if (estimasiSampai!.isBefore(tanggalPemesanan!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estimasi tidak boleh sebelum tanggal pemesanan'),
        ),
      );
      return;
    }

    final dataPaket = {
      'nama_barang': _namaController.text.trim(),
      'marketplace': marketplace!,
      'tanggal_pemesanan':
      tanggalPemesanan!.toIso8601String(),
      'estimasi_sampai':
      estimasiSampai!.toIso8601String(),
      'status_pengiriman': statusPengiriman!,
      'metode_pembayaran': metodePembayaran!,
      'status_pembayaran': statusPembayaran!,
    };

    try {
      if (widget.paket == null) {
        await DatabaseHelper.instance.tambahPaket(dataPaket);
      } else {
        await DatabaseHelper.instance.ubahPaket(
          widget.paket!['id'] as int,
          dataPaket,
        );
        await DatabaseHelper.instance.sinkronkanPaket();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paket berhasil disimpan!'),
          backgroundColor: Color(0xFF47845C),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan paket: $e'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        title: Text(
          widget.paket == null ? 'Tambah Paket' : 'Edit Paket',
          style: TextStyle(
            color: coklat,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
             Text(
              widget.paket == null
                  ? 'Yuk, catat paket barumu!'
                  : 'Yuk, perbarui informasi paketmu!',
              style: TextStyle(
                color: Color(0xFF92796D),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            judulField('Nama Barang'),
            TextFormField(
              controller: _namaController,
              decoration: dekorasi('Contoh: Skincare wajah'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            dropdownField(
              'Marketplace',
              marketplace,
              ['Shopee', 'TikTok Shop', 'Tokopedia', 'Lazada', 'Lainnya'],
                  (value) => setState(() => marketplace = value),
            ),
            tanggalField(
              'Tanggal Pemesanan',
              tanggalPemesanan,
              true,
            ),
            tanggalField(
              'Estimasi Sampai',
              estimasiSampai,
              false,
            ),
            dropdownField(
              'Status Pengiriman',
              statusPengiriman,
              ['Dikirim', 'Dalam Perjalanan', 'Diterima'],
                  (value) => setState(() => statusPengiriman = value),
            ),
            dropdownField(
              'Metode Pembayaran',
              metodePembayaran,
              ['COD', 'PayLater', 'Transfer', 'E-Wallet', 'QRIS'],
                  (value) => setState(() => metodePembayaran = value),
            ),
            dropdownField(
              'Status Pembayaran',
              statusPembayaran,
              ['Belum Dibayar', 'Sudah Dibayar'],
                  (value) => setState(() => statusPembayaran = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: simpanPaket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: terracotta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:  Text(
                  widget.paket == null ? 'Simpan Paket' : 'Simpan Perubahan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Catatan paketmu bisa diedit kapan saja.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF92796D),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
