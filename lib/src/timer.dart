import 'dart:async';
import 'dart:collection';
import 'package:func/func.dart';

class ChipTimer {
  static final Duration _60hz = new Duration(milliseconds: (1000 / 60).floor());
  final Queue<VoidFunc0> _queue = new Queue<VoidFunc0>();
  Timer _timer;

  void start() {
    _timer = new Timer.periodic(_60hz, (_) {
      if (_queue.isNotEmpty) {
        _queue.removeFirst()();
      }
    });
  }

  void schedule(VoidFunc0 callback) {
    _queue.addLast(callback);
  }

  void stop() {
    _timer.cancel();
  }
}
