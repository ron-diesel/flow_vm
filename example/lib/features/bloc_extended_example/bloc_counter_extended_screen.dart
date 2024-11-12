import 'package:example/features/bloc_extended_example/counter_extended_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocCounterExtendedScreen extends StatelessWidget {
  const BlocCounterExtendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterExtendedBloc(),
      child: Builder(builder: (context) {
        return Scaffold(
          body: Center(
            child: BlocBuilder<CounterExtendedBloc, CounterState>(
                builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(state.message),
                  const SizedBox(height: 20),
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '${state.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Text("Sum: ${state.sum}"),
                  const SizedBox(height: 20),
                  Text("Logs: ${state.logs}"),
                ],
              );
            }),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                context.read<CounterExtendedBloc>().add(Increment()),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }
}
