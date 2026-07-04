import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/role_switch.dart';
import '../widgets/week_rail.dart';
import 'timeline_screen.dart';
import 'knowledge_screen.dart';
import 'tools_screen.dart';
import 'reminders_screen.dart';
import 'profile_screen.dart';
import 'add_node_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final isTimeline = _tab == 0;

    return Scaffold(
      backgroundColor: AppColors.scaffold(app.role),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _appBar(app, accent),
            if (isTimeline) ...[
              const RoleSwitch(),
              const SizedBox(height: 14),
              const WeekRail(),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  TimelineScreen(),
                  KnowledgeScreen(),
                  ToolsScreen(),
                  RemindersScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isTimeline
          ? GestureDetector(
              onDoubleTap: app.goToday,
              child: FloatingActionButton(
                backgroundColor: accent,
                onPressed: () => showAddNodeSheet(context, app.selectedWeek),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    Text('今天',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            )
          : null,
      bottomNavigationBar: _bottomBar(accent),
    );
  }

  Widget _appBar(AppState app, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('孕育时光',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: .5)),
              Text('BUMPJOURNEY',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sub,
                      letterSpacing: 2)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  '预产期 ${app.dueDate.year}.${app.dueDate.month.toString().padLeft(2, '0')}.${app.dueDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.sub)),
              const SizedBox(height: 2),
              Text(app.daysLeftLabel,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(Color accent) {
    final items = [
      (Icons.calendar_today_outlined, '时间线'),
      (Icons.menu_book_outlined, '知识库'),
      (Icons.monitor_heart_outlined, '工具'),
      (Icons.notifications_none, '提醒'),
      (Icons.person_outline, '我的'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (i) {
            final on = _tab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].$1,
                        size: 22, color: on ? accent : AppColors.sub),
                    const SizedBox(height: 3),
                    Text(items[i].$2,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: on ? accent : AppColors.sub)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
