import 'package:example/common/random_message.dart';
import 'package:flow_vm/flow_vm.dart';

class ExtendedCounterVM extends ViewModel {
  late final counterFlow = this.dataFlow(0);
  late final sumFlow = this.dataFlow(0);
  late final logsFlow = this.dataFlow(<int>[]);
  late final messageFlow = this.dataFlow("");
  void onIncrement() => intentNamed(action: _onIncrement);

  void _onIncrement(Updater update) {
    final count = counterFlow.value + 1;
    update(counterFlow).set(count);
    update(sumFlow).change((it) => it + count);
    update(logsFlow).change((it) => [...it, count]);
    update(messageFlow).set(RandomMessage.get());
  }
}
