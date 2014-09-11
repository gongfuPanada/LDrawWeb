// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Object3D {
  Object3D parent;
  List<Object3D> children;

  static Vec4 kUpwardVector = new Vec4.xyz(0.0, 1.0, 0.0);

  Vec4 position;
  Euler rotation_;
  Quaternion quaternion_;
  bool visible;
  bool frustumCulled;
  Vec4 scale;
  Vec4 up;

  Mat4 matrix;
  Mat4 matrixWorld;
  Mat4 modelViewMatrix;
  Mat3 normalMatrix;
  bool matrixAutoUpdate;
  bool matrixWorldNeedsUpdate;

  Object3D() {
    parent = null;
    children = new List<Object3D>();

    visible = true;
    frustumCulled = true;
    
    position = new Vec4();
    rotation_ = new Euler();
    rotation_.onChange = updateQuaternion;
    quaternion_ = new Quaternion();
    quaternion_.onChange = updateEuler;
    scale = new Vec4.xyz(1.0, 1.0, 1.0);
    up = new Vec4.from(kUpwardVector);

    matrix = new Mat4.identity();
    matrixAutoUpdate = true;
    matrixWorld = new Mat4.identity();
    modelViewMatrix = new Mat4.identity();
    normalMatrix = new Mat3();
    matrixWorldNeedsUpdate = true;
  }

  void updateQuaternion() {
    quaternion_.setFromEuler(rotation_, false);
  }

  void updateEuler() {
    rotation_.setFromQuaternion(quaternion_, null, false);
  }

  Quaternion get quaternion => quaternion_;
  void set quaternion(Quaternion v) {
    quaternion_ = v;
    quaternion_.onChange = updateEuler;
  }

  Euler get rotation => rotation_;
  void set rotation(Euler v) {
    rotation_ = v;
    rotation_.onChange = updateQuaternion;
  }

  void applyMatrix(Mat4 matrix) {
    matrix.multiply(this.matrix, this.matrix);
    this.matrix.decompose(position, quaternion_, scale);
  }

  void updateMatrix() {
    matrix.compose(position, quaternion_, scale);
    matrixWorldNeedsUpdate = true;
  }
  
  void updateWorldMatrix([bool force = false]) {
    if (matrixAutoUpdate)
      updateMatrix();

    if (force || matrixWorldNeedsUpdate) {
      if (parent == null) {
        matrixWorld.clone(matrix);
      } else {
        matrix.multiply(parent.matrixWorld, matrixWorld);
      }

      matrixWorldNeedsUpdate = false;
      force = true;
    }

    for (Object3D child in children)
      child.updateWorldMatrix(force);
  }

  void setupMatrices(Camera camera) {
    matrixWorld.multiply(camera.matrixWorldInverse, modelViewMatrix);
    normalMatrix.getInverse(modelViewMatrix);
    normalMatrix.transpose();
  }

  void add(Object3D object) {
    if (object == this) {
      print('Object3D.add(): The object could not be added to itself');
      return;
    }

    if (object.parent != null)
      object.parent.remove(object);

    object.parent = this;
    children.add(object);
    
    // add to scene
    Object3D scene = this;
    while (scene.parent != null)
      scene = scene.parent;

    if (scene != null && scene is Scene)
      scene._add(object);
  }

  void remove(Object3D object) {
    object.parent = null;
    children.remove(object);
    
    // remove from scene
    Object3D scene = this;
    while (scene.parent != null)
      scene = scene.parent;

    if (scene != null && scene is Scene)
      scene._remove(object);
  }

  void renderChildren(Context context, Camera camera, [bool preorder = true]) {
    if (!visible)
      return;

    GlobalUniformValues uniformValues = context.uniformValues;

    if (preorder && this is Geometry) {
      uniformValues.modelMatrix = matrixWorld;
      setupMatrices(camera);
      uniformValues.modelViewMatrix = modelViewMatrix;
      uniformValues.normalMatrix = normalMatrix;
      render(context);
    }

    for (Object3D child in children) {
      child.renderChildren(context, camera, preorder);
    }
    
    if (!preorder && this is Geometry) {
      uniformValues.modelMatrix = matrixWorld;
      setupMatrices(camera);
      uniformValues.modelViewMatrix = modelViewMatrix;
      uniformValues.normalMatrix = normalMatrix;
      render(context);
    }
  }

  static Mat4 m1_ = new Mat4();
  
  void lookAt(Vec4 to) {
    m1_.lookAt(position, to, up);
    quaternion.setFromRotationMatrix(m1_);
  }
}

abstract class Geometry extends Object3D {
  void render(Context context);
}

