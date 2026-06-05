import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bumpjourney/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('按末次月经推算:预产期 = LMP + 280 天', () async {
    final app = AppState();
    final lmp = DateTime(2026, 1, 1);
    await app.setDueDateFromLmp(lmp);
    expect(app.dueDate, lmp.add(const Duration(days: AppState.fullTermDays)));
  });

  test('按 B 超孕周推算:等效 LMP = 检查日 -(周*7+天),再 +280 天', () async {
    final app = AppState();
    final scan = DateTime(2026, 3, 1);
    await app.setDueDateFromBScan(scan, 10, 0); // 孕 10 周 0 天
    final expectedLmp = scan.subtract(const Duration(days: 70));
    expect(app.dueDate,
        expectedLmp.add(const Duration(days: AppState.fullTermDays)));
  });

  test('设定预产期后 weekForDate 自洽', () async {
    final app = AppState();
    final due = DateTime(2026, 1, 1);
    await app.setDueDate(due);
    expect(app.weekForDate(due), 40); // 预产期当天 = 40 周
    expect(app.weekForDate(due.subtract(const Duration(days: 70))), 30); // 提前 10 周
  });
}
