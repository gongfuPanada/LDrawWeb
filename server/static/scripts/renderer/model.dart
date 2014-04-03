// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

class RenderableModel {
  num DEFAULT_PART_FALL_DURATION = 500.0;
  num DEFAULT_PART_DELAY_DURATION = 75.0;

  Map<MeshCategory, Buffer> vertexBuffers;
  Map<MeshCategory, Buffer> normalBuffers;
  Buffer edgeVertices;
  Buffer edgeColors;

  Map<MeshCategory, int> triCounts;
  int edgeCount;
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

  Mat4 projectionMatrix;
  Mat4 modelViewMatrix;
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

    /* build vertex/normal buffer for meshes */
    vertexBuffers = new HashMap<MeshCategory, Buffer>();
    normalBuffers = new HashMap<MeshCategory, Buffer>();
    triCounts = new HashMap<MeshCategory, int>();

    for (MeshCategory c in renderingOrder) {
      vertexBuffers[c] = GL.createBuffer();
      GL.bindBuffer(ARRAY_BUFFER, vertexBuffers[c]);
      GL.bufferDataTyped(ARRAY_BUFFER,
          new Float32List.fromList(model.meshChunks[c].vertexArray),
          STATIC_DRAW);
      
      normalBuffers[c] = GL.createBuffer();
      GL.bindBuffer(ARRAY_BUFFER, normalBuffers[c]);
      GL.bufferDataTyped(ARRAY_BUFFER,
          new Float32List.fromList(model.meshChunks[c].normalArray),
          STATIC_DRAW);

      triCounts[c] = model.meshChunks[c].count;
    }

    edgeVertices = GL.createBuffer();
    GL.bindBuffer(ARRAY_BUFFER, edgeVertices);
    GL.bufferDataTyped(ARRAY_BUFFER,
        new Float32List.fromList(model.edges.edgeVertices),
        STATIC_DRAW);
    edgeColors = GL.createBuffer();
    GL.bindBuffer(ARRAY_BUFFER, edgeColors);
    GL.bufferDataTyped(ARRAY_BUFFER,
        new Float32List.fromList(model.edges.edgeColors),
        STATIC_DRAW);
    edgeCount = model.edges.count;

    indices = model.indices;
    steps = model.steps;
  }

  void setProjectionMatrix(Mat4 mat) {
    projectionMatrix = mat;
  }

  void setModelViewMatrix(Mat4 mat) {
    modelViewMatrix = mat;
  }

  void render() {
    if (currentStep == -1)
      return;

    MaterialManager materials = MaterialManager.instance;

    modelViewMatrix.toInverseMat3(normalMatrix);

    /* render triangles */

    for (MeshCategory c in renderingOrder) {
      materials.bind(c.color);
      LDrawShader s = materials.activeShader;

      GL.uniformMatrix4fv(s.projectionMatrix, false, projectionMatrix.val);
      GL.uniformMatrix4fv(s.modelViewMatrix, false, modelViewMatrix.val);
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
    }
    
    /* render edges */

    materials.bindEdgeShader();
    EdgeShader s = materials.activeShader;

    GL.disable(CULL_FACE);
    GL.disable(BLEND);

    GL.uniformMatrix4fv(s.projectionMatrix, false, projectionMatrix.val);
    GL.uniformMatrix4fv(s.modelViewMatrix, false, modelViewMatrix.val);
    GL.bindBuffer(ARRAY_BUFFER, edgeVertices);
    GL.vertexAttribPointer(s.vertexPosition, 3, FLOAT, false, 0, 0);
    GL.bindBuffer(ARRAY_BUFFER, edgeColors);
    GL.vertexAttribPointer(s.vertexColor, 3, FLOAT, false, 0, 0);

    if (currentIndex >= 0) {
      Index idx = indices[currentIndex];
      GL.drawArrays(LINES, 0, idx.edgeStart + idx.edgeCount);
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