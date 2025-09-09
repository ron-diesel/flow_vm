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
