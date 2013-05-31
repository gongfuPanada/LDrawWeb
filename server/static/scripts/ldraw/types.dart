// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

/* math */

class Vec4 {
  num val[4];

  Vec4(this.val[0], this.val[1], this.val[2], this.val[3]);
  Vec4(this.val[0], this.val[1], this.val[2]) : val[3] = 1.0;
  Vec4() : val[0] = 0.0, val[1] = 0.0, val[2] = 0.0, val[3] = 1.0;
}

class Matrix4 {
  num val[16];

  
}

/* colors and materials */

class LDrawColor {
  int id;

  LDrawColor(this.id);
}

/* commands */

abstract class LDrawCommand {
}

class LDrawBaseString extends LDrawCommand {
  String str;
  
  LDrawBaseString(this.str);
}

/* meta commands */

class LDrawStep extends LDrawCommand {
}

class LDrawClear extends LDrawCommand {
}

class LDrawPause extends LDrawCommand {
}

class LDrawSave extends LDrawCommand {
}

class LDrawBfc extends LDrawCommand {  
}

class LDrawComment extends LDrawBaseString {
}

class LDrawWrite extends LDrawBaseString {
}

/* drawing commands */

class LDrawDrawingCommand extends LDrawCommand {
}

class LDrawLine1 extends LDrawDrawingCommand {
  LDrawColor color;
  Vec4 position;
  Matrix4 matrix;
  String name;

  LDrawLine1(this.color, this.position, this.matrix, this.name);
}

class LDrawLine2 extends LDrawDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;

  LDrawLine2(this.color, this.v1, this.v2);
}

class LDrawLine3 extends LDrawDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;
  Vec4 v3;

  LDrawLine3(this.color, this.v1, this.v2, this.v3);
}

class LDrawLine4 extends LDrawDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;
  Vec4 v3;
  Vec4 v4;

  LDrawLine4(this.color, this.v1, this.v2, this.v3, this.v4);
}

class LDrawLine5 extends LDrawDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;
  Vec4 p1;
  Vec4 p2;

  LDrawLine5(this.color, this.v1, this.v2, this.p1, this.p2);
}

/* models */

class LDrawMetadata {
  String name;
  String author;
}

class LDrawModel {
  String filename;
  LDrawMetadata metadata;
  List<LDrawElement> elements;
}

class LDrawMultipartModel extends LDrawModel {
  Map<String, LDrawModel> parts;
}