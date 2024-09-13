part of 'view_model.dart';

abstract interface class MutableFlow<T> {
  void set(T value);

  void change(Change<T> change);
}

sealed class FlowVm<T> implements Disposable {
  FlowVm(this._notifier);

  final FlowNotifier<T> _notifier;

  @override
  void dispose() {
    _notifier.dispose();
  }

  ValueListenable<T> get listenable => _notifier;

  _setValue(T value) {
    _notifier.value = value;
  }

  T get value => _notifier.value;
}

class DataFlow<T> extends FlowVm<T> {
  @visibleForTesting
  DataFlow(T value) : super(FlowNotifier(value: value, isLazy: false));
}

class _DataFlowMutable<T> extends DataFlow<T> with _Mutable<T> {
  _DataFlowMutable(super.value);
}

class ActionFlow<T> extends FlowVm<T> with _Mutable<T> {
  @visibleForTesting
  ActionFlow() : super(FlowNotifier(value: null, isLazy: true));

  @override
  void _setValue(T value) {
    _notifier.forceValue(value);
  }
}

class _ActionFlowMutable<T> extends ActionFlow<T> with _Mutable<T> {
  _ActionFlowMutable();
}

mixin _Mutable<T> on FlowVm<T> implements MutableFlow<T> {
  @override
  void set(T value) {
    _setValue(value);
  }

  @override
  void change(Change<T> change) {
    _setValue(change(value));
  }
}

typedef Change<T> = T Function(T it);
