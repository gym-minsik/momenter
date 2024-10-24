import 'package:momenter/src/moment.dart';

sealed class MomenterState<M extends Moment> {
  const MomenterState();
}

final class MomenterPlay<M extends Moment> extends MomenterState<M> {
  const MomenterPlay();
}

final class MomenterPause<M extends Moment> extends MomenterState<M> {
  const MomenterPause();
}

final class MomenterCompleted<M extends Moment> extends MomenterState<M> {
  const MomenterCompleted();
}

final class MomenterTriggered<M extends Moment> extends MomenterState<M> {
  final M moment;

  MomenterTriggered(this.moment);
}

final class MomenterReset<M extends Moment> extends MomenterState<M> {
  const MomenterReset();
}
