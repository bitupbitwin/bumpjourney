import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// 孕期基准设定弹窗:支持「预产期 / 末次月经 / B超孕周」三种方式推算预产期。
Future<void> showDueDateSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const DueDateSheet(),
  );
}

class DueDateSheet extends StatefulWidget {
  const DueDateSheet({super.key});
  @override
  State<DueDateSheet> createState() => _DueDateSheetState();
}

class _DueDateSheetState extends State<DueDateSheet> {
  int _mode = 0; // 0=预产期 1=末次月经 2=B超孕周
  late DateTime _date = context.read<AppState>().dueDate;
  int _bWeeks = 8;
  int _bDays = 0;

  static const _modes = ['按预产期', '按末次月经', '按B超孕周'];

  // 根据当前输入预览推算出的预产期。
  DateTime get _previewDue {
    switch (_mode) {
      case 1:
        return _date.add(const Duration(days: AppState.fullTermDays));
      case 2:
        final lmp = _date.subtract(Duration(days: _bWeeks * 7 + _bDays));
        return lmp.add(const Duration(days: AppState.fullTermDays));
      default:
        return _date;
    }
  }

  int get _previewWeek {
    final daysToDue = _previewDue.difference(DateTime.now()).inDays;
    return (40 - (daysToDue / 7).round()).clamp(1, 40);
  }

  void _onModeChange(int m) {
    setState(() {
      _mode = m;
      // 切换方式时给一个合理的默认日期
      _date = m == 0 ? context.read<AppState>().dueDate : DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final first = DateTime.now().subtract(const Duration(days: 300));
    final last = DateTime.now().add(const Duration(days: 300));
    // initialDate 超出范围会触发 DatePicker 断言崩溃(如存储的预产期已很久远),钳制到范围内
    var initial = _date;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    final app = context.read<AppState>();
    switch (_mode) {
      case 1:
        await app.setDueDateFromLmp(_date);
        break;
      case 2:
        await app.setDueDateFromBScan(_date, _bWeeks, _bDays);
        break;
      default:
        await app.setDueDate(_date);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context.watch<AppState>().role);
    final dateLabel = _mode == 0
        ? '预产期'
        : (_mode == 1 ? '末次月经第一天' : 'B超检查日期');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0D6C7),
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const Text('设定孕期基准',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // 方式切换
              Row(
                children: List.generate(_modes.length, (i) {
                  final on = _mode == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onModeChange(i),
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: on ? accent : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: on ? accent : AppColors.line, width: 1.5),
                        ),
                        child: Text(_modes[i],
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: on ? Colors.white : AppColors.sub)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),

              // 日期选择
              Text(dateLabel,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.sub, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmtDate(_date), style: const TextStyle(fontSize: 14)),
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.sub),
                    ],
                  ),
                ),
              ),

              // B超孕周输入
              if (_mode == 2) ...[
                const SizedBox(height: 16),
                const Text('B超当时孕周',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.sub, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                        child: _stepper('周', _bWeeks, 4, 42,
                            (v) => setState(() => _bWeeks = v), accent)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _stepper('天', _bDays, 0, 6,
                            (v) => setState(() => _bDays = v), accent)),
                  ],
                ),
              ],

              const SizedBox(height: 18),
              // 预览
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.accentSoft(context.read<AppState>().role),
                    borderRadius: BorderRadius.circular(14)),
                child: Text(
                    '推算预产期 ${_fmtDate(_previewDue)} · 当前约第 $_previewWeek 周',
                    style: TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700, color: accent)),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('保存',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepper(String unit, int value, int min, int max,
      ValueChanged<int> onChanged, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(Icons.remove, accent,
              value > min ? () => onChanged(value - 1) : null),
          Text('$value $unit',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          _circleBtn(Icons.add, accent,
              value < max ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color accent, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null ? AppColors.line : accent.withValues(alpha: .14),
        ),
        child: Icon(icon,
            size: 18, color: onTap == null ? AppColors.sub : accent),
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
