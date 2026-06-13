import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/ai_extractor.dart';
import '../theme/app_theme.dart';

Future<void> showAddNodeSheet(BuildContext context, int week) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddNodeSheet(week: week),
  );
}

class AddNodeSheet extends StatefulWidget {
  final int week;
  const AddNodeSheet({super.key, required this.week});
  @override
  State<AddNodeSheet> createState() => _AddNodeSheetState();
}

class _AddNodeSheetState extends State<AddNodeSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  DateTime _date = DateTime.now();
  final _tags = <String>{};
  int _remind = 3;
  bool _extracting = false;
  bool _saving = false;
  int? _suggestedWeek;

  static const _tagOptions = ['#待产包清单', '#控糖食谱', '#分娩攻略', '#建档'];

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _runAi() async {
    if (_body.text.trim().isEmpty) return;
    setState(() => _extracting = true);
    final r = await AiExtractor.extract(_body.text);
    setState(() {
      _extracting = false;
      if (_title.text.isEmpty) _title.text = r.title;
      _body.text = r.structured;
      _suggestedWeek = r.suggestedWeek;
    });
  }

  Future<void> _save() async {
    if (_saving) return; // 防重复点击,避免存成多条
    setState(() => _saving = true);
    final app = context.read<AppState>();
    final week = _suggestedWeek ?? widget.week;
    await app.addEvent(CustomEvent(
      title: _title.text.trim().isEmpty ? '未命名事件' : _title.text.trim(),
      content: _body.text.trim(),
      targetDate: _date,
      associatedWeek: week,
      remindDaysBefore: _remind,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final saveWeek = _suggestedWeek ?? widget.week;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0D6C7), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const Text('新建自定义节点',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // AI 提示 + 触发
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFF6E9), Color(0xFFFCEEDD)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0DEC4)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('💡 粘贴网页攻略,AI 自动提炼为【时间/证件/费用/步骤】并建议锚定周',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF8A6D3B), height: 1.5)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _extracting ? null : _runAi,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: _extracting
                          ? const SizedBox(
                              width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('提炼', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _label('标题'),
              _input(_title, '如:到 XX 医院建档'),
              const SizedBox(height: 14),

              _label('内容 / 粘贴网页文本'),
              _input(_body, '可直接粘贴小红书 / 公众号攻略原文…', maxLines: 3),
              if (_suggestedWeek != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('🤖 AI 建议锚定到第 $_suggestedWeek 周',
                      style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 14),

              _label('日期'),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2027),
                  );
                  if (d != null) setState(() => _date = d);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line, width: 1.5),
                  ),
                  child: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 14),

              _label('标签'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tagOptions.map((t) {
                  final on = _tags.contains(t);
                  return GestureDetector(
                    onTap: () => setState(() => on ? _tags.remove(t) : _tags.add(t)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: on ? accent : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: on ? accent : AppColors.line, width: 1.5),
                      ),
                      child: Text(t,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: on ? Colors.white : AppColors.sub)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              _label('提前提醒'),
              Row(
                children: [
                  _remindChip('不提醒', 0, accent),
                  const SizedBox(width: 8),
                  _remindChip('提前 1 天', 1, accent),
                  const SizedBox(width: 8),
                  _remindChip('提前 3 天', 3, accent),
                ],
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withValues(alpha: .5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('保存到第 $saveWeek 周时间线',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(fontSize: 12, color: AppColors.sub, fontWeight: FontWeight.w600)),
      );

  Widget _input(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.sub, fontSize: 13),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.line, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.accent(context.read<AppState>().role), width: 1.5)),
      ),
    );
  }

  Widget _remindChip(String label, int val, Color accent) {
    final on = _remind == val;
    return GestureDetector(
      onTap: () => setState(() => _remind = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? accent : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: on ? accent : AppColors.line, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : AppColors.sub)),
      ),
    );
  }
}
