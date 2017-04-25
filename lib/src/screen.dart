import 'dart:async';

abstract class ChipScreen {
  void clear();
  Future close();
  bool draw(int x, int y, int width, int height);
}