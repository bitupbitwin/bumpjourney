import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

/// 宫缩计时器。临产典型「5-1-1」原则:宫缩约每 5 分钟一次、每次持续约 1 分钟、
/// 规律持续 1 小时,应及时入院(经产妇或医生另有医嘱者从其建议)。
class ContractionScreen extends StatefulWidget {
  const ContractionScreen({super.key});
  @override
  State<ContractionScreen> createState() => _ContractionScreenState();
}

class _ContractionScreenState extends State<ContractionScreen> {
  DateTime? _ongoingStart;
  Timer? _ticker;

  bool get _ongoing => _ongoingStart != null;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _ongoingStart = DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    _ticker = null;
    final start = _ongoingStart;
    setState(() => _ongoingStart = null);
    if (start != null) {
      await context.read<AppState>().addContraction(
          ContractionRecord(startTime: start, endTime: DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final accent = AppColors.accent(app.role);
    final accentSoft = AppColors.accentSoft(app.role);
    // 升序记录,显示时倒序
    final asc = app.contractions;
    final live = _ongoing ? DateTime.now().difference(_ongoingStart!) : Duration.zero;
    final stats = _recentStats(asc);

    return Scaffold(
      backgroundColor: AppColors.scaffold(app.role),
      appBar: AppBar(
        title: const Text('宫缩计时', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.scaffold(app.role),
        foregroundColor: AppColors.ink,
        elevation: 0,
        actions: [
          if (asc.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(app),
              child: const Text('清空', style: TextStyle(color: AppColors.sub)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
        children: [
          SectionCard(
            background: accentSoft,
            child: const Text(
              '📒 阵痛来时点「开始」,结束时点「结束」。临产「5-1-1」:每 5 分钟一次、'
              '每次约 1 分钟、规律持续 1 小时应入院;破水或见红伴规律宫缩请立即就医。',
              style: TextStyle(fontSize: 13, color: Color(0xFF5C564E), height: 1.7),
            ),
          ),
          // —— 5-1-1 提示 ——
          if (stats.pattern)
            const SectionCard(
              background: AppColors.badSoft,
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.bad),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('已接近规律宫缩(5-1-1),建议尽快前往医院评估。',
                        style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.bad,
                            fontWeight: FontWeight.w700,
                            height: 1.6)),
                  ),
                ],
              ),
            ),
          // —— 计时主区 ——
          SectionCard(
            child: Column(
              children: [
                Text(_ongoing ? '本次已持续' : '准备就绪',
                    style: const TextStyle(fontSize: 13, color: AppColors.sub)),
                const SizedBox(height: 8),
                Text(_ongoing ? _fmtClock(live) : '--:--',
                    style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: _ongoing ? accent : AppColors.line)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _ongoing ? _stop : _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ongoing ? AppColors.bad : accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(_ongoing ? '结束这次宫缩' : '开始一次宫缩',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
          // —— 近 1 小时统计 ——
          if (asc.isNotEmpty)
            SectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('近1h次数', '${stats.count}', accent),
                  _stat('平均间隔', stats.avgInterval, accent),
                  _stat('平均持续', stats.avgDuration, accent),
                ],
              ),
            ),
          // —— 历史 ——
          if (asc.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 6, 4, 8),
              child: Text('宫缩记录',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            ...List.generate(asc.length, (i) {
              final idx = asc.length - 1 - i; // 倒序展示
              final c = asc[idx];
              final prev = idx > 0 ? asc[idx - 1] : null;
              final interval = prev == null
                  ? null
                  : c.startTime.difference(prev.startTime);
              return _recordTile(app, c, interval, accent, accentSoft);
            }),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color accent) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.sub)),
        ],
      );

  Widget _recordTile(AppState app, ContractionRecord c, Duration? interval,
      Color accent, Color accentSoft) {
    return Dismissible(
      key: ValueKey('ct_${c.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24, bottom: 14),
        child: const Icon(Icons.delete_outline, color: AppColors.bad),
      ),
      onDismissed: (_) => app.deleteContraction(c.id!),
      child: SectionCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: accentSoft, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Icon(Icons.monitor_heart_outlined, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_fmtTime(c.startTime)} 开始 · 持续 ${_fmtSpan(c.duration)}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(interval == null ? '首次记录' : '距上次间隔 ${_fmtSpan(interval)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.sub)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空宫缩记录?'),
        content: const Text('将删除全部宫缩计时记录,此操作不可撤销。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('清空', style: TextStyle(color: AppColors.bad))),
        ],
      ),
    );
    if (ok == true) await app.clearContractions();
  }

  /// 统计近 1 小时宫缩的次数、平均间隔、平均持续,并判断是否接近 5-1-1。
  _Stats _recentStats(List<ContractionRecord> asc) {
    final now = DateTime.now();
    final recent = asc
        .where((c) => now.difference(c.startTime).inMinutes <= 60)
        .toList();
    if (recent.isEmpty) {
      return const _Stats(0, '—', '—', false);
    }
    // 平均持续
    final avgDurSec = recent
            .map((c) => c.duration.inSeconds)
            .fold<int>(0, (a, b) => a + b) ~/
        recent.length;
    // 平均间隔(相邻开始时间差)
    int avgIntSec = 0;
    if (recent.length >= 2) {
      var total = 0;
      for (var i = 1; i < recent.length; i++) {
        total += recent[i].startTime.difference(recent[i - 1].startTime).inSeconds;
      }
      avgIntSec = total ~/ (recent.length - 1);
    }
    // 5-1-1 粗略判断:近 1 小时 ≥ 6 次、平均间隔 ≤ 5 分钟、平均持续 ≥ 50 秒
    final pattern = recent.length >= 6 &&
        avgIntSec > 0 &&
        avgIntSec <= 5 * 60 &&
        avgDurSec >= 50;
    return _Stats(
      recent.length,
      recent.length >= 2 ? _fmtSpan(Duration(seconds: avgIntSec)) : '—',
      _fmtSpan(Duration(seconds: avgDurSec)),
      pattern,
    );
  }
}

class _Stats {
  final int count;
  final String avgInterval;
  final String avgDuration;
  final bool pattern;
  const _Stats(this.count, this.avgInterval, this.avgDuration, this.pattern);
}

String _two(int n) => n.toString().padLeft(2, '0');
String _fmtTime(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';
String _fmtClock(Duration d) => '${_two(d.inMinutes)}:${_two(d.inSeconds % 60)}';
String _fmtSpan(Duration d) {
  if (d.inMinutes > 0) return '${d.inMinutes}分${d.inSeconds % 60}秒';
  return '${d.inSeconds}秒';
}
