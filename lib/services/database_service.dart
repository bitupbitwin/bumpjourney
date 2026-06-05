import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/models.dart';

/// 本地优先(Local-First)存储。孕期敏感数据仅存于设备本地。
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  /// 当前数据库 schema 版本。新增表 / 字段时 +1,并在 [_migrations] 中登记升级步骤。
  static const int dbVersion = 4;

  /// 待产包标准模板(首次建表时注入)。
  static const Map<String, List<String>> checklistTemplate = {
    '证件': ['身份证(夫妻双方)', '医保卡 / 社保卡', '产检本 / 病历', '银行卡 / 少量现金', '准生证(按当地)'],
    '妈妈': [
      '哺乳内衣 2-3 件',
      '月子服 / 睡衣',
      '产褥垫 + 一次性内裤',
      '防滑拖鞋、毛巾牙具',
      '吸奶器 + 乳头膏',
      '保温杯、加餐零食(巧克力)',
      '充电器 / 充电宝',
    ],
    '宝宝': [
      '新生儿连体衣 / 和尚服',
      '包被 / 抱被',
      '纸尿裤(NB 码)+ 湿巾',
      '隔尿垫、口水巾',
      '奶瓶 + 小勺',
      '帽子、袜子',
    ],
  };

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
      options: OpenDatabaseOptions(
        version: dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
    return _db!;
  }

  // ============================================================
  // 迁移框架
  // ------------------------------------------------------------
  // 每个版本号对应一段「从上一版升级到本版」的 SQL。全新安装时在 onCreate
  // 里建好 v1 基础表后,顺序跑一遍 2..dbVersion 的迁移即可达到最新结构;
  // 老用户升级时,onUpgrade 只跑 oldVersion+1 到 newVersion 之间的迁移。
  // 后续加表 / 加字段:dbVersion +1,在此登记一条即可,新老用户都安全。
  // ============================================================
  static final Map<int, Future<void> Function(Database)> _migrations = {
    2: (db) async {
      // 持久化产检 / 老公任务勾选态(此前仅存于内存,重启即丢)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_check_states (
          state_key TEXT PRIMARY KEY
        )
      ''');
      // 胎动计数会话
      await db.execute('''
        CREATE TABLE IF NOT EXISTS fetal_movement_sessions (
          fm_id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          count INTEGER NOT NULL DEFAULT 0
        )
      ''');
      // 宫缩计时记录
      await db.execute('''
        CREATE TABLE IF NOT EXISTS contraction_records (
          ct_id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL
        )
      ''');
    },
    3: (db) async {
      // 体重记录(孕期体重增长曲线)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS weight_records (
          w_id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          weight REAL NOT NULL
        )
      ''');
    },
    4: (db) async {
      // 待产包清单(建表 + 注入标准模板)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS checklist_items (
          cl_id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          title TEXT NOT NULL,
          is_checked INTEGER NOT NULL DEFAULT 0
        )
      ''');
      final batch = db.batch();
      checklistTemplate.forEach((category, items) {
        for (final title in items) {
          batch.insert('checklist_items',
              {'category': category, 'title': title, 'is_checked': 0});
        }
      });
      await batch.commit(noResult: true);
    },
  };

  Future<void> _onCreate(Database db, int version) async {
    await _createBaseSchema(db);
    await _seedDemo(db);
    // 全新安装:把 v1 之后的所有迁移补齐到最新版本
    for (var v = 2; v <= version; v++) {
      await _migrations[v]?.call(db);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      await _migrations[v]?.call(db);
    }
  }

  /// v1 基础表(自定义事件 + 知识库)。
  Future<void> _createBaseSchema(Database db) async {
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

  // ---------- 勾选态(产检 / 老公任务) ----------
  Future<Set<String>> getCheckStates() async {
    final db = await _database;
    final rows = await db.query('user_check_states');
    return rows.map((r) => r['state_key'] as String).toSet();
  }

  Future<void> setCheckState(String key, bool present) async {
    final db = await _database;
    if (present) {
      await db.insert('user_check_states', {'state_key': key},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db.delete('user_check_states', where: 'state_key = ?', whereArgs: [key]);
    }
  }

  // ---------- 胎动计数 ----------
  Future<List<FetalMovementSession>> getFetalSessions() async {
    final db = await _database;
    final rows = await db.query('fetal_movement_sessions', orderBy: 'start_time DESC');
    return rows.map(FetalMovementSession.fromMap).toList();
  }

  Future<int> insertFetalSession(FetalMovementSession s) async {
    final db = await _database;
    return db.insert('fetal_movement_sessions', s.toMap());
  }

  Future<void> deleteFetalSession(int id) async {
    final db = await _database;
    await db.delete('fetal_movement_sessions', where: 'fm_id = ?', whereArgs: [id]);
  }

  // ---------- 宫缩计时 ----------
  Future<List<ContractionRecord>> getContractions() async {
    final db = await _database;
    final rows = await db.query('contraction_records', orderBy: 'start_time ASC');
    return rows.map(ContractionRecord.fromMap).toList();
  }

  Future<int> insertContraction(ContractionRecord c) async {
    final db = await _database;
    return db.insert('contraction_records', c.toMap());
  }

  Future<void> deleteContraction(int id) async {
    final db = await _database;
    await db.delete('contraction_records', where: 'ct_id = ?', whereArgs: [id]);
  }

  Future<void> clearContractions() async {
    final db = await _database;
    await db.delete('contraction_records');
  }

  // ---------- 体重记录 ----------
  Future<List<WeightRecord>> getWeights() async {
    final db = await _database;
    final rows = await db.query('weight_records', orderBy: 'date ASC');
    return rows.map(WeightRecord.fromMap).toList();
  }

  Future<int> insertWeight(WeightRecord w) async {
    final db = await _database;
    return db.insert('weight_records', w.toMap());
  }

  Future<void> deleteWeight(int id) async {
    final db = await _database;
    await db.delete('weight_records', where: 'w_id = ?', whereArgs: [id]);
  }

  // ---------- 待产包清单 ----------
  Future<List<ChecklistItem>> getChecklist() async {
    final db = await _database;
    final rows = await db.query('checklist_items', orderBy: 'cl_id ASC');
    return rows.map(ChecklistItem.fromMap).toList();
  }

  Future<int> insertChecklistItem(ChecklistItem c) async {
    final db = await _database;
    return db.insert('checklist_items', c.toMap());
  }

  Future<void> updateChecklistChecked(int id, bool checked) async {
    final db = await _database;
    await db.update('checklist_items', {'is_checked': checked ? 1 : 0},
        where: 'cl_id = ?', whereArgs: [id]);
  }

  Future<void> deleteChecklistItem(int id) async {
    final db = await _database;
    await db.delete('checklist_items', where: 'cl_id = ?', whereArgs: [id]);
  }
}
