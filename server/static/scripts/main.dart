import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

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

void blah(Model model) {
  r.Camera camera = new r.PerspectiveCamera(45.0, window.innerWidth / window.innerHeight, 1.0, 100000.0);
  //camera.position.z = 100.0;
  camera.position.y = -50.0;
  //camera.rotation.x = -2.0;

  model.rotation.x = PI;
  model.position.z = -300.0;

  r.Scene scene = new r.Scene();
  scene.add(model);
  
  num pt = 0.0;

  query('#mainCanvas').onMouseWheel.listen((WheelEvent e) {
    if (e.deltaY == 0.0)
      return;

    model.position.z -= e.deltaY * 0.5;
    //camera.position.y -= e.deltaY * 0.5;

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

    num timedelta = (pt - time) / 1500.0;

    model.animate(time);
    model.rotation.y += timedelta;
    model.updateWorldMatrix();

    rc.render(camera, scene);

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
    r.NormalVisualizer nv = new r.NormalVisualizer.fromModel(rc, model);
    nv.visible = false;
    rm.add(nv);
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
