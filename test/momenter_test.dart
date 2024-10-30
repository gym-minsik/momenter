import 'package:momenter/src/moment.dart';
import 'package:momenter/src/moment_state.dart';
import 'package:momenter/src/momenter.dart';
import 'package:test/test.dart';

void main() {
  group('Momenter E2E Tests', () {
    late Momenter<Moment> momenter;
    late List<MomenterState<Moment>> events;

    setUp(() {
      momenter = Momenter<Moment>();
      events = [];
      momenter.setSpeedMultipler(100);
    });

    group('stream', () {
      test('#1', () async {
        final emitted = <MomenterState<Moment>>[];
        momenter.addAll([
          Moment(Duration.zero),
          Moment(Duration(seconds: 1)),
        ]);
        momenter.stream.listen((s) {
          emitted.add(s);
        });
        momenter.play();

        await Future.delayed(Duration(milliseconds: 100));

        expect(emitted, [
          isA<MomenterPlay<Moment>>(),
          isA<MomenterTriggered<Moment>>(),
          isA<MomenterTriggered<Moment>>(),
          isA<MomenterCompleted<Moment>>(),
        ]);
      });
    });

    group('.reset', () {
      test('should reset without queue', () async {
        momenter.addAll([
          Moment(Duration.zero),
          Moment(const Duration(seconds: 2)),
        ]);
        expect(momenter.elapsedTime, equals(Duration.zero));
        expect(momenter.momentQueue.isNotEmpty, isTrue);
        momenter.reset();
        expect(momenter.momentQueue.isNotEmpty, isTrue);
      });

      test('should reset all', () async {
        momenter.addAll([
          Moment(Duration.zero),
          Moment(const Duration(seconds: 2)),
        ]);
        expect(momenter.elapsedTime, equals(Duration.zero));
        expect(momenter.momentQueue.isNotEmpty, isTrue);
        momenter.reset(shouldClearMoments: true);
        expect(momenter.momentQueue.isEmpty, isTrue);
      });
    });

    test('should add moments and transition through states correctly',
        () async {
      // Add moments to Momenter
      momenter.add(Moment(const Duration(seconds: 2)));
      momenter.add(Moment(const Duration(seconds: 4)));

      expect(momenter.totalDuration, const Duration(seconds: 4));
      expect(momenter.isCompleted, isFalse);

      // Start playing the moments
      momenter.play();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        events,
        [
          isA<MomenterPlay<Moment>>(),
          isA<MomenterTriggered<Moment>>(),
          isA<MomenterTriggered<Moment>>(),
          isA<MomenterCompleted<Moment>>(),
        ],
      );
    });
  });
}
