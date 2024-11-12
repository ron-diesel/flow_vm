import 'package:flutter/foundation.dart';

/// A notifier that holds a value and notifies listeners when the value changes.
///
/// The [FlowNotifier] class implements [ValueListenable] to allow observing changes to the value.
/// It provides both lazy and non-lazy initialization, allowing flexible value management.
class FlowNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Creates a [FlowNotifier] with an optional initial [value].
  ///
  /// The [isLazy] parameter determines if the value is lazily initialized.
  /// If [isLazy] is false, the value must be provided and initialized immediately.
  FlowNotifier({T? value, bool isLazy = false}) {
    if (!isLazy) {
      _isInitialized = true;
      _value = value as T;
    }

    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  late T _value;
  bool _isInitialized = false;

  /// Returns the current value.
  ///
  /// Throws a [StateError] if the value has not been initialized.
  @override
  T get value {
    if (!_isInitialized) {
      throw StateError('Value has not been initialized.');
    }
    return _value;
  }

  /// Sets a new value and notifies listeners if the value has changed.
  set value(T newValue) {
    if (_isInitialized && _value == newValue) {
      return;
    }
    _isInitialized = true;
    _value = newValue;
    notifyListeners();
  }

  /// Forces the value to be updated and optionally notifies listeners even if the value is unchanged.
  void forceValue(T newValue) {
    final isNeedNotify = _isInitialized && newValue == _value;
    value = newValue;
    if (isNeedNotify) notifyListeners();
  }

  /// Returns a string representation of the [FlowNotifier], including the current value if initialized.
  @override
  String toString() =>
      '${describeIdentity(this)}(${_isInitialized ? value : 'not initialized yet'})';
}
