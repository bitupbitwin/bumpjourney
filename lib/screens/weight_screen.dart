import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

/// 孕期体重记录与增长曲线。孕中晚期一般每周增重约 0.3–0.5kg,整孕期建议增重
/// 因孕前 BMI 而异(偏瘦 12.5–18kg / 正常 11.5–16kg / 超重 7–11.5kg)。
class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final accentSoft = AppColors.accentSoft(app.role);
    final records = app.weights;

    final gain = records.length >= 2
        ? records.last.weightKg - records.first.weightKg
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.scaffold(app.role),
      appBar: AppBar(
        title: const Text('体重记录', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.scaffold(app.role),
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () => _showAdd(context, app),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
        children: [
          SectionCard(
            background: accentSoft,
            child: const Text(
              '⚖️ 孕中晚期每周增重约 0.3–0.5kg。整孕期建议增重视孕前 BMI 而定:'
              '偏瘦 12.5–18kg、正常 11.5–16kg、超重 7–11.5kg。',
              style: TextStyle(fontSize: 13, color: Color(0xFF5C564E), height: 1.7),
            ),
          ),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: Text('还没有记录,点右下角 + 添加第一条体重',
                    style: TextStyle(color: AppColors.sub, fontSize: 13)),
              ),
            )
          else ...[
            // 统计
            SectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('当前体重', '${records.last.weightKg.toStringAsFixed(1)} kg', accent),
                  _stat('累计增长',
                      '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)} kg', accent),
                  _stat('记录数', '${records.length}', accent),
                ],
              ),
            ),
            // 曲线
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryTag('📈 体重曲线', color: accent, bg: accentSoft),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: records.length < 2
                        ? const Center(
                            child: Text('再记录一条即可生成曲线',
                                style: TextStyle(color: AppColors.sub, fontSize: 12)))
                        : CustomPaint(
                            painter: _WeightChartPainter(records, accent),
                          ),
                  ),
                ],
              ),
            ),
            // 列表
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 6, 4, 8),
              child: Text('历史记录',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            ...records.reversed.map((w) => _tile(app, w, accent, accentSoft)),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color accent) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: accent)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.sub)),
        ],
      );

  Widget _tile(AppState app, WeightRecord w, Color accent, Color accentSoft) {
    return Dismissible(
      key: ValueKey('wt_${w.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24, bottom: 14),
        child: const Icon(Icons.delete_outline, color: AppColors.bad),
      ),
      onDismissed: (_) => app.deleteWeight(w.id!),
      child: SectionCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: accentSoft, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Text(w.weightKg.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: accent)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmtDate(w.date),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('第 ${app.weekForDate(w.date)} 周 · ${w.weightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 12, color: AppColors.sub)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdd(BuildContext context, AppState app) async {
    final controller = TextEditingController();
    DateTime date = DateTime.now();
    final accent = AppColors.accent(app.role);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('添加体重'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '体重(kg)',
                  hintText: '如 58.5',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmtDate(date), style: const TextStyle(fontSize: 14)),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime.now().subtract(const Duration(days: 300)),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setLocal(() => date = d);
                    },
                    child: const Text('选择日期'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            TextButton(
              onPressed: () {
                final v = double.tryParse(controller.text.trim());
                if (v != null && v > 0 && v < 200) {
                  app.addWeight(WeightRecord(date: date, weightKg: v));
                  Navigator.pop(ctx);
                }
              },
              child: Text('保存', style: TextStyle(color: accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final Color accent;
  _WeightChartPainter(this.records, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.length < 2) return;
    final weights = records.map((e) => e.weightKg).toList();
    var minW = weights.reduce((a, b) => a < b ? a : b);
    var maxW = weights.reduce((a, b) => a > b ? a : b);
    if (maxW - minW < 1) {
      minW -= 1;
      maxW += 1;
    } else {
      final pad = (maxW - minW) * 0.15;
      minW -= pad;
      maxW += pad;
    }

    const leftPad = 8.0;
    const bottomPad = 18.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    Offset pointAt(int i) {
      final x = leftPad + (records.length == 1 ? 0 : i / (records.length - 1) * chartW);
      final y = chartH - (weights[i] - minW) / (maxW - minW) * chartH;
      return Offset(x, y);
    }

    // 网格基线
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(leftPad, chartH), Offset(size.width, chartH), gridPaint);

    // 折线
    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < records.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    canvas.drawPath(path, linePaint);

    // 数据点
    final dotPaint = Paint()..color = accent;
    final dotInner = Paint()..color = Colors.white;
    for (var i = 0; i < records.length; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 1.8, dotInner);
    }

    // 起止体重标注
    _label(canvas, weights.first.toStringAsFixed(1), pointAt(0), accent);
    _label(canvas, weights.last.toStringAsFixed(1),
        pointAt(records.length - 1), accent);
  }

  void _label(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(at.dx - tp.width / 2, at.dy - 16));
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.records != records || old.accent != accent;
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
