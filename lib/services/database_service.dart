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
  static const int dbVersion = 5;

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

  /// 新生儿 / 宝妈清单模板(覆盖产前到产后第一年,分子类带建议数量与时机)。
  /// timing:产前 / 月子 / 3M+ / 6M+ / 1M+ / 按需。
  static const List<({String list, String category, String title, String qty, String timing})>
      seedItems = [
    // —— 新生儿:喂养类 ——
    (list: 'newborn', category: '喂养类', title: '玻璃奶瓶 120ml', qty: '1-2个', timing: '产前'),
    (list: 'newborn', category: '喂养类', title: '宽口奶瓶 240ml', qty: '2个', timing: '月子'),
    (list: 'newborn', category: '喂养类', title: '奶瓶刷 + 奶嘴刷', qty: '', timing: '产前'),
    (list: 'newborn', category: '喂养类', title: '蒸汽消毒锅 / 消毒柜', qty: '', timing: '产前'),
    (list: 'newborn', category: '喂养类', title: '恒温调奶器 / 温奶器', qty: '', timing: '月子'),
    (list: 'newborn', category: '喂养类', title: '小罐配方奶粉(应急)', qty: '1罐', timing: '产前'),
    (list: 'newborn', category: '喂养类', title: '硅胶软勺 / 喂药器', qty: '', timing: '月子'),
    (list: 'newborn', category: '喂养类', title: '哺乳枕 / 躺喂枕', qty: '', timing: '月子'),
    (list: 'newborn', category: '喂养类', title: '奶瓶清洁剂', qty: '', timing: '产前'),
    (list: 'newborn', category: '喂养类', title: '备用奶嘴(按月龄)', qty: '', timing: '按需'),
    (list: 'newborn', category: '喂养类', title: '辅食工具(研磨碗/辅食剪/吸盘碗/软勺)', qty: '', timing: '6M+'),
    (list: 'newborn', category: '喂养类', title: '学饮杯 / 吸管杯', qty: '', timing: '6M+'),
    (list: 'newborn', category: '喂养类', title: '婴儿餐椅', qty: '', timing: '6M+'),
    // —— 新生儿:消耗护理类 ——
    (list: 'newborn', category: '消耗护理类', title: 'NB 码纸尿裤(别囤多)', qty: '1包', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: 'S 码纸尿裤', qty: '', timing: '1M+'),
    (list: 'newborn', category: '消耗护理类', title: '棉柔巾(干巾)', qty: '2-3包', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '婴儿湿巾(手口/护臀)', qty: '', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '护臀膏', qty: '', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '隔尿垫(一次性 + 可水洗)', qty: '', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '婴儿面霜 / 身体乳', qty: '', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '抚触油 / 润肤油', qty: '', timing: '月子'),
    (list: 'newborn', category: '消耗护理类', title: '棉签 / 伏棉签', qty: '', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '护脐贴(脐带未脱前)', qty: '', timing: '产前'),
    (list: 'newborn', category: '消耗护理类', title: '碘伏棉棒(脐部护理)', qty: '', timing: '产前'),
    // —— 新生儿:衣物类 ——
    (list: 'newborn', category: '衣物类', title: '和尚服 / 连体衣(52-59码)', qty: '3-5件', timing: '产前'),
    (list: 'newborn', category: '衣物类', title: '包被 / 抱被', qty: '2条', timing: '产前'),
    (list: 'newborn', category: '衣物类', title: '防踢睡袋', qty: '1-2个', timing: '月子'),
    (list: 'newborn', category: '衣物类', title: '胎帽', qty: '2顶', timing: '产前'),
    (list: 'newborn', category: '衣物类', title: '婴儿袜 / 防抓手套', qty: '', timing: '产前'),
    (list: 'newborn', category: '衣物类', title: '纱布浴巾 / 小方巾', qty: '若干', timing: '产前'),
    (list: 'newborn', category: '衣物类', title: '口水巾 / 围嘴', qty: '', timing: '月子'),
    (list: 'newborn', category: '衣物类', title: '大一码衣物(66/73码)', qty: '', timing: '3M+'),
    // —— 新生儿:睡眠类 ——
    (list: 'newborn', category: '睡眠类', title: '婴儿床 / 床中床', qty: '', timing: '产前'),
    (list: 'newborn', category: '睡眠类', title: '硬质婴儿床垫', qty: '', timing: '产前'),
    (list: 'newborn', category: '睡眠类', title: '床品(床单 + 防水隔尿垫)', qty: '', timing: '产前'),
    (list: 'newborn', category: '睡眠类', title: '安抚奶嘴', qty: '', timing: '月子'),
    (list: 'newborn', category: '睡眠类', title: '小夜灯', qty: '', timing: '产前'),
    (list: 'newborn', category: '睡眠类', title: '婴儿监视器(可选)', qty: '', timing: '按需'),
    // —— 新生儿:洗护类 ——
    (list: 'newborn', category: '洗护类', title: '洗澡盆(带浴网/浴架)', qty: '', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '小脸盆(分区使用)', qty: '2-3个', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '婴儿洗发沐浴二合一', qty: '', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '连帽婴儿浴巾', qty: '', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '水温计', qty: '', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '婴儿指甲剪 / 磨甲器', qty: '', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '吸鼻器', qty: '', timing: '按需'),
    (list: 'newborn', category: '洗护类', title: '婴儿洗衣液 / 皂', qty: '', timing: '产前'),
    (list: 'newborn', category: '洗护类', title: '指套牙刷 / 软毛牙刷(出牙后)', qty: '', timing: '6M+'),
    // —— 新生儿:健康医护类 ——
    (list: 'newborn', category: '健康医护类', title: '体温计(耳温/额温)', qty: '', timing: '产前'),
    (list: 'newborn', category: '健康医护类', title: '维生素 D3 滴剂(遵医嘱)', qty: '', timing: '月子'),
    (list: 'newborn', category: '健康医护类', title: '退热贴', qty: '', timing: '按需'),
    (list: 'newborn', category: '健康医护类', title: '生理盐水喷雾 / 海盐水', qty: '', timing: '按需'),
    (list: 'newborn', category: '健康医护类', title: '益生菌(遵医嘱)', qty: '', timing: '按需'),
    (list: 'newborn', category: '健康医护类', title: '家庭小药箱(遵医嘱备)', qty: '', timing: '按需'),
    // —— 新生儿:出行大件类 ——
    (list: 'newborn', category: '出行大件类', title: '婴儿提篮 / 安全座椅(出院即用)', qty: '', timing: '产前'),
    (list: 'newborn', category: '出行大件类', title: '婴儿推车', qty: '', timing: '产前'),
    (list: 'newborn', category: '出行大件类', title: '背带 / 腰凳', qty: '', timing: '3M+'),
    (list: 'newborn', category: '出行大件类', title: '妈咪包 / 外出尿布包', qty: '', timing: '产前'),
    (list: 'newborn', category: '出行大件类', title: '爬行垫', qty: '', timing: '6M+'),
    (list: 'newborn', category: '出行大件类', title: '围栏 / 婴儿游戏床', qty: '', timing: '6M+'),
    // —— 新生儿:玩具早教类 ——
    (list: 'newborn', category: '玩具早教类', title: '黑白卡 / 视觉卡', qty: '', timing: '月子'),
    (list: 'newborn', category: '玩具早教类', title: '床铃 / 健身架', qty: '', timing: '月子'),
    (list: 'newborn', category: '玩具早教类', title: '安抚玩偶 / 牙胶', qty: '', timing: '3M+'),
    // —— 宝妈:衣物类 ——
    (list: 'mom', category: '衣物类', title: '哺乳内衣', qty: '2-3件', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '哺乳睡衣 / 月子服', qty: '2套', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '月子帽', qty: '', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '长筒袜 / 月子袜', qty: '', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '包跟防滑拖鞋', qty: '', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '一次性内裤', qty: '10条+', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '宽松出院衣物', qty: '', timing: '产前'),
    (list: 'mom', category: '衣物类', title: '收腹带 / 骨盆带', qty: '', timing: '月子'),
    // —— 宝妈:产后护理类 ——
    (list: 'mom', category: '产后护理类', title: '产褥垫', qty: '2包', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '产妇 / 超长夜用卫生巾', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '安睡裤', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '刀纸 / 产褥纸', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '会阴冲洗器', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '一次性马桶垫', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '痔疮膏 / 喷雾', qty: '', timing: '按需'),
    (list: 'mom', category: '产后护理类', title: '防溢乳垫(一次性/可洗)', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '乳头膏(羊脂膏)', qty: '', timing: '产前'),
    (list: 'mom', category: '产后护理类', title: '热敷乳贴 / 通乳工具', qty: '', timing: '月子'),
    // —— 宝妈:哺乳类 ——
    (list: 'mom', category: '哺乳类', title: '电动双边吸奶器', qty: '', timing: '产前'),
    (list: 'mom', category: '哺乳类', title: '储奶袋 / 储奶瓶', qty: '', timing: '月子'),
    (list: 'mom', category: '哺乳类', title: '哺乳枕', qty: '', timing: '月子'),
    (list: 'mom', category: '哺乳类', title: '外出哺乳遮巾', qty: '', timing: '按需'),
    // —— 宝妈:个护恢复类 ——
    (list: 'mom', category: '个护恢复类', title: '软毛牙刷 + 漱口水', qty: '', timing: '产前'),
    (list: 'mom', category: '个护恢复类', title: '温和护肤品 / 润唇膏', qty: '', timing: '产前'),
    (list: 'mom', category: '个护恢复类', title: '吸管杯(产后躺着喝水)', qty: '', timing: '产前'),
    (list: 'mom', category: '个护恢复类', title: '免洗洗发帽 / 发圈', qty: '', timing: '月子'),
    (list: 'mom', category: '个护恢复类', title: '盆底肌康复(遵医嘱)', qty: '', timing: '按需'),
    (list: 'mom', category: '个护恢复类', title: '产后 42 天复查', qty: '', timing: '月子'),
    // —— 宝妈:营养补剂类 ——
    (list: 'mom', category: '营养补剂类', title: '钙片 / 铁剂(遵医嘱)', qty: '', timing: '月子'),
    (list: 'mom', category: '营养补剂类', title: '哺乳期复合维生素 / DHA', qty: '', timing: '月子'),
    (list: 'mom', category: '营养补剂类', title: '月子餐 / 催乳汤食材', qty: '', timing: '月子'),
    // —— 宝妈:心理其他 ——
    (list: 'mom', category: '心理其他', title: '关注产后情绪(警惕产后抑郁)', qty: '', timing: '月子'),
    (list: 'mom', category: '心理其他', title: '纪念物 / 记录本', qty: '', timing: '按需'),
  ];

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
    5: (db) async {
      // 清单泛化:支持多份清单 + 数量/时机/排序;并注入新生儿、宝妈两套模板
      await db.execute(
          "ALTER TABLE checklist_items ADD COLUMN list_key TEXT NOT NULL DEFAULT 'hospital_bag'");
      await db.execute('ALTER TABLE checklist_items ADD COLUMN qty TEXT');
      await db.execute('ALTER TABLE checklist_items ADD COLUMN timing TEXT');
      await db.execute(
          'ALTER TABLE checklist_items ADD COLUMN sort INTEGER NOT NULL DEFAULT 0');
      await seedChecklistTemplate(db, 'newborn');
      await seedChecklistTemplate(db, 'mom');
    },
  };

  /// 为指定清单注入标准模板(供 v5 迁移与「恢复默认」复用)。
  /// 注:hospital_bag 的模板在 v4 迁移中已注入,此处主要服务 newborn / mom;
  /// 「恢复默认」时三者均可走此方法重建。
  /// 必须为 static —— v5 迁移在静态 [_migrations] 闭包中调用它(无 this)。
  static Future<void> seedChecklistTemplate(Database db, String listKey) async {
    final batch = db.batch();
    var sort = 0;
    if (listKey == 'hospital_bag') {
      checklistTemplate.forEach((category, items) {
        for (final title in items) {
          batch.insert('checklist_items', {
            'list_key': 'hospital_bag',
            'category': category,
            'title': title,
            'is_checked': 0,
            'sort': sort++,
          });
        }
      });
    } else {
      for (final it in seedItems.where((e) => e.list == listKey)) {
        batch.insert('checklist_items', {
          'list_key': listKey,
          'category': it.category,
          'title': it.title,
          'qty': it.qty.isEmpty ? null : it.qty,
          'timing': it.timing.isEmpty ? null : it.timing,
          'is_checked': 0,
          'sort': sort++,
        });
      }
    }
    await batch.commit(noResult: true);
  }

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

  // ---------- 清单(待产包 / 新生儿 / 宝妈) ----------
  Future<List<ChecklistItem>> getChecklist() async {
    final db = await _database;
    final rows =
        await db.query('checklist_items', orderBy: 'list_key ASC, sort ASC, cl_id ASC');
    return rows.map(ChecklistItem.fromMap).toList();
  }

  /// 恢复某份清单为默认模板:删除该 list_key 全部条目后重新注入。
  Future<void> resetChecklist(String listKey) async {
    final db = await _database;
    await db.delete('checklist_items', where: 'list_key = ?', whereArgs: [listKey]);
    await seedChecklistTemplate(db, listKey);
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
