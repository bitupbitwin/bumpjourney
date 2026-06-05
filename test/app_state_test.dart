import 'package:flutter_test/flutter_test.dart';
import 'package:bumpjourney/providers/app_state.dart';

void main() {
  group('AppState 孕周推算', () {
    test('预产期即今天 → 第 40 周', () {
      final app = AppState();
      app.dueDate = DateTime.now();
      expect(app.currentWeek, 40);
    });

    test('预产期极远 → 钳制到下限第 1 周', () {
      final app = AppState();
      app.dueDate = DateTime.now().add(const Duration(days: 400));
      expect(app.currentWeek, 1);
    });

    test('currentWeek 始终落在 1..40', () {
      final app = AppState();
      for (final days in [-30, 0, 50, 140, 280, 500]) {
        app.dueDate = DateTime.now().add(Duration(days: days));
        expect(app.currentWeek, inInclusiveRange(1, 40));
      }
    });
  });
}
