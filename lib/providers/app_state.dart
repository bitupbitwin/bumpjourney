import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  final _db = DatabaseService.instance;

  /// 足月妊娠天数(末次月经起算 280 天 ≈ 40 周)。
  static const int fullTermDays = 280;
  static const String _dueDateKey = 'due_date';

  // —— 孕期基准 —— 可由「我的」页按 预产期 / 末次月经 / B超孕周 设定,已持久化
  DateTime dueDate = DateTime.now().add(const Duration(days: 107));

  int get currentWeek => weekForDate(DateTime.now());

  /// 任意日期对应的孕周(用于体重曲线等按日期定位)。
  int weekForDate(DateTime d) {
    final daysToDue = dueDate.difference(d).inDays;
    final w = 40 - (daysToDue / 7).round();
    return w.clamp(1, 40);
  }

  int get daysLeft => dueDate.difference(DateTime.now()).inDays;

  // —— 选中态 ——
  late int selectedWeek = currentWeek;
  AppRole role = AppRole.mom;

  List<CustomEvent> _events = [];
  List<KnowledgeItem> _knowledge = [];
  Set<String> _checkStates = {};
  List<FetalMovementSession> _fetalSessions = [];
  List<ContractionRecord> _contractions = [];
  List<WeightRecord> _weights = [];
  List<ChecklistItem> _checklist = [];

  List<CustomEvent> get allEvents => _events;
  List<KnowledgeItem> get allKnowledge => _knowledge;
  List<FetalMovementSession> get fetalSessions => _fetalSessions;
  List<ContractionRecord> get contractions => _contractions;
  List<WeightRecord> get weights => _weights;
  List<ChecklistItem> get checklist => _checklist;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_dueDateKey);
    if (stored != null) {
      dueDate = DateTime.tryParse(stored) ?? dueDate;
      selectedWeek = currentWeek;
    }
    _events = await _db.getEvents();
    _knowledge = await _db.getKnowledge();
    _checkStates = await _db.getCheckStates();
    _fetalSessions = await _db.getFetalSessions();
    _contractions = await _db.getContractions();
    _weights = await _db.getWeights();
    _checklist = await _db.getChecklist();
    notifyListeners();
    NotificationService.instance.rescheduleAll(_events);
  }

  // —— 待产包清单 ——
  Future<void> toggleChecklistItem(ChecklistItem item) async {
    if (item.id == null) return;
    final next = !item.checked;
    await _db.updateChecklistChecked(item.id!, next);
    final i = _checklist.indexWhere((x) => x.id == item.id);
    if (i >= 0) _checklist[i] = item.copyWith(checked: next);
    notifyListeners();
  }

  Future<void> addChecklistItem(String category, String title) async {
    final item = ChecklistItem(category: category, title: title);
    final id = await _db.insertChecklistItem(item);
    _checklist.add(ChecklistItem(id: id, category: category, title: title));
    notifyListeners();
  }

  Future<void> deleteChecklistItem(int id) async {
    await _db.deleteChecklistItem(id);
    _checklist.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  // —— 孕期基准设定(三种方式),均持久化 ——
  Future<void> setDueDate(DateTime d) async {
    dueDate = DateTime(d.year, d.month, d.day);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dueDateKey, dueDate.toIso8601String());
    selectedWeek = currentWeek;
    notifyListeners();
  }

  /// 按末次月经(LMP)推算:预产期 = LMP + 280 天。
  Future<void> setDueDateFromLmp(DateTime lmp) =>
      setDueDate(lmp.add(const Duration(days: fullTermDays)));

  /// 按 B 超孕周推算:已知某次 B 超日期及当时孕周(周+天)。
  /// 等效末次月经 = 检查日 -(周*7+天),预产期 = 等效 LMP + 280 天。
  Future<void> setDueDateFromBScan(DateTime scanDate, int weeks, int days) {
    final gestDays = weeks * 7 + days;
    final lmp = scanDate.subtract(Duration(days: gestDays));
    return setDueDateFromLmp(lmp);
  }

  // —— 体重记录 ——
  Future<void> addWeight(WeightRecord w) async {
    final id = await _db.insertWeight(w);
    _weights.add(WeightRecord(id: id, date: w.date, weightKg: w.weightKg));
    _weights.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> deleteWeight(int id) async {
    await _db.deleteWeight(id);
    _weights.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  // —— 勾选态(产检 / 老公任务),已持久化到 SQLite ——
  bool isChecked(String key) => _checkStates.contains(key);

  void setCheck(String key, bool present) {
    if (present) {
      _checkStates.add(key);
    } else {
      _checkStates.remove(key);
    }
    notifyListeners();
    _db.setCheckState(key, present); // 本地写入,无需阻塞 UI
  }

  // —— 胎动计数 ——
  Future<void> addFetalSession(FetalMovementSession s) async {
    final id = await _db.insertFetalSession(s);
    _fetalSessions.insert(
        0,
        FetalMovementSession(
            id: id, startTime: s.startTime, endTime: s.endTime, count: s.count));
    notifyListeners();
  }

  Future<void> deleteFetalSession(int id) async {
    await _db.deleteFetalSession(id);
    _fetalSessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // —— 宫缩计时(按开始时间升序存,便于推算间隔) ——
  Future<void> addContraction(ContractionRecord c) async {
    final id = await _db.insertContraction(c);
    _contractions.add(ContractionRecord(
        id: id, startTime: c.startTime, endTime: c.endTime));
    _contractions.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
  }

  Future<void> deleteContraction(int id) async {
    await _db.deleteContraction(id);
    _contractions.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> clearContractions() async {
    await _db.clearContractions();
    _contractions = [];
    notifyListeners();
  }

  void selectWeek(int w) {
    selectedWeek = w;
    notifyListeners();
  }

  void goToday() {
    selectedWeek = currentWeek;
    notifyListeners();
  }

  void setRole(AppRole r) {
    role = r;
    notifyListeners();
  }

  // —— 按周筛选 ——
  List<CustomEvent> eventsForWeek(int w) =>
      _events.where((e) => e.associatedWeek == w).toList();

  List<KnowledgeItem> knowledgeForWeek(int w) =>
      _knowledge.where((k) => k.pinnedWeek == w).toList();

  // —— 写操作 ——
  Future<void> addEvent(CustomEvent e) async {
    final id = await _db.insertEvent(e);
    final saved = e.copyWith(id: id);
    _events.add(saved);
    notifyListeners();
    await NotificationService.instance.scheduleEvent(saved);
  }

  Future<void> toggleEvent(CustomEvent e) async {
    if (e.id == null) return;
    final nowCompleted = !e.isCompleted;
    await _db.updateEventCompleted(e.id!, nowCompleted);
    final i = _events.indexWhere((x) => x.id == e.id);
    if (i >= 0) _events[i] = e.copyWith(isCompleted: nowCompleted);
    notifyListeners();
    // 完成则取消提醒,重新打开则重新安排
    if (nowCompleted) {
      await NotificationService.instance.cancel(e.id!);
    } else if (i >= 0) {
      await NotificationService.instance.scheduleEvent(_events[i]);
    }
  }

  Future<void> deleteEvent(int id) async {
    await _db.deleteEvent(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    await NotificationService.instance.cancel(id);
  }

  Future<void> addKnowledge(KnowledgeItem k) async {
    final id = await _db.insertKnowledge(k);
    _knowledge.insert(0, KnowledgeItem(
      id: id,
      title: k.title,
      rawContent: k.rawContent,
      sourceUrl: k.sourceUrl,
      tags: k.tags,
      pinnedWeek: k.pinnedWeek,
    ));
    notifyListeners();
  }

  Future<void> deleteKnowledge(int id) async {
    await _db.deleteKnowledge(id);
    _knowledge.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}
