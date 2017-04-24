import 'exception.dart';

class ChipOpcode {
  final ChipOpcodeType type;
  final int operand1, operand2;

  ChipOpcode(this.type, [this.operand1, this.operand2]);

  static ChipOpcode readOpcode(List<int> program, int index) {
    int b = program[index];

    switch (b) {
      case 0x00EE:
        return new ChipOpcode(
            ChipOpcodeType.RETURN, _readNext(program, index + 1));
      case 0x00E0:
        return new ChipOpcode(ChipOpcodeType.CLEAR);
    }

    var front = b >> 4;

    if (front == 6) {
      return new ChipOpcode(ChipOpcodeType.SET_CONST, b.toUnsigned(4),
          _readNext(program, index + 1));
    }

    if (front == 0xA) {
      int left = b.toUnsigned(4) >> 4;
    }

    return new ChipOpcode(ChipOpcodeType.INVALID, b);
  }

  static int _readNext(List<int> program, int index) {
    try {
      return program[index];
    } on RangeError {
      throw new ChipException(
          'Premature end-of-file at offset 0x${(index - 1).toRadixString(16)}');
    }
  }
}

enum ChipOpcodeType { INVALID, CALL, CLEAR, RETURN, SET_ADDR, SET_CONST }
