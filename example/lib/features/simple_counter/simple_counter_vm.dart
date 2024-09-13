import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flow_vm/flow_vm.dart';

class SimpleCounterVM extends ViewModel {
  late final DataFlow<int> counterFlow = newDataFlow(0);

  void onIncrement() => intentNamed(
        action: _onIncrement,
        transformer: restartable(),
      );

  void _onIncrement(Updater emit) async {
    await Future.delayed(Duration(seconds: 1));
    emit(counterFlow).change((it) => it + 1);
  }
}
