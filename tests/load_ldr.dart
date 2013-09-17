import 'dart:collection';
import 'dart:io';
import '../ldrawlib/ldraw_backend.dart';

void postprocessModel(LDrawModel m, Resolver r) {
  generateMesh(m, r);
}

void main() {
  List<String> argv = (new Options()).arguments;
  Resolver r = new Resolver();

  for (String file in argv) {
    File f = new File(file);
    f.readAsLines().then((List<String> list) {
	print(file);
	LDrawMultipartModel model = new LDrawMultipartModel();
	parseMultipartModel(model, list.iterator);
        r.resolveModel(model, onUpdate: (String s, LDrawModel m) {
	    if (m == null)
	      print('part $s not found!');
	    else
	      print('part $s loaded! ${r.getItemsDatLoaded().length} / ${r.registry.length}');
	  },
	  onFinished: () {
	    print('all files loaded!');
	    postprocessModel(model, r);
	  });
      });
  }
}
