import 'dart:async';

import 'package:meta/meta.dart';
import 'package:momenter/src/moment.dart';
import 'package:momenter/src/moment_queue.dart';
import 'package:momenter/src/moment_state.dart';

class Momenter<M extends Moment> {
  Momenter();

  double _timeMultiplier = 1.0;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  bool _isCompleted = false;
  @visibleForTesting
  final momentQueue = MomentQueue<M>();

  final _streamController = StreamController<MomenterState<M>>.broadcast();

  bool get isCompleted => _isCompleted;

  // Track last recorded elapsed time when speed multiplier changes
  Duration _lastRecordedElapsed = Duration.zero;

  // Elapsed time adjusted by time multiplier
  Duration get elapsedTime =>
      _lastRecordedElapsed + (_stopwatch.elapsed * (1 / _timeMultiplier));

  double get speed => 1 / _timeMultiplier;

  Duration get totalDuration {
    return momentQueue.lastOrNull?.value ?? Duration.zero;
  }

  Stream<MomenterState<M>> get stream => _streamController.stream;

  void add(M moment) {
    momentQueue.add(moment);
  }

  void addAll(Iterable<M> moments) => moments.forEach(add);

  void play() {
    _streamController.add(MomenterPlay<M>());

    scheduleNext();
  }

  void pause() {
    _timer?.cancel();
    _stopwatch.stop();
    _timer = null;
    _streamController.add(MomenterPause<M>());
  }

  void reset({
    bool shouldClearMoments = false,
  }) {
    _timer?.cancel();
    _stopwatch.stop();
    _timer = null;
    _stopwatch.reset();
    if (shouldClearMoments) {
      clear();
    }
    _streamController.add(MomenterReset<M>());
  }

  void clear() {
    momentQueue.clear();
  }

  void setSpeedMultipler(double x) {
    // Capture effective elapsed time at the current multiplier before changing it
    _lastRecordedElapsed += _stopwatch.elapsed * (1 / _timeMultiplier);
    _stopwatch.reset();
    _timeMultiplier = 1 / x;
    if (_timer != null) {
      pause();
      play();
    }
  }

  @visibleForTesting
  void scheduleNext() {
    if (momentQueue.isEmpty) {
      _stopwatch.stop();
      _timer?.cancel();
      _timer = null;
      _isCompleted = true;
      _streamController.add(MomenterCompleted<M>());
      return;
    }
    _stopwatch.stop();
    final nextMoment = momentQueue.first.value;
    _timer = Timer(
      (nextMoment - elapsedTime) * _timeMultiplier,
      () {
        final M m = momentQueue.removeFirst();
        _streamController.add(MomenterTriggered<M>(m));

        scheduleNext();
      },
    );
    _stopwatch.start();
  }
}
