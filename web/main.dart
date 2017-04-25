import 'dart:async';
import 'dart:html';
import 'package:chip8/browser.dart';

final DivElement $promptSection = querySelector('#prompt-section'),
    $gameSection = querySelector('#game-section');
final FormElement $promptForm = querySelector('#prompt-form');
final FileUploadInputElement $promptFile = querySelector('#prompt-file');
final CanvasElement $screen = querySelector('#screen');

main() {
  StreamSubscription<Event> sub;

  sub = $promptForm.onSubmit.listen((e) {
    e.preventDefault();

    if ($promptFile.files.isEmpty) {
      window.alert('Load a ROM first.');
    } else {
      sub.cancel();
      $promptSection.style.display = 'none';
      $gameSection.style.display = 'initial';
      var rdr = new FileReader();

      rdr
        ..onLoad.listen((_) {
          var vm = createVm($screen);
          return vm.execute(rdr.result);
        })
        ..readAsArrayBuffer($promptFile.files.first.slice());
    }
  });
}
