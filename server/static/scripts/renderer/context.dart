// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Renderer {

  RenderingContext gl;
  CanvasElement canvas;
  MaterialManager materialManager;

  bool get isInitialized {
    return gl != null;
  }

  Renderer(CanvasElement canvas,
      {bool alpha: true, bool antialias: true, bool stencil: false}) {
    this.canvas = canvas;

    try {
      gl =
        canvas.getContext3d(alpha: alpha, antialias: antialias, stencil: stencil);
    } catch (e) {
      gl = null;
    }
  }

  void resizeView(int width, int height)
  {
    canvas.width = width;
    canvas.height = height;
    gl.viewport(0, 0, width, height); 
  }

  void setupState() {
    gl.clearColor(0.0, 0.0, 0.0, 0.0);
    gl.cullFace(BACK);
    gl.enable(CULL_FACE);
    gl.enable(DEPTH_TEST);
    gl.enable(BLEND);
    gl.depthFunc(LEQUAL);
    gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
    gl.lineWidth(1.0);
  }

  void setupMaterials() {
    materialManager = new MaterialManager(this);
  }

  void render(Camera camera, Scene scene, void func()) {
    gl.clear(COLOR_BUFFER_BIT, DEPTH_BUFFER_BIT);

    func();

    gl.finish();
  }

}