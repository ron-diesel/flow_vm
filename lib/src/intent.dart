import 'dart:async';

import 'package:flow_vm/flow_vm.dart';

class Intent {
  Intent({
    required IntentAction action,
    required this.intentKey,
  }) : _action = action;
  final Completer _completer = Completer();
  final IntentAction _action;

  Future<void> get completerFuture => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  Future<Intent> execute(Updater updater) async {
    await _action(updater);
    _completer.complete();
    return this;
  }

  final Object intentKey;
}
