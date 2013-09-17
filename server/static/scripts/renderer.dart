// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

library renderer;

import 'dart:collection';
import 'dart:html';
import 'dart:math';
import 'dart:web_gl';
import 'dart:typed_data';
import 'ldraw.dart';

part 'renderer/math.dart';
part 'renderer/shaders.dart';
part 'renderer/utils.dart';

RenderingContext GL;

void setGlobalRenderingContext(RenderingContext ctx) {
  GL = ctx;
}