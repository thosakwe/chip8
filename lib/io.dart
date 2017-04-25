import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:charcode/ascii.dart';
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
  StreamSubscription<int> _sub;

  IoKeyboard() {
    _sub = stdin.expand((l) => l).listen(injectKey);
  }

  @override
  void injectKey(int keyCode) {
    if (_queue.isNotEmpty)
      _queue.removeFirst().complete(keyCode);
    else
      _buf.add(keyCode);
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
      stdout.write('\rEnter key(s):');
      return c;
    }
  }

  @override
  Future close() async {
    _sub.cancel();
  }
}

class IoScreen implements ChipScreen {
  static int width = 64, height = 32;
  final List<List<int>> grid = new List<List<int>>.generate(height, (_) {
    return new List<int>.filled(width, $space);
  });

  @override
  void clear() {
    grid.forEach((g) => g.fillRange(0, g.length, $space));
    drawScreen();
  }

  void drawScreen() {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        stdout.writeCharCode(grid[row][col]);
      }

      stdout.writeln();
    }
  }
}
