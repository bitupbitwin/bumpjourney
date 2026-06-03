import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 14, top: 6),
          child: Text('我的', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CategoryTag('🍼 孕期信息',
                  color: AppColors.gold, bg: AppColors.goldSoft),
              const SizedBox(height: 14),
              _row('当前孕周', '第 ${app.currentWeek} 周'),
              const Divider(color: AppColors.line),
              _row('距预产期', '${app.daysLeft} 天'),
              const Divider(color: AppColors.line),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: app.dueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 300)),
                    lastDate: DateTime.now().add(const Duration(days: 300)),
                  );
                  if (d != null) {
                    app.dueDate = d;
                    app.goToday();
                  }
                },
                child: _row('预产期',
                    '${app.dueDate.year}-${app.dueDate.month.toString().padLeft(2, '0')}-${app.dueDate.day.toString().padLeft(2, '0')} ›'),
              ),
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryTag('🔒 隐私', color: accent, bg: AppColors.accentSoft(app.role)),
              const SizedBox(height: 12),
              const Text('本地优先(Local-First):所有数据仅存于本设备,未上传任何服务器。',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5C564E), height: 1.6)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('本产品内容仅供参考,不构成医疗诊断建议。',
              style: TextStyle(fontSize: 11, color: AppColors.sub)),
        ),
      ],
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(fontSize: 14, color: AppColors.sub)),
            Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
