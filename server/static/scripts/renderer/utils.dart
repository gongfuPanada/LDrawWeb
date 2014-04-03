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

void resizeView(CanvasElement elem, int width, int height)
{
  elem.width = width;
  elem.height = height;
  GL.viewport(0, 0, width, height); 
}