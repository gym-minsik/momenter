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
      momenter.addListener((event) => events.add(event));
      momenter.setSpeedMultipler(100);
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
