// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

const int BASE_MODEL_COLOR = 7;
const num NORMAL_BLEND_THRESHOLD = 0.523598776;

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

class EdgeGroup {
  List<num> edgeVertices;
  List<num> edgeColors;

  EdgeGroup.fromJson(Map json) {
    edgeVertices = json['edgeVertices'];
    edgeColors = json['edgeColors'];
  }
  
  EdgeGroup() {
    edgeVertices = new List<num>();
    edgeColors = new List<num>();
  }

  int get count {
    return (edgeVertices.length / 3).floor();
  }

  void add(Vec4 pos, Color c) {
    edgeVertices.add(pos.x);
    edgeVertices.add(pos.y);
    edgeVertices.add(pos.z);

    if (c.isMainColor) {
      edgeColors.add(-1.0);
      edgeColors.add(-1.0);
      edgeColors.add(-1.0);
    } else if (c.isEdgeColor) {
      edgeColors.add(null);
      edgeColors.add(null);
      edgeColors.add(null);
    } else {
      edgeColors.add(c.color.r);
      edgeColors.add(c.color.g);
      edgeColors.add(c.color.b);
    }
  }

  void merge(EdgeGroup g, Color c, [Mat4 transform = null]) {
    int index = 0;
    Vec4 v = new Vec4();
    for (int i = 0; i < g.count; ++i) {
      if (transform == null) {
        edgeVertices.add(g.edgeVertices[index]);
        edgeVertices.add(g.edgeVertices[index + 1]);
        edgeVertices.add(g.edgeVertices[index + 2]);
      } else {
        v.set(g.edgeVertices[index], g.edgeVertices[index + 1], g.edgeVertices[index + 2]);
        transform.transform(v, v);
        edgeVertices.add(v.x);
        edgeVertices.add(v.y);
        edgeVertices.add(v.z);
      }

      if (c.isMainColor) {
        edgeColors.add(g.edgeColors[index]);
        edgeColors.add(g.edgeColors[index + 1]);
        edgeColors.add(g.edgeColors[index + 2]);
      } else {
        if (g.edgeColors[index] == null) {
          edgeColors.add(c.edge.r);
          edgeColors.add(c.edge.g);
          edgeColors.add(c.edge.b);
        } else if (g.edgeColors[index] < 0.0) {
          edgeColors.add(c.color.r);
          edgeColors.add(c.color.g);
          edgeColors.add(c.color.b);
        } else {
          edgeColors.add(g.edgeColors[index]);
          edgeColors.add(g.edgeColors[index + 1]);
          edgeColors.add(g.edgeColors[index + 2]);
        }
      }
      
      index += 3;
    }
  }

  Map toJson() {
    return {
      'edgeVertices': edgeVertices,
      'edgeColors': edgeColors
    };
  }
}

class MeshGroup {
  /* temporary */
  List<Face> faces;

  List<num> vertexArray;
  List<num> normalArray;
  bool built;

  MeshGroup.fromJson(Map json) {
    vertexArray = json['vertexArray'];
    normalArray = json['normalArray'];
    built = json['built'];
  }

  MeshGroup() {
    built = false;
    faces = null;
    vertexArray = null;
    normalArray = null;
  }

  void add(Face face) {
    if (faces == null)
      faces = new List<Face>();

    faces.add(face);
  }

  void merge(MeshGroup other, [Mat4 transform = null]) {
    assert(other.built);

    if (vertexArray == null)
      vertexArray = new List<num>();
    if (normalArray == null)
      normalArray = new List<num>();

    if (transform == null) {
      vertexArray.addAll(other.vertexArray);
      normalArray.addAll(other.normalArray);
    } else {
      int index = 0;
      Mat4 rotmat = new Mat4.copy(transform);
      rotmat.setTranslation(0.0, 0.0, 0.0);
      Vec4 v = new Vec4();
      Vec4 n = new Vec4();
      for (int i = 0; i < other.count; ++i) {
        v.set(other.vertexArray[index], other.vertexArray[index + 1], other.vertexArray[index + 2]);
        transform.transform(v, v);
        n.set(other.normalArray[index], other.normalArray[index + 1], other.normalArray[index + 2]);
        rotmat.transform(n, n);
        n.normalize(n);
        vertexArray.add(v.x);
        vertexArray.add(v.y);
        vertexArray.add(v.z);
        normalArray.add(n.x);
        normalArray.add(n.y);
        normalArray.add(n.z);
        index += 3;
      }
    }
  }

  void clear() {
    faces = null;
    vertexArray = null;
    normalArray = null;
    built = false;
  }

  int get count {
    if (!built && faces != null)
      return faces.length;
    else if (vertexArray != null)
      return (vertexArray.length / 3).floor();
    else
      return 0;
  }

  void finish() {
    if (!built) {
      if (faces == null && vertexArray != null && normalArray != null) {
        built = true;
        return;
      }
    } else {
      return;
    }

    vertexArray = new List<num>();
    normalArray = new List<num>();

    int index = 0;

    /* build adjacency map */
    KdTree<Adjacency> faceMap = new KdTree<Adjacency>();
    for (Face f in faces) {
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

    void buildBuffer(List<num> vertexArray, List<num> normalArray, Vec4 v, Vec4 n) {
      vertexArray.add(v.x);
      vertexArray.add(v.y);
      vertexArray.add(v.z);
      normalArray.add(n.x);
      normalArray.add(n.y);
      normalArray.add(n.z);
    }

    /* build normal and write */
    index = 0;
    for (Face f in faces) {
      Vec4 faceNormal = f.getNormal();
      for (int idx in f.indexOrder) {
        Vec4 v = f.vertices[idx];
        Adjacency adj = faceMap.exact(v).tag;
        List<Face> adjacentFaces = adj.query(v, f);
        /* look for adjacent faces and blend their normals to smooth the faces */
        if (adjacentFaces.length > 0) {
          Vec4 blendedNormal = new Vec4.copy(faceNormal);
          for (Face otherFace in adjacentFaces) {
            Vec4 otherNormal = otherFace.getNormal();
            num angle = Vec4.angle(otherNormal, blendedNormal);
            if (Vec4.angle(otherNormal, blendedNormal).abs() < NORMAL_BLEND_THRESHOLD) {
              Vec4.interpolate(blendedNormal, otherNormal, blendedNormal);
              blendedNormal.normalize(blendedNormal);
            }
          }
          buildBuffer(vertexArray, normalArray, v, blendedNormal);
        } else {
          buildBuffer(vertexArray, normalArray, v, faceNormal);
        }
      }
    }

    faces.clear();
    built = true;
  }

  Map toJson() {
    return {
      'vertexArray': vertexArray,
      'normalArray': normalArray,
      'built': true
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

  void add(Mat4 matrix, bool flipNormal) {
    matrices.add(matrix, flipNormal);
  }

  List toJson() {
    return {
      'matrices': matrices,
      'flipNormal': new List<int>.generate(flipNormal.length, (int index) => flipNormal[index] ? 1 : 0);
    }
  }
}

class Part {
  static Set<String> kFeatures = new HashSet.from(['stud.dat']);

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
      value.forEach((key, value) {
        MeshCategory cat = new MeshGroup.fromJson(JSON.decode(key));
        features[cat] = new FeatureMap.fromJson(value);
      });
    });
    edges = new EdgeGroup.fromJson(json['edges']);
  }

  Part.fromLDrawModel(LDrawModel model, Resolver pool,
      {bool excludeRefs: false}) {
    header = model.header;
    parseLDrawModel(model, pool, excludeRefs);
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
          if (kFeatures.contains(name) ) {
            Map<MeshCategory, FeatureMap> currentFeatures;
            if (features.containsKey(name)) {
              currentFeatures = features[name];
            } else {
              currentFeatures = new HashMap<MeshCategory, FeatureMap>();
              features[name] = currentFeatures;
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
      min = new Vec4.copy(point);
      max = new Vec4.copy(point);
    } else {
      if (point.x > max.x)
        max.setX(point.x);
      if (point.y > max.y)
        max.setY(point.y);
      if (point.z > max.z)
        max.setZ(point.z);
      if (point.x < min.x)
        min.setX(point.x);
      if (point.y < min.y)
        min.setY(point.y);
      if (point.z < min.z)
        min.setZ(point.z);
    }
  }

  Vec4 center() {
    return (min + max) * 0.5;
  }
}

class Index {
  Map<MeshCategory, int> start;
  Map<MeshCategory, int> count;
  int edgeStart;
  int edgeCount;
  BoundingBox boundingBox;
  Model parent;

  Index(this.parent) {
    start = new HashMap<MeshCategory, int>();
    count = new HashMap<MeshCategory, int>();
  }

  void add(MeshCategory category, int start, int count) {
    this.start[category] = start;
    this.count[category] = count;
  }

  void setEdgeIndex(int start, int count) {
    edgeStart = start;
    edgeCount = count;
  }

  void finish() {
    boundingBox = new BoundingBox();

    Vec4 v = new Vec4();
    for (MeshCategory c in count.keys) {
      int s = start[c], cnt = count[c];
      List<num> vertices = parent.meshChunks[c].vertexArray;
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
  EdgeGroup edges;

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

  void compile() {
    meshChunks = new HashMap<MeshCategory, MeshGroup>();
    edges = new EdgeGroup();

    Set<String> visitedSubparts = new HashSet<String>();

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
            MeshGroup group;
            /* inherit color */
            MeshCategory from = cat;
            if (cat.color.isMainColor)
              cat = new MeshCategory(c, cat.bfc);
            /* allocate new mesh chunk */
            if (!meshChunks.containsKey(cat)) {
              group = new MeshGroup();
              meshChunks[cat] = group;
            } else {
              group = meshChunks[cat];
            }
            /* merge */
            group.merge(p.meshes[from], matrix * cmd.matrix);
          }
          /* merge colors */
          edges.merge(p.edges, c, matrix * cmd.matrix);
        }
      }
    }

    traverseMesh(root, ColorMap.instance.query(BASE_MODEL_COLOR),
        new Mat4.identity(), true);

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
    int curEdgeIndex = 0;
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

            Index idx = new Index(this);

            ++stepIndex;
            
            MeshCategory partColorBfc = new MeshCategory(
                ColorMap.instance.query(refcmd.color), true);
            MeshCategory partColor = new MeshCategory(
                ColorMap.instance.query(refcmd.color), false);
            
            for (MeshCategory c in categories) {
              int count;
              if (submodels[name].meshes.containsKey(c))
                count = submodels[name].meshes[c].count;
              else
                count = 0;
              
              try {
                if (partColorBfc == c)
                  count += submodels[name].meshes[defaultColorBfc].count;
                else if (partColor == c)
                  count += submodels[name].meshes[defaultColor].count;
              } catch (e) {}
              
              if (!curTriIndex.containsKey(c))
                curTriIndex[c] = 0;
              
              idx.add(c, curTriIndex[c], count);
              curTriIndex[c] += count;
            }
            
            idx.setEdgeIndex(curEdgeIndex, submodels[name].edges.count);
            curEdgeIndex += submodels[name].edges.count;
            
            idx.finish();
            indices.add(idx);
          }
        } else if (cmd is LDrawStep || cmd is LDrawPause) {
          steps.add(stepIndex);
        }
      }
    }
    traverseIndex(root);

    /* add last step */
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

  void recycle() {
    /* free all vertex array (may free some of heap after uploading into VBO) */
    submodels = null;
    meshChunks = null;
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
