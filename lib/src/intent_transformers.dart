import 'package:flow_vm/flow_vm.dart';
import 'package:stream_transform/stream_transform.dart';

/// A collection of helpers for shaping how `Intent` streams are consumed and
/// mapped into other `Intent`s.
///
/// These transformers control concurrency, ordering and debouncing semantics
/// for the `Intent` processing pipeline used by `ViewModel`s.
class Transformers {
  Transformers._();

  /// The default transformer.
  ///
  /// Uses `concurrentAsyncExpand` to process intents concurrently, allowing
  /// multiple mapped intent streams to be active at the same time.
  static IntentTransformer get defaultTransformer => concurrent();

  /// Processes intents sequentially.
  ///
  /// Each intent starts after the previous intent's mapped stream completes
  /// (FIFO). Implemented with `asyncExpand`.
  static IntentTransformer sequential() {
    return (events, mapper) => events.asyncExpand(mapper);
  }

  /// Debounces incoming intents and is restartable.
  ///
  /// - Waits for [duration] of inactivity before starting the mapper for the
  ///   latest intent.
  /// - If a new intent arrives during the wait or while the current mapped
  ///   stream is active, the previous work is cancelled and restarted for the
  ///   new intent (via `switchMap`).
  ///
  /// Useful for text input where only the latest value should be processed.
  static IntentTransformer debouncedRestartable<T>(Duration duration) {
    return (intents, mapper) => intents.switchMap(
          (intent) => Stream<void>.fromFuture(Future.delayed(duration))
              .asyncExpand((_) => mapper(intent)),
        );
  }

  /// Debounces then processes intents sequentially.
  ///
  /// Collapses bursts of intents into a single intent (the latest after the
  /// [duration] window) and then processes each resulting intent in order,
  /// one after another (via `asyncExpand`).
  static IntentTransformer debouncedSequential(Duration duration) {
    return (intents, mapper) => intents.debounce(duration).asyncExpand(mapper);
  }

  /// Processes intents concurrently.
  ///
  /// Each intent is mapped and run immediately without waiting for others to
  /// finish. Implemented with `concurrentAsyncExpand`.
  static IntentTransformer concurrent() {
    return (intents, mapper) => intents.concurrentAsyncExpand(mapper);
  }

  /// Drops intents that arrive while the previous one is still running.
  ///
  /// The first intent starts at once. Intents that arrive before its mapped
  /// stream completes are ignored. Once it completes, normally or with an
  /// error, the next intent starts. Implemented with `concurrentAsyncExpand`
  /// behind a running flag.
  ///
  /// Useful for work that must not run twice at the same time, such as an
  /// initial load or a retry.
  static IntentTransformer droppable() {
    return (intents, mapper) {
      var isRunning = false;
      return intents.where((_) => !isRunning).concurrentAsyncExpand((intent) {
        isRunning = true;
        return mapper(intent).tap(null, onDone: () => isRunning = false);
      });
    };
  }
}

/// Signature of an intent transformer function.
///
/// Takes a source stream of `Intent`s and an [IntentMapper], and returns a new
/// stream of `Intent`s after applying timing/concurrency policies.
typedef IntentTransformer = Stream<Intent> Function(
  Stream<Intent> intents,
  IntentMapper mapper,
);
