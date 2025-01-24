import 'package:example/common/random_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдеры для управления состоянием
final counterProvider = StateProvider<int>((ref) => 0);
final sumProvider = StateProvider<int>((ref) => 0);
final logsProvider = StateProvider<List<int>>((ref) => []);
final messageProvider = StateProvider<String>((ref) => "");

class RiverpodExtendedScreen extends StatelessWidget {
  const RiverpodExtendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _RiverpodExtendedScreen());
  }
}

class _RiverpodExtendedScreen extends ConsumerWidget {
  const _RiverpodExtendedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final sum = ref.watch(sumProvider);
    final logs = ref.watch(logsProvider);
    final message = ref.watch(messageProvider);

    void incrementCounter() {
      final newCount = count + 1;
      final newSum = sum + newCount;

      ref.read(counterProvider.notifier).state = newCount;
      ref.read(sumProvider.notifier).state = newSum;
      ref.read(logsProvider.notifier).state = [...logs, newCount];
      ref.read(messageProvider.notifier).state = RandomMessage.get();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text("Sum: $sum"),
            const SizedBox(height: 20),
            Text("Logs: $logs"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
