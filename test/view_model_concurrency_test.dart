// ignore_for_file: invalid_use_of_protected_member, avoid_print
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
  group('IntentTransformer Tests', () {
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
      print("-----------next test---------");
      viewModel = TestableViewModel();
      flow1 = viewModel.testDataFlow(0);
      flow2 = viewModel.testDataFlow(0);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('concurrent and droppable handling of different intents', () async {
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 1));
        viewModel.intentNamed(
          action: action1,
          transformer: droppable(),
        );
        viewModel.intentNamed(
          action: action2,
          transformer: concurrent(),
        );
      }

      await Future.delayed(const Duration(milliseconds: 220));
      await viewModel.awaitCurrentIntents();
      expect(flow1.value, 1);
      expect(flow2.value, 10);
    });

    test('sequential and restartable handling of different intents', () async {
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 1));
        viewModel.intentNamed(
          action: action1,
          transformer: sequential(),
        );
        viewModel.intentNamed(
          action: action2,
          transformer: restartable(),
        );
      }

      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 101));
        expect(flow1.value, i + 1);
        if (i > 2) {
          expect(flow2.value, 1);
        }
      }
    });
  });
}
