import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>(
      _onIncrement,
    );
  }

  FutureOr<void> _onIncrement(Increment event, Emitter<int> emit) {
    emit(state + 1);
  }
}

sealed class CounterEvent {}

class Increment extends CounterEvent {}
