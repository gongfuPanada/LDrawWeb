// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class RenderableModel {
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

  RenderableModel.fromModel(Model model) {
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
      vertexBuffers[c] = GL.createBuffer();
      GL.bindBuffer(ARRAY_BUFFER, vertexBuffers[c]);
      GL.bufferDataTyped(ARRAY_BUFFER,
          model.meshChunks[c].vertices,
          STATIC_DRAW);
      
      normalBuffers[c] = GL.createBuffer();
      GL.bindBuffer(ARRAY_BUFFER, normalBuffers[c]);
      GL.bufferDataTyped(ARRAY_BUFFER,
          model.meshChunks[c].normals,
          STATIC_DRAW);

      /* build stud buffer */
      if (model.hasFeatures && model.featureChunks.containsKey(c)) {
        studVertexBuffers[c] = GL.createBuffer();
        GL.bindBuffer(ARRAY_BUFFER, studVertexBuffers[c]);
        GL.bufferDataTyped(ARRAY_BUFFER,
            model.featureChunks[c].vertices,
            STATIC_DRAW);
        
        studNormalBuffers[c] = GL.createBuffer();
        GL.bindBuffer(ARRAY_BUFFER, studNormalBuffers[c]);
        GL.bufferDataTyped(ARRAY_BUFFER,
            model.featureChunks[c].normals,
            STATIC_DRAW);
      }

      triCounts[c] = model.meshChunks[c].count;
    }

    /* build edge buffer */
    edgeVertices = GL.createBuffer();
    GL.bindBuffer(ARRAY_BUFFER, edgeVertices);
    GL.bufferDataTyped(ARRAY_BUFFER,
        model.edges.vertices,
        STATIC_DRAW);
    edgeColors = GL.createBuffer();
    GL.bindBuffer(ARRAY_BUFFER, edgeColors);
    GL.bufferDataTyped(ARRAY_BUFFER,
        model.edges.colors,
        STATIC_DRAW);
    edgeCount = model.edges.count;

    /* build edge buffer for studs */
    if (model.hasFeatures) {
      studEdgeVertices = GL.createBuffer();
      GL.bindBuffer(ARRAY_BUFFER, studEdgeVertices);
      GL.bufferDataTyped(ARRAY_BUFFER,
          model.featureEdges.vertices,
          STATIC_DRAW);
      studEdgeColors = GL.createBuffer();
      GL.bindBuffer(ARRAY_BUFFER, studEdgeColors);
      GL.bufferDataTyped(ARRAY_BUFFER,
          model.featureEdges.colors,
          STATIC_DRAW);
      studEdgeCount = model.featureEdges.count;
    }

    indices = model.indices;
    steps = model.steps;
  }

  void render(Camera camera, Mat4 modelViewMatrix) {
    if (currentStep == -1)
      return;

    MaterialManager materials = MaterialManager.instance;

    modelViewMatrix.toInverseMat3(normalMatrix);

    /* render triangles */

    for (MeshCategory c in renderingOrder) {
      materials.bind(c.color);
      LDrawShader s = materials.activeShader;

      GL.uniformMatrix4fv(s.projectionMatrix, false, camera.projectionMatrix.val);
      GL.uniformMatrix4fv(s.modelViewMatrix, false, modelViewMatrix.val);
      GL.uniformMatrix4fv(s.modelMatrix, false, camera.matrixWorld.val);
      GL.uniformMatrix4fv(s.viewMatrix, false, camera.matrixWorldInverse.val);
      GL.uniformMatrix3fv(s.normalMatrix, false, normalMatrix.val);
      GL.uniform1i(s.isBfcCertified, c.bfc ? 1 : 0);

      if (c.bfc)
        GL.enable(CULL_FACE);
      else
        GL.disable(CULL_FACE);

      if (c.color.isTransparent)
        GL.enable(BLEND);
      else
        GL.disable(BLEND);

      GL.bindBuffer(ARRAY_BUFFER, vertexBuffers[c]);
      GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
      GL.bindBuffer(ARRAY_BUFFER, normalBuffers[c]);
      GL.vertexAttribPointer(s.vertexNormal, 3, FLOAT, false, 0, 0);

      if (currentIndex >= 0) {
        Index idx = indices[currentIndex];
        GL.drawArrays(TRIANGLES, 0, idx.start[c] + idx.count[c]);
      }

      if (studVertexBuffers != null && studVertexBuffers.containsKey(c)) {
        GL.bindBuffer(ARRAY_BUFFER, studVertexBuffers[c]);
        GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
        GL.bindBuffer(ARRAY_BUFFER, studNormalBuffers[c]);
        GL.vertexAttribPointer(s.vertexNormal, 3, FLOAT, false, 0, 0);
        
        if (currentIndex >= 0) {
          Index idx = indices[currentIndex];
          GL.drawArrays(TRIANGLES, 0, idx.studStart[c] + idx.studCount[c]);
        }
      }
    }
    
    /* render edges */

    materials.bindEdgeShader();
    EdgeShader s = materials.activeShader;

    GL.disable(CULL_FACE);
    GL.disable(BLEND);

    GL.uniformMatrix4fv(s.projectionMatrix, false, camera.projectionMatrix.val);
    GL.uniformMatrix4fv(s.modelViewMatrix, false, modelViewMatrix.val);
    GL.bindBuffer(ARRAY_BUFFER, edgeVertices);
    GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
    GL.bindBuffer(ARRAY_BUFFER, edgeColors);
    GL.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);

    if (currentIndex >= 0) {
      Index idx = indices[currentIndex];
      GL.drawArrays(LINES, 0, idx.edgeStart + idx.edgeCount);
    }

    if (studEdgeVertices != null) {
      GL.bindBuffer(ARRAY_BUFFER, studEdgeVertices);
      GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
      GL.bindBuffer(ARRAY_BUFFER, studEdgeColors);
      GL.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);
      
      if (currentIndex >= 0) {
        Index idx = indices[currentIndex];
        GL.drawArrays(LINES, 0, idx.studEdgeStart + idx.studEdgeCount);
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