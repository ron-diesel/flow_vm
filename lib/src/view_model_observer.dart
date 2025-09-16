import 'package:flow_vm/flow_vm.dart';

abstract class ViewModelObserver {
  void onIntentStart(Symbol intentKey) {}

  void onIntentExecuted(Symbol intentKey) {}

  void onFlowUpdated(
    Symbol? intentKey,
    FlowVm<dynamic> flow,
    Mutation<dynamic> change,
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
