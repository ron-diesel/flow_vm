# flow_vm

`flow_vm` is a state management solution for Flutter applications, providing a streamlined and efficient way to
manage ViewModel-based architectures. It aims to make handling application state simpler,
more predictable, and highly performant.

### Key Features:

- MVVM Architecture: `flow_vm` is built around the MVVM (Model-View-ViewModel) architecture, providing a clear
  separation of concerns.
- Intents for MVI Architecture: Flow VM supports Intents, which extend the classic ViewModel pattern to make
  the architecture more aligned with the MVI (Model-View-Intent) pattern. This allows for better handling of user
  interactions and side effects, making the application state flow more predictable and easier to manage.
- Ease of Use: Designed to be intuitive and easy to implement for managing state across Flutter applications.
- Performance: Optimized for high performance, ensuring quick updates with minimal overhead.

## Getting Started

Add `flow_vm` to your project's dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flow_vm: ^1.0.0
```

## Usage

```dart
import 'package:example/features/simple_counter/simple_counter_vm.dart';
import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

class SimpleCounterVM extends SimpleViewModel {
  late final DataFlow<int> counterFlow = this.dataFlow(0);

  void onIncrement() {
    update(counterFlow).change((it) => it + 1);
  }
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
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                FlowBuilder(
                    flow: viewModel.counterFlow,
                    builder: (context, count) {
                      return Text(
                        '$count',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineMedium,
                      );
                    }),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.onIncrement,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
