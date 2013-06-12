import 'dart:collection';
import 'dart:io';
import '../ldrawlib/ldraw_backend.dart';

main() {
  List<String> argv = (new Options()).arguments;
  Resolver r = new Resolver();

  for (String file in argv) {
    File f = new File(file);
    f.readAsLines().then((List<String> list) {
	print(file);
	LDrawMultipartModel model = new LDrawMultipartModel();
	parseMultipartModel(model, list.iterator);
        r.resolveModel(model);
      });
  }
}
