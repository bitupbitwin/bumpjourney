import 'package:flutter_test/flutter_test.dart';
import 'package:bumpjourney/data/standard_data.dart';

void main() {
  group('StandardData', () {
    test('完整覆盖第 1–40 周,且每周精确命中', () {
      for (var w = 1; w <= 40; w++) {
        expect(StandardData.isMilestone(w), isTrue, reason: '第 $w 周应存在');
        expect(StandardData.resolve(w).week, w, reason: '第 $w 周应精确命中');
      }
    });

    test('越界孕周回退到最近边界', () {
      expect(StandardData.resolve(0).week, 1);
      expect(StandardData.resolve(-5).week, 1);
      expect(StandardData.resolve(100).week, 40);
    });

    test('每周关键字段均非空(饮食/营养/起居/注意事项/准爸爸)', () {
      for (var w = 1; w <= 40; w++) {
        final d = StandardData.resolve(w);
        expect(d.fetusSummary, isNotEmpty, reason: 'W$w fetusSummary');
        expect(d.bodyChange, isNotEmpty, reason: 'W$w bodyChange');
        expect(d.dietGood, isNotEmpty, reason: 'W$w dietGood');
        expect(d.dietBad, isNotEmpty, reason: 'W$w dietBad');
        expect(d.tips, isNotEmpty, reason: 'W$w tips');
        expect(d.nutrition, isNotEmpty, reason: 'W$w nutrition');
        expect(d.exercise, isNotEmpty, reason: 'W$w exercise');
        expect(d.sleep, isNotEmpty, reason: 'W$w sleep');
        expect(d.water, isNotEmpty, reason: 'W$w water');
        expect(d.dadTip, isNotEmpty, reason: 'W$w dadTip');
      }
    });
  });
}
