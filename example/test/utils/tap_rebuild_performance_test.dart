import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<int> tapRebuildPerformanceTest(
    WidgetTester tester, Widget widget) async {
  final stopwatch = Stopwatch()..start();

  await tester.pumpWidget(MaterialApp(home: widget));

  // act
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pump();

  stopwatch.stop();

  final elapsed = stopwatch.elapsedMicroseconds;

  final textFinders = find.text('1');

  expect(textFinders, findsOneWidget);

  return elapsed;
}
