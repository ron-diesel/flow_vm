import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

/// A widget that listens to changes in a [FlowVm] and triggers a callback when the value changes.
///
/// The [FlowListener] widget is useful for performing side effects in response to changes in the state
/// managed by a [FlowVm]. It listens to the value and calls the provided [listener] function whenever
/// the value changes, without rebuilding the UI.
class FlowListener<T> extends StatefulWidget {
  /// Creates a [FlowListener] widget.
  ///
  /// The [flow] parameter provides the data to be listened to, the [listener] function is called
  /// whenever the value changes, and the [child] widget is the UI that remains unchanged.
  const FlowListener({
    super.key,
    required this.flow,
    required this.listener,
    required this.child,
  });

  /// The [FlowVm] that provides the value to listen to and react to changes.
  final FlowVm<T> flow;

  /// A function that is called whenever the value in the [flow] changes.
  final Listener<T> listener;

  /// The child widget that is displayed and does not rebuild when the value changes.
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

/// A type definition for a function that is called with the given data of type [T] whenever the value changes.
typedef Listener<T> = void Function(BuildContext context, T data);
