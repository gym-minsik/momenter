import 'dart:async';

import 'package:meta/meta.dart';
import 'package:momenter/src/moment.dart';
import 'package:momenter/src/moment_queue.dart';
import 'package:momenter/src/moment_state.dart';
import 'package:momenter/src/momenter_listener.dart';

class Momenter<M extends Moment> {
  Momenter();

  double _timeMultiplier = 1.0;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  bool _isCompleted = false;
  @visibleForTesting
  final momentQueue = MomentQueue<M>();
  final _completedMoments = <M>[];
  final _listeners = <MomenterListener<M>>{};

  bool get isCompleted => _isCompleted;

  Duration get elapsedTime => _stopwatch.elapsed;

  double get speed => 1 / _timeMultiplier;

  Duration get totalDuration {
    return momentQueue.lastOrNull?.value ?? Duration.zero;
  }

  void add(M moment) {
    momentQueue.add(moment);
  }

  void addAll(Iterable<M> moments) => moments.forEach(add);

  void addListener(MomenterListener<M> l) {
    _listeners.add(l);
  }

  void play() {
    for (final l in _listeners) {
      l(MomenterPlay<M>());
    }
    scheduleNext();
  }

  void pause() {
    _timer?.cancel();
    _stopwatch.stop();
    _timer = null;
    for (final l in _listeners) {
      l(MomenterPause<M>());
    }
  }

  void reset() {
    _timer?.cancel();
    _stopwatch.stop();
    _timer = null;
    _stopwatch.reset();
    for (final l in _listeners) {
      l(MomenterReset<M>());
    }
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
      for (final l in _listeners) {
        l(MomenterCompleted<M>());
      }
      return;
    }
    _stopwatch.stop();
    final nextMoment = momentQueue.first.value;
    _timer = Timer(
      (nextMoment - _stopwatch.elapsed) * _timeMultiplier,
      () {
        final M m = momentQueue.removeFirst();
        _completedMoments.add(m);
        for (final l in _listeners) {
          final s = MomenterTriggered<M>(m);
          l(s);
        }
        scheduleNext();
      },
    );
    _stopwatch.start();
  }
}
