import 'dart:async';

import 'package:flow_vm/src/disposable.dart';
import 'package:flow_vm/src/flow_notifier.dart';
import 'package:flow_vm/src/intent.dart';
import 'package:flow_vm/src/updater.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_transform/stream_transform.dart';

part 'flow.dart';

part 'flow_manager.dart';

abstract class ViewModel extends _FlowManager {
  final StreamController<Intent> _intentController =
      StreamController.broadcast();
  final Map<Object, StreamSubscription<Intent>> _subscriptions = {};
  final List<Intent> _activeIntents = [];

  @protected
  void intent({
    required Object queueKey,
    IntentTransformer? transformer,
    required IntentAction action,
  }) {
    if (!_subscriptions.containsKey(queueKey)) {
      _subscribe(queueKey, transformer ?? _defaultTransformer);
    }

    _intentController.add(Intent(action: action, intentKey: queueKey));
  }

  @protected
  void intentNamed({
    IntentTransformer? transformer,
    required IntentAction action,
  }) {
    intent(queueKey: action.hashCode, action: action, transformer: transformer);
  }

  @override
  @mustCallSuper
  void dispose() {
    _intentController.close();
    for (var item in _subscriptions.values) {
      item.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  void _subscribe(Object queueKey, IntentTransformer transformer) {
    final stream = _intentController.stream
        .where((intent) => intent.intentKey == queueKey);

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

    _subscriptions[queueKey] = subscription;
  }

  @visibleForTesting
  Future<void> awaitCurrentIntents() =>
      Future.wait(_activeIntents.map((intent) => intent.completerFuture));

  void onError(Object error, StackTrace stackTrace) {}
}

abstract class SimpleViewModel extends ViewModel {
  Updater get update => UpdaterImpl._();
}

final class TestableViewModel extends SimpleViewModel {
  @visibleForTesting
  TestableViewModel();

  StreamController<Intent> get intentController => _intentController;

  Map<Object, StreamSubscription<Intent>> get subscriptions => _subscriptions;
}

class UpdaterImpl implements Updater {
  UpdaterImpl._();

  bool _isCanceled = false;

  @override
  MutableFlow<T> call<T>(FlowVm<T> flow) {
    return _isCanceled ? _DummyFlow() : _MutableFlow<T>(flow);
  }

  void cancel() {
    _isCanceled = true;
  }
}

typedef IntentAction = FutureOr<void> Function(Updater update);

typedef IntentMapper = Stream<Intent> Function(Intent intent);
typedef IntentTransformer = Stream<Intent> Function(
  Stream<Intent> intents,
  IntentMapper mapper,
);

IntentTransformer get _defaultTransformer {
  return (intents, mapper) => intents.concurrentAsyncExpand(mapper);
}
