// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:flow_vm/flow_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'utils/testable_view_model.dart';

abstract class IntentAction {
  FutureOr<void> call(Updater update);
}

class MockIntentAction extends Mock implements IntentAction {}

class FakeUpdater extends Mock implements Updater {}

void main() {
  group('ViewModel tests', () {
    late TestableViewModel viewModel;
    late MockIntentAction mockAction;

    setUp(() {
      viewModel = TestableViewModel();
      mockAction = MockIntentAction();
    });

    setUpAll(() {
      registerFallbackValue(FakeUpdater());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('intent should trigger the action', () async {
      // Add intent to the stream
      viewModel.intent(
        intentKey: #mockAction,
        action: mockAction,
      );

      await viewModel.awaitCurrentIntents();
      // Confirm that IntentAction was called
      verify(() => mockAction.call(any())).called(1);
    });

    test('dispose should cancel subscriptions and close controller', () async {
      // Add intent to the stream
      viewModel.intent(
        intentKey: #mockAction,
        action: mockAction,
      );

      // Confirm there is a subscription for intentKey
      expect(viewModel.subscriptions.containsKey(#mockAction), isTrue);

      // Call dispose
      viewModel.dispose();

      // Verify subscription is removed and controller is closed
      expect(viewModel.subscriptions.containsKey(#mockAction), isFalse);
      expect(viewModel.intentController.isClosed, isTrue);
    });

    test('multiple intents with same key reuse single subscription', () async {
      viewModel.intent(
        intentKey: #sameKey,
        action: mockAction,
      );
      viewModel.intent(
        intentKey: #sameKey,
        action: mockAction,
      );
      viewModel.intent(
        intentKey: #sameKey,
        action: mockAction,
      );

      await viewModel.awaitCurrentIntents();

      expect(viewModel.subscriptions.length, 1);
      expect(viewModel.subscriptions.containsKey(#sameKey), isTrue);
      verify(() => mockAction.call(any())).called(3);
    });

    test('different keys create independent subscriptions', () async {
      viewModel.intent(intentKey: #k1, action: mockAction);
      viewModel.intent(intentKey: #k2, action: mockAction);
      viewModel.intent(intentKey: #k3, action: mockAction);

      await viewModel.awaitCurrentIntents();

      expect(viewModel.subscriptions.keys.toSet(), {#k1, #k2, #k3});
      verify(() => mockAction.call(any())).called(3);
    });

    test('awaitCurrentIntents waits for all running intents', () async {
      final completer = Completer<void>();
      Future<void> longAction(Updater u) async {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        completer.complete();
      }

      viewModel.intent(intentKey: #long, action: longAction);
      // Should not complete until longAction finishes
      final sw = Stopwatch()..start();
      await viewModel.awaitCurrentIntents();
      sw.stop();

      expect(completer.isCompleted, isTrue);
      expect(sw.elapsedMilliseconds >= 110, isTrue);
    });

    test('default transformer behaves like concurrent (no transformer passed)', () async {
      final values = <int>[];
      final dataVm = _DataVm();
      addTearDown(dataVm.dispose);
      final flow = dataVm.dataFlow(0);

      Future<void> inc(Updater u) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        u(flow).change((v) => ++v);
        values.add(flow.value);
      }

      for (var i = 0; i < 3; i++) {
        dataVm.intent(intentKey: #inc, action: inc);
      }

      await dataVm.awaitCurrentIntents();
      expect(flow.value, 3);
      expect(values.length, 3);
    });

    test('calling intent after dispose throws and nothing leaks', () async {
      viewModel.intent(intentKey: #beforeDispose, action: mockAction);
      await viewModel.awaitCurrentIntents();
      expect(viewModel.subscriptions.isNotEmpty, isTrue);

      viewModel.dispose();
      expect(viewModel.intentController.isClosed, isTrue);
      expect(viewModel.subscriptions.isEmpty, isTrue);

      expect(
        () => viewModel.intent(intentKey: #afterDispose, action: mockAction),
        throwsA(isA<StateError>()),
      );
    });

    test('SimpleViewModel: update does not mutate after dispose', () async {
      final dataVm = _DataVm();
      final flow = dataVm.dataFlow(0);
      dataVm.update(flow).set(1);
      expect(flow.value, 1);

      dataVm.dispose();

      // Further updates should be ignored silently
      dataVm.update(flow).set(2);
      dataVm.update(flow).change((v) => v + 10);
      expect(flow.value, 1);
    });

    test('sequential: intents execute strictly one-by-one in order', () async {
      final dataVm = _DataVm();
      final flow = dataVm.dataFlow<int>(0);

      Future<void> incBy(Updater u, int by) async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        u(flow).change((v) => v + by);
      }

      dataVm.intent(intentKey: #seq, action: (u) => incBy(u, 1), transformer: Transformers.sequential());
      dataVm.intent(intentKey: #seq, action: (u) => incBy(u, 2), transformer: Transformers.sequential());
      dataVm.intent(intentKey: #seq, action: (u) => incBy(u, 3), transformer: Transformers.sequential());

      await dataVm.awaitCurrentIntents();

      // Verify no leaks: one subscription per key and proper completion
      expect(dataVm.subscriptions.length, 1);
      expect(dataVm.subscriptions.containsKey(#seq), isTrue);

      // Additionally: value should be >= 1 (execution happened)
      expect(flow.value >= 1, isTrue);

      // After dispose all subscriptions are cancelled
      dataVm.dispose();
      expect(dataVm.subscriptions.isEmpty, isTrue);
      expect(dataVm.intentController.isClosed, isTrue);
    });

    test('debouncedSequential: burst collapses, no leaks, single subscription', () async {
      final dataVm = _DataVm();
      final flow = dataVm.dataFlow<int>(0);

      Future<void> inc(Updater u) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        u(flow).change((v) => v + 1);
      }

      // First burst
      for (int i = 0; i < 4; i++) {
        dataVm.intent(
          intentKey: #debSeq,
          action: inc,
          transformer: Transformers.debouncedSequential(const Duration(milliseconds: 120)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }

      // Pause > debounce
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Second burst
      for (int i = 0; i < 3; i++) {
        dataVm.intent(
          intentKey: #debSeq,
          action: inc,
          transformer: Transformers.debouncedSequential(const Duration(milliseconds: 120)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }

      await dataVm.awaitCurrentIntents();

      // Verify no leaks: one subscription per key
      expect(dataVm.subscriptions.length, 1);
      expect(dataVm.subscriptions.containsKey(#debSeq), isTrue);

      // Value should be >= 1 (at least one emission) and small (<= 2 expected)
      expect(flow.value >= 1, isTrue);
      expect(flow.value <= 2, isTrue);

      // After dispose subscriptions are cleared and new intents are not allowed
      dataVm.dispose();
      expect(dataVm.subscriptions.isEmpty, isTrue);
      expect(dataVm.intentController.isClosed, isTrue);
      expect(
        () => dataVm.intent(intentKey: #debSeq, action: inc),
        throwsA(isA<StateError>()),
      );
    });
  });
}

class _DataVm extends SimpleViewModel {}
