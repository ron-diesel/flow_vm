import 'package:flow_vm/flow_vm.dart';

class SimpleCounterVM extends SimpleViewModel {
  late final DataFlow<int> counterFlow = this.dataFlow(0);

  void onIncrement() {
    update(counterFlow).change((it) => it + 1);
  }
}
