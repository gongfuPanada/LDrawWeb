// Copyright 2014 Park "segfault" Joon Kyu <segfault87@gmail.com>

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import '../ldrawlib/ldraw_backend.dart';

bool rescanAll = false;
List<String> buildTargets = null;

const string DAT_PATH = "server/contents/dat/parts";
const string PROCESSED_PATH = "server/contents/postprocessed/parts";

void parseArgs(List<String> argv) {
  for (String arg in argv) {
    if (arg.startsWith("-")) {
      if (arg == "-a" || arg == "--all")
        rescanAll = true;
    } else {
      if (buildTargets == null)
        buildTargets = new List<String>();
      buildTargets.add(arg);
    }
  }
}

List<String> glob(String ldrawPath) {
  List<String> list = new List<String>();

  Directory d = new Directory(ldrawPath);
  for (FileSystemEntity entity in d.listSync()) {
    if (entity is File) {
      File f = entity as File;
      if (!f.path.toLowerCase().endsWith(".dat"))
        continue;
      list.add(f.path);
    }
  }

  return list;
}

Resolver r = new Resolver();
ColorMap map;

void main(List<String> argv) {
  parseArgs(argv);

  if (buildTargets == null) {
    buildTargets = glob(DAT_PATH);
  }

  httpGetJson('http://localhost:8080/s/colors.json', (response) {
    map = new ColorMap.fromJson(response);
    startJob();
  });
}

void startJob() {
  new Stream.fromIterable(buildTargets).listen((path) {
    String name = path.split("/").last;
    String outname = "$PROCESSED_PATH/$name.json";
    if (new File(outname).existsSync() && !rescanAll)
      return;

    print("processing $name...");
    File f = new File(path);
    List<String> contents = f.readAsLinesSync();
    LDrawMultipartModel model = new LDrawMultipartModel();
    parseMultipartModel(model, contents.iterator);
    r.resolveModelLocally(model, 'server/contents/dat', onUpdate: (String s, LDrawModel m) {
      print("dependency $s loaded");
    });
    Part part = new Part.fromLDrawModel(model, r);
    new File(outname).writeAsStringSync(JSON.encode(buildJsonPrimitive(part)));
    print('wrote to $outname');
  });
}
