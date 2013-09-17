// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

Mat4 perspectiveMatrix(num fovY, num aspectRatio, num zNear, num zFar) {
  assert(zNear > 0.0 && zFar > 0.0);

  num height = tan(fovY * 0.5) * zNear;
  num width = height * aspectRatio;

  return frustumMatrix(-width, width, -height, height, zNear, zFar);
}

Mat4 frustumMatrix(num left, num right, num bottom, num top, num near, num far) {
  Mat4 m = new Mat4();
  setFrustumMatrix(m, left, right, bottom, top, near, far);
  return m;
}

void setFrustumMatrix(Mat4 m, num left, num right, num bottom, num top,
		      num near, num far) {
  num near2 = near * 2.0;
  num rl = right - left;
  num tb = top - bottom;
  num fn = far - near;
  m.clear();
  m.set(0, 0, near2 / rl);
  m.set(1, 1, near2 / tb);
  m.set(0, 2, (right + left) / rl);
  m.set(1, 2, (top + bottom) / tb);
  m.set(2, 2, -(far + near) / fn);
  m.set(3, 2, -1.0);
  m.set(2, 3, -(near2 * far) / fn);
}

void matrixRotate(Mat4 mat, Vec4 axis, num angle) {
  num len = axis.length;
  num x = axis.x / len;
  num y = axis.y / len;
  num z = axis.z / len;
  num c = cos(angle);
  num s = sin(angle);
  num C = 1.0 - c;
  num m11 = x * x * C + c;
  num m12 = x * y * C - z * s;
  num m13 = x * z * C + y * s;
  num m21 = y * x * C + z * s;
  num m22 = y * y * C + c;
  num m23 = y * z * C - x * s;
  num m31 = z * x * C - y * s;
  num m32 = z * y * C + x * s;
  num m33 = z * z * C + c;
  num t1 = mat.val[0] * m11 + mat.val[4] * m21 + mat.val[8] * m31;
  num t2 = mat.val[1] * m11 + mat.val[5] * m21 + mat.val[9] * m31;
  num t3 = mat.val[2] * m11 + mat.val[6] * m21 + mat.val[10] * m31;
  num t4 = mat.val[3] * m11 + mat.val[7] * m21 + mat.val[11] * m31;
  num t5 = mat.val[0] * m12 + mat.val[4] * m22 + mat.val[8] * m32;
  num t6 = mat.val[1] * m12 + mat.val[5] * m22 + mat.val[9] * m32;
  num t7 = mat.val[2] * m12 + mat.val[6] * m22 + mat.val[10] * m32;
  num t8 = mat.val[3] * m12 + mat.val[7] * m22 + mat.val[11] * m32;
  num t9 = mat.val[0] * m13 + mat.val[4] * m23 + mat.val[8] * m33;
  num t10 = mat.val[1] * m13 + mat.val[5] * m23 + mat.val[9] * m33;
  num t11 = mat.val[2] * m13 + mat.val[6] * m23 + mat.val[10] * m33;
  num t12 = mat.val[3] * m13 + mat.val[7] * m23 + mat.val[11] * m33;
  mat.val[0] = t1;
  mat.val[1] = t2;
  mat.val[2] = t3;
  mat.val[3] = t4;
  mat.val[4] = t5;
  mat.val[5] = t6;
  mat.val[6] = t7;
  mat.val[7] = t8;
  mat.val[8] = t9;
  mat.val[9] = t10;
  mat.val[10] = t11;
  mat.val[11] = t12;
}

void matrixScale(Mat4 mat, var v) {
  num sx, sy, sz, sw;
  if (v is num) {
    sx = v;
    sy = v;
    sz = v;
    sw = 1.0;
  } else if (v is Vec4) {
    sx = v.x;
    sy = v.y;
    sz = v.z;
    sw = v.w;
  } else {
    return;
  }

  mat.val[0] *= sx;
  mat.val[1] *= sx;
  mat.val[2] *= sx;
  mat.val[3] *= sx;
  mat.val[4] *= sy;
  mat.val[5] *= sy;
  mat.val[6] *= sy;
  mat.val[7] *= sy;
  mat.val[8] *= sz;
  mat.val[9] *= sz;
  mat.val[10] *= sz;
  mat.val[11] *= sz;
  mat.val[12] *= sw;
  mat.val[13] *= sw;
  mat.val[14] *= sw;
  mat.val[15] *= sw;  
}

void matrixTranslate(Mat4 mat, num tx, num ty, num tz, [num tw = 1.0])
{
  num t1 = mat.val[0] * tx + mat.val[4] * ty + mat.val[8] * tz + mat.val[12] * tw;
  num t2 = mat.val[1] * tx + mat.val[5] * ty + mat.val[9] * tz + mat.val[13] * tw;
  num t3 = mat.val[2] * tx + mat.val[6] * ty + mat.val[10] * tz + mat.val[14] * tw;
  num t4 = mat.val[3] * tx + mat.val[7] * ty + mat.val[11] * tz + mat.val[15] * tw;
  mat.val[12] = t1;
  mat.val[13] = t2;
  mat.val[14] = t3;
  mat.val[15] = t4;
}
