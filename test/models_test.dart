import 'package:flutter_test/flutter_test.dart';
import 'package:bumpjourney/models/models.dart';

void main() {
  test('CustomEvent toMap/fromMap 往返一致', () {
    final e = CustomEvent(
      id: 7,
      title: '建档',
      content: '带身份证',
      targetDate: DateTime(2026, 6, 5),
      associatedWeek: 12,
      remindDaysBefore: 3,
      isCompleted: true,
    );
    final back = CustomEvent.fromMap(e.toMap());
    expect(back.id, 7);
    expect(back.title, '建档');
    expect(back.content, '带身份证');
    expect(back.associatedWeek, 12);
    expect(back.remindDaysBefore, 3);
    expect(back.isCompleted, isTrue);
    expect(back.targetDate, e.targetDate);
  });

  test('FetalMovementSession 计算时长并可序列化往返', () {
    final s = FetalMovementSession(
      id: 1,
      startTime: DateTime(2026, 6, 5, 10, 0),
      endTime: DateTime(2026, 6, 5, 11, 0),
      count: 8,
    );
    expect(s.duration, const Duration(hours: 1));
    final back = FetalMovementSession.fromMap(s.toMap());
    expect(back.count, 8);
    expect(back.startTime, s.startTime);
    expect(back.endTime, s.endTime);
  });

  test('ContractionRecord 计算时长并可序列化往返', () {
    final c = ContractionRecord(
      id: 1,
      startTime: DateTime(2026, 6, 5, 10, 0, 0),
      endTime: DateTime(2026, 6, 5, 10, 1, 0),
    );
    expect(c.duration, const Duration(minutes: 1));
    final back = ContractionRecord.fromMap(c.toMap());
    expect(back.startTime, c.startTime);
    expect(back.endTime, c.endTime);
  });
}
