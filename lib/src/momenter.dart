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
  final _completedMoments = <M>[];

  final _streamController = StreamController<MomenterState<M>>.broadcast();

  bool get isCompleted => _isCompleted;

  Duration get elapsedTime => _stopwatch.elapsed;

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
    _timeMultiplier = 1 / x;
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
      (nextMoment - _stopwatch.elapsed) * _timeMultiplier,
      () {
        final M m = momentQueue.removeFirst();
        _completedMoments.add(m);
        _streamController.add(MomenterTriggered<M>(m));

        scheduleNext();
      },
    );
    _stopwatch.start();
  }
}
