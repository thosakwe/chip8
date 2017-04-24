import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'chip8.dart';
export 'chip8.dart';

Chip8 createVm() =>
    new Chip8(new IoConsole(), new IoKeyboard(), new IoScreen());

class IoConsole implements ChipConsole {
  @override
  void error(Object object) => stderr.writeln(object);

  @override
  void info(Object object) => log(object);

  @override
  void log(Object object) => stdout.writeln(object);
}

class IoKeyboard extends ChipKeyboard {
  final Queue<int> _buf = new Queue<int>();
  final Queue<Completer<int>> _queue = new Queue<Completer<int>>();

  void injectKey(int keyCode) {
    if (_queue.isNotEmpty)
      _queue.removeFirst().complete(keyCode);
    else _buf.add(keyCode);
  }

  @override
  bool isPressed(int keyCode) => _buf.isNotEmpty && _buf.first == keyCode;

  @override
  Future<int> nextKeyPress() {
    if (_buf.isNotEmpty)
      return new Future<int>.value(_buf.removeFirst());
    else {
      var c = new Completer<int>();
      _queue.add(c);
      _queue.add(c);
      return c;
    }
  }
}

class IoScreen implements ChipScreen {}
