import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';
import 'dart:json';
import 'dart:web_gl';
import 'dart:typed_data';

import 'ldraw.dart';
import 'renderer.dart';

ColorMap map;

void main() {
  initializeView(query('#mainCanvas'), setup, () {});
  httpGetJson('/s/colors.json', (response) {
    map = new ColorMap.fromJson(response);
  });
}

void setup(RenderingContext gl) {
  setGlobalRenderingContext(gl);
  new MaterialManager();
  Map<String, String> attrs = query('#data').attributes;
  if (attrs.containsKey('data-uri'))
    httpGetPlainText(attrs['data-uri'], parseDat);
  else if (attrs.containsKey('data-model'))
    print('has model: ' + parse(attrs['data-model']).toString());
}

void postprocessModel(LDrawModel m, Resolver r) {
  Model model = new Model(m);
  model.buildPartAsynchronously(r, (int id, String partName, Part partData, int total, int remaining, int elapsed) {
    query('#progress').appendHtml('processed subfile $partName in $elapsed ms (${total - remaining} / $total)<br />');
  }, () {
    query('#progress').appendHtml('postprocess done.<br />');
    query('#progress').appendHtml('compiling...<br />');
    Stopwatch w = new Stopwatch();
    w.start();
    model.compile();
    w.stop();
    query('#progress').appendHtml('compiling done in ${w.elapsedMilliseconds} ms.<br />');
    query('#progress').appendHtml('# of total tris: ${model.triCount}<br />');
    query('#progress').appendHtml('# of total edges: ${model.edgeCount}<br />');
    
    blah(model);
  });
}

void blah(Model model) {
  MaterialManager m = MaterialManager.instance;
  Mat4 persp = perspectiveMatrix(radians(45.0), 1024.0/768.0, 1.0, 1000.0);
  Mat4 mv = new Mat4.identity();
  Vec4 worldPos = new Vec4();

  matrixTranslate(persp, 0.0, 0.0, -600.0);
  matrixRotate(mv, new Vec4.xyz(1.0, 0.0, 0.0), radians(220.0));

  query('#mainCanvas').onMouseWheel.listen((WheelEvent e) {
    if (e.deltaY == 0.0)
      return;

    matrixTranslate(persp, 0.0, 0.0, -e.deltaY * 0.5);

    e.preventDefault();
  });

  Vec4 axis = new Vec4.xyz(0.0, 0.5, 0.0);

  GL.clearColor(0.8, 0.8, 0.8, 1.0);
  GL.enable(CULL_FACE);
  GL.cullFace(BACK);
  GL.enable(DEPTH_TEST);
  GL.enable(BLEND);
  GL.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
  GL.lineWidth(3.0);

  Mat3 normalMatrix = new Mat3();

  /* init geometry */
  Map<MeshCategory, Buffer> vbufs = new HashMap<MeshCategory, Buffer>();
  Map<MeshCategory, Buffer> nbufs = new HashMap<MeshCategory, Buffer>();
  Map<MeshCategory, int> elems = new HashMap<MeshCategory, int>();
  List<MeshCategory> renderingOrder = new List.from(model.meshChunks.keys);
  renderingOrder.sort();

  for (MeshCategory c in renderingOrder) {
    Buffer b;
    b = GL.createBuffer();
    GL.bindBuffer(ARRAY_BUFFER, b);
    GL.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(model.meshChunks[c].vertexArray), STATIC_DRAW);
    vbufs[c] = b;
    b = GL.createBuffer();
    GL.bindBuffer(ARRAY_BUFFER, b);
    GL.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(model.meshChunks[c].normalArray), STATIC_DRAW);
    nbufs[c] = b;
    elems[c] = model.meshChunks[c].count;
  }

  Buffer edgev, edgec;
  edgev = GL.createBuffer();
  GL.bindBuffer(ARRAY_BUFFER, edgev);
  GL.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(model.edges.edgeVertices), STATIC_DRAW);
  edgec = GL.createBuffer();
  GL.bindBuffer(ARRAY_BUFFER, edgec);
  GL.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList(model.edges.edgeColors), STATIC_DRAW);
  int edgecnt = model.edges.count;

  model.recycle();

  num pt = 0.0;
  int cstp = -1;
  void draw(num frame) {
    GL.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);

    matrixRotate(mv, axis, (pt - frame) / 500.0);
    mv.toInverseMat3(normalMatrix);

    int step = frame.floor();
    for (MeshCategory c in renderingOrder) {
      m.bind(c.color);
      LDrawShader s = m.activeShader;

      GL.uniformMatrix4fv(s.projectionMatrix, false, persp.val);
      GL.uniformMatrix4fv(s.modelViewMatrix, false, mv.val);
      GL.uniformMatrix3fv(s.normalMatrix, false, normalMatrix.val);
      GL.uniform1i(s.isBfcCertified, c.bfc ? 1 : 0);

      if (c.bfc)
        GL.enable(CULL_FACE);
      else
        GL.disable(CULL_FACE);

      if (c.color.isTransparent)
        GL.enable(BLEND);
      else
        GL.disable(BLEND);

      GL.bindBuffer(ARRAY_BUFFER, vbufs[c]);
      GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
      GL.bindBuffer(ARRAY_BUFFER, nbufs[c]);
      GL.vertexAttribPointer(s.vertexNormal, 3, FLOAT, false, 0, 0);
      GL.drawArrays(TRIANGLES, 0, elems[c]);
    }

    m.bindEdgeShader();
    EdgeShader s = m.activeShader;

    GL.disable(CULL_FACE);
    GL.disable(BLEND);

    GL.uniformMatrix4fv(s.projectionMatrix, false, persp.val);
    GL.uniformMatrix4fv(s.modelViewMatrix, false, mv.val);
    GL.bindBuffer(ARRAY_BUFFER, edgev);
    GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
    GL.bindBuffer(ARRAY_BUFFER, edgec);
    GL.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);
    GL.drawArrays(LINES, 0, edgecnt);

    GL.finish();

    window.requestAnimationFrame(draw);

    pt = frame;
  }

  window.requestAnimationFrame(draw);
}

void parseDat(List<String> response) {
  Resolver r = new Resolver();
  LDrawMultipartModel model = new LDrawMultipartModel();
  parseMultipartModel(model, response.iterator);
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
    });
}
