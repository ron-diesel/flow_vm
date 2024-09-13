import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flow_vm/src/view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class IntentAction {
  FutureOr<void> call(Updater update);
}

class MockIntentAction extends Mock implements IntentAction {}

class FakeUpdater extends Mock implements Updater {}

FutureOr<void> _work1(int test) async {
  print("start action1 test: $test");
  await Future.delayed(const Duration(milliseconds: 100));
  print("finish action1 test: $test");
}

FutureOr<void> _work2(int test) async {
  print("start action2 test: $test");
  await Future.delayed(const Duration(milliseconds: 100));
  print("finish action2 test: $test");
}

void main() {
  group('IntentTransformer Tests', () {
    late TestableViewModel viewModel;
    late MockIntentAction action1;
    late MockIntentAction action2;
    int counter = 0;

    setUpAll(() {
      registerFallbackValue(FakeUpdater());
      viewModel = TestableViewModel();
      action1 = MockIntentAction();
      action2 = MockIntentAction();
    });

    setUp((){
      counter++;
      print("-----------next test---------");
      viewModel = TestableViewModel();
      reset(action1);
      reset(action2);
      when(() => action1.call(any())).thenAnswer((_) => _work1(counter));
      when(() => action2.call(any())).thenAnswer((_) => _work2(counter));
    });

    tearDown((){
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

      await viewModel.completeCurrentIntents;
      verify(() => action1.call(any())).called(1);
      verify(() => action2.call(any())).called(10);
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

      await Future.delayed(Duration.zero);
      await viewModel.completeCurrentIntents;
      verify(() => action1.call(any())).called(2);
      verify(() => action2.call(any())).called(10);
    });
  });
}
