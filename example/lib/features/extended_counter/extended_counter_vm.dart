import 'package:example/common/random_message.dart';
import 'package:flow_vm/flow_vm.dart';

class ExtendedCounterVM extends ViewModel {
  late final counterFlow = newDataFlow(0);
  late final sumFlow = newDataFlow(0);
  late final logsFlow = newDataFlow(<int>[]);
  late final messageFlow = newDataFlow("");

  void onIncrement() => intentNamed(action: _onIncrement);

  void _onIncrement(Updater update) {
    final count = counterFlow.value + 1;
    update(counterFlow).set(count);
    update(sumFlow).change((it) => it + count);
    update(logsFlow).change((it) => [...it, count]);
    update(messageFlow).set(RandomMessage.get());
  }
}
