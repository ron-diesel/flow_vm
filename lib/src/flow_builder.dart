import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';

/// A widget that listens to a [DataFlow] and rebuilds when the value changes.
///
/// The [FlowBuilder] widget is useful for building a widget tree that reacts to changes in the state
/// managed by a [DataFlow]. It uses a [ValueListenableBuilder] to listen to the flow and updates
/// the UI whenever the value changes.
class FlowBuilder<T> extends StatelessWidget {
  /// Creates a [FlowBuilder] widget.
  ///
  /// The [flow] parameter provides the data to be listened to, and the [builder] function
  /// is used to build the widget tree with the current state.
  const FlowBuilder({
    super.key,
    required this.flow,
    required this.builder,
  });

  /// The [DataFlow] that provides the value to listen to and react to changes.
  final DataFlow<T> flow;

  /// A function that builds the widget tree using the current value from the [flow].
  final Builder<T> builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: flow.listenable,
      builder: (context, state, _) {
        return builder(context, state);
      },
    );
  }
}

/// A type definition for a function that builds a widget tree with the given data of type [T].
typedef Builder<T> = Widget Function(BuildContext context, T data);
