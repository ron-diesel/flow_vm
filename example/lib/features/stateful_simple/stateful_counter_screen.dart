import 'package:flutter/material.dart';

class StatefulCounterScreen extends StatefulWidget {
  const StatefulCounterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StatefulCounterScreenState();
}

class _StatefulCounterScreenState extends State<StatefulCounterScreen> {
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
