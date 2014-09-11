// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

const int BASE_MODEL_COLOR = 7;
const num NORMAL_BLEND_THRESHOLD = 0.785398163;

class Edge {
  Vec4 v1, v2;

  Edge(this.v1, this.v2);
}

abstract class Face {
  List<Vec4> vertices;
  List<Edge> edges;

  int get vertexCount;

  Vec4 operator [] (int index) {
    if (index >= vertexCount)
      throw new RangeError("index out of range");
    
    return vertices[index];
  }
  
  void operator []= (int index, Vec4 vec) {
    if (index >= vertexCount)
      throw new RangeError("index out of range");
    
    vertices[index] = vec;
  }
    
  bool contains(Vec4 vec) {
    for (int i = 0; i < vertexCount; ++i) {
      if (vertices[i] == vec)
	return true;
    }
    return false;
  }

  Edge edge(int index) {
    if (edges == null) {
      edges = new List<Edge>();
      for (int i = 0; i < vertexCount; ++i)
	edges.add(new Edge(vertices[i], vertices[(i + 1) % vertexCount]));
    }

    return edges[index];
  }

  Vec4 getNormal() {
    if (vertexCount < 3)
      return null;

    return Vec4.cross(vertices[1] - vertices[2],
        vertices[1] - vertices[0]).normalize() * -1.0;
  }

  List<int> get indexOrder;

  String toString() => vertices.toString();
}

class TriangleFace extends Face {
  int get vertexCount => 3;

  TriangleFace(Vec4 a, Vec4 b, Vec4 c) {
    vertices = [a, b, c];
  }

  List<int> indexOrder_ = [0, 1, 2];
  List<int> get indexOrder {
    return indexOrder_;
  }
}

class QuadFace extends Face {
  int get vertexCount => 4;

  QuadFace(Vec4 a, Vec4 b, Vec4 c, Vec4 d) {
    vertices = [a, b, c, d];
  }

  List<int> indexOrder_ = [0, 1, 2, 2, 3, 0];
  List<int> get indexOrder {
    return indexOrder_;
  }
}

class FinishedEntityError extends Error {
  FinishedEntityError() : super();
}

class EdgeGroup {
  /* temporary */
  List<num> vertexBuffer_;
  List<num> colorBuffer_;
  bool built;

  Float32List vertices;
  Float32List colors;

  EdgeGroup.fromJson(Map json) {
    vertices = new Float32List.fromList(json['vertices']);
    colors = new Float32List.fromList(json['colors']);
    built = true;
  }
  
  EdgeGroup() {
    clear();
  }

  int get count {
    if (built)
      return (vertices.length / 3).floor();
    else
      return (vertexBuffer_.length / 3).floor();
  }

  void clear() {
    vertices = null;
    colors = null;

    vertexBuffer_ = null;
    colorBuffer_ = null;

    built = false;
  }

  void add(Vec4 pos, Color c) {
    if (built)
      throw new FinishedEntityError();

    if (vertexBuffer_ == null)
      vertexBuffer_ = new List<num>();
    if (colorBuffer_ == null)
      colorBuffer_ = new List<num>();

    vertexBuffer_.add(pos.x);
    vertexBuffer_.add(pos.y);
    vertexBuffer_.add(pos.z);

    if (c.isMainColor) {
      colorBuffer_.add(-1.0);
      colorBuffer_.add(-1.0);
      colorBuffer_.add(-1.0);
    } else if (c.isEdgeColor) {
      colorBuffer_.add(-2.0);
      colorBuffer_.add(-2.0);
      colorBuffer_.add(-2.0);
    } else {
      colorBuffer_.add(c.color.r);
      colorBuffer_.add(c.color.g);
      colorBuffer_.add(c.color.b);
    }
  }

  void applyFeatures(List queue) {
    if (queue.length == 0) {
      vertices = new Float32List(0);
      colors = new Float32List(0);
      built = true;
      return;
    }

    clear();

    int count = 0;
    MeshCategory defaultCat = new MeshCategory(ColorMap.instance.query(16), true); // use this only

    /* search for array size */
    for (List item in queue) {
      Part feature = item[0];
      FeatureMap fm = item[1];
      count += feature.edges.count * fm.matrices.length * 3;
    }

    /* allocate */
    vertices = new Float32List(count);
    colors = new Float32List(count);

    /* fill */
    int index = 0;
    Vec4 v = new Vec4();
    Mat4 localMat = new Mat4();
    for (List item in queue) {
      Part feature = item[0];
      FeatureMap fm = item[1];
      Color c = item[2];
      Mat4 mat = item[3];
      EdgeGroup other = feature.edges;

      for (int i = 0; i < fm.matrices.length; ++i) {
        mat.multiply(fm.matrices[i], localMat);

        for (int j = 0; j < feature.edgeCount() * 3; j += 3) {
          v.set(other.vertices[j], other.vertices[j + 1], other.vertices[j + 2]);
          localMat.transform(v, v);
          vertices[index]     = v.x;
          vertices[index + 1] = v.y;
          vertices[index + 2] = v.z;

          if (other.colors[j] < -1.0) {
            colors[index]     = c.edge.r;
            colors[index + 1] = c.edge.g;
            colors[index + 2] = c.edge.b;
          } else if (other.colors[j] < 0.0) {
            colors[index]     = c.color.r;
            colors[index + 1] = c.color.g;
            colors[index + 2] = c.color.b;
          } else {
            colors[index]     = other.colors[j];
            colors[index + 1] = other.colors[j + 1];
            colors[index + 2] = other.colors[j + 2];
          }

          index += 3;
        }
      }
    }

    built = true;
  }

  void commitMerge(List queue) {
    if (queue.length == 0) {
      vertices = new Float32List(0);
      colors = new Float32List(0);
      built = true;
      return;
    }

    clear();

    List last = queue[queue.length - 1];
    int count = (last[1] + last[2]) * 3; /* starting index + count */

    vertices = new Float32List(count);
    colors = new Float32List(count);

    Vec4 v = new Vec4();
    int index = 0;

    for (List item in queue) {
      EdgeGroup other = item[0];
      Color c = item[3];
      Mat4 matrix = item[4];

      for (int i = 0; i < other.count * 3; i += 3) {
        v.set(other.vertices[i], other.vertices[i+1], other.vertices[i+2]);
        matrix.transform(v, v);
        vertices[index]     = v.x;
        vertices[index + 1] = v.y;
        vertices[index + 2] = v.z;

        if (c.isMainColor) {
          colors[index]     = other.colors[i];
          colors[index + 1] = other.colors[i + 1];
          colors[index + 2] = other.colors[i + 2];
        } else {
          if (other.colors[i] < -1.0) {
            colors[index]     = c.edge.r;
            colors[index + 1] = c.edge.g;
            colors[index + 2] = c.edge.b;
          } else if (other.colors[i] < 0.0) {
            colors[index]     = c.color.r;
            colors[index + 1] = c.color.g;
            colors[index + 2] = c.color.b;
          } else {
            colors[index]     = other.colors[i];
            colors[index + 1] = other.colors[i + 1];
            colors[index + 2] = other.colors[i + 2];
          }
        }

        index += 3;
      }
    }

    built = true;
  }

  void merge(EdgeGroup g, Color c, [Mat4 transform = null]) {
    int index = 0;
    Vec4 v = new Vec4();
    for (int i = 0; i < g.count; ++i) {
      if (transform == null) {
        vertices.add(g.vertices[index]);
        vertices.add(g.vertices[index + 1]);
        vertices.add(g.vertices[index + 2]);
      } else {
        v.set(g.vertices[index], g.vertices[index + 1], g.vertices[index + 2]);
        transform.transform(v, v);
        vertices.add(v.x);
        vertices.add(v.y);
        vertices.add(v.z);
      }

      if (c.isMainColor) {
        colors.add(g.colors[index]);
        colors.add(g.colors[index + 1]);
        colors.add(g.colors[index + 2]);
      } else {
        if (g.colors[index] < -1.0) {
          colorBuffer_.add(c.edge.r);
          colorBuffer_.add(c.edge.g);
          colorBuffer_.add(c.edge.b);
        } else if (g.colors[index] < 0.0) {
          colorBuffer_.add(c.color.r);
          colorBuffer_.add(c.color.g);
          colorBuffer_.add(c.color.b);
        } else {
          colorBuffer_.add(g.colors[index]);
          colorBuffer_.add(g.colors[index + 1]);
          colorBuffer_.add(g.colors[index + 2]);
        }
      }
      
      index += 3;
    }
  }

  void finish() {
    if (built)
      throw new FinishedEntityError();

    if (vertexBuffer_ == null && colorBuffer_ == null) {
      vertices = new Float32List(0);
      colors = new Float32List(0);
    } else {
      vertices = new Float32List.fromList(vertexBuffer_);
      colors = new Float32List.fromList(colorBuffer_);
    }

    vertexBuffer_ = null;
    colorBuffer_ = null;

    built = true;
  }

  Map toJson() {
    return {
      'vertices': vertices,
      'colors': colors
    };
  }
}

class MeshGroup {
  /* temporary */
  List<Face> faces_;
  bool built;

  Float32List vertices;
  Float32List normals;

  MeshGroup.fromJson(Map json) {
    vertices = new Float32List.fromList(json['vertices']);
    normals = new Float32List.fromList(json['normals']);
    built = true;
  }

  MeshGroup() {
    clear();
  }

  void add(Face face) {
    if (built)
      throw new FinishedEntityError();

    if (faces_ == null)
      faces_ = new List<Face>();

    faces_.add(face);
  }

  void applyFeatures(List queue) {
    if (queue.length == 0) {
      vertices = new Float32List(0);
      normals = new Float32List(0);
      faces_ = null;
      built = true;
      return;
    }

    clear();

    int count = 0;
    MeshCategory defaultCat = new MeshCategory(ColorMap.instance.query(16), true); // use this only

    /* search for array size */
    for (List item in queue) {
      Part feature = item[0];
      FeatureMap featureMap = item[1];
      count += feature.meshes[defaultCat].count * featureMap.matrices.length * 3;
    }

    /* allocate */
    vertices = new Float32List(count);
    normals = new Float32List(count);

    /* fill */
    int index = 0;
    Vec4 v1 = new Vec4(), v2 = new Vec4(), v3 = new Vec4();
    Vec4 n1 = new Vec4(), n2 = new Vec4(), n3 = new Vec4();
    Mat4 localMat = new Mat4();
    for (List item in queue) {
      Part feature = item[0];
      FeatureMap featureMap = item[1];
      Mat4 matrix = item[2];
      Mat4 rotmat = new Mat4();
      MeshGroup targetMesh = feature.meshes[defaultCat];
      bool flip;

      for (int i = 0; i < featureMap.matrices.length; ++i) {
        matrix.multiply(featureMap.matrices[i], localMat);
        rotmat.clone(localMat);
        rotmat.setTranslation(0.0, 0.0, 0.0, row: true);
        bool flip = (rotmat.det() < 0.0) != featureMap.flipNormal[i];

        for (int j = 0; j < feature.triCount(defaultCat) * 3; j += 9) {
          v1.set(targetMesh.vertices[j  ], targetMesh.vertices[j+1], targetMesh.vertices[j+2]);
          v2.set(targetMesh.vertices[j+3], targetMesh.vertices[j+4], targetMesh.vertices[j+5]);
          v3.set(targetMesh.vertices[j+6], targetMesh.vertices[j+7], targetMesh.vertices[j+8]);
          localMat.transform(v1, v1);
          localMat.transform(v2, v2);
          localMat.transform(v3, v3);
          n1.set(targetMesh.normals[j  ], targetMesh.normals[j+1], targetMesh.normals[j+2]);
          n2.set(targetMesh.normals[j+3], targetMesh.normals[j+4], targetMesh.normals[j+5]);
          n3.set(targetMesh.normals[j+6], targetMesh.normals[j+7], targetMesh.normals[j+8]);
          rotmat.transform(n1, n1);
          rotmat.transform(n2, n2);
          rotmat.transform(n3, n3);

          if (flip) {
            vertices[index]     = v3.x;
            vertices[index + 1] = v3.y;
            vertices[index + 2] = v3.z;
            vertices[index + 3] = v2.x;
            vertices[index + 4] = v2.y;
            vertices[index + 5] = v2.z;
            vertices[index + 6] = v1.x;
            vertices[index + 7] = v1.y;
            vertices[index + 8] = v1.z;
            normals[index]      = n3.x;
            normals[index + 1]  = n3.y;
            normals[index + 2]  = n3.z;
            normals[index + 3]  = n2.x;
            normals[index + 4]  = n2.y;
            normals[index + 5]  = n2.z;
            normals[index + 6]  = n1.x;
            normals[index + 7]  = n1.y;
            normals[index + 8]  = n1.z;
          } else {
            vertices[index]     = v1.x;
            vertices[index + 1] = v1.y;
            vertices[index + 2] = v1.z;
            vertices[index + 3] = v2.x;
            vertices[index + 4] = v2.y;
            vertices[index + 5] = v2.z;
            vertices[index + 6] = v3.x;
            vertices[index + 7] = v3.y;
            vertices[index + 8] = v3.z;
            normals[index]      = -n1.x;
            normals[index + 1]  = -n1.y;
            normals[index + 2]  = -n1.z;
            normals[index + 3]  = -n2.x;
            normals[index + 4]  = -n2.y;
            normals[index + 5]  = -n2.z;
            normals[index + 6]  = -n3.x;
            normals[index + 7]  = -n3.y;
            normals[index + 8]  = -n3.z;
          }

          index += 9;
        }
      }
    }
  }

  void commitMerge(List queue) {
    if (queue.length == 0) {
      vertices = new Float32List(0);
      normals = new Float32List(0);
      faces_ = null;
      built = true;
      return;
    }

    clear();

    List last = queue[queue.length - 1];
    int count = (last[1] + last[2]) * 3; /* starting index + count */

    vertices = new Float32List(count);
    normals = new Float32List(count);

    int index = 0;

    for (List item in queue) {
      MeshGroup targetMesh = item[0];
      Mat4 localMat = item[3];
      Mat4 rotMat = new Mat4();
      rotMat.clone(localMat);
      rotMat.setTranslation(0.0, 0.0, 0.0, row: true);

      Vec4 v1 = new Vec4();
      Vec4 v2 = new Vec4();
      Vec4 v3 = new Vec4();
      Vec4 n1 = new Vec4();
      Vec4 n2 = new Vec4();
      Vec4 n3 = new Vec4();

      bool flip = false;
      if (rotMat.det() < 0.0) {
        flip = true;
      }
      
      for (int i = 0; i < targetMesh.count * 3; i += 9) {
        v1.set(targetMesh.vertices[i  ], targetMesh.vertices[i+1], targetMesh.vertices[i+2]);
        v2.set(targetMesh.vertices[i+3], targetMesh.vertices[i+4], targetMesh.vertices[i+5]);
        v3.set(targetMesh.vertices[i+6], targetMesh.vertices[i+7], targetMesh.vertices[i+8]);
        localMat.transform(v1, v1);
        localMat.transform(v2, v2);
        localMat.transform(v3, v3);
        n1.set(targetMesh.normals[i  ], targetMesh.normals[i+1], targetMesh.normals[i+2]);
        n2.set(targetMesh.normals[i+3], targetMesh.normals[i+4], targetMesh.normals[i+5]);
        n3.set(targetMesh.normals[i+6], targetMesh.normals[i+7], targetMesh.normals[i+8]);
        rotMat.transform(n1, n1);
        rotMat.transform(n2, n2);
        rotMat.transform(n3, n3);
        
        if (flip) {
          vertices[index]     = v3.x;
          vertices[index + 1] = v3.y;
          vertices[index + 2] = v3.z;
          vertices[index + 3] = v2.x;
          vertices[index + 4] = v2.y;
          vertices[index + 5] = v2.z;
          vertices[index + 6] = v1.x;
          vertices[index + 7] = v1.y;
          vertices[index + 8] = v1.z;
          normals[index]      = n3.x;
          normals[index + 1]  = n3.y;
          normals[index + 2]  = n3.z;
          normals[index + 3]  = n2.x;
          normals[index + 4]  = n2.y;
          normals[index + 5]  = n2.z;
          normals[index + 6]  = n1.x;
          normals[index + 7]  = n1.y;
          normals[index + 8]  = n1.z;
        } else {
          vertices[index]     = v1.x;
          vertices[index + 1] = v1.y;
          vertices[index + 2] = v1.z;
          vertices[index + 3] = v2.x;
          vertices[index + 4] = v2.y;
          vertices[index + 5] = v2.z;
          vertices[index + 6] = v3.x;
          vertices[index + 7] = v3.y;
          vertices[index + 8] = v3.z;
          normals[index]      = -n1.x;
          normals[index + 1]  = -n1.y;
          normals[index + 2]  = -n1.z;
          normals[index + 3]  = -n2.x;
          normals[index + 4]  = -n2.y;
          normals[index + 5]  = -n2.z;
          normals[index + 6]  = -n3.x;
          normals[index + 7]  = -n3.y;
          normals[index + 8]  = -n3.z;
        }

        index += 9;
      }
    }
  }

  /*void merge(MeshGroup other, [Mat4 transform = null]) {
    assert(other.built);

    int firstLength = 0;

    vertices = new Float32List();
    normals = new Float32List();

    if (transform == null) {
      vertices.addAll(other.vertices);
      normals.addAll(other.normals);
    } else {
      int index = 0;
      Mat4 rotmat = new Mat4.copy(transform);
      rotmat.setTranslation(0.0, 0.0, 0.0);
      Vec4 v = new Vec4();
      Vec4 n = new Vec4();
      for (int i = 0; i < other.count; ++i) {
        v.set(other.vertices[index], other.vertices[index + 1], other.vertices[index + 2]);
        transform.transform(v, v);
        n.set(other.normals[index], other.normals[index + 1], other.normals[index + 2]);
        rotmat.transform(n, n);
        n.normalize(n);
        vertices.add(v.x);
        vertices.add(v.y);
        vertices.add(v.z);
        normals.add(n.x);
        normals.add(n.y);
        normals.add(n.z);
        index += 3;
      }
    }
  }*/

  void clear() {
    faces_ = null;
    vertices = null;
    normals = null;
    built = false;
  }

  int get count {
    if (!built && faces_ != null)
      return faces_.length;
    else if (vertices != null)
      return (vertices.length / 3).floor();
    else
      return 0;
  }

  void finish() {
    if (!built) {
      if (faces_ == null && vertices != null && normals != null) {
        built = true;
        return;
      }
    } else {
      return;
    }

    List<num> va = new List<num>();
    List<num> na = new List<num>();

    int index = 0;

    /* build adjacency map */
    KdTree<Adjacency> faceMap = new KdTree<Adjacency>();
    for (Face f in faces_) {
      for (Vec4 v in f.vertices) {
	KdNodeData<Adjacency> node = faceMap.exact(v);
	Adjacency a;
	if (node == null) {
	  a = new Adjacency(index++);
	  faceMap.insert(v, a);
	} else {
	  a = node.tag;
	}
	a.add(f);
      }
    }

    void buildBuffer(List<num> vertices, List<num> normals, Vec4 v, Vec4 n) {
      vertices.add(v.x);
      vertices.add(v.y);
      vertices.add(v.z);
      normals.add(n.x);
      normals.add(n.y);
      normals.add(n.z);
    }

    /* build normal and write */
    index = 0;
    for (Face f in faces_) {
      Vec4 faceNormal = f.getNormal();
      for (int idx in f.indexOrder) {
        Vec4 v = f.vertices[idx];
        Adjacency adj = faceMap.exact(v).tag;
        List<Face> adjacentFaces = adj.query(v, f);
        /* look for adjacent faces and blend their normals to smooth the faces */
        if (adjacentFaces.length > 0) {
          Vec4 blendedNormal = new Vec4.from(faceNormal);
          for (Face otherFace in adjacentFaces) {
            Vec4 otherNormal = otherFace.getNormal();
            num angle = Vec4.angle(otherNormal, blendedNormal);
            if (Vec4.angle(otherNormal, blendedNormal).abs() < NORMAL_BLEND_THRESHOLD) {
              Vec4.interpolate(blendedNormal, otherNormal, blendedNormal);
              blendedNormal.normalize(blendedNormal);
            }
          }
          buildBuffer(va, na, v, blendedNormal);
        } else {
          buildBuffer(va, na, v, faceNormal);
        }
      }
    }

    vertices = new Float32List.fromList(va);
    normals = new Float32List.fromList(na);

    faces_.clear();
    built = true;
  }

  Map toJson() {
    return {
      'vertices': vertices,
      'normals': normals,
    };
  }
}

class Adjacency {
  List<Face> faces;
  int index;

  Adjacency(this.index) {
    faces = new List<Face>();
  }

  void add(Face face) {
    faces.add(face);
  }

  List<Face> query(Vec4 v, [Face self = null]) {
    List<Face> result = new List<Face>();
    for (Face f in faces) {
      if (f.contains(v) && f != self)
	result.add(f);
    }
    return result;
  }
}

class MeshCategory extends Comparable<MeshCategory> {
  Color color;
  bool bfc;

  MeshCategory.fromJson(Map json) {
    color = new Color.fromJson(json['color']);
    bfc = json['bfc'];
  }

  MeshCategory(this.color, this.bfc);

  int get hashCode => '${color.id} $bfc'.hashCode;

  bool operator == (MeshCategory other) {
    return color == other.color && bfc == other.bfc;
  }

  String toString() {
    if (bfc)
      return '$color (with bfc)';
    else
      return '$color (without bfc)';
  }

  /* for transparency sorting in a crude way */
  int compareTo(MeshCategory other) {
    if (color.isTransparent && !other.color.isTransparent)
      return 1;
    else if (!color.isTransparent && other.color.isTransparent)
      return -1;
    else
      return color.id.compareTo(other.color.id);
  }

  Map toJson() {
    return {
      'color': color,
      'bfc': bfc
    };
  }
}

class FeatureMap {
  List<Mat4> matrices;
  List<bool> flipNormal;

  FeatureMap() {
    matrices = new List<Mat4>();
    flipNormal = new List<bool>();
  }

  FeatureMap.fromJson(Map map) {
    matrices = new List<Mat4>();
    flipNormal = new List<bool>();
    map['matrices'].forEach((value) {
      matrices.add(new Mat4.fromJson(value));
    });
    map['flipNormal'].forEach((value) {
      flipNormal.add(value ? true : false);
    });
  }

  void add(Mat4 matrix, bool flip) {
    matrices.add(matrix);
    flipNormal.add(flip);
  }

  List toJson() {
    return {
      'matrices': matrices,
      'flipNormal': new List<int>.generate(flipNormal.length, (int index) => (flipNormal[index] ? 1 : 0)),
    };
  }
}

class GlobalFeatureSet {
  static Map kFeatures = {
    'stud.dat': null,
    'stu2.dat': 'stud.dat',
    'stud2.dat': null,
    'stu22.dat': 'stud2.dat',
    'stud3.dat': null,
    'stu23.dat': 'stud3.dat',
    'stud4.dat': null,
    'stu24.dat': 'stud4.dat',
  };
  static List kUniqueFeatures = ['stud.dat', 'stud2.dat', 'stud3.dat', 'stud4.dat'];

  static GlobalFeatureSet instance_ = null;

  static GlobalFeatureSet get instance {
    if (instance_ == null)
      instance_ = new GlobalFeatureSet();
    return instance_;
  }

  Map<String, Part> parts;

  GlobalFeatureSet() {
    parts = new Map<String, Part>();
  }

  Part query(String part) {
    part = normalizePath(part);
    if (parts.containsKey(part))
      return parts[part];
    else
      return null;
  }

  void loadAll(void onComplete()) {
    int count = kUniqueFeatures.length;

    for (String part in kUniqueFeatures) {
      httpGetJson('$MESH_ENDPOINT/g/p/$part.json', (response) {
        print('feature $part loaded');
        parts[part] = new Part.fromJson(response);
        if (--count == 0) {
          onComplete();
        }
      }, onFailed: (int statusCode) {
        if (--count == 0) {
          onComplete();
        }
      });
    }
  }
}

class Part {
  LDrawHeader header;
  Set<Color> activeColors;
  Map<MeshCategory, MeshGroup> meshes;
  Map<String, Map<MeshCategory, FeatureMap>> features;
  EdgeGroup edges;

  Part.fromJson(Map json) {
    activeColors = new Set();
    header = new LDrawHeader.fromJson(json['header']);
    json['activeColors'].forEach((value) {
      activeColors.add(new Color.fromJson(value));
    });

    meshes = new HashMap<MeshCategory, MeshGroup>();
    json['meshes'].forEach((key, value) {
      MeshCategory cat = new MeshCategory.fromJson(JSON.decode(key));
      meshes[cat] = new MeshGroup.fromJson(value);
    });

    features = new HashMap<String, Map<MeshCategory, FeatureMap>>();
    json['features'].forEach((key, value) {
      features[key] = new HashMap<MeshCategory, FeatureMap>();
      value.forEach((key2, value2) {
        MeshCategory cat = new MeshCategory.fromJson(JSON.decode(key2));
        features[key][cat] = new FeatureMap.fromJson(value2);
      });
    });

    edges = new EdgeGroup.fromJson(json['edges']);
  }

  Part.fromLDrawModel(LDrawModel model, Resolver pool,
      {bool excludeRefs: false}) {
    header = model.header;
    parseLDrawModel(model, pool, excludeRefs);
  }

  int triCount(MeshCategory category) {
    if (!meshes.containsKey(category))
      return 0;

    return meshes[category].count;
  }

  int edgeCount() {
    return edges.count;
  }

  int featureTriCount() {
    MeshCategory category = new MeshCategory(ColorMap.instance.query(16), true);

    int count = 0;

    features.forEach((name, data) {
      if (!data.containsKey(category))
        return;
      Part p = GlobalFeatureSet.instance.query(name);
      if (p != null)
        count += p.triCount(category) * data[category].matrices.length;
    });

    return count;
  }

  int featureEdgeCount() {
    MeshCategory category = new MeshCategory(ColorMap.instance.query(16), true);

    int count = 0;

    features.forEach((name, data) {
      Part p = GlobalFeatureSet.instance.query(name);
      if (p != null && data[category] != null){
        count += p.edgeCount() * data[category].matrices.length;
      }
    });

    return count;
  }

  void parseLDrawModel(LDrawModel root, Resolver pool, bool excludeRefs) {
    /* build mesh data from a LDraw model */

    activeColors = new Set<Color>();
    meshes = new HashMap<MeshCategory, MeshGroup>();
    features = new HashMap<String, Map<MeshCategory, FeatureMap>>();
    edges = new EdgeGroup();

    KdTree<Adjacency> kdTree = new KdTree();
    List<Color> colorStack = new List<Color>();

    // initialize
    colorStack.add(ColorMap.instance.mainColor);

    void traverse(LDrawModel model, Mat4 matrix, bool cull, bool invert, [int depth = 0]) {
      bool localCull = true;
      bool ccw = true;
      bool bfcCertified = false;
      bool invertNext = false;

      if (model == null)
	return;

      if (model.header.bfc == LDrawHeader.BFC_CERTIFIED_CCW) {
	bfcCertified = true;
	if (invert)
	  ccw = false;
	else
	  ccw = true;
      } else if (model.header.bfc == LDrawHeader.BFC_CERTIFIED_CW) {
	bfcCertified = true;
	if (invert)
	  ccw = true;
	else
	  ccw = false;
      }

      Vec4 va = new Vec4();
      Vec4 vb = new Vec4();
      Vec4 vc = new Vec4();
      Vec4 vd = new Vec4();
      
      for (LDrawCommand cmd in model.commands) {
	if (cmd is LDrawLine1) {
	  LDrawLine1 refcmd = cmd;
	  LDrawModel part = root.findPart(refcmd.name, resolver: pool);

	  if (part == null)
	    continue;

          Color col;
	  if (refcmd.color == 16)
            col = colorStack.last;
          else
            col = ColorMap.instance.query(refcmd.color);

          String name = normalizePath(refcmd.name);
          /* treat studs */
          if (GlobalFeatureSet.kFeatures.containsKey(name)) {
            String featureName = GlobalFeatureSet.kFeatures[name];
            if (featureName == null)
              featureName = name;
            Map<MeshCategory, FeatureMap> currentFeatures;
            if (features.containsKey(featureName)) {
              currentFeatures = features[featureName];
            } else {
              currentFeatures = new HashMap<MeshCategory, FeatureMap>();
              features[featureName] = currentFeatures;
            }
            MeshCategory category = new MeshCategory(col, true);
            FeatureMap featureMap;
            if (currentFeatures.containsKey(category)) {
              featureMap = currentFeatures[category];
            } else {
              featureMap = new FeatureMap();
              currentFeatures[category] = featureMap;
            }
            featureMap.add(matrix * refcmd.matrix, !ccw);
          } else {
            colorStack.add(col);
            bool c;
            if (bfcCertified)
              c = cull && localCull;
            else
              c = false;
            bool invertChild = invert != invertNext;
            if (refcmd.matrix.det() < 0.0)
              invertChild = !invertChild;
            traverse(part, matrix * refcmd.matrix, c, invertChild, depth + 1);
            colorStack.removeLast();
          }
        } else if (cmd is LDrawLine2) {
          LDrawLine2 line = cmd;
          Color col = ColorMap.instance.query(line.color);
          if (col.isMainColor)
            col = colorStack.last;

          Vec4 a = matrix.transform(line.v1);
          Vec4 b = matrix.transform(line.v2);

          edges.add(a, col);
          edges.add(b, col);
	} else if (cmd is LDrawLine3 || cmd is LDrawLine4) {
	  LDrawDrawingCommand drawcmd = cmd;
	  Color col = ColorMap.instance.query(drawcmd.color);

	  if (!activeColors.contains(col))
	    activeColors.add(col);

          if (col.isMainColor)
            col = colorStack.last;

	  Face f;
	  if (cmd is LDrawLine3) {
	    LDrawLine3 tri = cmd;
	    Vec4 a = matrix.transform(tri.v1);
	    Vec4 b = matrix.transform(tri.v2);
            Vec4 c = matrix.transform(tri.v3);

	    if (!ccw) {
	      f = new TriangleFace(c, b, a);
	    } else {
	      f = new TriangleFace(a, b, c);
	    }
	  } else {
	    LDrawLine4 quad = cmd;
	    Vec4 a = matrix.transform(quad.v1);
	    Vec4 b = matrix.transform(quad.v2);
	    Vec4 c = matrix.transform(quad.v3);
	    Vec4 d = matrix.transform(quad.v4);
	    if (!ccw) {
	      f = new QuadFace(d, c, b, a);
	    } else {
	      f = new QuadFace(a, b, c, d);
	    }
	  }

	  MeshGroup group;
          bool bfc;
	  if (bfcCertified)
            bfc = cull && localCull;
	  else
            bfc = false;
	  
          MeshCategory category = new MeshCategory(col, bfc);
	  if (!meshes.containsKey(category)) {
	    group = new MeshGroup();
            meshes[category] = group;
	  } else {
	    group = meshes[category];
	  }

	  group.add(f);
	} else if (cmd is LDrawBfc) {
	  LDrawBfc bfc = cmd;

	  if (bfc.command == LDrawBfc.INVERTNEXT)
	    invertNext = true;
	  if ((bfc.command & LDrawBfc.CLIP) != 0) {
	    localCull = true;
	  } else if ((bfc.command & LDrawBfc.NOCLIP) != 0) {
	    localCull = false;
	  }
	  if ((bfc.command & LDrawBfc.CW) != 0) {
	    if (invert)
	      ccw = true;
	    else
	      ccw = false;
	  } else if ((bfc.command & LDrawBfc.CCW) != 0) {
	    if (invert)
	      ccw = false;
	    else
	      ccw = true;
	  }
	}

	if (!(cmd is LDrawBfc)) {
	  invertNext = false;
	} else {
	  LDrawBfc bfc = cmd;
	  if (bfc.command != LDrawBfc.INVERTNEXT)
	    invertNext = false;
	}
      }
    }

    traverse(root, new Mat4.identity(), true, false);

    for (MeshGroup m in meshes.values)
      m.finish();
    edges.finish();
  }

  Map toJson() {
    return {
      'activeColors': new List.from(activeColors),
      'header': header.toJson(),
      'meshes': meshes,
      'features': features,
      'edges': edges
    };
  }
}

class BoundingBox {
  Vec4 min = null;
  Vec4 max = null;
 
  BoundingBox() {}

  BoundingBox.fromPoints(Vec4 a, Vec4 b) {
    num minx, maxx;
    num miny, maxy;
    num minz, maxz;

    if (a.x > b.x) {
      maxx = a.x; minx = b.x;
    } else {
      maxx = b.x; minx = a.x;
    }

    if (a.y > b.y) {
      maxy = a.y; miny = b.y;
    } else {
      maxy = b.y; miny = a.y;
    }

    if (a.z > b.z) {
      maxz = a.z; minz = b.z;
    } else {
      maxz = b.z; minz = a.z;
    }

    min = new Vec4.xyz(minx, miny, minz);
    max = new Vec4.xyz(maxx, maxy, maxz);
  }

  bool get isValid {
    return min != null && max != null && min != max;
  }

  void update(Vec4 point) {
    if (min == null || max == null) {
      min = new Vec4.from(point);
      max = new Vec4.from(point);
    } else {
      if (point.x > max.x)
        max.x = point.x;
      if (point.y > max.y)
        max.y = point.y;
      if (point.z > max.z)
        max.z = point.z;
      if (point.x < min.x)
        min.x = point.x;
      if (point.y < min.y)
        min.y = point.y;
      if (point.z < min.z)
        min.z = point.z;
    }
  }

  void merge(BoundingBox other) {
    update(other.min);
    update(other.max);
  }

  Vec4 center() {
    return (min + max) * 0.5;
  }
}

class Index {
  Map<MeshCategory, int> start;
  Map<MeshCategory, int> count;
  Map<MeshCategory, int> studStart;
  Map<MeshCategory, int> studCount;
  int edgeStart;
  int edgeCount;
  int studEdgeStart;
  int studEdgeCount;
  BoundingBox boundingBox;

  Index() {
    start = new HashMap<MeshCategory, int>();
    count = new HashMap<MeshCategory, int>();
    studStart = new HashMap<MeshCategory, int>();
    studCount = new HashMap<MeshCategory, int>();
  }

  void add(MeshCategory category, int start, int count, int studStart, int studCount) {
    this.start[category] = start;
    this.count[category] = count;
    this.studStart[category] = studStart;
    this.studCount[category] = studCount;
  }

  void setEdgeIndex(int start, int count, int studStart, int studCount) {
    edgeStart = start;
    edgeCount = count;
    studEdgeStart = studStart;
    studEdgeCount = studCount;
  }

  void finish(Model parent) {
    boundingBox = new BoundingBox();

    Vec4 v = new Vec4();
    for (MeshCategory c in count.keys) {
      int s = start[c], cnt = count[c];
      List<num> vertices = parent.meshChunks[c].vertices;
      for (int i = s; i < s + cnt; ++i) {
        v.set(vertices[i*3], vertices[i*3+1], vertices[i*3+2]);
        boundingBox.update(v);
      }
    }
  }
}

class Model {
  Set<Color> usedColors;

  // disposable
  Map<String, Part> submodels;
  Map<MeshCategory, MeshGroup> meshChunks;
  Map<MeshCategory, MeshGroup> featureChunks;
  EdgeGroup edges;
  EdgeGroup featureEdges;

  // index
  List<String> subparts;
  Map<String, List<Index>> subpartIndices;
  List<Index> indices;
  List<int> steps;
  BoundingBox boundingBox;
  bool built;

  LDrawModel root;

  Model(this.root) {
    prepare();
  }

  void prepare() {
    ColorMap cm = ColorMap.instance;

    usedColors = new Set<Color>();
    submodels = new HashMap<String, Part>();

    void traverse(LDrawModel model) {
      if (model == null)
	return;

      for (LDrawLine1 cmd in model.filterRefCmds()) {
        /* add to color set */
        Color c = cm.query(cmd.color);
        if (!c.isMainColor && !c.isEdgeColor)
          usedColors.add(c);

	if (root.hasPart(cmd.name)) {
	  traverse(root.findPart(cmd.name));
	} else {
	  String path = normalizePath(cmd.name);
	  if (!submodels.containsKey(path))
	    submodels[path] = null;
	}
      }
    }
    traverse(root);
  }

  void compile([bool excludeFeatures = false]) {
    meshChunks = new HashMap<MeshCategory, MeshGroup>();
    edges = new EdgeGroup();
    if (excludeFeatures) {
      featureChunks = null;
      featureEdges = null;
    } else {
      featureChunks = new HashMap<MeshCategory, MeshGroup>();
      featureEdges = new EdgeGroup();
    }

    Set<String> visitedSubparts = new HashSet<String>();

    Map meshMergeQueue = new Map();
    Map featureMergeQueue = new Map();
    List edgeMergeQueue = new List();
    List featureEdgeMergeQueue = new List();

    int edgeOffset = 0;
    int featureEdgeOffset = 0;

    void traverseMesh(LDrawModel model, Color color, Mat4 matrix, bool divideIndices) {
      if (model == null)
        return;

      for (LDrawLine1 cmd in model.filterRefCmds()) {
        String path = normalizePath(cmd.name);
        Color c = ColorMap.instance.query(cmd.color);
        /* inherit color */
        if (c.isMainColor)
          c = color;
        if (root.hasPart(path)) {
          /* if subpart */
          bool div;
          /* if inside subpart, divide into indices only traversed into submodel at first */
          if (visitedSubparts.contains(path))
            div = false;
          else
            div = true;
          traverseMesh(root.findPart(path), c, matrix * cmd.matrix, div);
          visitedSubparts.add(path);
        } else {
          /* merge into big mesh chunks */
          if (!submodels.containsKey(path) || submodels[path] == null)
            continue;
          Part p = submodels[path];
          /* group by colors */
          for (MeshCategory cat in p.meshes.keys) {
            /* inherit color */
            MeshCategory from = cat;
            if (cat.color.isMainColor)
              cat = new MeshCategory(c, cat.bfc);
            /* add to merge queue */
            if (!meshMergeQueue.containsKey(cat))
              meshMergeQueue[cat] = [];
            int startCount;
            var target = meshMergeQueue[cat];
            if (target.length == 0)
              startCount = 0;
            else
              startCount = target[target.length - 1][1] + target[target.length - 1][2];
            target.add([p.meshes[from], startCount, p.meshes[from].count, matrix * cmd.matrix]);
          }
          /* merge colors */
          edgeMergeQueue.add([p.edges, edgeOffset, p.edges.count, c, matrix * cmd.matrix]);
          edgeOffset += p.edges.count;
          /* gather features */
          if (!excludeFeatures) {
            p.features.forEach((String featureName, Map object) {
              Part feature = GlobalFeatureSet.instance.query(featureName);
              if (feature == null)
                return;
              
              object.forEach((MeshCategory cat, FeatureMap featureMap) {
                /* inherit color */
                MeshCategory from = cat;
                if (cat.color.isMainColor)
                  cat = new MeshCategory(c, cat.bfc);
                
                if (!featureMergeQueue.containsKey(cat))
                  featureMergeQueue[cat] = [];
                featureMergeQueue[cat].add([feature, featureMap, matrix * cmd.matrix]);

                featureEdgeMergeQueue.add([feature, featureMap, c, matrix * cmd.matrix]);
                edgeOffset += feature.edges.count;
              });
            });
          }
        }
      }
    }

    traverseMesh(root, ColorMap.instance.query(BASE_MODEL_COLOR),
        new Mat4.identity(), true);

    meshMergeQueue.forEach((key, value) {
      MeshGroup group;
      if (!meshChunks.containsKey(key)) {
        group = new MeshGroup();
        meshChunks[key] = group;
      } else {
        group = meshChunks[key];
      }
      group.commitMerge(value);
    });
    edges.commitMerge(edgeMergeQueue);
    if (!excludeFeatures) {
      featureMergeQueue.forEach((key, value) {
        MeshGroup group;
        if (!featureChunks.containsKey(key)) {
          group = new MeshGroup();
          featureChunks[key] = group;
        } else {
          group = featureChunks[key];
        }
        group.applyFeatures(value);
      });
      featureEdges.applyFeatures(featureEdgeMergeQueue);
    }

    Set<MeshCategory> categories = new Set.from(meshChunks.keys);

    for (MeshCategory c in categories) {
      meshChunks[c].finish();
    }

    /* build index */
    indices = new List<Index>();
    subpartIndices = new HashMap<String, List<Index>>();
    subparts = new List<String>();
    steps = new List<int>();
    
    /* build subpart hierarchy */
    Map<MeshCategory, int> curTriIndex = new HashMap<MeshCategory, int>();
    Map<MeshCategory, int> curStudIndex = new HashMap<MeshCategory, int>();
    int curEdgeIndex = 0;
    int curStudEdgeIndex = 0;
    int stepIndex = -1;
    MeshCategory defaultColorBfc = new MeshCategory(ColorMap.instance.query(16), true);
    MeshCategory defaultColor = new MeshCategory(ColorMap.instance.query(16), false);

    void traverseIndex(LDrawModel model) {
      if (model == null)
        return;

      for (LDrawCommand cmd in model.commands) {
        if (cmd is LDrawLine1) {
          LDrawLine1 refcmd = cmd;
          String name = normalizePath(refcmd.name);

          if (root.hasPart(name)) {
            traverseIndex(root.findPart(name));

            if (!subparts.contains(name))
              subparts.add(name);
          } else {
            if (!submodels.containsKey(name) || submodels[name] == null)
              continue;

            Part part = submodels[name];

            Index idx = new Index();

            ++stepIndex;
            
            MeshCategory partColorBfc = new MeshCategory(
                ColorMap.instance.query(refcmd.color), true);
            MeshCategory partColor = new MeshCategory(
                ColorMap.instance.query(refcmd.color), false);
            
            for (MeshCategory c in categories) {
              int count;
              int studCount;

              count = part.triCount(c);
              if (c.color.id == refcmd.color)
                studCount = part.featureTriCount();
              else
                studCount = 0;

              if (partColorBfc == c) {
                count += part.triCount(defaultColorBfc);
              } else if (partColor == c) {
                count += part.triCount(defaultColor);
              }
              
              if (!curTriIndex.containsKey(c))
                curTriIndex[c] = 0;

              if (!curStudIndex.containsKey(c))
                curStudIndex[c] = 0;
              
              idx.add(c, curTriIndex[c], count, curStudIndex[c], studCount);
              curTriIndex[c] += count;
              curStudIndex[c] += studCount;
            }
            
            idx.setEdgeIndex(curEdgeIndex, part.edgeCount(), curStudEdgeIndex, part.featureEdgeCount());
            curEdgeIndex += part.edgeCount();
            if (!excludeFeatures)
              curStudEdgeIndex += part.featureEdgeCount();
            
            idx.finish(this);
            indices.add(idx);
          }
        } else if (cmd is LDrawStep || cmd is LDrawPause) {
          steps.add(stepIndex);
        }
      }
    }
    traverseIndex(root);

    /* add the last step */
    if (steps.length == 0 || steps.last != stepIndex)
      steps.add(stepIndex);

    print(steps);
    print(indices.length);

    built = true;
  }

  int get triCount {
    int cnt = 0;

    for (MeshGroup g in meshChunks.values) {
      cnt += g.count;
    }

    return (cnt / 3).floor();
  }

  int get edgeCount {
    return (edges.count / 2).floor();
  }

  int get studTriCount {
    if (!hasFeatures)
      return 0;

    int cnt = 0;

    for (MeshGroup g in featureChunks.values) {
      cnt += g.count;
    }

    return (cnt / 3).floor();
  }

  int get studEdgeCount {
    if (!hasFeatures)
      return 0;

    return (featureEdges.count / 2).floor();
  }

  bool get hasFeatures {
    return featureChunks != null;
  }

  void recycle() {
    /* free all vertex array (may free some of heap after uploading into VBO) */
    submodels = null;
    meshChunks = null;
    featureChunks = null;
    edges = null;
  }

  Set<String> getDependencies() {
    return new Set.from(submodels.keys);
  }

  Set<Color> getColors() {
    Set<Color> set = new HashSet.from(usedColors);

    for (Part p in submodels.values) {
      set = set.union(p.activeColors);
    }

    /* remove 16 and 24 */
    set.remove(ColorMap.instance.mainColor);
    set.remove(ColorMap.instance.edgeColor);

    return set;
  }

  void loadPart(String partName, {void onLoaded(String s, Part p): null,
                                  void onLoadFailed(String s, int statusCode): null}) {
    partName = normalizePath(partName);
    httpGetJson('$MESH_ENDPOINT/g/parts/$partName.json', (response) {
      Part p = new Part.fromJson(response);
      submodels[partName] = p;
      if (onLoaded != null)
        onLoaded(partName, p);
    }, onFailed: (int statusCode) {
      if (onLoadFailed != null)
        onLoadFailed(partName, statusCode);
    });
  }

  void buildPartsSynchronously(String partName, Resolver r) {
    partName = normalizePath(partName);

    if (!submodels.containsKey(partName))
      return;

    submodels[partName] = new Part.fromLDrawModel(r.getPart(partName), r);
  }

  int MAX_WORKERS = 4;

  void buildPartsAsynchronously(Resolver r,
      void onPartBuilt(int workerId, String partName, Part partData,
          int totalParts, int remainingParts, int elapsed),
      void onFinished()) {
    List<String> parts = new List.from(submodels.keys);
    int workers = parts.length < MAX_WORKERS ? parts.length : MAX_WORKERS;
    int total = parts.length;
    int remaining = total;

    Map serializableColorMap = ColorMap.instance.rawData;
    Map serializableResolver = buildJsonPrimitive(r);

    void receive(List response) {
      if (response != null) {
        int id = response[0];
        String partName = response[1];
        Part part = new Part.fromJson(response[2]);
        int elapsed = response[3];

        --remaining;
        
        if (part != null) {
          if (onPartBuilt != null)
            onPartBuilt(id, partName, part, total, remaining, elapsed);
          submodels[partName] = part;
        }
        
        if (remaining == 0) {
          if (onFinished != null)
            onFinished();
        }
      }
    }

    for (int i = 0; i < workers; ++i) {
      List<String> dividedParts = new List<String>();
      for (int j = 0; j < parts.length; ++j) {
        if (j % workers == i)
          dividedParts.add(parts[j]);
      }
      print('worker queue $i: $dividedParts');

      var msg = [i, serializableResolver, serializableColorMap, dividedParts];
      var response = new ReceivePort();
      Future<Isolate> remote = Isolate.spawnUri(ISOLATE_URI_PART_BUILDER, ['a'], response.sendPort);
      remote.then((_) => response.first).then((sendPort) {
        print(sendPort);
      });
    }
  }
}
