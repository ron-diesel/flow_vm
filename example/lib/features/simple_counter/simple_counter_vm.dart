import 'package:flow_vm/flow_vm.dart';

class SimpleCounterVM extends ViewModel {
  late final DataFlow<int> counterFlow = newDataFlow(0);

  void onIncrement() => intentNamed(
        action: _onIncrement,
      );

  void _onIncrement(Updater emit) {
    emit(counterFlow).change((it) => it + 1);
  }
}
