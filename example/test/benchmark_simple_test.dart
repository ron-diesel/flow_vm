import 'dart:math';

import 'package:example/features/bloc_example/bloc_counter_screen.dart';
import 'package:example/features/simple_counter/simple_counter_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/benchmark.dart';
import 'utils/warming_up_widget.dart';

void main() {
  final random = Random();
  const numRuns = 100;
  final times = <String, List<int>>{
    "ViewModel": [],
    "BLoC": [],
    "Stateful": [],
  };

  group("Benchmarks", () {
    testWidgets('Warming Up', (WidgetTester tester) async {
      await benchmarkTest(tester, const WarmingUpWidget(), 'Warming Up');
    });

    final uutWidgets = {
      "ViewModel": () => const SimpleCounterScreen(),
      "BLoC": () => const BlocCounterScreen(),
      "Stateful": () => const StatefulCounter(),
    };

    for (int i = 0; i < numRuns; i++) {
      final uut = uutWidgets.entries.elementAt(random.nextInt(uutWidgets.length));
      testWidgets(uut.key, (WidgetTester tester) async {
        final elapsed = await benchmarkTest(tester, uut.value(), uut.key);
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
