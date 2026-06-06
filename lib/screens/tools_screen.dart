import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import 'fetal_movement_screen.dart';
import 'contraction_screen.dart';
import 'weight_screen.dart';
import 'checklist_screen.dart';

/// 孕期工具中心。当前提供胎动计数与宫缩计时,后续可扩展待产包清单、体重曲线等。
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final accentSoft = AppColors.accentSoft(app.role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 14, top: 6),
          child: Text('孕期工具',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        _toolTile(
          context,
          emoji: '🍼',
          title: '胎动计数',
          subtitle: '孕晚期每日记录,守护宝宝安危',
          accent: accent,
          accentSoft: accentSoft,
          page: const FetalMovementScreen(),
        ),
        _toolTile(
          context,
          emoji: '⏱️',
          title: '宫缩计时',
          subtitle: '临产阵痛计时,判断 5-1-1 入院时机',
          accent: accent,
          accentSoft: accentSoft,
          page: const ContractionScreen(),
        ),
        _toolTile(
          context,
          emoji: '⚖️',
          title: '体重记录',
          subtitle: '记录孕期体重,生成增长曲线',
          accent: accent,
          accentSoft: accentSoft,
          page: const WeightScreen(),
        ),
        _toolTile(
          context,
          emoji: '🎒',
          title: '待产包清单',
          subtitle: '入院当天必备:证件 / 妈妈 / 宝宝',
          accent: accent,
          accentSoft: accentSoft,
          page: const ChecklistScreen(
            listKey: 'hospital_bag',
            title: '待产包清单',
            hint: '建议孕 36 周前备齐,放在门口随手可取。',
          ),
        ),
        _toolTile(
          context,
          emoji: '🍼',
          title: '新生儿用品清单',
          subtitle: '0–1 岁全清单,按时机分阶段备齐',
          accent: accent,
          accentSoft: accentSoft,
          page: const ChecklistScreen(
            listKey: 'newborn',
            title: '新生儿用品清单',
            hint: '标签为建议准备时机(产前 / 月子 / 3M+ / 6M+ / 按需),按需分批购买。',
          ),
        ),
        _toolTile(
          context,
          emoji: '🤱',
          title: '宝妈用品清单',
          subtitle: '产后 / 月子 / 哺乳,恢复用品一站备',
          accent: accent,
          accentSoft: accentSoft,
          page: const ChecklistScreen(
            listKey: 'mom',
            title: '宝妈用品清单',
            hint: '涵盖待产、月子与哺乳期恢复用品。',
          ),
        ),
      ],
    );
  }

  Widget _toolTile(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color accent,
    required Color accentSoft,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => page)),
      child: SectionCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: accentSoft, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.sub)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.sub),
          ],
        ),
      ),
    );
  }
}
