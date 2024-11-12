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
      final intentKey = 'testKey';

      // Добавляем intent в поток
      viewModel.intent(
        queueKey: intentKey,
        action: mockAction,
      );

      await viewModel.awaitCurrentIntents();
      // Подтверждаем, что IntentAction был вызван
      verify(() => mockAction.call(any())).called(1);
    });

    test('dispose should cancel subscriptions and close controller', () async {
      final intentKey = 'testKey';

      // Добавляем intent в поток
      viewModel.intent(
        queueKey: intentKey,
        action: mockAction,
      );

      // Подтверждаем, что есть подписка на intentKey
      expect(viewModel.subscriptions.containsKey(intentKey), isTrue);

      // Вызываем dispose
      viewModel.dispose();

      // Проверяем, что подписка удалена и контроллер закрыт
      expect(viewModel.subscriptions.containsKey(intentKey), isFalse);
      expect(viewModel.intentController.isClosed, isTrue);
    });

    test('intentNamed should trigger action', () async {
      viewModel.intentNamed(action: mockAction);

      await viewModel.awaitCurrentIntents();
      verify(() => mockAction.call(any())).called(1);
    });
  });
}
