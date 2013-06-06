import 'dart:io';
import '../ldrawlib/ldraw.dart';

main() {
  List<String> argv = (new Options()).arguments;

  for (String file in argv) {
    File f = new File(file);
    f.readAsLines().then((List<String> list) {
        print(file);
        LDrawModel model = parseModel(list);
	//for (LDrawCommand cmd in model.commands)
	//  print(cmd);
      });
  }
}
