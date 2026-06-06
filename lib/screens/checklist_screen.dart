import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

/// 通用清单页:服务待产包 / 新生儿 / 宝妈三份清单(按 listKey 区分)。
/// 工具内按子类分组,条目展示建议数量与时机标签,可勾选 / 增删 / 一键恢复默认模板。
class ChecklistScreen extends StatelessWidget {
  final String listKey;
  final String title;
  final String hint;
  const ChecklistScreen({
    super.key,
    required this.listKey,
    required this.title,
    this.hint = '',
  });

  static const _emoji = {
    '证件': '📄', '妈妈': '🤱', '宝宝': '🍼',
    '喂养类': '🍼', '消耗护理类': '🧷', '衣物类': '👕', '睡眠类': '🛏️',
    '洗护类': '🛁', '健康医护类': '🩺', '出行大件类': '🚙', '玩具早教类': '🧸',
    '产后护理类': '🩹', '哺乳类': '🤱', '个护恢复类': '💄', '营养补剂类': '💊',
    '心理其他': '💗',
  };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final accentSoft = AppColors.accentSoft(app.role);
    final items = app.checklistFor(listKey);
    final done = items.where((e) => e.checked).length;

    // 子类按首次出现顺序(列表已按 sort 排序)
    final categories = <String>[];
    for (final e in items) {
      if (!categories.contains(e.category)) categories.add(e.category);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold(app.role),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.scaffold(app.role),
        foregroundColor: AppColors.ink,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: '恢复默认模板',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _confirmReset(context, app),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 60),
        children: [
          SectionCard(
            background: accentSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已备 $done / ${items.length} 项',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800, color: accent)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: items.isEmpty ? 0 : done / items.length,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                if (hint.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(hint,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF5C564E), height: 1.5)),
                ],
              ],
            ),
          ),
          ...categories.map((c) =>
              _categoryCard(context, app, items, c, accent, accentSoft)),
        ],
      ),
    );
  }

  Widget _categoryCard(BuildContext context, AppState app,
      List<ChecklistItem> all, String category, Color accent, Color accentSoft) {
    final items = all.where((e) => e.category == category).toList();
    final done = items.where((e) => e.checked).length;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryTag('${_emoji[category] ?? '📦'} $category  $done/${items.length}',
                  color: accent, bg: accentSoft),
              GestureDetector(
                onTap: () => _addItem(context, app, category, accent),
                child: Icon(Icons.add_circle_outline, color: accent, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...items.map((item) => _row(app, item, accent, accentSoft)),
        ],
      ),
    );
  }

  Widget _row(AppState app, ChecklistItem item, Color accent, Color accentSoft) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                              fontSize: 14,
                              color: item.checked ? AppColors.sub : AppColors.ink,
                              decoration: item.checked
                                  ? TextDecoration.lineThrough
                                  : null)),
                      if (item.qty != null && item.qty!.isNotEmpty)
                        Text('· ${item.qty}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.sub)),
                      if (item.timing != null && item.timing!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: accentSoft,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(item.timing!,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accent)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addItem(
      BuildContext context, AppState app, String category, Color accent) async {
    final titleCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('添加到「$category」'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: '物品名称'),
            ),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: '建议数量(可选,如 2条)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isNotEmpty) {
                app.addChecklistItem(listKey, category, t,
                    qty: qtyCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text('添加', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复默认模板?'),
        content: Text('将清空当前「$title」的所有条目(含你添加的)并还原为默认模板,不影响其他清单。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('恢复', style: TextStyle(color: AppColors.bad))),
        ],
      ),
    );
    if (ok == true) await app.resetChecklist(listKey);
  }
}
