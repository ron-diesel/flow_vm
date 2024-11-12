part of 'view_model.dart';

/// Throws an exception if DataFlow is initialized incorrectly.
///
/// This function is intended to signal incorrect use of the DataFlow initialization.
/// The correct way to initialize it is to use the 'late final' keyword, like this:
/// 'late final myFlow = this.dataFlow(data)'.
Never dataFlow(Never never) {
  throw Exception("Incorrect DataFlow initialization! "
      "Use 'late final myFlow = this.dataFlow(data)'");
}

/// Throws an exception if ActionFlow is initialized incorrectly.
///
/// This function is intended to signal incorrect use of the ActionFlow initialization.
/// The correct way to initialize it is to use the 'late final' keyword, like this:
/// 'late final myFlow = this.actionFlow<Type>()'.
Never actionFlow(Never never) {
  throw Exception("Incorrect ActionFlow initialization! "
      "Use 'late final myFlow = this.actionFlow()'");
}

/// The `_FlowManager` class manages multiple flows and disposes of them when needed.
///
/// This class is intended to manage instances of `DataFlow` and `ActionFlow`.
/// It implements the `Disposable` interface, meaning it can clean up resources
/// when no longer needed by disposing of all flows it manages.
class _FlowManager implements Disposable {
  /// A list of disposable resources to keep track of all created flows.
  final List<Disposable> _disposables = [];

  /// Creates a `DataFlow` instance with the given initial value.
  ///
  /// This method is protected, meaning it is intended to be used by subclasses
  /// of `_FlowManager`. The created `DataFlow` instance is automatically added
  /// to the list of disposables for proper resource management.
  @protected
  DataFlow<V> dataFlow<V>(V value) {
    final newFlow = DataFlow(value);
    _disposables.add(newFlow);
    return newFlow;
  }

  /// Creates an `ActionFlow` instance without an initial value.
  ///
  /// This method is protected, meaning it is intended to be used by subclasses
  /// of `_FlowManager`. The created `ActionFlow` instance is automatically added
  /// to the list of disposables for proper resource management.
  @protected
  ActionFlow<V> actionFlow<V>() {
    final newFlow = ActionFlow<V>();
    _disposables.add(newFlow);
    return newFlow;
  }

  /// Creates a `DataFlow` instance specifically for testing purposes.
  ///
  /// This method allows creating a `DataFlow` while testing, to facilitate unit tests.
  @visibleForTesting
  DataFlow<V> testDataFlow<V>(V value) => dataFlow(value);

  /// Creates an `ActionFlow` instance specifically for testing purposes.
  ///
  /// This method allows creating an `ActionFlow` while testing, to facilitate unit tests.
  @visibleForTesting
  ActionFlow<V> testActionFlow<V>() => actionFlow();

  /// Disposes of all managed flows.
  ///
  /// This method should be called to clean up resources when the `_FlowManager`
  /// is no longer needed. It iterates over all disposable resources and calls their
  /// `dispose` method. The `@mustCallSuper` annotation ensures that any subclass
  /// calling `dispose` must also call this base implementation.
  @override
  @mustCallSuper
  void dispose() {
    for (var element in _disposables) {
      element.dispose();
    }
  }
}
