library chip8.src.vm;

import 'dart:async';
import 'dart:collection';
import 'console.dart';
import 'exception.dart';
import 'keyboard.dart';
import 'opcode.dart';
import 'screen.dart';
import 'timer.dart';

class Chip8 {
  final Queue<int> _callStack = new Queue<int>();
  ChipOpcode _current;

  final ChipTimer delayTimer = new ChipTimer(), soundTimer = new ChipTimer();
  final List<List<int>> registers = new List<List<int>>.generate(
      16, (_) => new List<int>.filled(8, 0),
      growable: false);
  final ChipConsole console;
  final ChipKeyboard keyboard;
  final ChipScreen screen;

  Chip8(this.console, this.keyboard, this.screen);

  Future<bool> execute(List<int> program) async {
    bool success = true;
    delayTimer.start();
    soundTimer.start();

    try {
      await jump(0, program);
    } on ChipException catch (e) {
      success = false;
      console.error('fatal error: $e');

      if (_current != null && _current.type != ChipOpcodeType.INVALID) {
        console.error(
            'current opcode: ${_current.type} (op: ${_current.operand})');
      }

      if (_callStack.isNotEmpty) {
        console.error('CALL STACK:');

        while (_callStack.isNotEmpty) {
          var offset = _callStack.removeFirst();
          console.error('Offset: $offset');
        }
      }
    } finally {
      delayTimer.stop();
      soundTimer.stop();
    }

    return success;
  }

  Future jump(int offset, List<int> program) async {
    if (offset > program.length - 1) {
      throw new ChipException('Jump target offset out of range', offset);
    } else {
      for (int i = offset; i < program.length; i++) {
        var op = _current = ChipOpcode.readOpcode(program, i);
        if (op.type != ChipOpcodeType.INVALID && op.operand != null) i++;

        switch (op.type) {
          case ChipOpcodeType.INVALID:
            throw new ChipException(
                'Invalid opcode at offset 0x${i.toRadixString(16)}',
                op.operand == null
                    ? null
                    : '0x' + op.operand.toRadixString(16));
          default:
            await runOpcode(op, program);
        }
      }
    }
  }

  Future runOpcode(ChipOpcode op, List<int> program) async {
    if (op.type == ChipOpcodeType.RETURN) {
      if (_callStack.length < 2)
        throw new ChipException(
            'Cannot return from function when no jump was made prior.');
      var cur = _callStack.removeLast(), offset = _callStack.removeLast();
      _callStack.addLast(cur);
      return await jump(offset, program);
    }
  }
}
