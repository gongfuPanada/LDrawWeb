// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Object3D {
  static Vec4 kUpside = new Vec4.xyz(0.0, -1.0, 0.0);

  Object3D parent;
  List<Object3D> children;

  Vec4 position;
  Euler rotation_;
  Quaternion quaternion_;
  Vec4 scale;

  Mat4 matrix;
  Mat4 matrixWorld;
  bool matrixAutoUpdate;
  bool matrixWorldNeedsUpdate;

  Object3D() {
    parent = null;
    children = new List<Object3D>();

    position = new Vec4();
    rotation_ = new Euler();
    quaternion_ = new Quaternion();
    rotation_.quaternion = quaternion_;
    quaternion_.euler = rotation_;
    scale = new Vec4.xyz(1.0, 1.0, 1.0);

    matrix = new Mat4.identity();
    matrixAutoUpdate = true;
    matrixWorld = new Mat4.identity();
    matrixWorldNeedsUpdate = true;
  }

  Quaternion get quaternion => quaternion_;
  void set quaternion(Quaternion v) {
    quaternion_ = v;
    quaternion_.euler = rotation_;
    rotation_.quaternion = quaternion_;
    quaternion_.updateEuler();
  }

  Euler get rotation => rotation_;
  void set rotation(Euler v) {
    rotation_ = v;
    rotation_.quaternion = quaternion_;
    quaternion_.euler = rotation_;
    rotation_.updateQuaternion();
  }

  void applyMatrix(Mat4 matrix) {
    matrix.multiply(matrix, this.matrix, this.matrix);
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
        parent.matrixWorld.multiply(matrix, matrixWorld);
      }

      matrixWorldNeedsUpdate = false;
      force = true;
    }

    for (Object3D child in children)
      child.updateWorldMatrix(force);
  }
}

class Geometry extends Object3D {

}

