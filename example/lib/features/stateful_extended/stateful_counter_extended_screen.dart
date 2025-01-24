import 'package:example/common/random_message.dart';
import 'package:flutter/material.dart';

class StatefulCounterExtendedScreen extends StatefulWidget {
  const StatefulCounterExtendedScreen({super.key});

  @override
  State<StatefulCounterExtendedScreen> createState() =>
      _StatefulCounterExtendedScreenState();
}

class _StatefulCounterExtendedScreenState
    extends State<StatefulCounterExtendedScreen> {
  int _count = 0;
  int _sum = 0;
  final List<int> _logs = [];
  String _message = "";

  void _incrementCounter() {
    setState(() {
      _count++;
      _sum += _count;
      _logs.add(_count);
      _message = RandomMessage.get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_message),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text("Sum: $_sum"),
            const SizedBox(height: 20),
            Text("Logs: $_logs"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
