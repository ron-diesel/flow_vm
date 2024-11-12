import 'package:example/features/extended_counter/extended_counter_vm.dart';
import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

class ExtendedCounterScreen extends StatelessWidget {
  const ExtendedCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Disposer(
        create: (_) => ExtendedCounterVM(),
        builder: (BuildContext context, ExtendedCounterVM viewModel) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlowBuilder(
                      flow: viewModel.messageFlow,
                      builder: (context, message) {
                        return Text(message);
                      }),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  FlowBuilder(
                      flow: viewModel.sumFlow,
                      builder: (context, sum) {
                        return Text("Sum: $sum");
                      }),
                  const SizedBox(height: 20),
                  FlowBuilder(
                      flow: viewModel.logsFlow,
                      builder: (context, logs) {
                        return Text("Logs: $logs");
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
        });
  }
}
