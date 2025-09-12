import 'package:flow_vm/flow_vm.dart';

abstract class ViewModelObserver {
  void onIntentStart(Symbol intentKey) {}

  void onIntentExecuted(Symbol intentKey) {}

  void onFlowUpdated(Symbol intentKey, FlowVm<dynamic> flow, dynamic value) {}

  void onIntentCanceled(Symbol intentKey) {}
}
