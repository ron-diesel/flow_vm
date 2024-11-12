import 'dart:async';

import 'package:flow_vm/src/disposable.dart';
import 'package:flow_vm/src/flow_notifier.dart';
import 'package:flow_vm/src/intent.dart';
import 'package:flow_vm/src/updater.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_transform/stream_transform.dart';

part 'flow.dart';

part 'flow_manager.dart';

/// The `ViewModel` class provides the base functionality for managing intents and flows.
///
/// This abstract class extends `_FlowManager` and handles the processing of intents.
/// It includes methods to add new intents, manage intent subscriptions, and handle disposal.
abstract class ViewModel extends _FlowManager {
  /// A stream controller for managing intents, allowing broadcast to multiple listeners.
  @visibleForTesting
  final StreamController<Intent> intentController =
      StreamController.broadcast();

  /// A map to keep track of active intent subscriptions based on queue keys.
  @visibleForTesting
  final Map<Object, StreamSubscription<Intent>> subscriptions = {};

  /// A list of currently active intents.
  final List<Intent> _activeIntents = [];

  /// Adds a new intent to the queue.
  ///
  /// - [queueKey]: The key used to manage the queue for this intent.
  /// - [transformer]: An optional transformer for transforming the intent stream.
  /// - [action]: The action associated with the intent.
  ///
  /// If the queueKey has no existing subscription, a new subscription is created.
  @protected
  void intent({
    required Object queueKey,
    IntentTransformer? transformer,
    required IntentAction action,
  }) {
    if (!subscriptions.containsKey(queueKey)) {
      _subscribe(queueKey, transformer ?? _defaultTransformer);
    }

    intentController.add(Intent(action: action, intentKey: queueKey));
  }

  /// Adds a new intent using a named action.
  ///
  /// - [transformer]: An optional transformer for transforming the intent stream.
  /// - [action]: The action associated with the intent.
  ///
  /// Uses the hash code of the action as the queue key.
  @protected
  void intentNamed({
    IntentTransformer? transformer,
    required IntentAction action,
  }) {
    intent(queueKey: action.hashCode, action: action, transformer: transformer);
  }

  /// Disposes of the ViewModel by closing the intent controller and canceling all subscriptions.
  ///
  /// Ensures that resources are properly cleaned up to prevent memory leaks.
  @override
  @mustCallSuper
  void dispose() {
    intentController.close();
    for (var item in subscriptions.values) {
      item.cancel();
    }
    subscriptions.clear();
    super.dispose();
  }

  /// Subscribes to intents for the given [queueKey] using the provided [transformer].
  ///
  /// The subscription listens to the transformed stream and adds it to the list of subscriptions.
  void _subscribe(Object queueKey, IntentTransformer transformer) {
    final stream =
        intentController.stream.where((intent) => intent.intentKey == queueKey);

    final transformedStream = transformer(
      stream,
      (intent) {
        _activeIntents.add(intent);
        final updater = UpdaterImpl._();

        final controller = StreamController<Intent>.broadcast(
          sync: true,
          onCancel: updater.cancel,
        );

        Future<void> handleIntent() async {
          try {
            if (!controller.isClosed) await intent.execute(updater);
          } catch (error, stackTrace) {
            onError(error, stackTrace);
            rethrow;
          } finally {
            _activeIntents.remove(intent);
            if (!controller.isClosed) controller.close();
          }
        }

        handleIntent();
        return controller.stream;
      },
    );

    final subscription = transformedStream.listen(null);

    subscriptions[queueKey] = subscription;
  }

  /// Awaits all currently active intents to complete.
  ///
  /// Useful for testing purposes to ensure all intents have finished processing.
  @visibleForTesting
  Future<void> awaitCurrentIntents() =>
      Future.wait(_activeIntents.map((intent) => intent.completerFuture));

  /// Handles errors that occur during intent execution.
  ///
  /// Override this method to provide custom error handling logic.
  void onError(Object error, StackTrace stackTrace) {}
}

/// A simplified version of `ViewModel` that provides an `Updater` for updates.
abstract class SimpleViewModel extends ViewModel {
  /// Provides an instance of `Updater` for state updates.
  Updater get update => _update;
  final UpdaterImpl _update = UpdaterImpl._();

  @override
  @mustCallSuper
  void dispose() {
    _update.cancel();
    super.dispose();
  }
}

/// An implementation of `Updater` used to manage state changes.
class UpdaterImpl implements Updater {
  UpdaterImpl._();

  bool _isCanceled = false;

  /// Creates a mutable flow if the updater has not been canceled.
  ///
  /// If the updater is canceled, returns a dummy flow that does not allow modifications.
  @override
  MutableFlow<T> call<T>(FlowVm<T> flow) {
    return _isCanceled ? _DummyFlow() : _MutableFlow<T>(flow);
  }

  /// Cancels the updater, preventing further state modifications.
  void cancel() {
    _isCanceled = true;
  }
}

/// A function type representing an action that takes an `Updater` for state updates.
typedef IntentAction = FutureOr<void> Function(Updater update);

/// A function type representing a mapper that transforms an `Intent`.
typedef IntentMapper = Stream<Intent> Function(Intent intent);

/// A function type representing a transformer that transforms a stream of `Intent` objects.
typedef IntentTransformer = Stream<Intent> Function(
  Stream<Intent> intents,
  IntentMapper mapper,
);

/// The default intent transformer that uses `concurrentAsyncExpand` to process intents concurrently.
IntentTransformer get _defaultTransformer {
  return (intents, mapper) => intents.concurrentAsyncExpand(mapper);
}
