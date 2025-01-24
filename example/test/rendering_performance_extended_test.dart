// ignore_for_file: avoid_print
import 'dart:math';

import 'package:example/features/bloc_extended_example/bloc_counter_extended_screen.dart';
import 'package:example/features/extended_counter/extended_counter_screen.dart';
import 'package:example/features/riverpod_extended/riverpod_extended_screen.dart';
import 'package:example/features/stateful_extended/stateful_counter_extended_screen.dart';
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
      await tapRebuildPerformanceTest(
          tester, const WarmingUpWidget());
    });

    final uutWidgets = {
      "flow_vm": () => const ExtendedCounterScreen(),
      "BLoC": () => const BlocCounterExtendedScreen(),
      "StatefulWidget": () => const StatefulCounterExtendedScreen(),
      "Riverpod": () => const RiverpodExtendedScreen(),
    };

    for (int i = 0; i < numRuns; i++) {
      final uut =
          uutWidgets.entries.elementAt(random.nextInt(uutWidgets.length));
      testWidgets(uut.key, (WidgetTester tester) async {
        final elapsed =
            await tapRebuildPerformanceTest(tester, uut.value());
        times[uut.key]!.add(elapsed);
      });
    }

    test('Print average times', () {
      print("Benchmark extended test");
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
