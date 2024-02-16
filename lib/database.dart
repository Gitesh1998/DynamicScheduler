import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  DatabaseHelper();
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database_name.db');
    bool databaseExist = await databaseExists(path);

    if (!databaseExist) {
      // If the database does not exist, create it and execute _createDb
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: createDb,
      );
    } else {
      // If the database exists, simply open it
      _database = await openDatabase(path);
    }

    return _database!;
  }

  Future<void> createDb(Database db, int version) async {
    // Check if the 'items' table already exists
    var tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='items'");

    if (tableExists.isEmpty) {
      print("here");
      // If the 'items' table does not exist, create it
      await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    } else {
      print(" now here");

      // If the table exists but is empty, insert initial data
      var rowCount = Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM items"));

      if (rowCount == 0) {
        // Insert initial data (you can customize this based on your requirements)
        await db.insert('items', {'name': 'Initial Item 1'});
      }
    }
  }

  Future<void> insertItem(String name) async {
    final db = await database;
    await db.insert(
      'items',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (index) {
      return maps[index]['name'];
    });
  }

  Future<void> deleteItem(String name) async {
    final db = await database;
    await db.delete(
      'items',
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
