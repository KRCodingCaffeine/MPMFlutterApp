import 'package:mpm/model/notification/NotificationDataModel.dart';
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
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    } catch (e) {
      print('Database init error: $e');
      rethrow;
    }
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
  Future<void> insertNotification(NotificationDataModel notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationDataModel>> getAllNotifications() async {
    try {
      final db = await instance.database;
      final result = await db.query('notifications', orderBy: 'timestamp DESC');
      return result.map((json) => NotificationDataModel.fromMap(json)).toList();
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  Future<void> deleteAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }

  Future<void> deleteNotificationById(int id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
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
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE isRead = 0'
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Get unread count error: $e');
      return 0;
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}