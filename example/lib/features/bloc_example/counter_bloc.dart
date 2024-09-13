import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>(
      _onIncrement,
      transformer: restartable()
    );
  }

  FutureOr<void> _onIncrement(Increment event, Emitter<int> emit) async{
    await Future.delayed(Duration(seconds: 1));
    emit(state + 1);
  }
}

sealed class CounterEvent {}

class Increment extends CounterEvent {}
