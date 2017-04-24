import 'package:chip8/io.dart';
import 'package:test/test.dart';

main() {
  test('premature return', () async {
    expect(await createVm().execute([0x00EE, 0]), isFalse);
  });
}
