// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class NormalVisualizer extends Geometry {
  Buffer edgeVertices;
  Buffer edgeColors;
  int lineCount;

  NormalVisualizer.fromModel(Renderer context, Model model, {num distance: 4.0}) : super() {
    RenderingContext gl = context.gl;

    lineCount = 0;

    /* count all of vertices */
    for (MeshGroup m in model.meshChunks.values) {
      lineCount += m.vertices.length;
    }
    for (MeshGroup m in model.featureChunks.values) {
      lineCount += m.vertices.length;
    }

    lineCount *= 2; /* 2 vertices */
    lineCount = lineCount ~/ 3; /* 3 elements (x, y, z) */

    Float32List edges = new Float32List(lineCount * 3);
    Float32List colors = new Float32List(lineCount * 3);

    int i = 0;
    for (MeshGroup m in model.meshChunks.values) {
      Float32List tv = m.vertices;
      Float32List tm = m.normals;
      for (int j = 0; j < tv.length; j += 3) {
        edges[i  ] = tv[j  ];
        edges[i+1] = tv[j+1];
        edges[i+2] = tv[j+2];
        edges[i+3] = tv[j  ] + (tm[j  ] * distance);
        edges[i+4] = tv[j+1] + (tm[j+1] * distance);
        edges[i+5] = tv[j+2] + (tm[j+2] * distance);
        colors[i  ] = 0.2;
        colors[i+1] = 0.2;
        colors[i+2] = 0.2;
        colors[i+3] = 0.8;
        colors[i+4] = 0.8;
        colors[i+5] = 0.8;
        i += 6;
      }
    }
    for (MeshGroup m in model.featureChunks.values) {
      Float32List tv = m.vertices;
      Float32List tm = m.normals;
      for (int j = 0; j < tv.length; j += 3) {
        edges[i  ] = tv[j  ];
        edges[i+1] = tv[j+1];
        edges[i+2] = tv[j+2];
        edges[i+3] = tv[j  ] + (tm[j  ] * distance);
        edges[i+4] = tv[j+1] + (tm[j+1] * distance);
        edges[i+5] = tv[j+2] + (tm[j+2] * distance);
        colors[i  ] = 0.2;
        colors[i+1] = 0.2;
        colors[i+2] = 0.2;
        colors[i+3] = 0.8;
        colors[i+4] = 0.8;
        colors[i+5] = 0.8;
        i += 6;
      }
    }

    edgeVertices = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, edgeVertices);
    gl.bufferDataTyped(ARRAY_BUFFER,
        edges,
        STATIC_DRAW);
    edgeColors = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, edgeColors);
    gl.bufferDataTyped(ARRAY_BUFFER,
        colors,
        STATIC_DRAW);
  }

  void render(Renderer context) {
    MaterialManager materials = MaterialManager.instance;
    RenderingContext gl = context.gl;

    materials.bindEdgeShader();
    EdgeShader s = materials.activeShader;

    gl.disable(CULL_FACE);
    gl.disable(BLEND);
    gl.disable(DEPTH_TEST);

    s.bindCommonUniforms();
    gl.bindBuffer(ARRAY_BUFFER, edgeVertices);
    gl.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
    gl.bindBuffer(ARRAY_BUFFER, edgeColors);
    gl.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);

    gl.drawArrays(LINES, 0, lineCount);

    gl.enable(DEPTH_TEST);
  }
}

class Model extends Geometry {
  num DEFAULT_PART_FALL_DURATION = 500.0;
  num DEFAULT_PART_DELAY_DURATION = 75.0;

  Map<MeshCategory, Buffer> vertexBuffers;
  Map<MeshCategory, Buffer> normalBuffers;
  Map<MeshCategory, Buffer> studVertexBuffers;
  Map<MeshCategory, Buffer> studNormalBuffers;
  Buffer edgeVertices;
  Buffer edgeColors;
  Buffer studEdgeVertices;
  Buffer studEdgeColors;

  Map<MeshCategory, int> triCounts;
  Map<MeshCategory, int> studTriCounts;
  int edgeCount;
  int studEdgeCount;
  List<MeshCategory> renderingOrder;
  List<int> steps;
  List<Index> indices;
  
  num partFallDuration;
  num partDelayDuration;
  int currentStep;
  int currentIndex;
  int startIndex;
  num timeBase;
  bool renderStuds = true;
  bool animating;
  bool get initiated {
    return currentStep != -1;
  }

  Model.fromModel(Renderer context, Model model) : super() {
    RenderingContext gl = context.gl;

    /* default params */
    partFallDuration = DEFAULT_PART_FALL_DURATION;
    partDelayDuration = DEFAULT_PART_DELAY_DURATION;

    currentStep = -1;
    currentIndex = -1;

    renderingOrder = new List.from(model.meshChunks.keys);
    renderingOrder.sort();

    /* prepare vertex/normal buffer for meshes */
    vertexBuffers = new HashMap<MeshCategory, Buffer>();
    normalBuffers = new HashMap<MeshCategory, Buffer>();
    triCounts = new HashMap<MeshCategory, int>();
    if (model.hasFeatures) {
      studVertexBuffers = new HashMap<MeshCategory, Buffer>();
      studNormalBuffers = new HashMap<MeshCategory, Buffer>();
      studTriCounts = new HashMap<MeshCategory, int>();
    }

    for (MeshCategory c in renderingOrder) {
      /* build basic geometry */
      vertexBuffers[c] = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, vertexBuffers[c]);
      gl.bufferDataTyped(ARRAY_BUFFER,
          model.meshChunks[c].vertices,
          STATIC_DRAW);
      
      normalBuffers[c] = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, normalBuffers[c]);
      gl.bufferDataTyped(ARRAY_BUFFER,
          model.meshChunks[c].normals,
          STATIC_DRAW);

      /* build stud buffer */
      if (model.hasFeatures && model.featureChunks.containsKey(c)) {
        studVertexBuffers[c] = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, studVertexBuffers[c]);
        gl.bufferDataTyped(ARRAY_BUFFER,
            model.featureChunks[c].vertices,
            STATIC_DRAW);
        
        studNormalBuffers[c] = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, studNormalBuffers[c]);
        gl.bufferDataTyped(ARRAY_BUFFER,
            model.featureChunks[c].normals,
            STATIC_DRAW);
      }

      triCounts[c] = model.meshChunks[c].count;
    }

    /* build edge buffer */
    edgeVertices = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, edgeVertices);
    gl.bufferDataTyped(ARRAY_BUFFER,
        model.edges.vertices,
        STATIC_DRAW);
    edgeColors = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, edgeColors);
    gl.bufferDataTyped(ARRAY_BUFFER,
        model.edges.colors,
        STATIC_DRAW);
    edgeCount = model.edges.count;

    /* build edge buffer for studs */
    if (model.hasFeatures) {
      studEdgeVertices = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, studEdgeVertices);
      gl.bufferDataTyped(ARRAY_BUFFER,
          model.featureEdges.vertices,
          STATIC_DRAW);
      studEdgeColors = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, studEdgeColors);
      gl.bufferDataTyped(ARRAY_BUFFER,
          model.featureEdges.colors,
          STATIC_DRAW);
      studEdgeCount = model.featureEdges.count;
    }

    indices = model.indices;
    steps = model.steps;
  }

  void render(Renderer context) {
    if (currentStep == -1)
      return;

    MaterialManager materials = MaterialManager.instance;
    RenderingContext gl = context.gl;

    /* render triangles */

    for (MeshCategory c in renderingOrder) {
      materials.bind(c.color);
      LDrawShader s = materials.activeShader;
      
      s.bindCommonUniforms();
      gl.uniformMatrix3fv(s.normalMatrix, false, context.uniformValues.normalMatrix.val);
      gl.uniform1i(s.isBfcCertified, c.bfc ? 1 : 0);

      if (c.bfc)
        gl.enable(CULL_FACE);
      else
        gl.disable(CULL_FACE);

      if (c.color.isTransparent)
        gl.enable(BLEND);
      else
        gl.disable(BLEND);

      gl.bindBuffer(ARRAY_BUFFER, vertexBuffers[c]);
      gl.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
      gl.bindBuffer(ARRAY_BUFFER, normalBuffers[c]);
      gl.vertexAttribPointer(s.vertexNormal, 3, FLOAT, false, 0, 0);

      if (currentIndex >= 0) {
        Index idx = indices[currentIndex];
        gl.drawArrays(TRIANGLES, 0, idx.start[c] + idx.count[c]);
      }

      if (renderStuds) {
        if (studVertexBuffers != null && studVertexBuffers.containsKey(c)) {
          gl.bindBuffer(ARRAY_BUFFER, studVertexBuffers[c]);
          gl.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
          gl.bindBuffer(ARRAY_BUFFER, studNormalBuffers[c]);
          gl.vertexAttribPointer(s.vertexNormal, 3, FLOAT, false, 0, 0);
          
          if (currentIndex >= 0) {
            Index idx = indices[currentIndex];
            gl.drawArrays(TRIANGLES, 0, idx.studStart[c] + idx.studCount[c]);
          }
        }
      }
    }
    
    /* render edges */

    materials.bindEdgeShader();
    EdgeShader s = materials.activeShader;

    gl.disable(CULL_FACE);
    gl.disable(BLEND);

    s.bindCommonUniforms();
    gl.bindBuffer(ARRAY_BUFFER, edgeVertices);
    gl.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
    gl.bindBuffer(ARRAY_BUFFER, edgeColors);
    gl.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);

    if (currentIndex >= 0) {
      Index idx = indices[currentIndex];
      gl.drawArrays(LINES, 0, idx.edgeStart + idx.edgeCount);
    }

    if (renderStuds) {
      if (studEdgeVertices != null) {
        gl.bindBuffer(ARRAY_BUFFER, studEdgeVertices);
        gl.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
        gl.bindBuffer(ARRAY_BUFFER, studEdgeColors);
        gl.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);
        
        if (currentIndex >= 0) {
          Index idx = indices[currentIndex];
          gl.drawArrays(LINES, 0, idx.studEdgeStart + idx.studEdgeCount);
        }
      }
    }
  }

  void startAnimation(num time, [int targetStep = null]) {
    if (animating)
      return;
    
    if (currentStep >= steps.length - 1)
      return;

    timeBase = time;
    if (targetStep == null)
      ++currentStep;
    else
      currentStep = targetStep;
    animating = true;
  }

  void animate(num time) {
    if (!animating)
      return;

    num adjustedTime = time - timeBase;
    int prevIndex = -1;

    if (currentStep > 0)
      prevIndex = steps[currentStep - 1];

    if (adjustedTime >= partFallDuration) {
      currentIndex = prevIndex +
        ((adjustedTime - partFallDuration) / partDelayDuration).floor();
    } else {
      currentIndex = prevIndex;
    }

    num postamble = adjustedTime - ((currentIndex - (prevIndex < 0 ? 0 : prevIndex)) *
        partFallDuration);

    print (postamble);

    if (currentIndex >= steps[currentStep])
      animating = false;
  }
}