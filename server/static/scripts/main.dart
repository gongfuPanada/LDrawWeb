import 'dart:html';
import 'dart:json';

CanvasElement getCanvas(String id) {
  return query('#$id');
}

WebGLRenderingContext setupWebGL(CanvasElement elem) {
  assert(elem != null);
  WebGLRenderingContext gl = elem.getContext('experimental-webgl');

  if (gl == null)
    return null;

  gl.viewport(0, 0, elem.width, elem.height);

  return gl;
}

void main() {
  CanvasElement canvas = getCanvas('mainCanvas');
  WebGLRenderingContext gl = setupWebGL(canvas);

  if (gl != null) {
    print('manse');
  }

  Map<String, String> attrs = query('#data').attributes;
  if (attrs.containsKey('data-uri'))
    print('has uri: ' + attrs['data-uri']);
  else if (attrs.containsKey('data-model'))
    print('has model: ' + parse(attrs['data-model']).toString());
  else
    print('meh');
}
