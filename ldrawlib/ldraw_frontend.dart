// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

library ldraw;

import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:html';
import 'dart:math';
import 'dart:isolate';
import 'dart:json';
import 'dart:typed_data';

part 'ldraw/colors.dart';
part 'ldraw/io.dart';
part 'ldraw/io_frontend.dart';
part 'ldraw/kdtree.dart';
part 'ldraw/math.dart';
part 'ldraw/postprocess.dart';
part 'ldraw/resolver.dart';
part 'ldraw/types.dart';
part 'ldraw/util.dart';

const String DAT_ENDPOINT = '/geometry/dat/';
const String MESH_ENDPOINT = '/geometry/mesh/';
const bool IS_BACKEND = false;
