// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

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

  String toString() => '0 $str'.trim();
}

/* meta commands */

class LDrawStep extends LDrawCommand {
  LDrawStep();

  String toString() => '0 STEP';
}

class LDrawClear extends LDrawCommand {
  LDrawClear();

  String toString() => '0 CLEAR';
}

class LDrawPause extends LDrawCommand {
  LDrawPause();

  String toString() => '0 PAUSE';
}

class LDrawSave extends LDrawCommand {
  LDrawSave();

  String toString() => '0 SAVE';
}

class LDrawBfc extends LDrawCommand {  
  static const CW = 0;
  static const CCW = 1;
  static const CLIP = 2;
  static const CLIP_CW = 3;
  static const CLIP_CCW = 4;
  static const NOCLIP = 5;
  static const INVERTNEXT = 6;

  int command;

  LDrawBfc(this.command);

  String toString() {
    String cmd;
    switch (command) {
      case CW:
        cmd = "CW";
        break;
      case CCW:
        cmd = "CCW";
        break;
      case CLIP:
        cmd = "CLIP";
        break;
      case CLIP_CW:
        cmd = "CLIP CW";
        break;
      case CLIP_CCW:
        cmd = "CLIP CCW";
        break;
      case NOCLIP:
        cmd = "NOCLIP";
        break;
      case INVERTNEXT:
        cmd = "INVERTNEXT";
        break;
      default:
        return null;
    }
    return '0 BFC $cmd';
  }     
}

class LDrawComment extends LDrawBaseString {
  LDrawComment(String s) : super(s);
}

class LDrawWrite extends LDrawBaseString {
  LDrawWrite(String s) : super(s);
}

/* drawing commands */

class LDrawDrawingCommand extends LDrawCommand {
}

class LDrawPrimitiveDrawingCommand extends LDrawDrawingCommand {
}

class LDrawLine1 extends LDrawDrawingCommand {
  LDrawColor color;
  Matrix4 matrix;
  String name;

  LDrawLine1(this.color, this.matrix, this.name);

  String toString() => '1 ${color.id} ${matrix.toDat()} $name';
}

class LDrawLine2 extends LDrawPrimitiveDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;

  LDrawLine2(this.color, this.v1, this.v2);

  String toString() => '2 ${color.id} ${v1.toDat()} ${v2.toDat()}';
}

class LDrawLine3 extends LDrawPrimitiveDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;
  Vec4 v3;

  LDrawLine3(this.color, this.v1, this.v2, this.v3);

  String toString() => '3 ${color.id} ${v1.toDat()} ${v2.toDat()} ${v3.toDat()}';
}

class LDrawLine4 extends LDrawPrimitiveDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;
  Vec4 v3;
  Vec4 v4;

  LDrawLine4(this.color, this.v1, this.v2, this.v3, this.v4);

  String toString() => '4 ${color.id} ${v1.toDat()} ${v2.toDat()} ${v3.toDat()} ${v4.toDat()}';
}

class LDrawLine5 extends LDrawPrimitiveDrawingCommand {
  LDrawColor color;
  Vec4 v1;
  Vec4 v2;
  Vec4 p1;
  Vec4 p2;

  LDrawLine5(this.color, this.v1, this.v2, this.p1, this.p2);

  String toString() => '5 ${color.id} ${v1.toDat()} ${v2.toDat()} ${p1.toDat()} ${p2.toDat()}';
}

/* models */

class LDrawHeader {
  static const int BFC_UNSPECIFIED = -1;
  static const int BFC_NOCERTIFY = 0;
  static const int BFC_CERTIFIED_CCW = 1;
  static const int BFC_CERTIFIED_CW = 2;

  String name;
  String filename;
  String author;
  int bfc;
  List<String> metadata;

  LDrawHeader() {
    metadata = new List<String>();
    bfc = BFC_UNSPECIFIED;
  }
}

class LDrawModel {
  LDrawHeader header;
  List<LDrawCommand> commands;

  LDrawModel() {
    header = new LDrawHeader();
    commands = new List<LDrawCommand>();
  }
}

class LDrawMultipartModel extends LDrawModel {
  Map<String, LDrawModel> parts;
}
