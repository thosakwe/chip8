import 'exception.dart';

class ChipOpcode {
  final ChipOpcodeType type;
  final int operand;

  ChipOpcode(this.type, [this.operand]);

  static ChipOpcode readOpcode(List<int> program, int index) {
    int b = program[index];

    switch (b) {
      case 0x00EE:
        return new ChipOpcode(
            ChipOpcodeType.RETURN, _readNext(program, index + 1));
    }

    var front = b >> 4;
    print(front);

    if (front == 6) {
      // Maybe call
      // TODO: Fix
      int nReg = (b.toUnsigned(8) & 0x00001111);
      print('reg: ${nReg.toRadixString(16)}');
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

enum ChipOpcodeType { RETURN, INVALID }
