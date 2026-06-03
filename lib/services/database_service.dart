import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/models.dart';

/// 本地优先(Local-First)存储。孕期敏感数据仅存于设备本地。
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  /// 在 main() 中调用一次,初始化桌面端 ffi。
  static void init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'bumpjourney.db');
    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_custom_events (
        event_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        target_date TEXT NOT NULL,
        associated_week INTEGER NOT NULL,
        remind_days_before INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE user_knowledge_base (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        raw_content TEXT,
        source_url TEXT,
        tags TEXT,
        pinned_week INTEGER
      )
    ''');
    await _seedDemo(db);
  }

  /// 首次启动的演示数据,方便你打开即见效果(可随时删除)。
  Future<void> _seedDemo(Database db) async {
    await db.insert('user_custom_events', {
      'title': '拍孕妇照 📷',
      'content': '约好摄影师,挑两套衣服',
      'target_date': DateTime.now().add(const Duration(days: 4)).toIso8601String(),
      'associated_week': 16,
      'remind_days_before': 3,
      'is_completed': 0,
    });
    await db.insert('user_knowledge_base', {
      'title': 'XX 妇幼建档全流程攻略',
      'raw_content':
          '【时间】孕 12 周内 · 【证件】身份证+社保卡+早孕报告 · 【费用】约 ¥200 · 【步骤】抽血→B超→建小卡→建大卡',
      'source_url': '小红书 · AI 已提炼',
      'tags': '#建档',
      'pinned_week': 16,
    });
    await db.insert('user_knowledge_base', {
      'title': '控糖食谱:一周不重样',
      'raw_content': '低 GI 主食搭配,餐后散步 20 分钟,避免果汁,水果放两餐之间。',
      'source_url': '公众号 · 手动收藏',
      'tags': '#控糖食谱',
      'pinned_week': 24,
    });
  }

  // ---------- 自定义事件 ----------
  Future<List<CustomEvent>> getEvents() async {
    final db = await _database;
    final rows = await db.query('user_custom_events', orderBy: 'target_date ASC');
    return rows.map(CustomEvent.fromMap).toList();
  }

  Future<int> insertEvent(CustomEvent e) async {
    final db = await _database;
    return db.insert('user_custom_events', e.toMap());
  }

  Future<void> updateEventCompleted(int id, bool done) async {
    final db = await _database;
    await db.update('user_custom_events', {'is_completed': done ? 1 : 0},
        where: 'event_id = ?', whereArgs: [id]);
  }

  Future<void> deleteEvent(int id) async {
    final db = await _database;
    await db.delete('user_custom_events', where: 'event_id = ?', whereArgs: [id]);
  }

  // ---------- 知识库 ----------
  Future<List<KnowledgeItem>> getKnowledge() async {
    final db = await _database;
    final rows = await db.query('user_knowledge_base', orderBy: 'item_id DESC');
    return rows.map(KnowledgeItem.fromMap).toList();
  }

  Future<int> insertKnowledge(KnowledgeItem k) async {
    final db = await _database;
    return db.insert('user_knowledge_base', k.toMap());
  }

  Future<void> deleteKnowledge(int id) async {
    final db = await _database;
    await db.delete('user_knowledge_base', where: 'item_id = ?', whereArgs: [id]);
  }
}
