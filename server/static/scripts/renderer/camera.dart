// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Camera extends Object3D {
  Mat4 matrixWorldInverse;
  Mat4 projectionMatrix;

  Camera() : super() {
    matrixWorldInverse = new Mat4.identity();
    projectionMatrix = new Mat4.identity();
  }

  void updateWorldMatrix([bool force = false]) {
    super.updateWorldMatrix(force);

    matrixWorld.inverse(matrixWorldInverse);
  }
}

class PerspectiveCamera extends Camera {

  num fov_;
  num aspectRatio_;
  num near_;
  num far_;

  num get fov => fov_;
  num get aspectRatio => aspectRatio_;
  num get near => near_;
  num get far => far_;

  void set fov(num v) {
    fov_ = v;
    updateProjectionMatrix();
  }

  void set aspectRatio(num v) {
    aspectRatio_ = v;
    updateProjectionMatrix();
  }

  void set near(num v) {
    near_ = v;
    updateProjectionMatrix();
  }

  void set far(num v) {
    far_ = v;
    updateProjectionMatrix();
  }

  PerspectiveCamera(num fov, num aspectRatio, num near, num far) : super() {
    fov_ = fov;
    aspectRatio_ = aspectRatio;
    near_ = near;
    far_ = far;
    updateProjectionMatrix();
  }

  void updateProjectionMatrix() {
    num top = near_ * tan(radians(fov_ * 0.5));
    num bottom = -top;
    num left = bottom * aspectRatio_;
    num right = top * aspectRatio_;

    Float32List te = projectionMatrix.val;
    num x = 2 * near_ / (right - left);
    num y = 2 * near_ / (top - bottom);
    
    num a = (right + left) / (right - left);
    num b = (top + bottom) / (top - bottom);
    num c = - (far_ + near_) / (far_ - near_);
    num d = - 2 * far_ * near_ / (far_ - near_);
    
    te[0] = x;	te[4] = 0.0;  te[8] =   a;   te[12] = 0.0;
    te[1] = 0.0; te[5] = y;   te[9] =   b;   te[13] = 0.0;
    te[2] = 0.0; te[6] = 0.0; te[10] =  c;   te[14] = d;
    te[3] = 0.0; te[7] = 0.0; te[11] = -1.0; te[15] = 0.0;
  }

}
