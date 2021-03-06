// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

const num EPSILON = 0.000001;
const num DEG2RAD = PI / 180.0;
const num RAD2DEG = 180.0 / PI;

num radians(num deg) => deg * DEG2RAD;
num degrees(num rad) => rad * RAD2DEG;
num clamp(num v) => min(max(v, -1), 1);
num iszero(num v) => v.abs() < EPSILON;

class Vec4 implements Comparable {
  Float32List val;
  Function onChange;

  Vec4() {
    val = new Float32List(4);
    val[0] = 0.0; val[1] = 0.0; val[2] = 0.0; val[3] = 1.0;
  }

  Vec4.fromList(List array) {
    val = new Float32List(4);
    for (int i = 0; i < 4; ++i)
      val[i] = array[i];
  }

  Vec4.fromJson(List array) {
    val = new Float32List(4);
    for (int i = 0; i < 4; ++i)
      val[i] = array[i];
  }

  Vec4.xyz(num x, num y, num z) {
    val = new Float32List(4);
    val[0] = x; val[1] = y; val[2] = z; val[3] = 1.0;
  }

  Vec4.xyzw(num x, num y, num z, num w) {
    val = new Float32List(4);
    val[0] = x; val[1] = y; val[2] = z; val[3] = w;
  }

  Vec4.fromEuler(Euler euler) {
    super();
    setFromEuler(euler);
  }

  Vec4.from(Vec4 other) {
    val = new Float32List(4);
    val[0] = other.val[0];
    val[1] = other.val[1];
    val[2] = other.val[2];
    val[3] = other.val[3];
  }

  /* xyzw */
  num get x => val[0];
  num get y => val[1];
  num get z => val[2];
  num get w => val[3];

  /* rgba */
  num get r => val[0];
  num get g => val[1];
  num get b => val[2];
  num get a => val[3];

  num operator [] (int index) => val[index];
  void operator []= (int index, num v) {
    val[index] = v;

    onChangeCallback();
  }

  Vec4 set(num x, num y, num z, [num w = 1.0]) {
    val[0] = x; val[1] = y; val[2] = z; val[3] = w;

    onChangeCallback();

    return this;
  }

  Vec4 copy(Vec4 other) {
    val[0] = other.x;
    val[1] = other.y;
    val[2] = other.z;
    val[3] = other.w;

    onChangeCallback();

    return this;
  }

  void set x(num v) {
    val[0] = v;
    onChangeCallback();
  }

  void set y(num v) {
    val[1] = v;
    onChangeCallback();
  }

  void set z(num v) {
    val[2] = v;
    onChangeCallback();
  }

  void set w(num v) {
    val[3] = v;
    onChangeCallback();
  }

  int get hashCode => toString().hashCode;

  int compareTo(Vec4 other) {
    return length.compareTo(other.length);
  }

  num get length => sqrt(x*x + y*y + z*z);

  Vec4 normalize([Vec4 out = null]) {
    if (out == null)
      out = new Vec4();

    num r = length;

    if (r != 0.0)
      out.set(x / r, y / r, z / r);
    else
      out.set(0.0, 0.0, 0.0);

    out.onChangeCallback();

    return out;
  }

  String toString() {
    return '($x, $y, $z)';
  }

  String toDat() {
    return '$x $y $z';
  }

  Vec4 operator + (Vec4 rhs) {
    return add(rhs);
  }

  Vec4 operator - (Vec4 rhs) {
    return subtract(rhs);
  }

  Vec4 operator - () {
    return negate();
  }

  Vec4 operator * (num s) {
    return scalarMultiply(s);
  }

  Vec4 add(Vec4 other, [Vec4 out = null]) {
    if (out == null)
      out = new Vec4();

    out.x = x + other.x;
    out.y = y + other.y;
    out.z = z + other.z;

    out.onChangeCallback();

    return out;
  }

  Vec4 subtract(Vec4 other, [Vec4 out = null]) {
    if (out == null)
      out = new Vec4();

    out.x = x - other.x;
    out.y = y - other.y;
    out.z = z - other.z;

    out.onChangeCallback();

    return out;
  }

  Vec4 scalarMultiply(num v, [Vec4 out = null]) {
    if (out == null)
      out = new Vec4();

    out.x = x * v;
    out.y = y * v;
    out.z = z * v;

    out.onChangeCallback();

    return out;
  }
  
  Vec4 negate([Vec4 out = null]) {
    if (out == null)
      out = new Vec4.xyz(-x, -y, -z);
    else
      out.set(-x, -y, -z);

    out.onChangeCallback();

    return out;
  }

  bool operator == (Vec4 other) {
    return equals(this, other);
  }

  static num distance(Vec4 a, Vec4 b) {
    num x = a.x - b.x;
    num y = a.y - b.y;
    num z = a.z - b.z;

    return sqrt(x*x + y*y + z*z);
  }

  static num angle(Vec4 a, Vec4 b) {
    return acos(dot(a, b) / (sqrt(a.x*a.x + a.y*a.y + a.z*a.z) *
                             sqrt(b.x*b.x + b.y*b.y + b.z*b.z)));
  }

  static num dot(Vec4 a, Vec4 b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
  }

  static Vec4 cross(Vec4 a, Vec4 b, [Vec4 out = null]) {
    if (out == null)
      out = new Vec4();

    out.set(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);

    out.onChangeCallback();

    return out;
  }

  static Vec4 interpolate(Vec4 a, Vec4 b, [Vec4 out = null]) {
    if (out == null)
      out = new Vec4();

    out.set((a.x + b.x) * 0.5, (a.y + b.y) * 0.5, (a.z + b.z) * 0.5, (a.w + b.w) * 0.5);

    out.onChangeCallback();

    return out;
  }

  static bool equals(Vec4 a, Vec4 b) {
    num x = (a.x - b.x).abs();
    num y = (a.y - b.y).abs();
    num z = (a.z - b.z).abs();
    num w = (a.w - b.w).abs();

    if (x < EPSILON && y < EPSILON && z < EPSILON && w < EPSILON)
      return true;
    else
      return false;
  }

  List toJson() {
    return [x, y, z, w];
  }

  void onChangeCallback() {
    if (onChange != null)
      onChange();
  }
}

class Quaternion extends Vec4 {
  void setFromEuler(Euler euler, [bool updateLinked = true]) {
    num c1 = cos(euler.x / 2);
    num c2 = cos(euler.y / 2);
    num c3 = cos(euler.z / 2);
    num s1 = sin(euler.x / 2);
    num s2 = sin(euler.y / 2);
    num s3 = sin(euler.z / 2);

    if (euler.order == Euler.XYZ) {
      val[0] = s1 * c2 * c3 + c1 * s2 * s3;
      val[1] = c1 * s2 * c3 - s1 * c2 * s3;
      val[2] = c1 * c2 * s3 + s1 * s2 * c3;
      val[3] = c1 * c2 * c3 - s1 * s2 * s3;
    } else if (euler.order == Euler.YXZ) {
      val[0] = s1 * c2 * c3 + c1 * s2 * s3;
      val[1] = c1 * s2 * c3 - s1 * c2 * s3;
      val[2] = c1 * c2 * s3 - s1 * s2 * c3;
      val[3] = c1 * c2 * c3 + s1 * s2 * s3;
    } else if (euler.order == Euler.ZXY) {
      val[0] = s1 * c2 * c3 - c1 * s2 * s3;
      val[1] = c1 * s2 * c3 + s1 * c2 * s3;
      val[2] = c1 * c2 * s3 + s1 * s2 * c3;
      val[3] = c1 * c2 * c3 - s1 * s2 * s3;
    } else if (euler.order == Euler.ZYX) {
      val[0] = s1 * c2 * c3 - c1 * s2 * s3;
      val[1] = c1 * s2 * c3 + s1 * c2 * s3;
      val[2] = c1 * c2 * s3 - s1 * s2 * c3;
      val[3] = c1 * c2 * c3 + s1 * s2 * s3;
    } else if (euler.order == Euler.YZX) {
      val[0] = s1 * c2 * c3 + c1 * s2 * s3;
      val[1] = c1 * s2 * c3 + s1 * c2 * s3;
      val[2] = c1 * c2 * s3 - s1 * s2 * c3;
      val[3] = c1 * c2 * c3 - s1 * s2 * s3;
    } else if (euler.order == Euler.XZY) {
      val[0] = s1 * c2 * c3 - c1 * s2 * s3;
      val[1] = c1 * s2 * c3 - s1 * c2 * s3;
      val[2] = c1 * c2 * s3 + s1 * s2 * c3;
      val[3] = c1 * c2 * c3 + s1 * s2 * s3;
    }

    if (updateLinked)
      onChangeCallback();
  }

  Quaternion setFromRotationMatrix(Mat4 mat) {
    Float32List te = mat.val;

    num m11 = te[0], m12 = te[4], m13 = te[8];
    num m21 = te[1], m22 = te[5], m23 = te[9];
    num m31 = te[2], m32 = te[6], m33 = te[10];

    num trace = m11 + m22 + m33;
    num s;

    if (trace > 0.0) {
      s = 0.5 / sqrt(trace + 1.0);
      val[0] = (m32 - m23) * s;
      val[1] = (m13 - m31) * s;
      val[2] = (m21 - m12) * s;
      val[3] = 0.25 / s;
    } else if (m11 > m22 && m11 > m33) {
      s = 2.0 * sqrt(1.0 + m11 - m22 - m33);
      val[0] = 0.25 * s;
      val[1] = (m12 + m21) / s;
      val[2] = (m13 + m31) / s;
      val[3] = (m32 - m23) / s;
    } else if (m22 > m33) {
      s = 2.0 * sqrt(1.0 + m22 - m11 - m33);
      val[0] = (m12 + m21) / s;
      val[1] = 0.25 * s;
      val[2] = (m23 + m32) / s;
      val[3] = (m13 - m31) / s;
    } else {
      s = 2.0 * sqrt(1.0 + m33 - m11 - m22);
      val[0] = (m13 + m31) / s;
      val[1] = (m23 + m32) / s;
      val[2] = 0.25 * s;
      val[3] = (m21 - m12) / s;
    }

    onChangeCallback();

    return this;
  }

  String toString() {
    return '($x, $y, $z, $w)';
  }
}

class Mat3 {

  Float32List val;

  num get(int r, int c) => val[r*3 + c];
  num set(int r, int c, num v) => val[r*3 + c] = v;

  Mat3() {
    val = new Float32List(9);
  }

  Mat3.init(num a, num b, num c, num d, num e, num f, num g,
      num h, num i) {
    val = new Float32List(9);
    val[0] = a; val[1] = b; val[2] = c;
    val[3] = d; val[4] = e; val[5] = f;
    val[6] = g; val[7] = h; val[8] = i;
  }

  Mat3.copy(Mat3 other) {
    val = new Float32List(9);
    for (int i = 0; i < 9; ++i)
      val[i] = other.val[i];
  }

  Mat3.identity() {
    val = new Float32List(9);
    val[0] = 1.0; val[1] = 0.0; val[2] = 0.0;
    val[3] = 0.0; val[4] = 1.0; val[5] = 0.0;
    val[6] = 0.0; val[7] = 0.0; val[8] = 1.0;
  }

  Mat3 operator +(Mat3 other) {
    Mat3 n = new Mat3();
    for (int i = 0; i < 9; ++i)
      n.val[i] = val[i] + other.val[i];
    return n;
  }

  Mat3 operator -(Mat3 other) {
    Mat3 n = new Mat3();
    for (int i = 0; i < 9; ++i)
      n.val[i] = val[i] - other.val[i];
    return n;
  }

  Mat3 operator *(Mat3 v) {
    // matrix-by-matrix multiplication
    Mat3 n = new Mat3();
    for (int r = 0; r < 3; ++r) {
      for (int c = 0; c < 3; ++c) {
        n.set(r, c, 0.0);
        for (int k = 0; k < 3; ++k)
          n.set(r, c, n.get(r, c) + (get(r, k) * v.get(k, c)));
      }
    }
    return n;
  }

  Mat3 multiplyScalar(num f, [Mat3 out = null]) {
    if (out == null)
      out = new Mat3();

    Float32Array me = out.val;
    Float32Array te = val;

    me[0] = te[0] * f;
    me[1] = te[1] * f;
    me[2] = te[2] * f;
    me[3] = te[3] * f;
    me[4] = te[4] * f;
    me[5] = te[5] * f;
    me[6] = te[6] * f;
    me[7] = te[7] * f;
    me[8] = te[8] * f;

    return this;
  }

  void clone(Mat3 v) {
    for (int i = 0; i < 9; ++i)
      val[i] = v.val[i];
  }

  void getInverse(Mat4 other) {
    Float32Array me = other.val;
    Float32Array te = val;

    te[ 0 ] =   me[ 10 ] * me[ 5 ] - me[ 6 ] * me[ 9 ];
    te[ 1 ] = - me[ 10 ] * me[ 1 ] + me[ 2 ] * me[ 9 ];
    te[ 2 ] =   me[ 6 ] * me[ 1 ] - me[ 2 ] * me[ 5 ];
    te[ 3 ] = - me[ 10 ] * me[ 4 ] + me[ 6 ] * me[ 8 ];
    te[ 4 ] =   me[ 10 ] * me[ 0 ] - me[ 2 ] * me[ 8 ];
    te[ 5 ] = - me[ 6 ] * me[ 0 ] + me[ 2 ] * me[ 4 ];
    te[ 6 ] =   me[ 9 ] * me[ 4 ] - me[ 5 ] * me[ 8 ];
    te[ 7 ] = - me[ 9 ] * me[ 0 ] + me[ 1 ] * me[ 8 ];
    te[ 8 ] =   me[ 5 ] * me[ 0 ] - me[ 1 ] * me[ 4 ];

    num det = me[ 0 ] * te[ 0 ] + me[ 1 ] * te[ 3 ] + me[ 2 ] * te[ 6 ];
    
    if (det == 0.0) {
      print('Mat3.getInverse(): not inversible!');
      for (int i = 0; i < 9; ++i)
        te[i] = 0.0;
      return;
    }

    multiplyScalar(1.0 / det, this);
  }

  void transpose() {
    num tmp;

    tmp = val[ 1 ]; val[ 1 ] = val[ 3 ]; val[ 3 ] = tmp;
    tmp = val[ 2 ]; val[ 2 ] = val[ 6 ]; val[ 6 ] = tmp;
    tmp = val[ 5 ]; val[ 5 ] = val[ 7 ]; val[ 7 ] = tmp;
  }

  String toString() {
    return '[${val[0]}, ${val[1]}, ${val[2]},\n'
      ' ${val[3]}, ${val[4]}, ${val[5]},\n'
      ' ${val[6]}, ${val[7]}, ${val[8]}]';
  }

  List toJson() {
    return [val[0], val[1], val[2], val[3], val[4], val[5], val[6], val[7], val[8]];
  }
}

class Mat4 {

  Float32List val;

  num get(int r, int c) => val[r*4 + c];
  num set(int r, int c, num v) => val[r*4 + c] = v;

  Mat4() {
    val = new Float32List(16);
  }

  Mat4.fromList(List array) {
    val = new Float32List(16);
    for (int i = 0; i < 16; ++i)
      val[i] = array[i];
  }

  Mat4.fromJson(List array) {
    val = new Float32List(16);
    for (int i = 0; i < 16; ++i)
      val[i] = array[i];
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

    setIdentity();
  }

  Mat4.inversed(Mat4 other) {
    val = new Float32List(16);

    other.inverse(this);
  }

  Mat4 operator +(Mat4 other) {
    return add(other);
  }

  Mat4 operator -(Mat4 other) {
    return subtract(other);
  }

  Mat4 operator *(Mat4 v) {
    return multiply(v);
  }

  Mat4 add(Mat4 other, [Mat4 output = null]) {
    if (output == null)
      output = new Mat4();

    for (int i = 0; i < 16; ++i)
      output.val[i] = val[i] + other.val[i];

    return output;
  }

  Mat4 subtract(Mat4 other, [Mat4 output = null]) {
    if (output == null)
      output = new Mat4();

    for (int i = 0; i < 16; ++i)
      output.val[i] = val[i] - other.val[i];

    return output;
  }

  Mat4 multiply(Mat4 v, [Mat4 output = null]) {
    if (output == null)
      output = new Mat4();

    num x;
    for (int r = 0; r < 4; ++r) {
      for (int c = 0; c < 4; ++c) {
        x = 0.0;
        for (int k = 0; k < 4; ++k)
          x += get(r, k) * v.get(k, c);
        output.set(r, c, x);
      }
    }

    return output;
  }

  Mat4 setIdentity() {
    val[0]  = 1.0; val[1]  = 0.0; val[2]  = 0.0; val[3]  = 0.0;
    val[4]  = 0.0; val[5]  = 1.0; val[6]  = 0.0; val[7]  = 0.0;
    val[8]  = 0.0; val[9]  = 0.0; val[10] = 1.0; val[11] = 0.0;
    val[12] = 0.0; val[13] = 0.0; val[14] = 0.0; val[15] = 1.0;

    return this;
  }

  Mat4 zero() {
    val[0]  = 0.0; val[1]  = 0.0; val[2]  = 0.0; val[3]  = 0.0;
    val[4]  = 0.0; val[5]  = 0.0; val[6]  = 0.0; val[7]  = 0.0;
    val[8]  = 0.0; val[9]  = 0.0; val[10] = 0.0; val[11] = 0.0;
    val[12] = 0.0; val[13] = 0.0; val[14] = 0.0; val[15] = 0.0;

    return this;
  }

  Mat4 clone(Mat4 v) {
    val[0] = v.val[0];
    val[1] = v.val[1];
    val[2] = v.val[2];
    val[3] = v.val[3];
    val[4] = v.val[4];
    val[5] = v.val[5];
    val[6] = v.val[6];
    val[7] = v.val[7];
    val[8] = v.val[8];
    val[9] = v.val[9];
    val[10] = v.val[10];
    val[11] = v.val[11];
    val[12] = v.val[12];
    val[13] = v.val[13];
    val[14] = v.val[14];
    val[15] = v.val[15];

    return this;
  }

  Vec4 transform(Vec4 v, [Vec4 out = null]) {
    // linear transform
    if (out == null)
      out = new Vec4();
    
    out.set(
        val[0]*v.x + val[1]*v.y + val[2]*v.z + val[3]*v.w,
        val[4]*v.x + val[5]*v.y + val[6]*v.z + val[7]*v.w,
        val[8]*v.x + val[9]*v.y + val[10]*v.z + val[11]*v.w,
        val[12]*v.x + val[13]*v.y + val[14]*v.z + val[15]*v.w);

    return out;
  }

  Mat4 setTranslation(num x, num y, num z, {bool row: false}) {
    if (row) {
      val[3] = x;
      val[7] = y;
      val[11] = z;
    } else {
      val[12] = x;
      val[13] = y;
      val[14] = z;
    }

    return this;
  }

  Mat4 scale(Vec4 v, [Mat4 out = null]) {
    if (out == null)
      out = new Mat4();

    Float32Array te = out.val;

    num x = v.x;
    num y = v.y;
    num z = v.z;

    te[0] = val[0] * x; te[4] = val[4] * y; te[8] = val[8] * z;
    te[1] = val[1] * x; te[5] = val[5] * y; te[9] = val[9] * z;
    te[2] = val[2] * x; te[6] = val[6] * y; te[10] = val[10] * z;
    te[3] = val[3] * x; te[7] = val[7] * y; te[11] = val[11] * z;
    
    return out;
  }

  Mat4 applyRotationFromQuat(Vec4 q) {
    num x = q.x, y = q.y, z = q.z, w = q.w;
    num x2 = x + x, y2 = y + y, z2 = z + z;
    num xx = x * x2, xy = x * y2, xz = x * z2;
    num yy = y * y2, yz = y * z2, zz = z * z2;
    num wx = w * x2, wy = w * y2, wz = w * z2;
    
    val[0] = 1 - (yy + zz);
    val[4] = xy - wz;
    val[8] = xz + wy;
    
    val[1] = xy + wz;
    val[5] = 1 - (xx + zz);
    val[9] = yz - wx;
    
    val[2] = xz - wy;
    val[6] = yz + wx;
    val[10] = 1 - (xx + yy);
    
    val[3] = 0.0;
    val[7] = 0.0;
    val[11] = 0.0;
    
    val[12] = 0.0;
    val[13] = 0.0;
    val[14] = 0.0;
    val[15] = 1.0;

    return this;
  }

  Mat4 compose(Vec4 pos, Quaternion quat, Vec4 sc) {
    applyRotationFromQuat(quat);
    scale(sc, this);
    setTranslation(pos.x, pos.y, pos.z);

    return this;
  }

  /* for avoiding unnecessary allocs */
  static Vec4 v_ = new Vec4();
  static Mat4 m_ = new Mat4();
  static Vec4 x_ = new Vec4();
  static Vec4 y_ = new Vec4();
  static Vec4 z_ = new Vec4();

  void decompose(Vec4 pos, Quaternion quat, Vec4 scale) {
    Float32List te = val;

    num sx = v_.set(te[0], te[1], te[2]).length;
    num sy = v_.set(te[4], te[5], te[6]).length;
    num sz = v_.set(te[8], te[9], te[10]).length;
    
    num det = this.det();
    if (det < 0.0)
      sx = -sx;
    
    pos.x = te[3];
    pos.y = te[7];
    pos.z = te[11];
    
    m_.clone(this);
    
    num invSX = 1 / sx;
    num invSY = 1 / sy;
    num invSZ = 1 / sz;
    
    m_.val[0] *= invSX;
    m_.val[1] *= invSX;
    m_.val[2] *= invSX;
    
    m_.val[4] *= invSY;
    m_.val[5] *= invSY;
    m_.val[6] *= invSY;
    
    m_.val[8] *= invSZ;
    m_.val[9] *= invSZ;
    m_.val[10] *= invSZ;
    
    quaternion.setFromRotationMatrix(m_);
    
    scale.x = sx;
    scale.y = sy;
    scale.z = sz;
  }

  void lookAt(Vec4 eye, Vec4 target, Vec4 up) {
    Float32List te = val;

    eye.subtract(target, z_);
    z_.normalize(z_);
    if (z_.length == 0.0)
      z_.z = 1.0;

    Vec4.cross(up, z_, x_);
    x_.normalize(x_);
    if (x_.length == 0.0) {
      z_.x += 0.0001;
      Vec4.cross(up, z_, x_);
      x_.normalize(x_);
    }

    Vec4.cross(z_, x_, y_);
    
    te[0] = x_.x; te[4] = y_.x; te[8] = z_.x;
    te[1] = x_.y; te[5] = y_.y; te[9] = z_.y;
    te[2] = x_.z; te[6] = y_.z; te[10] = z_.z;
  }

  num det() {
    num det;

    det = val[0] * (val[5] * val[10] - val[6] * val[9]);
    det -= val[4] * (val[1] * val[10] - val[2] * val[9]);
    det += val[8] * (val[1] * val[6] - val[2] * val[5]);

    return det;
  }

  // Scalar multiplication
  Mat4 scalarMultiply(num v, [Mat4 target = null]) {
    if (target == null)
      target = new Mat4();

    for (int i = 0; i < 16; ++i)
      target.val[i] = val[i] * v;

    return target;
  }

  Mat4 transpose([Mat4 target = null]) {
    if (target == null)
      target = new Mat4();

    target.val[0] = val[0];
    target.val[1] = val[4];
    target.val[2] = val[8];
    target.val[3] = val[12];
    target.val[4] = val[1];
    target.val[5] = val[5];
    target.val[6] = val[9];
    target.val[7] = val[13];
    target.val[8] = val[2];
    target.val[9] = val[6];
    target.val[10] = val[10];
    target.val[11] = val[14];
    target.val[12] = val[3];
    target.val[13] = val[7];
    target.val[14] = val[11];
    target.val[15] = val[15];

    return target;
  }

  num inverse([Mat4 out = null]) {
    if (out == null)
      out = new Mat4();

    num a00 = val[0];
    num a01 = val[1];
    num a02 = val[2];
    num a03 = val[3];
    num a10 = val[4];
    num a11 = val[5];
    num a12 = val[6];
    num a13 = val[7];
    num a20 = val[8];
    num a21 = val[9];
    num a22 = val[10];
    num a23 = val[11];
    num a30 = val[12];
    num a31 = val[13];
    num a32 = val[14];
    num a33 = val[15];
    num b00 = a00 * a11 - a01 * a10;
    num b01 = a00 * a12 - a02 * a10;
    num b02 = a00 * a13 - a03 * a10;
    num b03 = a01 * a12 - a02 * a11;
    num b04 = a01 * a13 - a03 * a11;
    num b05 = a02 * a13 - a03 * a12;
    num b06 = a20 * a31 - a21 * a30;
    num b07 = a20 * a32 - a22 * a30;
    num b08 = a20 * a33 - a23 * a30;
    num b09 = a21 * a32 - a22 * a31;
    num b10 = a21 * a33 - a23 * a31;
    num b11 = a22 * a33 - a23 * a32;
    num det = (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06);
    if (det == 0.0) 
      return det;
    num invDet = 1.0 / det;

    out.val[0] = (a11 * b11 - a12 * b10 + a13 * b09) * invDet;
    out.val[1] = (-a01 * b11 + a02 * b10 - a03 * b09) * invDet;
    out.val[2] = (a31 * b05 - a32 * b04 + a33 * b03) * invDet;
    out.val[3] = (-a21 * b05 + a22 * b04 - a23 * b03) * invDet;
    out.val[4] = (-a10 * b11 + a12 * b08 - a13 * b07) * invDet;
    out.val[5] = (a00 * b11 - a02 * b08 + a03 * b07) * invDet;
    out.val[6] = (-a30 * b05 + a32 * b02 - a33 * b01) * invDet;
    out.val[7] = (a20 * b05 - a22 * b02 + a23 * b01) * invDet;
    out.val[8] = (a10 * b10 - a11 * b08 + a13 * b06) * invDet;
    out.val[9] = (-a00 * b10 + a01 * b08 - a03 * b06) * invDet;
    out.val[10] = (a30 * b04 - a31 * b02 + a33 * b00) * invDet;
    out.val[11] = (-a20 * b04 + a21 * b02 - a23 * b00) * invDet;
    out.val[12] = (-a10 * b09 + a11 * b07 - a12 * b06) * invDet;
    out.val[13] = (a00 * b09 - a01 * b07 + a02 * b06) * invDet;
    out.val[14] = (-a30 * b03 + a31 * b01 - a32 * b00) * invDet;
    out.val[15] = (a20 * b03 - a21 * b01 + a22 * b00) * invDet;

    return out;
  }

  Mat3 toInverseMat3([Mat3 dest = null]) {
    num a00 = val[0], a01 = val[1], a02 = val[2];
    num a10 = val[4], a11 = val[5], a12 = val[6];
    num a20 = val[8], a21 = val[9], a22 = val[10];

    num b01 = a22*a11 - a12*a21;
    num b11 = -a22*a10 + a12*a20;
    num b21 = a21*a10 - a11*a20;

    num d = a00*b01 + a01*b11 + a02*b21;
    if (d == 0.0)
      return null;
    num id = 1.0 / d;
        
    if (dest == null)
      dest = new Mat3();
    
    dest.val[0] = b01*id;
    dest.val[1] = (-a22*a01 + a02*a21)*id;
    dest.val[2] = (a12*a01 - a02*a11)*id;
    dest.val[3] = b11*id;
    dest.val[4] = (a22*a00 - a02*a20)*id;
    dest.val[5] = (-a12*a00 + a02*a10)*id;
    dest.val[6] = b21*id;
    dest.val[7] = (-a21*a00 + a01*a20)*id;
    dest.val[8] = (a11*a00 - a01*a10)*id;
    
    return dest;
  }

  String toString() {
    return '[${val[0]}, ${val[1]}, ${val[2]}, ${val[3]},\n'
      ' ${val[4]}, ${val[5]}, ${val[6]}, ${val[7]},\n'
      ' ${val[8]}, ${val[9]}, ${val[10]}, ${val[11]},\n'
      ' ${val[12]}, ${val[13]}, ${val[14]}, ${val[15]}]';
  }

  List toJson() {
    return [val[0], val[1], val[2], val[3],
            val[4], val[5], val[6], val[7],
            val[8], val[9], val[10], val[11],
            val[12], val[13], val[14], val[15]];
  }

  String toDat() {
    return
      '${val[3]} ${val[7]} ${val[11]} '
      '${val[0]} ${val[1]} ${val[2]} '
      '${val[4]} ${val[5]} ${val[6]} '
      '${val[8]} ${val[9]} ${val[10]}';
  }
}

class Euler {

  static const int XYZ = 0;
  static const int YZX = 1;
  static const int ZXY = 2;
  static const int XZY = 3;
  static const int YXZ = 4;
  static const int ZYX = 5;
  static const int DEFAULT_ORDER = 0;

  num x_;
  num y_;
  num z_;
  int order_;

  Function onChange;

  Euler() {
    set(0.0, 0.0, 0.0, DEFAULT_ORDER);
  }

  Euler.val(num x, num y, num z, [int order = 0]) {
    set(x, y, z, order);
  }

  Euler.copy(Euler other) {
    set(other.x, other.y, other.z, other.order);
  }

  Euler.fromRotationMatrix(Mat4 matrix, [int order = 0]) {
    setFromRotationMatrix(matrix, order);
  }

  Euler.fromQuaternion(Vec4 quat, [int order = 0]) {
    setFromQuaterion(quat, order);
  }

  num get x => x_;
  num get y => y_;
  num get z => z_;
  num get w => w_;
  int get order => order_;

  void set x(num x) {
    x_ = x;
    onChangeCallback();
  }

  void set y(num y) {
    y_ = y;
    onChangeCallback();
  }

  void set z(num z) {
    z_ = z;
    onChangeCallback();
  }

  void set w(num w) {
    w_ = w;
    onChangeCallback();
  }

  void set order(int order) {
    order_ = order;
    onChangeCallback();
  }

  Euler set(num x, num y, num z, [int order = 0]) {
    x_ = x;
    y_ = y;
    z_ = z;
    order_ = order;

    onChangeCallback();

    return this;
  }

  Euler setFromRotationMatrix(Mat4 matrix, [int order = 0]) {
    Float32List ot = matrix.val;

    num m11 = ot[0], m12 = ot[4], m13 = ot[8];
    num m21 = ot[1], m22 = ot[5], m23 = ot[9];
    num m31 = ot[2], m32 = ot[6], m33 = ot[10];

    this.order = order;

    switch (order) {
      case XYZ:
        y_ = asin(clamp(m13));
        if (m13.abs() < 0.99999) {
          x_ = atan2(-m23, m33);
          z_ = atan2(-m12, m11);
        } else {
          x_ = atan2(m32, m22);
          z_ = 0.0;
        }
        break;
      case YXZ:
        x_ = asin(-clamp(m23));
        if (m23.abs() < 0.99999) {
          y_ = atan2(m13, m33);
          z_ = atan2(m21, m22);
        } else {
          y_ = atan2(-m31, m11);
          z_ = 0.0;
        }
        break;
      case ZXY:
        x_ = asin(clamp(m32));
        if (m32.abs() < 0.99999) {
          y_ = atan2(-m31, m33);
          z_ = atan2(-m12, m22);
        } else {
          y_ = 0.0;
          z_ = atan2(-m12, m22);
        }
        break;
      case ZYX:
        y_ = asin(-clamp(m31));
        if (m31.abs() < 0.99999) {
          x_ = atan2(m32, m33);
          z_ = atan2(m21, m11);
        } else {
          x_ = 0.0;
          z_ = atan2(-m12, m22);
        }
        break;
      case YZX:
        z_ = asin(clamp(m21));
        if (m21.abs() < 0.99999) {
          x_ = atan2(-m23, m22);
          y_ = atan2(-m31, m11);
        } else {
          x_ = 0.0;
          y_ = atan2(m13, m33);
        }
        break;
      case XZY:
        z_ = asin(-clamp(m12));
        if (m12.abs() < 0.99999) {
          x_ = atan2(m32, m22);
          y_ = atan2(m13, m11);
        } else {
          x_ = atan2(-m23, m33);
          y_ = 0.0;
        }
      default:
        print('Euler.setFromRotationMatrix: unsupported order $order');
    }

    onChangeCallback();

    return this;
  }

  Euler setFromQuaternion(Vec4 q, [int order = 0, bool updateLinked = true]) {
    num sqx = q.x * q.x;
    num sqy = q.y * q.y;
    num sqz = q.z * q.z;
    num sqw = q.w * q.w;

    if (order != null)
      this.order = order;

    if (this.order == XYZ) {
      x_ = atan2(2 * (q.x * q.w - q.y * q.z), (sqw - sqx - sqy + sqz));
      y_ = asin(clamp(2 * (q.x * q.z + q.y * q.w)));
      z_ = atan2(2 * (q.z * q.w - q.x * q.y), (sqw + sqx - sqy - sqz));
    } else if (this.order == YXZ) {
      x_ = asin(clamp(2 * (q.x * q.w - q.y * q.z)));
      y_ = atan2(2 * (q.x * q.z + q.y * q.w), (sqw - sqx - sqy + sqz));
      z_ = atan2(2 * (q.x * q.y + q.z * q.w), (sqw - sqx + sqy - sqz));
    } else if (this.order == ZXY) {
      x_ = asin(clamp(2 * (q.x * q.w + q.y * q.z)));
      y_ = atan2(2 * (q.y * q.w - q.z * q.x), (sqw - sqx - sqy + sqz));
      z_ = atan2(2 * (q.z * q.w - q.x * q.y), (sqw - sqx + sqy - sqz));
    } else if (this.order == ZYX) {
      x_ = atan2(2 * (q.x * q.w + q.z * q.y), (sqw - sqx - sqy + sqz));
      y_ = asin(clamp(2 * (q.y * q.w - q.x * q.z)));
      z_ = atan2(2 * (q.x * q.y + q.z * q.w), (sqw + sqx - sqy - sqz));
    } else if (this.order == YZX) {
      x_ = atan2(2 * (q.x * q.w - q.z * q.y), (sqw - sqx + sqy - sqz));
      y_ = atan2(2 * (q.y * q.w - q.x * q.z), (sqw + sqx - sqy - sqz));
      z_ = asin(clamp(2 * (q.x * q.y + q.z * q.w)));
    } else if (this.order == XZY) {
      x_ = atan2(2 * (q.x * q.w + q.y * q.z ), (sqw - sqx + sqy - sqz));
      y_ = atan2(2 * (q.x * q.z + q.y * q.w ), (sqw + sqx - sqy - sqz));
      z_ = asin(clamp(2 * (q.z * q.w - q.x * q.y)));
    } else {
      print('Euler.setFromQuaternion: unsupported order $order');
      return this;
    }

    if (updateLinked)
      onChangeCallback();

    return this;
  }

  void onChangeCallback() {
    if (onChange != null) {
      onChange();
    }
  }
}

class Plane {
  Vec4 normal;
  num constant;

  Plane() {
    normal = new Vec4();
    constant = 0.0;
  }

  Plane.val(this.normal, this.constant);

  Plane setComponents(num x, num y, num z, num w) {
    normal.set(x, y, z);
    constant = w;

    return this;
  }
  
  Plane setFromNormalAndCoplanarPoint(Vec4 normal, Vec4 point) {
    this.normal.copy(normal);
    this.constant = -point.dot(this.normal);

    return this;
  }

  Plane normalize() {
    num inverseNormalLength = 1.0 / normal.length;
    normal.scalarMultiply(inverseNormalLength, normal);
    constant *= inverseNormalLength;

    return this;
  }

  num distanceToPoint(Vec4 point) {
    return Vec4.dot(normal, point) + constant;
  }

}

class Frustum {
  Plane p0, p1, p2, p3, p4, p5;

  Frustum() {
    p0 = new Plane();
    p1 = new Plane();
    p2 = new Plane();
    p3 = new Plane();
    p4 = new Plane();
    p5 = new Plane();
  }

  Frustum.val(this.p0, this.p1, this.p2, this.p3, this.p4, this.p5);

  void setFromMatrix(Mat4 m) {
    var me = m.val;

    p0.setComponents(me[3] - me[0], me[7] - me[4], me[11] - me[8], me[15] - me[12]).normalize();
    p1.setComponents(me[3] + me[0], me[7] + me[4], me[11] + me[8], me[15] + me[12]).normalize();
    p2.setComponents(me[3] + me[1], me[7] + me[5], me[11] + me[9], me[15] + me[13]).normalize();
    p3.setComponents(me[3] - me[1], me[7] - me[5], me[11] - me[9], me[15] - me[13]).normalize();
    p4.setComponents(me[3] - me[2], me[7] - me[6], me[11] - me[10], me[15] - me[14]).normalize();
    p5.setComponents(me[3] + me[2], me[7] + me[6], me[11] + me[10], me[15] + me[14]).normalize();
  }

  bool intersects(Object3D object) {
    return true; // FIXME
  }

}
