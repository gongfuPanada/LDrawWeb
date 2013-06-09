// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

library ldraw;

import 'dart:collection';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

part 'ldraw/io.dart';
part 'ldraw/math.dart';
part 'ldraw/meshgen.dart';
part 'ldraw/resolver.dart';
part 'ldraw/types.dart';
part 'ldraw/util.dart';

const String DAT_ENDPOINT = '/geometry/dat/';
const String MESH_ENDPOINT = '/geometry/mesh/';
const bool IS_BACKEND = false;
