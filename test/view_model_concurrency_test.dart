// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
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
  group('IntentTransformer Debounce Tests', () {
    late TestableViewModel viewModel;
    late DataFlow<int> flow1;
    late DataFlow<int> flow2;

    FutureOr<void> action1(Updater update) async {
      await Future.delayed(const Duration(milliseconds: 100));
      update(flow1).change((it) => ++it);
    }

    FutureOr<void> action2(Updater update) async {
      await Future.delayed(const Duration(milliseconds: 100));
      update(flow2).change((it) => ++it);
    }

    setUpAll(() {
      registerFallbackValue(FakeUpdater());
    });

    setUp(() {
      viewModel = TestableViewModel();
      flow1 = viewModel.testDataFlow(0);
      flow2 = viewModel.testDataFlow(0);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('debouncedRestartable: burst -> only last intent is executed',
        () async {
      viewModel.intent(
        intentKey: #debouncedRestartable,
        action: action1,
        transformer: Transformers.debouncedRestartable(
          const Duration(milliseconds: 150),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 30));
      // 5 rapid calls more frequent than the debounce window
      for (int i = 0; i < 5; i++) {
        viewModel.intent(
          intentKey: #debouncedRestartable,
          action: action2,
          transformer: Transformers.debouncedRestartable(
            const Duration(milliseconds: 150),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 30));
      }

      await Future.delayed(const Duration(milliseconds: 500));
      await viewModel.awaitCurrentIntents();

      // Only one update
      expect(flow1.value, 0);
      expect(flow2.value, 1);
    });

    test('debouncedSequential: two separated bursts -> 2 executions in order',
        () async {
      // First burst — collapses into 1 execution
      for (int i = 0; i < 4; i++) {
        viewModel.intent(
          intentKey: #debouncedSequential,
          action: action1,
          transformer: Transformers.debouncedSequential(
              const Duration(milliseconds: 120)),
        );
        await Future.delayed(const Duration(milliseconds: 25));
      }

      // Pause > debounce: a new window will start
      await Future.delayed(const Duration(milliseconds: 250));

      // Second burst — also collapses into 1 execution
      for (int i = 0; i < 3; i++) {
        viewModel.intent(
          intentKey: #debouncedSequential,
          action: action2,
          transformer: Transformers.debouncedSequential(
              const Duration(milliseconds: 120)),
        );
        await Future.delayed(const Duration(milliseconds: 20));
      }

      await Future.delayed(const Duration(milliseconds: 600));
      await viewModel.awaitCurrentIntents();

      expect(flow1.value, 1);
      expect(flow2.value, 1);
    });

    test(
        'debouncedRestartable cancels in-flight when a new debounced event appears',
        () async {
      // First run: wait for emission after debounce and start work
      viewModel.intent(
        intentKey: #debouncedRestartable,
        action: action1,
        transformer: Transformers.debouncedRestartable(
            const Duration(milliseconds: 120)),
      );

      // After some time, when the first is already running, start a new burst,
      // which after debounce will cancel the current execution (restartable)
      await Future.delayed(const Duration(milliseconds: 200));
      for (int i = 0; i < 3; i++) {
        viewModel.intent(
          intentKey: #debouncedRestartable,
          action: action2,
          transformer: Transformers.debouncedRestartable(
              const Duration(milliseconds: 120)),
        );
        await Future.delayed(const Duration(milliseconds: 30));
      }

      await Future.delayed(const Duration(milliseconds: 600));
      await viewModel.awaitCurrentIntents();

      // Result: only the last should execute (the first is cancelled).
      expect(flow1.value, 0);
      expect(flow2.value, 1);
    });

    test(
        'mix: debouncedRestartable + concurrent on different keys (debounce collapses, concurrent runs all)',
        () async {
      for (int i = 0; i < 5; i++) {
        viewModel.intent(
          intentKey: #search, // assume this is a "search" intent
          action: action1,
          transformer: Transformers.debouncedRestartable(
              const Duration(milliseconds: 120)),
        );
        viewModel.intent(
          intentKey: #log, // "logging" or some background work
          action: action2,
          transformer: concurrent(),
        );
        await Future.delayed(const Duration(milliseconds: 25));
      }

      await Future.delayed(const Duration(milliseconds: 700));
      await viewModel.awaitCurrentIntents();

      // debouncedRestartable collapses into 1
      expect(flow1.value, 1);
      // concurrent will execute all 5
      expect(flow2.value, 5);
    });

    test('concurrent: all intents run in parallel', () async {
      for (int i = 0; i < 3; i++) {
        viewModel.intent(
          intentKey: #concurrent,
          action: action1,
          transformer: concurrent(),
        );
      }

      await Future.delayed(const Duration(milliseconds: 150));
      expect(flow1.value, 3);
      await viewModel.awaitCurrentIntents();

      // All 3 should complete
      expect(flow1.value, 3);
    });

    test('sequential: intents run strictly one after another', () async {
      for (int i = 0; i < 3; i++) {
        viewModel.intent(
          intentKey: #sequential,
          action: action1,
          transformer: Transformers.sequential(),
        );
      }

      await Future.delayed(const Duration(milliseconds: 150));
      expect(flow1.value, 1);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(flow1.value, 2);
      await viewModel.awaitCurrentIntents();

      // All should complete, but sequentially
      expect(flow1.value, 3);
    });

    test('restartable: new intent cancels the previous one', () async {
      viewModel.intent(
        intentKey: #restartable,
        action: action1,
        transformer: restartable(),
      );

      // Start a new one before the first finishes
      await Future.delayed(const Duration(milliseconds: 50));
      viewModel.intent(
        intentKey: #restartable,
        action: action2,
        transformer: restartable(),
      );

      await viewModel.awaitCurrentIntents();

      // The first was cancelled, only the second will complete
      expect(flow1.value, 0);
      expect(flow2.value, 1);
    });

    test('droppable: drop new intent if previous is still running', () async {
      // Start the first one
      viewModel.intent(
        intentKey: #droppable,
        action: action1,
        transformer: droppable(),
      );

      // The second arrives while the first is still running → it will be dropped
      await Future.delayed(const Duration(milliseconds: 50));
      viewModel.intent(
        intentKey: #droppable,
        action: action2,
        transformer: droppable(),
      );

      await viewModel.awaitCurrentIntents();

      // Only the first completed
      expect(flow1.value, 1);
      expect(flow2.value, 0);
    });

    test('no transformer: behaves like concurrent by default', () async {
      for (int i = 0; i < 3; i++) {
        viewModel.intent(
          intentKey: #action1,
          action: action1,
        );
      }

      await viewModel.awaitCurrentIntents();

      // Without a transformer they run in parallel → 3 updates
      expect(flow1.value, 3);
    });
  });
}
