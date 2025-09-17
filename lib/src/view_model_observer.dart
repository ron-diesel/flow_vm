import 'package:flow_vm/flow_vm.dart';

abstract class ViewModelObserver {
  void onIntentStart(Symbol intentKey) {}

  void onIntentExecuted(Symbol intentKey) {}

  void onFlowUpdated<T>(
    Symbol? intentKey,
    FlowVm<T> flow,
    Mutation<T> change,
  ) {}

  void onIntentCanceled(Symbol intentKey) {}
}

class Mutation<T> {
  final T? oldValue;
  final T newValue;

  Mutation({
    required this.oldValue,
    required this.newValue,
  });
}
