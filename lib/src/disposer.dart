import 'package:flow_vm/src/disposable.dart';
import 'package:flutter/cupertino.dart';

class Disposer<T extends Disposable> extends StatefulWidget {
  const Disposer({
    super.key,
    required this.create,
    required this.builder,
  });

  final TargetCreator<T> create;
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

typedef TargetCreator<T extends Disposable> = T Function(BuildContext context);
typedef TargetBuilder<T extends Disposable> = Widget Function(
  BuildContext context,
  T target,
);
