import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final upcoming = app.allEvents.where((e) => !e.isCompleted).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 14, top: 6),
          child: Text('提醒中心',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        if (upcoming.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
                child: Text('暂无待办提醒',
                    style: TextStyle(color: AppColors.sub, fontSize: 13))),
          ),
        ...upcoming.map((e) {
          final dateStr =
              '${e.targetDate.year}-${e.targetDate.month.toString().padLeft(2, '0')}-${e.targetDate.day.toString().padLeft(2, '0')}';
          final remindText = e.remindDaysBefore == 0
              ? '不提醒'
              : '提前 ${e.remindDaysBefore} 天';
          return SectionCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft(app.role),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.notifications_active_outlined, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('$dateStr · W${e.associatedWeek} · $remindText',
                          style: const TextStyle(fontSize: 12, color: AppColors.sub)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.sub),
                  onPressed: () => app.toggleEvent(e),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        const Text('🔔 已开启本地通知:带「提前提醒」的事件会在目标日前提醒你(目标日前 N 天 09:00)。',
            style: TextStyle(fontSize: 12, color: AppColors.sub)),
      ],
    );
  }
}
