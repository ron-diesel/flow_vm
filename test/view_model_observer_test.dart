import 'package:flow_vm/flow_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockObserver extends Mock implements ViewModelObserver {}

class FakeMutation extends Fake implements Mutation<dynamic> {}

class FakeSymbol extends Fake implements Symbol {}

void main() {
  group('ViewModelObserver tests', () {
    late _SimpleViewModelUnit simpleViewModel;
    late _ViewModelUnit viewModel;
    late MockObserver mockObserver;

    setUpAll(() {
      registerFallbackValue(FakeMutation());
      registerFallbackValue(FakeSymbol());
    });

    setUp(() {
      viewModel = _ViewModelUnit();
      simpleViewModel = _SimpleViewModelUnit();
      mockObserver = MockObserver();
      viewModel.addObserver(mockObserver);
      simpleViewModel.addObserver(mockObserver);
    });

    tearDown(() {
      viewModel.dispose();
      simpleViewModel.dispose();
    });

    test('Observer receives Flow updates on set without intents', () async {
      simpleViewModel.onIncrementSet();
      await viewModel.awaitCurrentIntents();
      verify(
        () => mockObserver.onFlowUpdated(
            any(), simpleViewModel.counterFlow, any()),
      ).called(1);
      verify(
        () => mockObserver.onFlowUpdated(
            any(), simpleViewModel.actionsFlow, any()),
      ).called(1);
      verifyNever(() => mockObserver.onIntentStart(any()));
      verifyNever(() => mockObserver.onIntentExecuted(any()));
      verifyNever(() => mockObserver.onIntentCanceled(any()));
    });

    test('Observer receives Flow update on change without intents', () async {
      simpleViewModel.onIncrementChange();
      await viewModel.awaitCurrentIntents();
      verify(
        () => mockObserver.onFlowUpdated(
            any(), simpleViewModel.counterFlow, any()),
      ).called(1);
      verifyNever(
        () => mockObserver.onFlowUpdated(
            any(), simpleViewModel.actionsFlow, any()),
      );
      verifyNever(() => mockObserver.onIntentStart(any()));
      verifyNever(() => mockObserver.onIntentExecuted(any()));
      verifyNever(() => mockObserver.onIntentCanceled(any()));
    });

    test('Observer receives Flow updates on set with intents', () async {
      viewModel.onIncrementSet();

      await viewModel.awaitCurrentIntents();
      verify(
        () => mockObserver.onFlowUpdated(any(), viewModel.counterFlow, any()),
      ).called(1);
      verify(
        () => mockObserver.onFlowUpdated(any(), viewModel.actionsFlow, any()),
      ).called(1);
      verify(() => mockObserver.onIntentStart(any())).called(1);
      verify(() => mockObserver.onIntentExecuted(any())).called(1);
      verify(() => mockObserver.onIntentCanceled(any())).called(1);
    });

    test('Observer receives Flow update on change with intents', () async {
      viewModel.onIncrementChange();

      await viewModel.awaitCurrentIntents();
      verify(
        () => mockObserver.onFlowUpdated(any(), viewModel.counterFlow, any()),
      ).called(1);
      verifyNever(
        () => mockObserver.onFlowUpdated(any(), viewModel.actionsFlow, any()),
      );
      verify(() => mockObserver.onIntentStart(any())).called(1);
      verify(() => mockObserver.onIntentExecuted(any())).called(1);
      verify(() => mockObserver.onIntentCanceled(any())).called(1);
    });
  });
}

class _ViewModelUnit extends ViewModel {
  late final counterFlow = this.dataFlow(0);
  late final actionsFlow = this.actionFlow<String>();

  void onIncrementSet() => intent(
        intentKey: #onIncrementSet,
        action: (Updater update) {
          update(counterFlow).set(counterFlow.value + 1);
          update(actionsFlow).set(counterFlow.value.toString());
        },
      );

  void onIncrementChange() => intent(
        intentKey: #onIncrementChange,
        action: (Updater update) {
          update(counterFlow).change((it) => ++it);
        },
      );
}

class _SimpleViewModelUnit extends SimpleViewModel {
  late final counterFlow = this.dataFlow(0);
  late final actionsFlow = this.actionFlow<String>();

  void onIncrementSet() {
    update(counterFlow).set(counterFlow.value + 1);
    update(actionsFlow).set(counterFlow.value.toString());
  }

  void onIncrementChange() {
    update(counterFlow).change((it) => ++it);
  }
}
