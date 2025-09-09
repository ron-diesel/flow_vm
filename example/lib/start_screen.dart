import 'package:example/features/bloc_simple/bloc_counter_screen.dart';
import 'package:example/features/riverpod_extended/riverpod_extended_screen.dart';
import 'package:example/features/riverpod_simple/riverpod_simple_screen.dart';
import 'package:example/features/stateful_extended/stateful_counter_extended_screen.dart';
import 'package:flutter/material.dart';

import 'features/bloc_extended/bloc_counter_extended_screen.dart';
import 'features/flow_vm_extended/extended_counter_screen.dart';
import 'features/flow_vm_simple/simple_counter_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Row(
              label: "StatefulWidget:",
              children: [
                _NavButton(label: 'Simple', page: SimpleCounterScreen()),
                _NavButton(
                  label: 'Extended',
                  page: StatefulCounterExtendedScreen(),
                ),
              ],
            ),
            _Row(
              label: "flow_vm:",
              children: [
                _NavButton(label: 'Simple', page: SimpleCounterScreen()),
                _NavButton(
                  label: 'Extended',
                  page: ExtendedCounterScreen(),
                ),
              ],
            ),
            _Row(
              label: "BLoC:",
              children: [
                _NavButton(label: 'Simple', page: BlocCounterScreen()),
                _NavButton(
                  label: 'Extended',
                  page: BlocCounterExtendedScreen(),
                ),
              ],
            ),
            _Row(
              label: "Riverpod:",
              children: [
                _NavButton(label: 'Simple', page: RiverpodSimpleScreen()),
                _NavButton(
                  label: 'Extended',
                  page: RiverpodExtendedScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final List<Widget> children;
  final String label;

  const _Row({
    required this.children,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Row(
            children: children.map((child) => Expanded(child: child)).toList(),
          ),
        ],
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
