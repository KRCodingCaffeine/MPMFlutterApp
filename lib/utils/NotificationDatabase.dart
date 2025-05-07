import 'package:mpm/model/notification/NotificationModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class NotificationDatabase {
  static final NotificationDatabase instance = NotificationDatabase._init();
  static Database? _database;
  NotificationDatabase._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        image TEXT,
        timestamp TEXT,
        isRead INTEGER
      )
    ''');
  }
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await instance.database;
    final result = await db.query('notifications', orderBy: 'timestamp DESC');
    return result.map((json) => NotificationModel.fromMap(json)).toList();
  }

  Future<void> deleteAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }
  // Future<void> markNotificationAsRead(Map<String, dynamic> data) async {
  //   final db = await database;
  //   await db.update(
  //     'notifications',
  //     {'isRead': 1},
  //     where: 'timestamp = ?',
  //     whereArgs: [data['timestamp']], // or use another unique field
  //   );
  // }
  Future<void> markAllNotificationsAsRead() async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'isRead = 0',
    );
  }

  Future<int> getUnreadNotificationCount() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) FROM notifications WHERE isRead = 0");
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}