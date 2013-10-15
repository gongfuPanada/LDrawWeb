// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

RenderingContext setupContext(CanvasElement canvas,
    {bool alpha: true, bool antialias: true, bool stencil: false}) {
  RenderingContext gl =
    canvas.getContext3d(alpha: alpha, antialias: antialias, stencil: stencil);
  if (gl == null)
    return null;

  return gl;
}

void initializeView(CanvasElement elem,
    void onSuccess(CanvasElement elem, RenderingContext gl), void onFailed()) {
  if (elem == null) {
    onFailed();
    return;
  }

  RenderingContext gl = setupContext(elem);

  if (gl == null) {
    onFailed();
    return;
  }

  onSuccess(elem, gl);
}

void resizeView(CanvasElement elem, int width, int height)
{
  elem.width = width;
  elem.height = height;
  GL.viewport(0, 0, width, height); 
}