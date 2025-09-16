import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FlowListener calls listener on value change; child not rebuilt', (tester) async {
    final vm = _Vm();
    addTearDown(vm.dispose);
    int buildCount = 0;
    final called = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: FlowListener<int>(
          flow: vm.counter,
          listener: (context, value) => called.add(value),
          child: _BuildCounter(onBuild: () => buildCount++),
        ),
      ),
    );

    expect(buildCount, 1);
    expect(called, isEmpty);

    vm.counter.testSet(1);
    await tester.pump();
    expect(buildCount, 1); // child not rebuilt
    expect(called, [1]);
  });

  testWidgets('FlowListener re-subscribes when flow instance changes', (tester) async {
    final vm1 = _Vm();
    final vm2 = _Vm();
    addTearDown(vm1.dispose);
    addTearDown(vm2.dispose);

    final called = <int>[];

    Widget build(FlowVm<int> flow) => MaterialApp(
          home: FlowListener<int>(
            flow: flow,
            listener: (context, value) => called.add(value),
            child: const SizedBox(),
          ),
        );

    await tester.pumpWidget(build(vm1.counter));
    vm1.counter.testSet(1);
    await tester.pump();
    expect(called, [1]);

    await tester.pumpWidget(build(vm2.counter));
    vm2.counter.testSet(5);
    await tester.pump();
    expect(called, [1, 5]);
  });
}

class _BuildCounter extends StatelessWidget {
  const _BuildCounter({required this.onBuild});
  final VoidCallback onBuild;
  @override
  Widget build(BuildContext context) {
    onBuild();
    return const SizedBox();
  }
}

class _Vm extends SimpleViewModel {
  late final counter = this.dataFlow(0);
}


