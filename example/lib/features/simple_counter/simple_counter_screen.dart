import 'package:example/features/simple_counter/simple_counter_vm.dart';
import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

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
                        style: Theme.of(context).textTheme.headlineMedium,
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
