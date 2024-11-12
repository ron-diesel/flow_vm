import 'package:flow_vm/src/disposable.dart';
import 'package:flutter/cupertino.dart';

/// A widget that manages the lifecycle of a [Disposable] target.
///
/// The [Disposer] widget creates an instance of the target using the provided [create] function
/// and ensures that the target's [dispose] method is called when the widget is disposed.
/// This is useful for managing resources that need to be explicitly released.
class Disposer<T extends Disposable> extends StatefulWidget {
  /// Creates a [Disposer] widget.
  ///
  /// The [create] function is used to instantiate the target, and the [builder] function
  /// is used to build the widget tree with the created target.
  const Disposer({
    super.key,
    required this.create,
    required this.builder,
  });

  /// A function that creates the target of type [T].
  final TargetCreator<T> create;

  /// A function that builds the widget tree using the created target.
  final TargetBuilder<T> builder;

  @override
  State<Disposer<T>> createState() => _DisposerState<T>();
}

class _DisposerState<T extends Disposable> extends State<Disposer<T>> {
  late final T target;

  @override
  void initState() {
    target = widget.create(context);
    super.initState();
  }

  @override
  void dispose() {
    target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, target);
  }
}

/// A type definition for a function that creates a target of type [T].
typedef TargetCreator<T extends Disposable> = T Function(BuildContext context);

/// A type definition for a function that builds a widget tree with the given target of type [T].
typedef TargetBuilder<T extends Disposable> = Widget Function(
  BuildContext context,
  T target,
);
