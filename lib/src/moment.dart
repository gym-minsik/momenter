// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:meta/meta.dart';

/// {@template momenter.moment}
/// Represents a moment in time with millisecond precision.
///
/// The `Moment` class accepts a [Duration] and truncates any microsecond
/// values to ensure only millisecond precision is maintained. Negative
/// durations are not allowed.
///
/// Example usage:
/// ```
/// final moment = Moment(Duration(seconds: 1, microseconds: 500));
/// print(moment.value); // Outputs: Moment(0:00:01.000)
/// ```
///
/// Throws an [ArgumentError] if a negative duration is provided.
/// {@endtemplate}
@immutable
class Moment {
  final Duration value;

  /// {@macro momenter.moment}
  Moment(Duration duration) : value = duration.copyWith(microseconds: 0) {
    assert(() {
      if (duration != value)
        print(
          '[$Moment] Momenter only supports accuracy up to 1 millisecond. '
          'The microsecond part has been truncated due to Dart\'s limitation.',
        );
      return true;
    }());

    if (duration < Duration.zero) {
      throw ArgumentError.value(
        duration,
        'value',
        'A negative duration is not supported.',
      );
    }
  }

  @override
  bool operator ==(covariant Moment other) {
    if (identical(this, other)) return true;

    return other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  Moment copyWith({
    Duration? value,
  }) {
    return Moment(
      value ?? this.value,
    );
  }

  @override
  String toString() => 'Moment($value)';
}

extension on Duration {
  Duration copyWith({
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? milliseconds,
    int? microseconds,
  }) {
    return Duration(
      days: days ?? inDays,
      hours: hours ?? inHours.remainder(24),
      minutes: minutes ?? inMinutes.remainder(60),
      seconds: seconds ?? inSeconds.remainder(60),
      milliseconds: milliseconds ?? inMilliseconds.remainder(1000),
      microseconds: microseconds ?? inMicroseconds.remainder(1000),
    );
  }
}
