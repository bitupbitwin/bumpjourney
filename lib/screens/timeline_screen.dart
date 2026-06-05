import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/standard_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import '../widgets/check_row.dart';
import 'add_node_sheet.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});
  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final w = app.selectedWeek;
    final data = StandardData.resolve(w);
    final accent = AppColors.accent(app.role);
    final accentSoft = AppColors.accentSoft(app.role);
    final isDad = app.role == AppRole.dad;

    final statusLabel = w < app.currentWeek
        ? '已度过'
        : (w == app.currentWeek ? '本周 · 当前' : '未来计划');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      children: [
        // 周标题
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12, top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('第 $w 周',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              CategoryTag(statusLabel, color: accent, bg: accentSoft),
            ],
          ),
        ),

        if (!isDad) ..._momCards(app, data, accent, accentSoft),
        if (isDad) ..._dadCards(app, data, accent, accentSoft),

        // 知识库锚定
        ...app.knowledgeForWeek(w).map((k) => _knowledgeCard(k)),

        // 自定义节点
        ...app.eventsForWeek(w).map((e) => _eventCard(app, e)),

        // 添加按钮
        GestureDetector(
          onTap: () => showAddNodeSheet(context, w),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent, width: 1.5, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: accent, size: 20),
                const SizedBox(width: 8),
                Text('在第 $w 周添加自定义节点',
                    style: TextStyle(
                        color: accent, fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // —— 孕妈视角 ——
  List<Widget> _momCards(AppState app, StandardWeekData d, Color accent, Color accentSoft) {
    return [
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('🌱 当前周摘要', color: accent, bg: accentSoft),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [Color(0xFFFFF1E6), Color(0xFFFDE0CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  alignment: Alignment.center,
                  child: Text(d.fruitEmoji, style: const TextStyle(fontSize: 34)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.fetusSummary,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, height: 1.4)),
                      const SizedBox(height: 6),
                      Text('身体变化:${d.bodyChange}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF5C564E), height: 1.6)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('🍽️ 饮食红黑榜', color: accent, bg: accentSoft),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _dietCol('✓ 推荐', d.dietGood, AppColors.good, AppColors.goodSoft)),
                const SizedBox(width: 10),
                Expanded(child: _dietCol('✕ 禁忌', d.dietBad, AppColors.bad, AppColors.badSoft)),
              ],
            ),
          ],
        ),
      ),
      if (_hasLifestyle(d)) _lifestyleCard(d, accent, accentSoft),
      if (d.tips.isNotEmpty) _tipsCard(d.tips, accent, accentSoft),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('🏥 标准产检提醒', color: accent, bg: accentSoft),
            const SizedBox(height: 4),
            ...d.checks.asMap().entries.map((e) {
              final key = 'chk_${d.week}_${e.value.title}';
              return CheckRow(
                title: e.value.title,
                note: e.value.note,
                accent: accent,
                checked: app.isChecked(key),
                last: e.key == d.checks.length - 1,
                onTap: () => app.setCheck(key, !app.isChecked(key)),
              );
            }),
          ],
        ),
      ),
    ];
  }

  Widget _dietCol(String title, List<String> items, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 8),
          ...items.map((x) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('· $x',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF5C564E), height: 1.5)),
              )),
        ],
      ),
    );
  }

  bool _hasLifestyle(StandardWeekData d) =>
      d.nutrition.isNotEmpty ||
      d.exercise.isNotEmpty ||
      d.sleep.isNotEmpty ||
      d.water.isNotEmpty;

  // —— 起居调养:营养 / 运动 / 睡眠 / 喝水 ——
  Widget _lifestyleCard(StandardWeekData d, Color accent, Color accentSoft) {
    final rows = <(String, String, String)>[
      if (d.nutrition.isNotEmpty) ('💊', '营养补充', d.nutrition),
      if (d.exercise.isNotEmpty) ('🤸', '运动建议', d.exercise),
      if (d.sleep.isNotEmpty) ('🌙', '睡眠姿势', d.sleep),
      if (d.water.isNotEmpty) ('💧', '喝水建议', d.water),
    ];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryTag('🌿 起居调养', color: accent, bg: accentSoft),
          const SizedBox(height: 6),
          ...rows.asMap().entries.map((e) {
            final last = e.key == rows.length - 1;
            return Padding(
              padding: EdgeInsets.only(top: 10, bottom: last ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.value.$1, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.$2,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: accent)),
                        const SizedBox(height: 2),
                        Text(e.value.$3,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5C564E),
                                height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // —— 本周注意事项 ——
  Widget _tipsCard(List<String> tips, Color accent, Color accentSoft) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryTag('⚠️ 本周注意事项', color: accent, bg: accentSoft),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('·',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: accent)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5C564E),
                              height: 1.6)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // —— 准爸爸视角 ——
  List<Widget> _dadCards(AppState app, StandardWeekData d, Color accent, Color accentSoft) {
    return [
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('✅ 老公任务清单', color: accent, bg: accentSoft),
            const SizedBox(height: 4),
            ...d.dadTasks.asMap().entries.map((e) {
              final key = 'dad_${d.week}_${e.value.title}';
              final checked = app.isChecked(key) ||
                  (e.value.defaultDone && !app.isChecked('un_$key'));
              return CheckRow(
                title: e.value.title,
                accent: accent,
                checked: checked,
                last: e.key == d.dadTasks.length - 1,
                onTap: () {
                  if (checked) {
                    app.setCheck(key, false);
                    app.setCheck('un_$key', true);
                  } else {
                    app.setCheck(key, true);
                    app.setCheck('un_$key', false);
                  }
                },
              );
            }),
          ],
        ),
      ),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('👀 老婆这周的状态', color: accent, bg: accentSoft),
            const SizedBox(height: 10),
            Text('身体变化:${d.bodyChange}',
                style: const TextStyle(
                    fontSize: 13.5, color: Color(0xFF5C564E), height: 1.7)),
            if (d.tips.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...d.tips.take(2).map((t) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('·',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: accent)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(t,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5C564E),
                                  height: 1.6)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('💗 体贴提示', color: accent, bg: accentSoft),
            const SizedBox(height: 10),
            Text(
                d.dadTip.isNotEmpty
                    ? d.dadTip
                    : '这一周,记得多问一句「累不累」。陪伴不是任务,但先从勾掉这些任务开始。',
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF5C564E), height: 1.7)),
          ],
        ),
      ),
    ];
  }

  // —— 知识库卡片 ——
  Widget _knowledgeCard(KnowledgeItem k) {
    return SectionCard(
      background: const Color(0xFFFFFDFA),
      border: Border.all(color: AppColors.line, width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CategoryTag('📚 收藏 · 锚定本周',
              color: AppColors.gold, bg: AppColors.goldSoft),
          const SizedBox(height: 8),
          Text(k.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(k.rawContent,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF5C564E), height: 1.6)),
          if (k.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: k.tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.goldSoft, borderRadius: BorderRadius.circular(14)),
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
          if (k.sourceUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(k.sourceUrl, style: const TextStyle(fontSize: 11, color: AppColors.sub)),
          ],
        ],
      ),
    );
  }

  // —— 自定义事件卡片 ——
  Widget _eventCard(AppState app, CustomEvent e) {
    final dateStr =
        '${e.targetDate.month.toString().padLeft(2, '0')}-${e.targetDate.day.toString().padLeft(2, '0')}';
    return Dismissible(
      key: ValueKey('evt_${e.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24, bottom: 14),
        child: const Icon(Icons.delete_outline, color: AppColors.bad),
      ),
      onDismissed: (_) => app.deleteEvent(e.id!),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag('📍 自定义事件 · $dateStr',
                color: AppColors.custom, bg: AppColors.customSoft),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => app.toggleEvent(e),
                  child: Icon(
                    e.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: e.isCompleted ? AppColors.custom : AppColors.line,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration: e.isCompleted ? TextDecoration.lineThrough : null,
                          color: e.isCompleted ? AppColors.sub : AppColors.ink)),
                ),
              ],
            ),
            if (e.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(e.content,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF5C564E), height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}
