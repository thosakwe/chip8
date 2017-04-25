import 'exception.dart';

class ChipOpcode {
  final ChipOpcodeType type;
  final int operand1, operand2, operand3;

  ChipOpcode(this.type, [this.operand1, this.operand2, this.operand3]);

  static ChipOpcode readOpcode(List<int> program, int index) {
    int b = program[index];

    switch (b) {
      case 0xEE:
        return new ChipOpcode(
            ChipOpcodeType.RETURN, _readNext(program, index + 1));
      case 0xE0:
        return new ChipOpcode(ChipOpcodeType.CLEAR);
    }

    var front = b >> 4;

    if (front == 0x6) {
      return new ChipOpcode(ChipOpcodeType.SET_CONST, b.toUnsigned(4),
          _readNext(program, index + 1));
    }

    if (front == 0x2) {
      return new ChipOpcode(ChipOpcodeType.CALL, _readNnn(b, program, index));
    }

    if (front == 0xA) {
      return new ChipOpcode(
          ChipOpcodeType.SET_ADDR, _readNnn(b, program, index));
    }

    if (front == 0xD) {
      int x = b.toUnsigned(4);
      int next = _readNext(program, index + 1);
      int y = next >> 4;
      int h = next.toUnsigned(4);
      return new ChipOpcode(ChipOpcodeType.DRAW, x, y, h);
    }

    return new ChipOpcode(ChipOpcodeType.INVALID, b);
  }

  static int _readNnn(int b, List<int> program, int index) {
    //print('b: ${b.toRadixString(2)}');
    //int front = b >> 4;
    //print('front: ${front.toRadixString(2)}');
    //print('front: 0x${front.toRadixString(16)}');
    int last4 = b & 0x0F << 16;
    //print('last4: ${last4.toRadixString(2)}');
    int next = _readNext(program, index + 1);
    //print('next: ${next.toRadixString(2)}');
    //print('last4 padded: ${(last4 << 8).toRadixString(2)}');
    int nnn = (last4 << 8) + next;
    //print('NNN: ${nnn.toRadixString(2)}');
    //print('NNN: 0x${nnn.toRadixString(16)}');
    //print('NNN: $nnn');
    return nnn;
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

enum ChipOpcodeType { INVALID, CALL, CLEAR, DRAW, RETURN, SET_ADDR, SET_CONST }
