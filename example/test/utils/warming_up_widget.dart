import 'package:flutter/material.dart';

class WarmingUpWidget extends StatelessWidget {
  const WarmingUpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const Text("1"),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

class StatefulCounter extends StatefulWidget {
  const StatefulCounter({super.key});

  @override
  State<StatefulWidget> createState() => _StatefulCounterState();
}

class _StatefulCounterState extends State<StatefulCounter> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}
