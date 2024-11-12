import 'package:flow_vm/src/view_model.dart';

/// An abstract interface that defines a method for updating a [FlowVm] with a [MutableFlow].
///
/// The [Updater] interface is intended to provide a mechanism to access or modify a [FlowVm]
/// by creating a [MutableFlow] instance that can perform changes on the given [FlowVm].
abstract interface class Updater {
  /// Returns a [MutableFlow] for the given [FlowVm] to perform updates.
  ///
  /// The generic type [T] represents the type of data managed by the [FlowVm].
  MutableFlow<T> call<T>(FlowVm<T> flow);
}
