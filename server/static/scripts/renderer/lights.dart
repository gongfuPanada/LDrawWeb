// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Light extends Object3D {

  Vec4 color;

  Light(Vec4 color) : super() {
    this.color = color;
  }
  
}

class AmbientLight extends Light {

}

class DirectionalLight extends Light {

  Object3D target;
  num intensity;

  DirectionalLight(Vec4 color, [num intensity = null]) : super(color) {
    if (intensity == null)
      this.intensity = 1.0;
    else
      this.intensity = intensity;

    target = new Object3D();
    position.set(0.0, -1.0, 0.0);
  }

}

class HemisphereLight extends Light {

  Vec4 groundColor;
  num intensity;

  HemisphereLight(Vec4 color, Vec4 groundColor, [num intensity = null]) : super(color) {
    this.groundColor = groundColor;

    if (intensity == null)
      this.intensity = 1.0;
    else
      this.intensity = intensity;

    position.set(0.0, -5000.0, 0.0);
  }

}

class PointLight extends Light {
  
  num intensity;
  num distance;

  PointLight(Vec4 color, [num intensity = null, num distance = null]) : super(coor) {
    if (intensity == null)
      this.intensity = 1.0;
    else
      this.intensity = intensity;

    if (distance == null)
      this.distance = 0.0;
    else
      this.distance = distance;
  }

}
