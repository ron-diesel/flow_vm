import 'package:example/features/bloc_example/bloc_counter_screen.dart';
import 'package:example/features/bloc_extended_example/bloc_counter_extended_screen.dart';
import 'package:example/features/extended_counter/extended_counter_screen.dart';
import 'package:example/features/simple_counter/simple_counter_screen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavButton(label: 'Simple flow_vm', page: SimpleCounterScreen()),
            _NavButton(
              label: 'Extended flow_vm',
              page: ExtendedCounterScreen(),
            ),
            _NavButton(label: 'Simple BLoC', page: BlocCounterScreen()),
            _NavButton(
              label: 'Extended BLoC',
              page: BlocCounterExtendedScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final Widget page;

  const _NavButton({required this.label, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return page;
            },
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
