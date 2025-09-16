import 'package:flow_vm/src/flow_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowNotifier', () {
    test('lazy init: reading value before set throws', () {
      final n = FlowNotifier<int>(isLazy: true);
      expect(n.hasValue, isFalse);
      expect(() => n.value, throwsA(isA<StateError>()));
    });

    test('value= sets value, toggles hasValue and notifies once', () {
      final n = FlowNotifier<int>(isLazy: true);
      int notifyCount = 0;
      n.addListener(() => notifyCount++);

      n.value = 1;
      expect(n.hasValue, isTrue);
      expect(n.value, 1);
      expect(notifyCount, 1);

      // setting same value does not notify again
      n.value = 1;
      expect(notifyCount, 1);
    });

    test('forceValue notifies even when value is the same', () {
      final n = FlowNotifier<int>(value: 5, isLazy: false);
      int notifyCount = 0;
      n.addListener(() => notifyCount++);

      // first set to same value → one notification due to force
      n.forceValue(5);
      expect(n.value, 5);
      expect(notifyCount, 1);

      // changing to different value also notifies
      n.forceValue(6);
      expect(n.value, 6);
      expect(notifyCount, 2);
    });

    test('toString contains value or not-initialized marker', () {
      final lazy = FlowNotifier<int>(isLazy: true);
      expect(lazy.toString().contains('not initialized yet'), isTrue);

      final eager = FlowNotifier<int>(value: 10, isLazy: false);
      expect(eager.toString().contains('10'), isTrue);
    });
  });
}
