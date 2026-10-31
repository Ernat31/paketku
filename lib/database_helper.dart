
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('paketku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }


  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE paket (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_barang TEXT NOT NULL,
      marketplace TEXT NOT NULL,
      tanggal_pemesanan TEXT NOT NULL,
      estimasi_sampai TEXT NOT NULL,
      status_pengiriman TEXT NOT NULL,
      metode_pembayaran TEXT NOT NULL,
      status_pembayaran TEXT NOT NULL,
      supabase_id INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'pending'
    )
  ''');

    await db.execute('''
    CREATE TABLE antrean_hapus (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supabase_id INTEGER NOT NULL UNIQUE
    )
  ''');
  }



  Future<void> _upgradeDB(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE paket ADD COLUMN supabase_id INTEGER',
      );
      await db.execute(
        "ALTER TABLE paket ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'pending'",
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE antrean_hapus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supabase_id INTEGER NOT NULL UNIQUE
      )
    ''');
    }
  }



  Future<int> tambahPaket(Map<String, dynamic> data) async {
    final db = await database;

    final dataBaru = Map<String, dynamic>.from(data);

    dataBaru.remove('id');
    dataBaru.remove('supabase_id');
    dataBaru['sync_status'] = 'pending';

    final id = await db.insert('paket', dataBaru);

    try {
      await sinkronkanPaket();
    } catch (e) {
      debugPrint('Paket disimpan offline: $e');
    }

    return id;
  }


  Future<List<Map<String, dynamic>>> ambilSemuaPaket() async {
    final db = await database;
    return await db.query('paket', orderBy: 'id DESC');
  }

  Future<int> ubahPaket(int id,
      Map<String, dynamic> data,) async {
    final db = await database;

    final dataBaru = Map<String, dynamic>.from(data);
    dataBaru['sync_status'] = 'pending';

    return await db.update(
      'paket',
      dataBaru,
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<int> hapusPaket(int id) async {
    final db = await database;

    final hasil = await db.query(
      'paket',
      columns: ['supabase_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (hasil.isEmpty) return 0;

    final supabaseId = hasil.first['supabase_id'] as int?;

    await db.transaction((txn) async {
      if (supabaseId != null) {
        await txn.insert(
          'antrean_hapus',
          {'supabase_id': supabaseId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await txn.delete(
        'paket',
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    try {
      await sinkronkanPenghapusan();
    } catch (e) {
      debugPrint('Penghapusan menunggu koneksi: $e');
    }

    return 1;
  }




  Future<void> sinkronkanPaket() async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      return;
    }

    final db = await database;

    final paketPending = await db.query(
      'paket',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    debugPrint('JUMLAH PAKET PENDING: ${paketPending.length}');
    debugPrint('DATA PAKET PENDING: $paketPending');

    for (final paket in paketPending) {
      try {
        final data = {
          'nama_barang': paket['nama_barang'],
          'marketplace': paket['marketplace'],
          'tanggal_pemesanan': paket['tanggal_pemesanan'],
          'estimasi_sampai': paket['estimasi_sampai'],
          'status_pengiriman': paket['status_pengiriman'],
          'metode_pembayaran': paket['metode_pembayaran'],
          'status_pembayaran': paket['status_pembayaran'],
        };

        final supabaseId = paket['supabase_id'];

        if (supabaseId == null) {
          final hasil = await supabase
              .from('paket')
              .insert(data)
              .select('id')
              .single();

          await db.update(
            'paket',
            {
              'supabase_id': hasil['id'],
              'sync_status': 'synced',
            },
            where: 'id = ?',
            whereArgs: [paket['id']],
          );
        } else {
          await supabase
              .from('paket')
              .update(data)
              .eq('id', supabaseId)
              .select('id')
              .single();

          await db.update(
            'paket',
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [paket['id']],
          );
        }

        debugPrint('Paket berhasil disinkronkan');
      } catch (e) {
        debugPrint('Sinkronisasi gagal: $e');
      }
    }
  }


  Future<void> sinkronkanPenghapusan() async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) return;

    final db = await database;
    final antrean = await db.query('antrean_hapus');

    for (final item in antrean) {
      final supabaseId = item['supabase_id'] as int;

      try {
        await supabase
            .from('paket')
            .delete()
            .eq('id', supabaseId);

        await db.delete(
          'antrean_hapus',
          where: 'id = ?',
          whereArgs: [item['id']],
        );

        debugPrint('Penghapusan tersinkronisasi: $supabaseId');
      } catch (e) {
        debugPrint('Penghapusan belum tersinkronisasi: $e');
      }
    }
  }

}
