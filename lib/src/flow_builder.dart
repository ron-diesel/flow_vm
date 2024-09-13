import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

class FlowBuilder<T> extends StatelessWidget {
  const FlowBuilder({
    super.key,
    required this.flow,
    required this.builder,
  });

  final DataFlow<T> flow;
  final Builder<T> builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: flow.listenable,
        builder: (context, state, _) {
          return builder(context, state);
        });
  }
}

typedef Builder<T> = Widget Function(BuildContext context, T data);
