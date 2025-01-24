// ignore_for_file: avoid_print
import 'dart:math';

import 'package:example/features/bloc_simple/bloc_counter_screen.dart';
import 'package:example/features/riverpod_simple/riverpod_simple_screen.dart';
import 'package:example/features/simple_counter/simple_counter_screen.dart';
import 'package:example/features/stateful_simple/stateful_counter_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/tap_rebuild_performance_test.dart';
import 'utils/warming_up_widget.dart';

void main() {
  final random = Random();
  const numRuns = 2000;
  final times = <String, List<int>>{
    "flow_vm": [],
    "BLoC": [],
    "StatefulWidget": [],
    "Riverpod": [],
  };

  group("Benchmarks", () {
    testWidgets('Warming Up', (WidgetTester tester) async {
      await tapRebuildPerformanceTest(tester, const WarmingUpWidget());
    });

    final uutWidgets = {
      "flow_vm": () => const SimpleCounterScreen(),
      "BLoC": () => const BlocCounterScreen(),
      "StatefulWidget": () => const StatefulCounterScreen(),
      "Riverpod": () => const RiverpodSimpleScreen(),
    };

    for (int i = 0; i < numRuns; i++) {
      final uut =
          uutWidgets.entries.elementAt(random.nextInt(uutWidgets.length));
      testWidgets(uut.key, (WidgetTester tester) async {
        final elapsed = await tapRebuildPerformanceTest(tester, uut.value());
        times[uut.key]!.add(elapsed);
      });
    }

    test('Print average times', () {
      print("Benchmark simple test");
      for (final entry in times.entries) {
        final name = entry.key;
        final values = entry.value;
        if (values.isNotEmpty) {
          final average = values.reduce((a, b) => a + b) / values.length;
          print(
              'Average time with $name: ${average.toStringAsFixed(2)} microseconds of ${values.length} times');
        }
      }
    });
  });
}
