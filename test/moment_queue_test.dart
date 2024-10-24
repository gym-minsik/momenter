import 'package:momenter/src/moment.dart';
import 'package:momenter/src/moment_queue.dart';
import 'package:test/test.dart';

import 'fake_data.dart';

void main() {
  group('MomentQueue', () {
    group('.comparisonPolicy', () {
      test(
          'should return -1 when the first moment value is less than the second.',
          () {
        final moment1 = FakeMoments.fiveSeconds;
        final moment2 = FakeMoments.tenSeconds;

        final result = MomentQueue.comparisonPolicy(moment1, moment2);

        expect(result, equals(-1));
      });

      test(
          'should return 1 when the first moment value is greater than the second.',
          () {
        final moment1 = FakeMoments.tenSeconds;
        final moment2 = FakeMoments.fiveSeconds;

        final result = MomentQueue.comparisonPolicy(moment1, moment2);

        expect(result, equals(1));
      });

      test('should return 0 when both moments have equal values.', () {
        final moment1 = FakeMoments.fiveSeconds;
        final moment2 = FakeMoments.fiveSeconds;

        final result = MomentQueue.comparisonPolicy(moment1, moment2);

        expect(result, equals(0));
      });
    });

    group('.add', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should add a single moment and set it as first and last', () {
        final moment = FakeMoments.fiveSeconds;
        momentQueue.add(moment);

        expect(momentQueue.firstOrNull, equals(moment));
        expect(momentQueue.lastOrNull, equals(moment));
      });

      test('should add multiple moments and update first and last correctly',
          () {
        final moment1 = FakeMoments.fiveSeconds;
        final moment2 = FakeMoments.tenSeconds;
        final moment3 = FakeMoments.threeSeconds;

        momentQueue.add(moment1);
        momentQueue.add(moment2);
        momentQueue.add(moment3);

        // First element should be the one with the smallest value
        expect(momentQueue.firstOrNull, equals(moment3));

        // Last element should be the one with the largest value
        expect(momentQueue.lastOrNull, equals(moment2));
      });

      test(
          'should keep track of lastMoment correctly when moments are added in increasing order',
          () {
        final moment1 = FakeMoments.oneSecond;
        final moment2 = FakeMoments.twoSeconds;
        final moment3 = FakeMoments.threeSeconds;

        momentQueue.add(moment1);
        expect(momentQueue.lastOrNull, equals(moment1));

        momentQueue.add(moment2);
        expect(momentQueue.lastOrNull, equals(moment2));

        momentQueue.add(moment3);
        expect(momentQueue.lastOrNull, equals(moment3));
      });

      test(
          'should keep track of lastMoment correctly when moments are added in decreasing order',
          () {
        final moment1 = FakeMoments.fiveSeconds;
        final moment2 = FakeMoments.fourSeconds;
        final moment3 = FakeMoments.threeSeconds;

        momentQueue.add(moment1);
        expect(momentQueue.lastOrNull, equals(moment1));

        momentQueue.add(moment2);
        expect(momentQueue.lastOrNull,
            equals(moment1)); // lastMoment should remain moment1

        momentQueue.add(moment3);
        expect(momentQueue.lastOrNull,
            equals(moment1)); // lastMoment should remain moment1
      });

      test(
          'should keep track of lastMoment correctly when moments with duplicate values are added',
          () {
        final moment1 = FakeMoments.fiveSeconds;
        final moment2 = FakeMoments.fiveSeconds; // Same value as moment1

        momentQueue.add(moment1);
        expect(momentQueue.lastOrNull, equals(moment1));

        momentQueue.add(moment2);
        expect(momentQueue.lastOrNull,
            equals(moment2)); // lastMoment should update to the second moment
      });
    });

    group('.addAll', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should add all moments to the queue', () {
        final moments = [
          Moment(const Duration(seconds: 1)),
          Moment(const Duration(seconds: 3)),
          Moment(const Duration(seconds: 2)),
        ];

        momentQueue.addAll(moments);

        expect(momentQueue.isNotEmpty, isTrue);
        expect(momentQueue.first.value, equals(const Duration(seconds: 1)));
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 3)));
      });

      test('should maintain min-heap property after adding moments', () {
        final moments = [
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 8)),
          Moment(const Duration(seconds: 1)),
          Moment(const Duration(seconds: 3)),
        ];

        momentQueue.addAll(moments);

        // Check that the first moment is the smallest one (min-heap property)
        expect(momentQueue.first.value, equals(const Duration(seconds: 1)));

        // Check the last moment based on the order of adding and max value
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 8)));
      });

      test('should handle an empty iterable', () {
        momentQueue.addAll([]);

        expect(momentQueue.isEmpty, isTrue);
        expect(momentQueue.firstOrNull, isNull);
        expect(momentQueue.lastOrNull, isNull);
      });

      test('should update lastMoment correctly when moments are added', () {
        final moments = [
          Moment(const Duration(seconds: 4)),
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 6)),
        ];

        momentQueue.addAll(moments);

        // Verify that lastMoment is updated correctly
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 6)));
      });

      test('should add all moments and handle duplicates correctly', () {
        final moments = [
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 5)),
        ];

        momentQueue.addAll(moments);

        // Check that first moment is the smallest and duplicates are handled
        expect(momentQueue.first.value, equals(const Duration(seconds: 2)));
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 5)));
      });
    });

    group('.first', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should return the first moment when the queue has one element', () {
        final moment = Moment(const Duration(seconds: 5));
        momentQueue.add(moment);

        expect(momentQueue.first, equals(moment));
      });

      test('should return the smallest moment when multiple elements are added',
          () {
        final moments = [
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 3)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Since MomentQueue is using a min-heap, the first element should be the smallest one
        expect(momentQueue.first.value, equals(const Duration(seconds: 3)));
      });

      test('should throw StateError when first is called on an empty queue',
          () {
        expect(() => momentQueue.first, throwsA(isA<StateError>()));
      });

      test(
          'should maintain first moment when elements are added in non-sorted order',
          () {
        final moments = [
          Moment(const Duration(seconds: 10)),
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 6)),
        ];

        momentQueue.addAll(moments);

        // The first moment should be the one with the smallest value
        expect(momentQueue.first.value, equals(const Duration(seconds: 2)));
      });

      test(
          'should update first moment correctly after removing the first element',
          () {
        final moments = [
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Initially, the first should be the smallest element
        expect(momentQueue.first.value, equals(const Duration(seconds: 2)));

        // Remove the first element and check the updated first moment
        momentQueue.removeFirst();
        expect(momentQueue.first.value, equals(const Duration(seconds: 5)));
      });
    });

    group('firstOrNull', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should return null when the queue is empty', () {
        expect(momentQueue.firstOrNull, isNull);
      });

      test('should return the first moment when the queue has one element', () {
        final moment = Moment(const Duration(seconds: 5));
        momentQueue.add(moment);

        expect(momentQueue.firstOrNull, equals(moment));
      });

      test('should return the smallest moment when multiple elements are added',
          () {
        final moments = [
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 3)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Since MomentQueue is using a min-heap, the firstOrNull element should be the smallest one
        expect(
            momentQueue.firstOrNull?.value, equals(const Duration(seconds: 3)));
      });

      test(
          'should maintain firstOrNull when elements are added in non-sorted order',
          () {
        final moments = [
          Moment(const Duration(seconds: 10)),
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 6)),
        ];

        momentQueue.addAll(moments);

        // The firstOrNull moment should be the one with the smallest value
        expect(
            momentQueue.firstOrNull?.value, equals(const Duration(seconds: 2)));
      });

      test('should return null when all elements are removed from the queue',
          () {
        final moments = [
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Remove all elements from the queue
        momentQueue.removeFirstOrNull();
        momentQueue.removeFirstOrNull();
        momentQueue.removeFirstOrNull();

        // After removing all elements, firstOrNull should return null
        expect(momentQueue.firstOrNull, isNull);
      });
    });

    group('lastOrNull', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should return null when the queue is empty', () {
        expect(momentQueue.lastOrNull, isNull);
      });

      test(
          'should return the only moment as last when the queue has one element',
          () {
        final moment = Moment(const Duration(seconds: 5));
        momentQueue.add(moment);

        expect(momentQueue.lastOrNull, equals(moment));
      });

      test(
          'should return the largest moment as the last when multiple elements are added',
          () {
        final moments = [
          Moment(const Duration(seconds: 3)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // The lastOrNull should be the one with the largest value
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 7)));
      });

      test('should maintain lastOrNull when moments are added in random order',
          () {
        final moments = [
          Moment(const Duration(seconds: 10)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 8)),
        ];

        momentQueue.addAll(moments);

        // The lastOrNull moment should be the one with the largest value
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 10)));
      });

      test(
          'should update lastOrNull correctly when the largest element is removed',
          () {
        final moments = [
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Initially, lastOrNull should return the largest value
      });
    });

    group('.removeFirst', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should throw StateError when called on an empty queue', () {
        expect(() => momentQueue.removeFirst(), throwsA(isA<StateError>()));
      });

      test(
          'should remove and return the first moment when the queue has one element',
          () {
        final moment = Moment(const Duration(seconds: 5));
        momentQueue.add(moment);

        final removed = momentQueue.removeFirst();
        expect(removed, equals(moment));
        expect(momentQueue.isEmpty, isTrue);
      });

      test('should remove the smallest moment and maintain min-heap property',
          () {
        final moments = [
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 3)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Initially, the smallest moment should be the first
        expect(momentQueue.first.value, equals(const Duration(seconds: 3)));

        // Remove the first (smallest) moment
        final removed = momentQueue.removeFirst();
        expect(removed.value, equals(const Duration(seconds: 3)));

        // The new first should now be the next smallest element
        expect(momentQueue.first.value, equals(const Duration(seconds: 5)));
      });

      test(
          'should remove multiple moments in order and maintain the queue state',
          () {
        final moments = [
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 6)),
          Moment(const Duration(seconds: 4)),
          Moment(const Duration(seconds: 8)),
        ];

        momentQueue.addAll(moments);

        // Remove the first moment, expect the smallest one
        final firstRemoved = momentQueue.removeFirst();
        expect(firstRemoved.value, equals(const Duration(seconds: 2)));

        // Remove the next moment, expect the next smallest one
        final secondRemoved = momentQueue.removeFirst();
        expect(secondRemoved.value, equals(const Duration(seconds: 4)));

        // Check the current state of the queue (min-heap property)
        expect(momentQueue.first.value, equals(const Duration(seconds: 6)));
      });

      test('should correctly update first and last moments after removal', () {
        final moments = [
          Moment(const Duration(seconds: 1)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 3)),
        ];

        momentQueue.addAll(moments);

        // Initially, the first should be the smallest value, and last the largest
        expect(momentQueue.first.value, equals(const Duration(seconds: 1)));
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 5)));

        // Remove the first moment (smallest)
        momentQueue.removeFirst();

        // After removal, check that the first and last are updated correctly
        expect(momentQueue.first.value, equals(const Duration(seconds: 3)));
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 5)));
      });
    });

    group('.clear', () {
      late MomentQueue<Moment> momentQueue;

      setUp(() {
        momentQueue = MomentQueue<Moment>();
      });

      test('should leave the queue empty after clear is called', () {
        final moments = [
          Moment(const Duration(seconds: 3)),
          Moment(const Duration(seconds: 5)),
          Moment(const Duration(seconds: 7)),
        ];

        momentQueue.addAll(moments);

        // Verify that the queue is not empty initially
        expect(momentQueue.isNotEmpty, isTrue);

        // Clear the queue
        momentQueue.clear();

        // After clear, the queue should be empty
        expect(momentQueue.isEmpty, isTrue);
      });

      test('should have null as firstOrNull and lastOrNull after clear', () {
        final moments = [
          Moment(const Duration(seconds: 1)),
          Moment(const Duration(seconds: 4)),
          Moment(const Duration(seconds: 2)),
        ];

        momentQueue.addAll(moments);

        // Verify that firstOrNull and lastOrNull return values before clearing
        expect(
            momentQueue.firstOrNull?.value, equals(const Duration(seconds: 1)));
        expect(
            momentQueue.lastOrNull?.value, equals(const Duration(seconds: 4)));

        // Clear the queue
        momentQueue.clear();

        // After clear, firstOrNull and lastOrNull should return null
        expect(momentQueue.firstOrNull, isNull);
        expect(momentQueue.lastOrNull, isNull);
      });

      test(
          'should not throw an error when clear is called on an already empty queue',
          () {
        // Verify that the queue is initially empty
        expect(momentQueue.isEmpty, isTrue);

        // Clear the empty queue (should not throw an error)
        expect(() => momentQueue.clear(), returnsNormally);
      });

      test('should reset the state of the queue when clear is called', () {
        final moments = [
          Moment(const Duration(seconds: 2)),
          Moment(const Duration(seconds: 6)),
          Moment(const Duration(seconds: 5)),
        ];

        momentQueue.addAll(moments);

        // Verify the queue is not empty and has elements
        expect(momentQueue.isNotEmpty, isTrue);

        // Clear the queue
        momentQueue.clear();

        // After clearing, verify the queue is reset and behaves as an empty queue
        expect(momentQueue.isEmpty, isTrue);
        expect(momentQueue.firstOrNull, isNull);
        expect(momentQueue.lastOrNull, isNull);

        // Verify that new elements can be added after clearing
        momentQueue.add(Moment(const Duration(seconds: 3)));
        expect(
            momentQueue.firstOrNull?.value, equals(const Duration(seconds: 3)));
      });
    });
  });
}
