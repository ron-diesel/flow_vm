import 'dart:async';

import 'package:flow_vm/flow_vm.dart';
import 'package:flow_vm/src/flow_notifier.dart';
import 'package:flutter/foundation.dart';

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
  final Map<Symbol, StreamSubscription<Intent>> subscriptions = {};

  final List<ViewModelObserver> _observers = [];

  /// A list of currently active intents.
  final List<Intent> _activeIntents = [];

  @mustCallSuper
  void addObserver(ViewModelObserver observer) {
    _observers.add(observer);
  }

  @mustCallSuper
  void removeObserver(ViewModelObserver observer) {
    _observers.remove(observer);
  }

  @mustCallSuper
  void removeAllObservers() {
    _observers.clear();
  }

  /// Adds a new intent to the queue.
  ///
  /// - [intentKey]: The key used to manage the queue for this intent.( use #nameOfMethod)
  /// - [transformer]: An optional transformer for transforming the intent stream.
  /// - [action]: The action associated with the intent.
  ///
  /// If the intentKey has no existing subscription, a new subscription is created.
  @protected
  void intent({
    required Symbol intentKey,
    IntentTransformer? transformer,
    required IntentAction action,
  }) {
    for (var observer in _observers) {
      observer.onIntentStart(intentKey);
    }
    if (!subscriptions.containsKey(intentKey)) {
      _subscribe(
        intentKey,
        transformer ?? Transformers.defaultTransformer,
      );
    }

    intentController.add(Intent(action: action, intentKey: intentKey));
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

  /// Subscribes to intents for the given [intentKey] using the provided [transformer].
  ///
  /// The subscription listens to the transformed stream and adds it to the list of subscriptions.
  void _subscribe(Symbol intentKey, IntentTransformer transformer) {
    final stream = intentController.stream
        .where((intent) => intent.intentKey == intentKey);

    final transformedStream = transformer(
      stream,
      (intent) {
        _activeIntents.add(intent);
        final updater = UpdaterImpl._(intent.intentKey, () => _observers);

        final controller = StreamController<Intent>.broadcast(
          sync: true,
          onCancel: updater.cancel,
        );

        Future<void> handleIntent() async {
          try {
            if (!controller.isClosed) {
              await intent.execute(updater);
              for (var observer in _observers) {
                observer.onIntentExecuted(intent.intentKey);
              }
            }
          } catch (error, stackTrace) {
            onError(error, stackTrace);
            rethrow;
          } finally {
            intent.complete();
            _activeIntents.remove(intent);
            if (!controller.isClosed) controller.close();
          }
        }

        handleIntent();
        return controller.stream;
      },
    );

    final subscription = transformedStream.listen(null);

    subscriptions[intentKey]?.cancel();
    subscriptions[intentKey] = subscription;
  }

  /// Awaits all currently active intents to complete.
  ///
  /// Useful for testing purposes to ensure all intents have finished processing.
  @visibleForTesting
  Future<void> awaitCurrentIntents() async {
    await Future.delayed(Duration.zero);
    await Future.wait(_activeIntents.map((intent) => intent.completerFuture));
  }

  /// Handles errors that occur during intent execution.
  ///
  /// Override this method to provide custom error handling logic.
  void onError(Object error, StackTrace stackTrace) {}
}

/// A simplified version of `ViewModel` that provides an `Updater` for updates.
abstract class SimpleViewModel extends ViewModel {
  /// Provides an instance of `Updater` for state updates.
  Updater get update => _update;
  late final UpdaterImpl _update = UpdaterImpl._(null, () => _observers);

  @override
  @mustCallSuper
  void dispose() {
    _update.cancel();
    super.dispose();
  }
}

/// An implementation of `Updater` used to manage state changes.
class UpdaterImpl implements Updater {
  UpdaterImpl._(this._intentKey, this._observersGetter);

  final ValueGetter<List<ViewModelObserver>> _observersGetter;
  final Symbol? _intentKey;

  bool _isCanceled = false;

  /// Creates a mutable flow if the updater has not been canceled.
  ///
  /// If the updater is canceled, returns a dummy flow that does not allow modifications.
  @override
  MutableFlow<T> call<T>(FlowVm<T> flow) {
    if (_isCanceled) {
      return _DummyFlow();
    } else {
      return _MutableFlow<T>(flow, (value) {
        for (var observer in _observersGetter()) {
          observer.onFlowUpdated<T>(_intentKey, flow, value);
        }
      });
    }
  }

  /// Cancels the updater, preventing further state modifications.
  void cancel() {
    _isCanceled = true;
    final intentKey = _intentKey;
    if (intentKey != null) {
      for (var observer in _observersGetter()) {
        observer.onIntentCanceled(intentKey);
      }
    }
  }
}

/// A function type representing an action that takes an `Updater` for state updates.
typedef IntentAction = FutureOr<void> Function(Updater update);

/// A function type representing a mapper that transforms an `Intent`.
typedef IntentMapper = Stream<Intent> Function(Intent intent);
