import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

/// 待产包清单。内置证件 / 妈妈 / 宝宝三类标准模板,可勾选、增删,落 SQLite。
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  static const _order = ['证件', '妈妈', '宝宝'];
  static const _emoji = {'证件': '📄', '妈妈': '🤱', '宝宝': '🍼'};

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final accentSoft = AppColors.accentSoft(app.role);
    final all = app.checklist;
    final done = all.where((e) => e.checked).length;

    final categories = [
      ..._order.where((c) => all.any((e) => e.category == c)),
      ...all.map((e) => e.category).where((c) => !_order.contains(c)).toSet(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold(app.role),
      appBar: AppBar(
        title: const Text('待产包清单', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.scaffold(app.role),
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 60),
        children: [
          SectionCard(
            background: accentSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已准备 $done / ${all.length} 项',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800, color: accent)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: all.isEmpty ? 0 : done / all.length,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('建议孕 36 周前备齐,放在门口随手可取。',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5C564E))),
              ],
            ),
          ),
          ...categories.map((c) =>
              _categoryCard(context, app, c, accent, accentSoft)),
        ],
      ),
    );
  }

  Widget _categoryCard(BuildContext context, AppState app, String category,
      Color accent, Color accentSoft) {
    final items = app.checklist.where((e) => e.category == category).toList();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryTag('${_emoji[category] ?? '📦'} $category',
                  color: accent, bg: accentSoft),
              GestureDetector(
                onTap: () => _addItem(context, app, category, accent),
                child: Icon(Icons.add_circle_outline, color: accent, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...items.map((item) => _row(app, item, accent)),
        ],
      ),
    );
  }

  Widget _row(AppState app, ChecklistItem item, Color accent) {
    return Dismissible(
      key: ValueKey('cl_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: AppColors.bad),
      ),
      onDismissed: (_) => app.deleteChecklistItem(item.id!),
      child: GestureDetector(
        onTap: () => app.toggleChecklistItem(item),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.checked ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: item.checked ? accent : AppColors.line, width: 2),
                ),
                child: item.checked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.title,
                    style: TextStyle(
                        fontSize: 14,
                        color: item.checked ? AppColors.sub : AppColors.ink,
                        decoration: item.checked
                            ? TextDecoration.lineThrough
                            : null)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addItem(
      BuildContext context, AppState app, String category, Color accent) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('添加到「$category」'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '物品名称'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isNotEmpty) {
                app.addChecklistItem(category, t);
                Navigator.pop(ctx);
              }
            },
            child: Text('添加', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }
}
