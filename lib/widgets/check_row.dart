import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CheckRow extends StatelessWidget {
  final String title;
  final String note;
  final bool checked;
  final Color accent;
  final VoidCallback onTap;
  final bool last;

  const CheckRow({
    super.key,
    required this.title,
    this.note = '',
    required this.checked,
    required this.accent,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: checked ? accent : AppColors.line, width: 2),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          color: checked ? AppColors.sub : AppColors.ink,
                          decoration:
                              checked ? TextDecoration.lineThrough : null)),
                  if (note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('📌 $note',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.sub)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
