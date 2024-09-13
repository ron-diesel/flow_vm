import 'dart:async';

import 'package:example/common/random_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterExtendedBloc extends Bloc<CounterEvent, CounterState> {
  CounterExtendedBloc() : super(CounterState.initial()) {
    on<Increment>(
      _onIncrement,
    );
  }

  FutureOr<void> _onIncrement(
      Increment event, Emitter<CounterState> emit)  {
    final count = state.count + 1;
    emit(CounterState(
      count: count,
      logs: [...state.logs, count],
      message: RandomMessage.get(),
      sum: state.sum + count,
    ));
  }
}

sealed class CounterEvent {}

class Increment extends CounterEvent {}

class CounterState {
  final int count;
  final List<int> logs;
  final String message;
  final int sum;

  const CounterState.initial()
      : count = 0,
        logs = const [],
        message = '',
        sum = 0;

  const CounterState({
    required this.count,
    required this.logs,
    required this.message,
    required this.sum,
  });
}
