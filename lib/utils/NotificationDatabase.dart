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
      return await openDatabase(
        path, 
        version: 2, // Increment version to trigger migration
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
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
        isRead INTEGER,
        type TEXT,
        actionUrl TEXT,
        serverId TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute('ALTER TABLE notifications ADD COLUMN type TEXT');
      await db.execute('ALTER TABLE notifications ADD COLUMN actionUrl TEXT');
      await db.execute('ALTER TABLE notifications ADD COLUMN serverId TEXT');
    }
  }
  Future<void> insertNotification(NotificationDataModel notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationDataModel>> getAllNotifications() async {
    try {
      final db = await instance.database;
      // Sort by timestamp DESC to show latest notifications first
      final result = await db.query(
        'notifications', 
        orderBy: 'timestamp DESC, id DESC' // Secondary sort by ID for consistency
      );
      return result.map((json) => NotificationDataModel.fromMap(json)).toList();
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  Future<void> deleteAllNotifications() async {
    final db = await instance.database;
    final result = await db.delete('notifications');
    print('🗑️ Deleted $result notifications from database');
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

  /// Get unread notification count by type (e.g., "event", "offer", "default")
  Future<int> getUnreadNotificationCountByType(String type) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE isRead = 0 AND type = ?',
        [type]
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('📊 Unread count for type "$type": $count');
      
      // Debug: List all notifications of this type
      final allOfType = await db.query(
        'notifications',
        where: 'type = ?',
        whereArgs: [type],
      );
      final unreadOfType = await db.query(
        'notifications',
        where: 'isRead = 0 AND type = ?',
        whereArgs: [type],
      );
      print('📊 Type "$type": Total=${allOfType.length}, Unread=${unreadOfType.length}');
      for (final notif in unreadOfType) {
        print('  - Unread: ${notif['title']} (ID: ${notif['id']}, ServerID: ${notif['serverId']}, Read: ${notif['isRead']})');
      }
      
      return count;
    } catch (e) {
      print('Get unread count by type error: $e');
      return 0;
    }
  }

  /// Mark all notifications as read by type
  /// Returns the number of notifications updated
  Future<int> markNotificationsAsReadByType(String type) async {
    try {
      final db = await database;
      final count = await db.update(
        'notifications',
        {'isRead': 1},
        where: 'isRead = 0 AND type = ?',
        whereArgs: [type],
      );
      print('✅ Marked $count $type notifications as read');
      return count;
    } catch (e) {
      print('❌ Error marking notifications as read by type: $e');
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

  // Method to reset database (useful for testing or if migration fails)
  Future<void> resetDatabase() async {
    try {
      final db = await instance.database;
      await db.close();
      _database = null;
      // Delete the database file
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'notifications.db');
      await deleteDatabase(path);
      // Recreate database
      await database;
      print('Database reset successfully');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }
}