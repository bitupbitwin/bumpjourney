import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class WeekRail extends StatefulWidget {
  const WeekRail({super.key});
  @override
  State<WeekRail> createState() => _WeekRailState();
}

class _WeekRailState extends State<WeekRail> {
  final _ctrl = ScrollController();
  static const double _itemW = 46 + 8; // 宽 + 间距

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnSelected(animate: false));
  }

  void _centerOnSelected({bool animate = true}) {
    final app = context.read<AppState>();
    final idx = app.selectedWeek - 1;
    final target = (idx * _itemW) - 150;
    final clamped = target.clamp(0.0, _ctrl.position.maxScrollExtent);
    if (animate) {
      _ctrl.animateTo(clamped,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      _ctrl.jumpTo(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 6),
          child: Text('孕周轮播 · 点击定位',
              style: TextStyle(
                  fontSize: 11, color: AppColors.sub, fontWeight: FontWeight.w600, letterSpacing: 1)),
        ),
        SizedBox(
          height: 64,
          child: ListView.separated(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 40, // W1..W40
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final w = i + 1;
              final isCur = w == app.currentWeek;
              final isSel = w == app.selectedWeek;
              final isPast = w < app.currentWeek;
              return GestureDetector(
                onTap: () {
                  app.selectWeek(w);
                  _centerOnSelected();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 46,
                  decoration: BoxDecoration(
                    color: isSel ? accent : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isSel
                            ? accent
                            : (isCur ? accent : AppColors.line),
                        width: 1.5),
                    boxShadow: isSel ? AppTheme.cardShadow : null,
                  ),
                  child: Opacity(
                    opacity: isPast && !isSel ? .55 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isPast ? '已过' : (isCur ? '本周' : 'WEEK'),
                          style: TextStyle(
                              fontSize: 9,
                              color: isSel
                                  ? Colors.white.withValues(alpha: .85)
                                  : (isCur ? accent : AppColors.sub)),
                        ),
                        Text('$w',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isSel ? Colors.white : AppColors.ink)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
