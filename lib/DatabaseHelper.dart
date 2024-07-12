import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    final path = join(await getDatabasesPath(), 'stories.db');
    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE Stories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          storyText TEXT,
          imagePaths TEXT
        )
      ''');
    });
  }

  Future<int> saveStory(String title, String storyText, List<String> imagePaths) async {
    final db = await database;
    return await db.insert('Stories', {
      'title': title,
      'storyText': storyText,
      'imagePaths': imagePaths.join(',')
    });
  }

  Future<int> deleteStory(int id) async {
    final db = await database;
    return await db.delete('Stories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getStories() async {
    final db = await database;
    return await db.query('Stories');
  }

  Future<bool> storyExists(String title, String storyText) async {
    final db = await database;
    var res = await db.query(
      'Stories',
      where: 'title = ? AND storyText = ?',
      whereArgs: [title, storyText],
    );
    return res.isNotEmpty;
  }
}
