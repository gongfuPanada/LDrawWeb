// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

RenderingContext setupContext(CanvasElement canvas,
			      {bool alpha: true,
				  bool antialias: true,
				  bool stencil: false}) {
  RenderingContext gl =
    canvas.getContext3d(alpha: alpha, antialias: antialias, stencil: stencil);
  if (gl == null)
    return null;

  return gl;
}

void initializeView(CanvasElement elem,
		    void onSuccess(RenderingContext gl),
		    void onFailed()) {
  if (elem == null) {
    onFailed();
    return;
  }

  RenderingContext gl = setupContext(elem);

  if (gl == null) {
    onFailed();
    return;
  }

  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
  gl.clearColor(0, 0, 0, 255);
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);

  onSuccess(gl);
}