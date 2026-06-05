import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bumpjourney/widgets/check_row.dart';

void main() {
  testWidgets('CheckRow 显示标题与备注,点击回调触发', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CheckRow(
          title: '建档产检',
          note: '带身份证',
          accent: const Color(0xFFE8916B),
          checked: false,
          onTap: () => tapped++,
        ),
      ),
    ));

    expect(find.text('建档产检'), findsOneWidget);
    expect(find.textContaining('带身份证'), findsOneWidget);

    await tester.tap(find.text('建档产检'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('CheckRow 勾选后标题显示删除线', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CheckRow(
          title: '已完成项',
          accent: const Color(0xFF6FA386),
          checked: true,
          onTap: () {},
        ),
      ),
    ));

    final text = tester.widget<Text>(find.text('已完成项'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });
}
