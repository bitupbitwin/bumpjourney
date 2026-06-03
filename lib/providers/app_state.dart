import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  final _db = DatabaseService.instance;

  // —— 孕期基准 —— 后续可由「我的」页设置末次月经/预产期推算
  DateTime dueDate = DateTime.now().add(const Duration(days: 107));

  int get currentWeek {
    final daysToDue = dueDate.difference(DateTime.now()).inDays;
    final w = 40 - (daysToDue / 7).round();
    return w.clamp(1, 40);
  }

  int get daysLeft => dueDate.difference(DateTime.now()).inDays;

  // —— 选中态 ——
  late int selectedWeek = currentWeek;
  AppRole role = AppRole.mom;

  List<CustomEvent> _events = [];
  List<KnowledgeItem> _knowledge = [];

  List<CustomEvent> get allEvents => _events;
  List<KnowledgeItem> get allKnowledge => _knowledge;

  Future<void> load() async {
    _events = await _db.getEvents();
    _knowledge = await _db.getKnowledge();
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
    _events.add(e.copyWith(id: id));
    notifyListeners();
  }

  Future<void> toggleEvent(CustomEvent e) async {
    if (e.id == null) return;
    await _db.updateEventCompleted(e.id!, !e.isCompleted);
    final i = _events.indexWhere((x) => x.id == e.id);
    if (i >= 0) _events[i] = e.copyWith(isCompleted: !e.isCompleted);
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    await _db.deleteEvent(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
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
