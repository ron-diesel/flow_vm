# flow_vm

[![pub.dev](https://img.shields.io/pub/v/flow_vm.svg)](https://pub.dev/packages/flow_vm)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

`flow_vm` is a lightweight, fast, and predictable state management library for Flutter based on the ViewModel concept with first-class support for MVVM and MVI (via Intents).

## Highlights

- MVVM core with a small, focused API
- Intents for MVI-style state transitions and side effects
- Widgets for building and listening to data flows
- Built-in intent transformers (concurrent, sequential, debounced)
- Observer hooks for analytics/debugging of intents and mutations
- High performance with minimal rebuilds
- Type-safe and testable by design

## Install

Add `flow_vm` to your `pubspec.yaml`:

```yaml
dependencies:
  flow_vm: ^1.1.0
```

## Quick Start

Create a simple `ViewModel` with a `DataFlow` and render it with `FlowBuilder`:

```dart
import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

class SimpleCounterVM extends SimpleViewModel {
  late final DataFlow<int> counterFlow = dataFlow(0);

  void onIncrement() => update(counterFlow).change((value) => value + 1);
}

class SimpleCounterScreen extends StatelessWidget {
  const SimpleCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Disposer<SimpleCounterVM>(
      create: (_) => SimpleCounterVM(),
      builder: (context, viewModel) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have pushed the button this many times:'),
                FlowBuilder(
                  flow: viewModel.counterFlow,
                  builder: (context, count) => Text(
                    '$count',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.onIncrement,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
```

## Intents (MVI)

Use `intent` to model user actions and orchestrate state updates and side effects in one place.

```dart
class ExtendedCounterVM extends ViewModel {
  late final stateFlow = dataFlow(0);
  late final actionsFlow = actionFlow<String>(); // side effects

  void onIncrement() => intent(
        intentKey: #onIncrement,
        action: (Updater update) {
          final next = stateFlow.value + 1;
          update(stateFlow).set(next);
          update(actionsFlow).set('show success toast');
        },
      );
}
```

## Intent transformers

Control concurrency and handler behavior for intents. By default, processing is concurrent. You can choose `sequential`, `concurrent`, `debouncedRestartable`, or `debouncedSequential`.

```dart
class SearchVM extends ViewModel {
  final query = dataFlow('');
  final results = dataFlow<List<String>>([]);

  void onQueryChanged(String text) => intent(
        intentKey: #onQueryChanged,
        transformer: Transformers.debouncedRestartable(const Duration(milliseconds: 300)),
        action: (update) async {
          update(query).set(text);
          final items = await fetch(text);
          update(results).set(items);
        },
      );
}
```

Available transformers: `Transformers.concurrent()` (default), `Transformers.sequential()`, `Transformers.debouncedRestartable(duration)`, `Transformers.debouncedSequential(duration)`.

## ViewModelObserver

Observe the lifecycle of intents and flow mutations — useful for logging, analytics, and debugging.

```dart
class LoggerObserver implements ViewModelObserver {
  @override
  void onIntentStart(Symbol intentKey) => debugPrint('start: $intentKey');

  @override
  void onIntentExecuted(Symbol intentKey) => debugPrint('done: $intentKey');

  @override
  void onFlowUpdated(Symbol? intentKey, FlowVm flow, Mutation change) {
    debugPrint('update($intentKey): ${change.oldValue} -> ${change.newValue}');
  }

  @override
  void onIntentCanceled(Symbol intentKey) => debugPrint('canceled: $intentKey');
}

final vm = SimpleCounterVM()..addObserver(LoggerObserver());
```

## Widgets

- `FlowBuilder<T>`: Rebuilds UI when `DataFlow<T>` emits new values.
- `FlowListener<T>`: Listens to actions/one-off events without rebuilding UI.
- `Disposer<VM>`: Creates and disposes a `ViewModel` for a subtree.

## Why flow_vm?

- Clear separation of state and side effects
- No boilerplate code generators
- Simple migration path from classic MVVM to MVI
- Works across all Flutter platforms

## Example App

Explore the examples under `example/` showcasing simple and extended patterns with Bloc and Riverpod comparisons.

## Testing

The repository includes unit and widget tests for `ViewModel`, observers, listeners, and concurrency. Run with `flutter test`.

## Roadmap

- More recipes and docs
- DevTools integration examples
- Additional intent transformers and utilities

## License

MIT License — see [LICENSE](./LICENSE).
