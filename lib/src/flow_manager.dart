part of 'view_model.dart';

class _FlowManager implements Disposable {
  final List<Disposable> _disposables = [];

  @protected
  DataFlow<V> newDataFlow<V>(V value) {
    final newFlow = _DataFlowMutable(value);
    _disposables.add(newFlow);
    return newFlow;
  }

  @protected
  ActionFlow<V> newActionFlow<V>() {
    final newFlow = _ActionFlowMutable<V>();
    _disposables.add(newFlow);
    return newFlow;
  }

  @override
  @mustCallSuper
  void dispose() {
    for (var element in _disposables) {
      element.dispose();
    }
  }
}
