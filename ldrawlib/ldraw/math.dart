// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

const num EPSILON = 0.000001;

class Vec4 implements Comparable {
  List<num> val;

  Vec4() {
    val = new Float32List(4);
    val[0] = 0.0; val[1] = 0.0; val[2] = 0.0; val[3] = 1.0;
  }

  Vec4.xyz(num x, num y, num z) {
    val = new Float32List(4);
    val[0] = x; val[1] = y; val[2] = z; val[3] = 1.0;
  }

  Vec4.xyzw(num x, num y, num z, num w) {
    val = new Float32List(4);
    val[0] = x; val[1] = y; val[2] = z; val[3] = w;
  }

  Vec4.copy(Vec4 other) {
    val = new Float32List(4);
    val[0] = other.val[0];
    val[1] = other.val[1];
    val[2] = other.val[2];
    val[3] = other.val[3];
  }

  num x() => val[0];
  num y() => val[1];
  num z() => val[2];
  num w() => val[3];

  setX(num v) => val[0] = v;
  setY(num v) => val[1] = v;
  setZ(num v) => val[2] = v;
  setW(num v) => val[3] = v;

  int compareTo(Vec4 other) {
    print(length());
    return length().compareTo(other.length());
  }

  num length() {
    return sqrt(x()*x() + y()*y() + z()*z());
  }

  Vec4 normalize() {
    num r = length();

    if (r != 0.0)
      return new Vec4.xyz(x() / r, y() / r, z() / r);
    else
      return new Vec4();
  }

  String toString() {
    return '(${x()}, ${y()}, ${z()})';
  }

  String toDat() {
    return '${x()} ${y()} ${z()}';
  }

  Vec4 operator +(Vec4 rhs) {
    return new Vec4.xyz(x()+rhs.x(), y()+rhs.y(), z()+rhs.z());
  }

  Vec4 operator -(Vec4 rhs) {
    return new Vec4.xyz(x()-rhs.x(), y()-rhs.y(), z()-rhs.z());
  }

  Vec4 operator -() {
    return new Vec4.xyz(-x(), -y(), -z());
  }

  Vec4 operator *(num s) {
    return new Vec4.xyz(x()*s, y()*s, z()*s);
  }

  static num distance(Vec4 a, Vec4 b) {
    return sqrt(
        pow(a.x()-b.x(), 2.0) +
        pow(a.y()-b.y(), 2.0) +
        pow(a.z()-b.z(), 2.0));
  }

  static num angle(Vec4 a, Vec4 b) {
    return acos(dot(a, b) / (sqrt(a.x()*a.x() + a.y()*a.y() + a.z()*a.z()) *
                             sqrt(b.x()*b.x() + b.y()*b.y() + b.z()*b.z())));
  }

  static num dot(Vec4 a, Vec4 b) {
    return a.x()*b.x() + a.y()*b.y() + a.z()*b.z();
  }

  static Vec4 cross(Vec4 a, Vec4 b) {
    return new Vec4.xyz(
        a.y()*b.z() - a.z()*b.y(),
        a.z()*b.x() - a.x()*b.z(),
        a.x()*b.y() - a.y()*b.x());
  }
}

class Mat4 {
  List<num> val;

  num get(int r, int c) => val[r*4 + c];
  num set(int r, int c, num v) => val[r*4 + c] = v;

  Mat4() {
    val = new Float32List(16);
  }

  Mat4.init(num a, num b, num c, num d, num e, num f, num g,
      num h, num i, [num x=0.0, num y=0.0, num z=0.0]) {
    val = new Float32List(16);
    val[0]  = a;   val[1]  = b;   val[2]  = c;   val[3] = x;
    val[4]  = d;   val[5]  = e;   val[6]  = f;   val[7] = y;
    val[8]  = g;   val[9]  = h;   val[10] = i;   val[11] = z;
    val[12] = 0.0; val[13] = 0.0; val[14] = 0.0; val[15] = 1.0;
  }

  Mat4.copy(Mat4 other) {
    val = new Float32List(16);
    for (int i = 0; i < 16; ++i)
      val[i] = other.val[i];
  }

  Mat4.identity() {
    val = new Float32List(16);
    val[0]  = 1.0; val[1]  = 0.0; val[2]  = 0.0; val[3]  = 0.0;
    val[4]  = 0.0; val[5]  = 1.0; val[6]  = 0.0; val[7]  = 0.0;
    val[8]  = 0.0; val[9]  = 0.0; val[10] = 1.0; val[11] = 0.0;
    val[12] = 0.0; val[13] = 0.0; val[14] = 0.0; val[15] = 1.0;
  }

  Mat4 operator +(Mat4 other) {
    Mat4 n = new Mat4();
    for (int i = 0; i < 16; ++i)
      n.val[i] = val[i] + other.val[i];
    return n;
  }

  Mat4 operator -(Mat4 other) {
    Mat4 n = new Mat4();
    for (int i = 0; i < 16; ++i)
      n.val[i] = val[i] - other.val[i];
    return n
  }

  Mat4 operator *(Mat4 v) {
    // matrix-by-matrix multiplication
    Mat4 n = new Mat4();
    for (int r = 0; r < 4; ++r) {
      for (int c = 0; c < 4; ++c) {
        n.set(r, c, 0.0);
        for (int k = 0; k < 4; ++k)
          n.set(r, c, n.get(r, c) + (get(r, k) * v.get(k, c)));
      }
    }
    return n;
  }

  Vec4 transform(Vec4 v) {
    // linear transform
    return new Vec4.xyzw(
        val[0]*v.x() + val[1]*v.y() + val[2]*v.z() + val[3]*v.w(),
        val[4]*v.x() + val[5]*v.y() + val[6]*v.z() + val[7]*v.w(),
        val[8]*v.x() + val[9]*v.y() + val[10]*v.z() + val[11]*v.w(),
        val[12]*v.x() + val[13]*v.y() + val[14]*v.z() + val[15]*v.w());
  }

  // Scalar multiplication
  Mat4 scale(num v) {
    Mat4 n = new Mat4();
    for (int i = 0; i < 16; ++i)
      n.val[i] = val[i] * v;
    return n;
  }

  Mat4 transpose() {
    Mat4 n = new Mat4.copy(this);

    n.set(0, 1, get(1, 0)); n.set(1, 0, get(0, 1));
    n.set(0, 2, get(2, 0)); n.set(2, 0, get(0, 2));
    n.set(1, 2, get(2, 1)); n.set(2, 1, get(1, 2));
    n.set(3, 0, get(0, 3)); n.set(0, 3, get(3, 0));
    n.set(3, 1, get(1, 3)); n.set(1, 3, get(3, 1));
    n.set(3, 2, get(2, 3)); n.set(2, 3, get(3, 2));

    return n;
  }

  String toString() {
    return '[${val[0]}, ${val[1]}, ${val[2]}, ${val[3]},\n'
      ' ${val[4]}, ${val[5]}, ${val[6]}, ${val[7]},\n'
      ' ${val[8]}, ${val[9]}, ${val[10]}, ${val[11]},\n'
      ' ${val[12]}, ${val[13]}, ${val[14]}, ${val[15]}]';
  }

  String toDat() {
    return
      '${val[3]} ${val[7]} ${val[11]} '
      '${val[0]} ${val[1]} ${val[2]} '
      '${val[4]} ${val[5]} ${val[6]} '
      '${val[8]} ${val[9]} ${val[10]}';
  }
}
