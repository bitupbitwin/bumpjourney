import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class RoleSwitch extends StatelessWidget {
  const RoleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final isDad = app.role == AppRole.dad;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7DA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final segW = (c.maxWidth - 8) / 2;
        return Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              alignment: isDad ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: segW,
                height: 38,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4))
                  ],
                ),
              ),
            ),
            Row(
              children: [
                _seg(context, '🤰 孕妈视角', !isDad, () => app.setRole(AppRole.mom)),
                _seg(context, '👨 准爸爸', isDad, () => app.setRole(AppRole.dad)),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _seg(BuildContext context, String label, bool on, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 38,
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: on ? Colors.white : AppColors.sub)),
          ),
        ),
      ),
    );
  }
}
