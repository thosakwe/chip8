import 'dart:async';

abstract class ChipKeyboard {
  bool isPressed(int keyCode);
  Future<int> nextKeyPress();
  bool isCursorUp() => isPressed(8);
  bool isCursorDown() => isPressed(2);
  bool isCursorLeft() => isPressed(4);
  bool isCursorRight() => isPressed(6);
}