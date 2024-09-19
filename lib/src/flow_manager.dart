part of 'view_model.dart';

class _FlowManager implements Disposable {
  final List<Disposable> _disposables = [];

  @protected
  DataFlow<V> newDataFlow<V>(V value) {
    final newFlow = DataFlow(value);
    _disposables.add(newFlow);
    return newFlow;
  }

  @protected
  ActionFlow<V> newActionFlow<V>() {
    final newFlow = ActionFlow<V>();
    _disposables.add(newFlow);
    return newFlow;
  }

  @visibleForTesting
  DataFlow<V> newTestDataFlow<V>(V value) => newDataFlow(value);

  @visibleForTesting
  ActionFlow<V> newTestActionFlow<V>() => newActionFlow();

  @override
  @mustCallSuper
  void dispose() {
    for (var element in _disposables) {
      element.dispose();
    }
  }
}
