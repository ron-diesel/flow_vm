part of 'view_model.dart';

/// A sealed class that provides base functionality for managing state using a [FlowNotifier].
///
/// The [FlowVm] class serves as a base for creating stateful flows.
/// It manages the lifecycle of a [FlowNotifier], allowing state changes and value listening.
sealed class FlowVm<T> implements Disposable {
  /// Creates a [FlowVm] instance with a [FlowNotifier].
  FlowVm(this._notifier);

  final FlowNotifier<T> _notifier;

  /// Disposes the underlying [FlowNotifier] when no longer needed.
  @override
  void dispose() {
    _notifier.dispose();
  }

  /// Provides a [ValueListenable] to observe value changes of the flow.
  ValueListenable<T> get listenable => _notifier;

  /// Updates the value of the [FlowNotifier].
  void _set(T value) {
    _notifier.value = value;
  }

  /// Method for testing purposes that allows setting a value.
  @visibleForTesting
  void testSet(T value) => _set(value);

  /// Changes the current value by applying the given [change] function.
  void _change(Change<T> change) {
    _set(change(value));
  }

  /// Returns the current value of the [FlowNotifier].
  T get value => _notifier.value;
}

/// A class that represents a data flow with an initial value.
final class DataFlow<T> extends FlowVm<T> {
  /// Creates a [DataFlow] with an initial [value].
  @visibleForTesting
  DataFlow(T value) : super(FlowNotifier(value: value, isLazy: false));
}

/// A class that represents an action flow without an initial value.
final class ActionFlow<T> extends FlowVm<T> {
  /// Creates an [ActionFlow] with a lazy initialization.
  @visibleForTesting
  ActionFlow() : super(FlowNotifier(value: null, isLazy: true));

  /// Sets a value to the [FlowNotifier], forcing the update.
  @override
  void _set(T value) {
    _notifier.forceValue(value);
  }
}

/// A sealed class that defines a mutable interface for [FlowVm].
sealed class MutableFlow<T> {
  /// Sets the value of the flow.
  void set(T value);

  /// Changes the current value by applying the given [change] function.
  void change(Change<T> change);
}

/// A concrete implementation of [MutableFlow] that allows modifying a [FlowVm].
class _MutableFlow<T> extends MutableFlow<T> {
  _MutableFlow(this._flow);

  final FlowVm<T> _flow;

  /// Sets a new value to the flow.
  @override
  void set(T value) => _flow._set(value);

  /// Changes the current value by applying the given [change] function.
  @override
  void change(Change<T> change) => _flow._change(change);
}

/// A dummy implementation of [MutableFlow] that does nothing.
///
/// Useful as a placeholder where a mutable flow interface is required but no operations are needed.
class _DummyFlow<T> implements MutableFlow<T> {
  @override
  void change(Change<T> change) {}

  @override
  void set(T value) {}
}

/// A function type that represents a transformation of a value of type [T].
typedef Change<T> = T Function(T it);
