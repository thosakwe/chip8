import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'chip8.dart';
export 'chip8.dart';

Chip8 createVm(CanvasElement $canvas) => new Chip8(
    new BrowserConsole(), new BrowserKeyboard(), new BrowserScreen($canvas));

class BrowserConsole implements ChipConsole {
  @override
  void error(Object object) => window.console.error(object);

  @override
  void info(Object object) => window.console.info(object);

  @override
  void log(Object object) => window.console.log(object);
}

class BrowserKeyboard extends ChipKeyboard {
  static const List<int> KEYS = const [
    KeyCode.NUM_TWO,
    KeyCode.NUM_FOUR,
    KeyCode.NUM_SIX,
    KeyCode.NUM_EIGHT
  ];

  final Queue<int> _buf = new Queue<int>();
  final List<int> _down = [];
  final Queue<Completer<int>> _queue = new Queue<Completer<int>>();
  final List<StreamSubscription<KeyboardEvent>> _subs = [];

  BrowserKeyboard() {
    _subs.addAll([
      document.onKeyDown.listen((e) {
        if (KEYS.contains(e.keyCode)) {
          var code = _transformKeyCode(e.keyCode);
          _down.add(code);
          injectKey(code);
        }
      }),
      document.onKeyUp.listen((e) {
        if (KEYS.contains(e.keyCode)) {
          var code = _transformKeyCode(e.keyCode);
          _down.remove(code);
          injectKey(code);
        }
      })
    ]);
  }

  int _transformKeyCode(int keyCode) {
    switch (keyCode) {
      case KeyCode.NUM_TWO:
        return 2;
      case KeyCode.NUM_FOUR:
        return 4;
      case KeyCode.NUM_SIX:
        return 6;
      case KeyCode.NUM_EIGHT:
        return 8;
      default:
        return -1;
    }
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
      _queue.add(c);
      return c;
    }
  }

  @override
  Future close() async {
    _subs.forEach((sub) => sub.cancel());
  }
}

class BrowserScreen implements ChipScreen {
  CanvasRenderingContext2D _context;
  final int _factor = 1;
  final List<List<int>> _grid = new List<List<int>>.generate(32, (_) {
    return new List<int>.filled(64, 0);
  });

  final CanvasElement $canvas;

  BrowserScreen(this.$canvas) {
    _context = $canvas.getContext('2d');
    _context.setFillColorRgb(255, 255, 255);
    _context.fillRect(0, 0, $canvas.width, $canvas.height);
  }

  @override
  void clear() {
    _context.clearRect(0, 0, $canvas.width, $canvas.height);
  }

  @override
  Future close() async {
    _context.clearRect(0, 0, $canvas.width, $canvas.height);
    $canvas.remove();
  }

  @override
  bool draw(int x, int y, int width, int height) {
    bool flipped = false;

    // Update grid
    for (int row = y; row < height - y; row++) {
      for (int col = x; col < width - x; col++) {
        flipped = flipped || _grid[row][col] == 0;
        _grid[row][col] = 1;
      }
    }

    // Actually draw
    _context.setFillColorRgb(0, 0, 0);
    _context.fillRect(
        x * _factor, y * _factor, width * _factor, height * _factor);

    return flipped;
  }
}
