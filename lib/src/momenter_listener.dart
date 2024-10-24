import 'moment.dart';
import 'moment_state.dart';

typedef MomenterListener<M extends Moment> = void Function(
    MomenterState<M> state);
