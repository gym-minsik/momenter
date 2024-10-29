import 'dart:async';
import 'dart:isolate';

import 'package:momenter/src/moment_state.dart';
import 'package:momenter/src/momenter.dart';

import 'moment.dart';

class ReliableMomenter<M extends Moment> {
  Isolate? _isolate;
  SendPort? _isolatePort;
  StreamSubscription? _subs;

  Future<void> initialize() async {
    final receivePort = ReceivePort();

    _isolate =
        await Isolate.spawn(_mainForMomenterIsolate<M>, receivePort.sendPort);
    final c = Completer();
    _subs = receivePort.listen((message) {
      if (message is SendPort) {
        _isolatePort = message;
        c.complete();
      } else {
        print(message);
      }
    });

    return c.future;
  }

  Future<void> play() async {
    _isolatePort!.send('PLAY');
  }

  void dispose() {
    _subs?.cancel();
    _isolate?.kill();
  }
}

@pragma('vm:entry-point')
void _mainForMomenterIsolate<M extends Moment>(SendPort sendPort) {
  final receivePort = ReceivePort();

  // Connect to the main isolate.
  sendPort.send(receivePort.sendPort);

  final momenter = Momenter<Moment>();
  momenter.addListener((event) {
    sendPort.send(event.toString());
  });

  momenter.addAll(
    [
      Moment(Duration.zero),
      Moment(Duration(seconds: 1)),
      Moment(Duration(seconds: 2)),
    ],
  );

  receivePort.listen(
    (message) {
      if (message == 'PLAY') {
        momenter.play();
      }
    },
  );
}

void main() async {
  final rm = ReliableMomenter<Moment>();
  await rm.initialize();

  rm.play();

  await Future.delayed(Duration(seconds: 3));
  rm.dispose();
}
