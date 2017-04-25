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
  final List<int> registers = new List<int>.filled(16, 0, growable: false);
  int regI = 0;
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
            'current opcode: ${_current.type} (op: ${_current.operand1})');
      }

      if (_callStack.isNotEmpty) {
        console.error('CALL STACK:');

        while (_callStack.isNotEmpty) {
          var offset = _callStack.removeFirst();
          console.error('Offset: 0x${offset.toRadixString(16)}');
        }
      }

      console.error('Register I: 0x${regI.toRadixString(16)}');
      for (int i = 0; i < registers.length; i++) {
        console.error('Register V${i.toRadixString(16).toUpperCase()}: 0x${registers[i].toRadixString(16)}');
      }
    } finally {
      delayTimer.stop();
      soundTimer.stop();
      await keyboard.close();
    }

    return success;
  }

  Future jump(int offset, List<int> program) async {
    if (offset > program.length - 1) {
      throw new ChipException('Jump target offset out of range', offset);
    } else {
      for (int i = offset; i < program.length; i++) {
        if (program[i] == 0) continue;

        _callStack.addLast(i);
        var op = _current = ChipOpcode.readOpcode(program, i);
        if (op.type != ChipOpcodeType.INVALID && op.operand1 != null) i++;

        switch (op.type) {
          case ChipOpcodeType.INVALID:
            throw new ChipException(
                'Invalid opcode at offset 0x${i.toRadixString(16)}',
                op.operand1 == null
                    ? null
                    : '0x' + op.operand1.toRadixString(16));
          default:
            await runOpcode(op, program);
        }
      }
    }
  }

  Future runOpcode(ChipOpcode op, List<int> program) async {
    if (op.type == ChipOpcodeType.CLEAR) {
      screen.clear();
    } else if (op.type == ChipOpcodeType.RETURN) {
      if (_callStack.length < 2)
        throw new ChipException(
            'Cannot return from function when no jump was made prior.');
      var cur = _callStack.removeLast(), offset = _callStack.removeLast();
      _callStack.addLast(cur);
      return await jump(offset, program);
    } else if (op.type == ChipOpcodeType.SET_ADDR) {
      regI = op.operand1;
    } else if (op.type == ChipOpcodeType.SET_CONST) {
      int target = op.operand1;
      if (target < 0 || target > 15)
        throw new ChipException(
            'Attempting to set non-existent register', target);
      else
        registers[target] = op.operand2;
    } else {
      throw new ChipException('Cannot handle opcode yet', op.type);
    }
  }
}
