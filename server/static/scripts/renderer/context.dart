// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class GlobalUniformValues {
  // Matrix
  Mat4 projectionMatrix;
  Mat4 modelViewMatrix;
  Mat4 viewMatrix;
  Mat4 modelMatrix;
  Mat3 normalMatrix;

  // Light
  Vec4 lightDirection;
  Vec4 lightColor;
}

class Renderer {

  RenderingContext gl;
  CanvasElement canvas;
  MaterialManager materialManager;
  GlobalUniformValues uniformValues;

  Mat4 _projScreenMatrix;
  Mat4 _projScreenMatrixPS;
  Frustum _frustum;

  bool get isInitialized {
    return gl != null;
  }

  Renderer(CanvasElement canvas,
      {bool alpha: true, bool antialias: true, bool stencil: false}) {
    this.canvas = canvas;

    uniformValues = new GlobalUniformValues();

    try {
      gl =
        canvas.getContext3d(alpha: alpha, antialias: antialias, stencil: stencil);
    } catch (e) {
      gl = null;
    }

    _projScreenMatrix = new Mat4.identity();
    _projScreenMatrixPS = new Mat4.identity();
    _frustum = new Frustum();
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

  void render(Camera camera, Scene scene) {
    gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);

    if (scene.autoUpdate)
      scene.updateWorldMatrix();

    camera.updateWorldMatrix();
    camera.projectionMatrix.multiply(camera.matrixWorldInverse, _projScreenMatrix);
    _frustum.setFromMatrix(_projScreenMatrix);

    if (scene.light == null) {
      if (uniformValues.lightColor == null && uniformValues.lightDirection == null) {
        // add default values;
        uniformValues.lightColor = new Vec4.xyz(1.0, 1.0, 1.0);
        uniformValues.lightDirection = new Vec4.xyz(0.0, 0.5, 0.7);
        uniformValues.lightDirection.normalize(uniformValues.lightDirection);
      }
    } else {
      uniformValues.lightColor = scene.light.color;
      uniformValues.lightDirection = scene.light.direction;
    }

    uniformValues.viewMatrix = camera.matrixWorldInverse;
    uniformValues.projectionMatrix = camera.projectionMatrix;

    for (Object3D object in scene.objects) {
      object.renderChildren(this, camera);
    }

    gl.finish();
  }

  void projectObject(Scene scene, Object3D object, Camera camera) {
    if (!object.visible)
      return;

    if (!object.frustumCulled || _frustum.intersects(object)) {
      updateObject(scene, object);
    }

    for (Object3D child in object.children) {
      projectObject(scene, child, camera);
    }
  }

  void updateObject(Scene scene, Object3D object) {
    
  }

}