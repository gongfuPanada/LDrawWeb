import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:web_gl';
import 'dart:typed_data';

import 'ldraw.dart';
import 'renderer.dart' as r;

ColorMap map;
r.Renderer rc;

void main() {
  rc = new r.Renderer(query('#mainCanvas'));
  window.onResize.listen((Event e) {
    rc.resizeView(window.innerWidth, window.innerHeight);
  });
  rc.resizeView(window.innerWidth, window.innerHeight);

  setup();
}

void setup() {
  httpGetJson('/s/colors.json', (response) {
    map = new ColorMap.fromJson(response);
    GlobalFeatureSet.instance.loadAll(() {
      print('loaded colors');

      rc.setupMaterials();
      
      Map<String, String> attrs = query('#data').attributes;
      if (attrs.containsKey('data-model')) {
        readFile(attrs['data-model'].split('\n'));
      } else if (attrs.containsKey('data-uri')) {
        httpGetPlainText(attrs['data-uri'], readFile);
      }
    });
  });
}

void postprocessModel(LDrawModel m, Resolver r) {
  Model model = new Model(m);

  List<String> parts = new List.from(model.submodels.keys);
  for (String part in parts) {
    model.buildPartSynchronously(part, r);
    query('#progress').appendHtml('processed subfile $part<br />');
  }

  model.compile();

  r.Model rm = new r.Model.fromModel(model);
  blah(rm);
  
  /*model.buildPartAsynchronously(r, (int id, String partName, Part partData, int total, int remaining, int elapsed) {
    query('#progress').appendHtml('processed subfile $partName in $elapsed ms (${total - remaining} / $total)<br />');
  }, () {

    query('#progress').appendHtml('compiling...<br />');
    Stopwatch w = new Stopwatch();
    w.start();
    model.compile();
    w.stop();
    query('#progress').appendHtml('compiling done in ${w.elapsedMilliseconds} ms.<br />');
    query('#progress').appendHtml('# of total tris: ${model.triCount} (+ ${model.studTriCount} for studs)<br />');
    query('#progress').appendHtml('# of total edges: ${model.edgeCount} (+ ${model.studEdgeCount} for studs)<br />');

    renderer.Model rm = new renderer.Model.fromModel(model);
    
    blah(rm);
    });*/
}

void blah(Model model) {
  r.Camera camera = new PerspectiveCamera(45.0, window.innerWidth / window.innerHeight, 1.0, 1000.0);
  camera.position.z = -600.0;
  camera.position.y = -600.0;
  camera.rotation.x = -0.52359;

  Mat4 viewMatrix = new Mat4.identity();
  Mat4 mv = new Mat4.identity();
  Vec4 worldPos = new Vec4();
  num pt = 0.0;

  query('#mainCanvas').onMouseWheel.listen((WheelEvent e) {
    if (e.deltaY == 0.0)
      return;

    camera.position.z -= e.deltaY * 0.5;
    camera.position.y -= e.deltaY * 0.5;

    e.preventDefault();
  });

  query('#mainCanvas').onClick.listen((MouseEvent e) {
    model.startAnimation(pt);
  });

  Vec4 axis = new Vec4.xyz(0.0, 0.5, 0.0);

  rc.setupState();

  void draw(num time) {
    if (!model.initiated)
      model.startAnimation(time);
    model.animate(time);

    r.matrixRotate(mv, axis, (pt - time) / 1500.0);
    
    rc.render(camera, null, () {
      model.render(camera, mv);
    });

    window.requestAnimationFrame(draw);

    pt = time;
  }

  window.requestAnimationFrame(draw);
}

void readFile(List<String> response) {
  LDrawMultipartModel ldrawModel = new LDrawMultipartModel();
  parseMultipartModel(ldrawModel, response.iterator);

  Model model = new Model(ldrawModel);
  Set<String> readMeshFiles = new HashSet<String>();
  int total = model.submodels.length;
  int remaining = total;
  int loaded = 0;

  void proceed() {
    query('#progress').appendHtml('compiling...<br />');
    Stopwatch w = new Stopwatch();
    w.start();
    model.compile();
    w.stop();
    query('#progress').appendHtml('compiling done in ${w.elapsedMilliseconds} ms.<br />');
    query('#progress').appendHtml('# of total tris: ${model.triCount} (+ ${model.studTriCount} for studs)<br />');
    query('#progress').appendHtml('# of total edges: ${model.edgeCount} (+ ${model.studEdgeCount} for studs)<br />');    

    r.Model rm = new r.Model.fromModel(rc, model);
    model.recycle();
    blah(rm);
  }

  void probeDatFiles() {
    proceed();
  }

  /* search for mesh files */
  void probePostprocessedFiles() {
    for (String part in model.submodels.keys) {
      model.loadPart(part, onLoaded: (String s, Part p) {
        ++loaded;
        --remaining;

        query('#progress').appendHtml('loaded preprocessed part $s ($loaded / $total)<br />');
        
        if (remaining == 0)
          probeDatFiles();
      }, onLoadFailed: (String s, int statusCode) {
        query('#progress').appendHtml('preprocessed part $s does not exists<br />');
        --remaining;
        
        if (remaining == 0)
          probeDatFiles();
      });
    }
  }

    /*Resolver r = new Resolver();
  r.resolveModel(model, onUpdate: (String s, LDrawModel m) {
      if (m != null) {
	int loaded = r.getItemsDatLoaded().length;
	int total = r.registry.length;
	query('#progress').appendHtml('loaded ${m.header.filename} ($loaded / $total) <br />');
      }
    },
    onFinished: () {
      query('#progress').appendHtml('loading done.<br />');
      postprocessModel(model, r);
      });*/

  probePostprocessedFiles();
}
