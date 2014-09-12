// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class Scene extends Object3D {

  bool autoUpdate;
  bool matrixAutoUpdate;

  Light light; // We use only one light
  List<Object3D> objects;

  Scene() : super() {
    autoUpdate = true;
    matrixAutoUpdate = false;

    light = null;
    objects = new List<Object3D>();

  }
  
  void _add(Object3D obj) {
    if (obj is Light) {
      if (light != null)
        remove(light);
      light = obj;
    } else {
      objects.add(obj);
    }
  }

  void _remove(Object3D obj) {
    if (obj is Light) {

    } else {
      objects.remove(obj);
    }
  }

}