// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

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
  bool animating;
  bool get initiated {
    return currentStep != -1;
  }

  Mat3 normalMatrix;

  Model.fromModel(Renderer context, Model model) : super() {
    RenderingContext gl = context.gl;

    /* default params */
    partFallDuration = DEFAULT_PART_FALL_DURATION;
    partDelayDuration = DEFAULT_PART_DELAY_DURATION;

    normalMatrix = new Mat3();
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

  void render(RenderingContext context, Camera camera, Mat4 modelViewMatrix) {
    if (currentStep == -1)
      return;

    MaterialManager materials = MaterialManager.instance;
    RenderingContext gl = context.gl;

    modelViewMatrix.toInverseMat3(normalMatrix);

    /* render triangles */

    for (MeshCategory c in renderingOrder) {
      materials.bind(c.color);
      LDrawShader s = materials.activeShader;

      gl.uniformMatrix4fv(s.projectionMatrix, false, camera.projectionMatrix.val);
      gl.uniformMatrix4fv(s.modelViewMatrix, false, modelViewMatrix.val);
      gl.uniformMatrix4fv(s.modelMatrix, false, camera.matrixWorld.val);
      gl.uniformMatrix4fv(s.viewMatrix, false, camera.matrixWorldInverse.val);
      gl.uniformMatrix3fv(s.normalMatrix, false, normalMatrix.val);
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
    
    /* render edges */

    materials.bindEdgeShader();
    EdgeShader s = materials.activeShader;

    gl.disable(CULL_FACE);
    gl.disable(BLEND);

    gl.uniformMatrix4fv(s.projectionMatrix, false, camera.projectionMatrix.val);
    gl.uniformMatrix4fv(s.modelViewMatrix, false, modelViewMatrix.val);
    gl.bindBuffer(ARRAY_BUFFER, edgeVertices);
    gl.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
    gl.bindBuffer(ARRAY_BUFFER, edgeColors);
    gl.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);

    if (currentIndex >= 0) {
      Index idx = indices[currentIndex];
      gl.drawArrays(LINES, 0, idx.edgeStart + idx.edgeCount);
    }

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