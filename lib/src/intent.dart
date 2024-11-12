import 'dart:async';

import 'package:flow_vm/flow_vm.dart';

/// A class representing an intent that performs an action on a [FlowVm].
///
/// The [Intent] class encapsulates an action that can be executed using an [Updater].
/// It provides a mechanism to asynchronously execute the action and track its completion status.
class Intent {
  /// Creates an [Intent] with the specified [action] and [intentKey].
  ///
  /// The [action] is a function that takes an [Updater] and performs changes on a [FlowVm].
  /// The [intentKey] is used to identify this intent uniquely.
  Intent({
    required IntentAction action,
    required this.intentKey,
  }) : _action = action;

  final Completer _completer = Completer();
  final IntentAction _action;

  /// A future that completes when the intent's action has been executed.
  Future<void> get completerFuture => _completer.future;

  /// Indicates whether the intent has been completed.
  bool get isCompleted => _completer.isCompleted;

  /// Executes the intent's action using the provided [Updater].
  ///
  /// Returns the [Intent] itself after the action has been executed.
  Future<Intent> execute(Updater updater) async {
    await _action(updater);
    _completer.complete();
    return this;
  }

  /// The key used to uniquely identify this intent.
  final Object intentKey;
}
