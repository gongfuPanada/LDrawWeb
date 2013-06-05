import 'dart:io';
import 'ldraw.dart';

main() {
  List<String> argv = (new Options()).arguments;

  for (String file in argv) {
    File f = new File(file);
    f.readAsLines().then((List<String> list) {
        LDrawModel model = parseModel(list);
      });
  }
}