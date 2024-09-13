import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

class FlowListener<T> extends StatefulWidget {
  const FlowListener({
    super.key,
    required this.flow,
    required this.listener,
    required this.child,
  });

  final FlowVm<T> flow;
  final Listener<T> listener;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _FlowListenerState<T>();
}

class _FlowListenerState<T> extends State<FlowListener<T>> {
  @override
  void initState() {
    super.initState();
    widget.flow.listenable.addListener(_onValueChanged);
  }

  @override
  void didUpdateWidget(FlowListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentNotifier = widget.flow.listenable;
    final oldNotifier = oldWidget.flow.listenable;
    if (currentNotifier != oldNotifier) {
      oldNotifier.removeListener(_onValueChanged);
      currentNotifier.addListener(_onValueChanged);
    }
  }

  @override
  void dispose() {
    widget.flow.listenable.removeListener(_onValueChanged);
    super.dispose();
  }

  void _onValueChanged() {
    widget.listener(context, widget.flow.listenable.value);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

typedef Listener<T> = void Function(BuildContext context, T data);
