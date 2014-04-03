// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

library ldraw;

import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

part 'ldraw/colors.dart';
part 'ldraw/io.dart';
part 'ldraw/io_backend.dart';
part 'ldraw/kdtree.dart';
part 'ldraw/math.dart';
part 'ldraw/postprocess.dart';
part 'ldraw/resolver.dart';
part 'ldraw/types.dart';
part 'ldraw/util.dart';

const String DAT_ENDPOINT = 'http://localhost:8080/geometry/dat/';
const String MESH_ENDPOINT = 'http://localhost:8080/geometry/mesh/';
const bool IS_BACKEND = true;