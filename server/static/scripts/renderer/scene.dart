// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Scene extends Object3D {

  bool autoUpdate;
  bool matrixAutoUpdate;

  List<Light> lights;
  List<Object3D> objects;

  Scene() : super() {
    autoUpdate = true;
    matrixAutoUpdate = false;

    lights = new List<Light>();
    objects = new List<Object3D>();

  }
  
  void _add(Object3D obj) {
    if (obj is Light)
      lights.add(obj);
    else
      objects.add(obj);
  }

  void _remove(Object3D obj) {
    if (obj is Light)
      lights.remove(obj);
    else
      objects.remove(obj);
  }

}