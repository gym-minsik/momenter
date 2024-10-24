import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'moment.dart';

final class MomentQueue<M extends Moment> {
  MomentQueue();

  @visibleForTesting
  static int comparisonPolicy<M extends Moment>(M a, M b) {
    if (a.value < b.value) return -1;
    if (a.value > b.value) return 1;
    return 0;
  }

  @visibleForTesting
  final storage = HeapPriorityQueue<M>(comparisonPolicy);

  @visibleForTesting
  M? lastMoment;

  bool get isEmpty => storage.isEmpty;

  bool get isNotEmpty => storage.isNotEmpty;

  void add(M moment) {
    if (lastMoment == null) {
      lastMoment = moment;
    } else if (lastMoment!.value <= moment.value) {
      lastMoment = moment;
    }

    storage.add(moment);
  }

  void addAll(Iterable<M> moments) => moments.forEach(add);

  M get first => storage.first;

  M? get firstOrNull {
    if (storage.isEmpty) return null;
    return storage.first;
  }

  M? get lastOrNull {
    if (storage.isEmpty) return null;
    return lastMoment;
  }

  M removeFirst() {
    return storage.removeFirst();
  }

  M? removeFirstOrNull() {
    if (storage.isEmpty) return null;
    return storage.removeFirst();
  }

  void clear() {
    storage.clear();
  }
}
