import 'package:flow_vm/src/view_model.dart';

abstract interface class Updater {
  MutableFlow<T> call<T>(FlowVm<T> flow);
}
