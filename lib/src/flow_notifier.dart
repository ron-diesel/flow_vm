import 'package:flutter/foundation.dart';

class FlowNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
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

  @override
  T get value {
    if (!_isInitialized) {
      throw StateError('Value has not been initialized.');
    }
    return _value;
  }

  set value(T newValue) {
    if (_isInitialized && _value == newValue) {
      return;
    }
    _isInitialized = true;
    _value = newValue;
    notifyListeners();
  }

  void forceValue(T newValue) {
    final isNeedNotify = _isInitialized && newValue == _value;
    value = newValue;
    if (isNeedNotify) notifyListeners();
  }

  @override
  String toString() =>
      '${describeIdentity(this)}(${_isInitialized ? value : 'not initialized yet'})';
}
