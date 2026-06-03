import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});
  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final all = app.allKnowledge;
    final allTags = {for (final k in all) ...k.tags}.toList();
    final list = _filter == null
        ? all
        : all.where((k) => k.tags.contains(_filter)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 14, top: 6),
          child: Text('知识库',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        if (allTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Wrap(
              spacing: 8,
              children: [
                _chip('全部', _filter == null, () => setState(() => _filter = null)),
                ...allTags.map((t) =>
                    _chip(t, _filter == t, () => setState(() => _filter = t))),
              ],
            ),
          ),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('还没有收藏。从时间线粘贴网页内容,\nAI 会帮你提炼归档。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.sub, fontSize: 13, height: 1.6)),
            ),
          ),
        ...list.map((k) => SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(k.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      if (k.pinnedWeek != null)
                        CategoryTag('W${k.pinnedWeek}',
                            color: AppColors.gold, bg: AppColors.goldSoft),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(k.rawContent,
                      style: const TextStyle(
                          fontSize: 13.5, color: Color(0xFF5C564E), height: 1.6)),
                  if (k.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: k.tags
                          .map((t) => Text(t,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600)))
                          .toList(),
                    ),
                  ],
                  if (k.sourceUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(k.sourceUrl,
                        style: const TextStyle(fontSize: 11, color: AppColors.sub)),
                  ],
                ],
              ),
            )),
      ],
    );
  }

  Widget _chip(String label, bool on, VoidCallback onTap) {
    final accent = AppColors.accent(context.read<AppState>().role);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? accent : AppColors.card,
          borderRadius: BorderRadius.circular(14),
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
