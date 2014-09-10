// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Camera extends Object3D {

  Mat4 matrixWorldInverse;
  Mat4 projectionMatrix;

  static Mat4 m1_ = new Mat4.identity();
  static Vec4 x_ = new Vec4();
  static Vec4 y_ = new Vec4();
  static Vec4 z_ = new Vec4();
  
  Camera() : super() {
    matrixWorldInverse = new Mat4.identity();
    projectionMatrix = new Mat4.identity();
  }

  static void lookAt_(Mat4 mat, Vec4 eye, Vec4 target, [Vec4 up = null]) {
    if (up == null)
      up = kUpside;
    
    eye.subtract(target, z_);
    if (z_.length == 0.0)
      z_.z = 1.0;

    Vec4.cross(up, z_, x_);
    x_.normalize(x_);
    if (x_.length == 0.0) {
      z_.x += 0.0001;
      Vec4.cross(up, z_, x_);
      x_.normalize();
    }
    
    Vec4.cross(z_, x_, y_);
    
    Float32List te = mat.val;
    te[0] = x.x; te[4] = y.x; te[8] = z.x;
    te[1] = x.y; te[5] = y.y; te[9] = z.y;
    te[2] = x.z; te[6] = y.z; te[10] = z.z;
  }

  void lookAt(Vec4 vector, [Vec4 up = null]) {
    lookAt_(m1_, position, vector, up);
    quaternion.setFromRotationMatrix(m1_);
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
