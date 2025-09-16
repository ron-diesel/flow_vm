import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FlowBuilder builds with initial value and rebuilds on change', (tester) async {
    final vm = _Vm();
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: FlowBuilder<int>(
          flow: vm.counter,
          builder: (context, value) => Text('v=$value', textDirection: TextDirection.ltr),
        ),
      ),
    );

    expect(find.text('v=0'), findsOneWidget);

    vm.counter.testSet(1);
    await tester.pump();

    expect(find.text('v=1'), findsOneWidget);
  });
}

class _Vm extends SimpleViewModel {
  late final counter = this.dataFlow(0);
}


