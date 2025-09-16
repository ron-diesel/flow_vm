import 'package:flow_vm/flow_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Disposer creates target once and disposes it on widget dispose', (tester) async {
    final created = <_DisposableImpl>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Disposer<_DisposableImpl>(
          create: (context) {
            final d = _DisposableImpl();
            created.add(d);
            return d;
          },
          builder: (context, target) {
            return const SizedBox();
          },
        ),
      ),
    );

    expect(created.length, 1);
    expect(created.first.disposed, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(created.first.disposed, isTrue);
  });
}

class _DisposableImpl implements Disposable {
  bool disposed = false;
  @override
  void dispose() {
    disposed = true;
  }
}


