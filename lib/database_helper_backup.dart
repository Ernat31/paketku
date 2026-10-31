
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: _createDB,
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
        status_pembayaran TEXT NOT NULL
      )
    ''');
  }

  Future<int> tambahPaket(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('paket', data);
  }

  Future<List<Map<String, dynamic>>> ambilSemuaPaket() async {
    final db = await database;
    return await db.query('paket', orderBy: 'id DESC');
  }

  Future<int> ubahPaket(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'paket',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapusPaket(int id) async {
    final db = await database;

    return await db.delete(
      'paket',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
