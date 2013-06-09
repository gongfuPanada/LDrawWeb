import 'dart:collection';
import 'dart:io';
import '../ldrawlib/ldraw_backend.dart';

main() {
  List<String> argv = (new Options()).arguments;

  for (String file in argv) {
    File f = new File(file);
    f.readAsLines().then((List<String> list) {
	print(file);
	LDrawMultipartModel model = new LDrawMultipartModel();
	parseMultipartModel(model, list.iterator);
	LDrawModel m = model.findPart('lever.ldr');
	print(m.header.name);
	for (LDrawCommand c in model.filterRefCmds())
	  print(c);
      });
  }
}
