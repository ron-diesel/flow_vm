part of 'view_model.dart';

sealed class FlowVm<T> implements Disposable {
  FlowVm(this._notifier);

  final FlowNotifier<T> _notifier;

  @override
  void dispose() {
    _notifier.dispose();
  }

  ValueListenable<T> get listenable => _notifier;

  _set(T value) {
    _notifier.value = value;
  }

  @visibleForTesting
  testSet(T value) => _set(value);

  void _change(Change<T> change) {
    _set(change(value));
  }

  T get value => _notifier.value;
}

final class DataFlow<T> extends FlowVm<T> {
  @visibleForTesting
  DataFlow(T value) : super(FlowNotifier(value: value, isLazy: false));
}

final class ActionFlow<T> extends FlowVm<T> {
  @visibleForTesting
  ActionFlow() : super(FlowNotifier(value: null, isLazy: true));

  @override
  void _set(T value) {
    _notifier.forceValue(value);
  }
}

sealed class MutableFlow<T> {
  void set(T value);

  void change(Change<T> change);
}

class _MutableFlow<T> extends MutableFlow<T> {
  _MutableFlow(this._flow);

  final FlowVm<T> _flow;

  @override
  void set(T value) => _flow._set(value);

  @override
  void change(Change<T> change) => _flow._change(change);
}

class _DummyFlow<T> implements MutableFlow<T> {
  @override
  void change(Change<T> change) {}

  @override
  void set(T value) {}
}

typedef Change<T> = T Function(T it);
