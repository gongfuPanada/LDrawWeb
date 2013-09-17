// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

/* commands */

abstract class LDrawCommand {

  static LDrawCommand fromJson(Map json) {
    switch (json['type']) {
      case 'step':
        return new LDrawStep();
      case 'clear':
        return new LDrawClear();
      case 'pause':
        return new LDrawPause();
      case 'save':
        return new LDrawSave();
      case 'bfc':
        return new LDrawBfc(json['command']);
      case 'comment':
        return new LDrawComment(json['str']);
      case 'write':
        return new LDrawComment(json['str']);
      case '1':
        return new LDrawLine1(json['color'], new Mat4.fromList(json['matrix']), json['name']);
      case '2':
        return new LDrawLine2(json['color'],
            new Vec4.fromList(json['v1']),
            new Vec4.fromList(json['v2']));
      case '3':
        return new LDrawLine3(json['color'],
            new Vec4.fromList(json['v1']),
            new Vec4.fromList(json['v2']),
            new Vec4.fromList(json['v3']));
      case '4':
        return new LDrawLine4(json['color'],
            new Vec4.fromList(json['v1']),
            new Vec4.fromList(json['v2']),
            new Vec4.fromList(json['v3']),
            new Vec4.fromList(json['v4']));
      case '5':
        return new LDrawLine5(json['color'],
            new Vec4.fromList(json['v1']),
            new Vec4.fromList(json['v2']),
            new Vec4.fromList(json['p1']),
            new Vec4.fromList(json['p2']));
    }
  }
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

  Map toJson() {
    return {
      'type': 'step'
    };
  }
}

class LDrawClear extends LDrawCommand {
  LDrawClear();

  String toString() => '0 CLEAR';

  Map toJson() {
    return {
      'type': 'clear'
    };
  }
}

class LDrawPause extends LDrawCommand {
  LDrawPause();

  String toString() => '0 PAUSE';

  Map toJson() {
    return {
      'type': 'pause'
    };
  }
}

class LDrawSave extends LDrawCommand {
  LDrawSave();

  String toString() => '0 SAVE';

  Map toJson() {
    return {
      'type': 'save'
    };
  }
}

class LDrawBfc extends LDrawCommand {  
  static const CW = 0x1;
  static const CCW = 0x2;
  static const CLIP = 0x4;
  static const CLIP_CW = CLIP | CW;
  static const CLIP_CCW = CLIP | CCW;
  static const NOCLIP = 0x8;
  static const INVERTNEXT = 0x10;

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

  Map toJson() {
    return {
      'type': 'bfc',
      'command': command
    };
  }
}

class LDrawComment extends LDrawBaseString {
  LDrawComment(String s) : super(s);

  Map toJson() {
    return {
      'type': 'comment',
      'str': str
    };
  }
}

class LDrawWrite extends LDrawBaseString {
  LDrawWrite(String s) : super(s);

  Map toJson() {
    return {
      'type': 'write',
      'str': str
    };
  }
}

/* drawing commands */

class LDrawDrawingCommand extends LDrawCommand {
  int color;
}

class LDrawPrimitiveDrawingCommand extends LDrawDrawingCommand {
}

class LDrawLine1 extends LDrawDrawingCommand {
  Mat4 matrix;
  String name;

  LDrawLine1(int color, this.matrix, this.name) {
    this.color = color;
  }

  String toString() => '1 ${color} ${matrix.toDat()} $name';

  Map toJson() {
    return {
      'type': '1',
      'color': color,
      'matrix': matrix,
      'name': name
    };
  }
}

class LDrawLine2 extends LDrawPrimitiveDrawingCommand {
  Vec4 v1;
  Vec4 v2;

  LDrawLine2(int color, this.v1, this.v2) {
    this.color = color;
  }

  String toString() => '2 ${color} ${v1.toDat()} ${v2.toDat()}';

  Map toJson() {
    return {
      'type': '2',
      'color': color,
      'v1': v1,
      'v2': v2
    };
  }
}

class LDrawLine3 extends LDrawPrimitiveDrawingCommand {
  Vec4 v1;
  Vec4 v2;
  Vec4 v3;

  LDrawLine3(int color, this.v1, this.v2, this.v3) {
    this.color = color;
  }

  String toString() => '3 ${color} ${v1.toDat()} ${v2.toDat()} ${v3.toDat()}';

  Map toJson() {
    return {
      'type': '3',
      'color': color,
      'v1': v1,
      'v2': v2,
      'v3': v3
    };
  }
}

class LDrawLine4 extends LDrawPrimitiveDrawingCommand {
  Vec4 v1;
  Vec4 v2;
  Vec4 v3;
  Vec4 v4;

  LDrawLine4(int color, this.v1, this.v2, this.v3, this.v4) {
    this.color = color;
  }

  String toString() => '4 ${color} ${v1.toDat()} ${v2.toDat()} ${v3.toDat()} ${v4.toDat()}';

  Map toJson() {
    return {
      'type': '4',
      'color': color,
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'v4': v4
    };
  }
}

class LDrawLine5 extends LDrawPrimitiveDrawingCommand {
  Vec4 v1;
  Vec4 v2;
  Vec4 p1;
  Vec4 p2;

  LDrawLine5(int color, this.v1, this.v2, this.p1, this.p2) {
    this.color = color;
  }

  String toString() => '5 ${color} ${v1.toDat()} ${v2.toDat()} ${p1.toDat()} ${p2.toDat()}';

  Map toJson() {
    return {
      'type': '5',
      'color': color,
      'v1': v1,
      'v2': v2,
      'p1': p1,
      'p2': p2
    };
  }
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

  LDrawHeader.fromJson(Map json) {
    name = json['name'];
    filename = json['filename'];
    author = json['author'];
    bfc = json['bfc'];
    metadata = json['metadata'];
  }

  Map toJson() {
    return {
      'name': name,
      'filename': filename,
      'author': author,
      'bfc': bfc,
      'metadata': metadata
    };
  }
}

class LDrawModel {
  LDrawHeader header;
  List<LDrawCommand> commands;

  LDrawModel() {
    header = new LDrawHeader();
    commands = new List<LDrawCommand>();
  }

  LDrawModel.fromJson(Map json) {
    header = new LDrawHeader.fromJson(json['header']);
    commands = new List<LDrawCommand>();
    json['commands'].forEach((value) {
      commands.add(LDrawCommand.fromJson(value));
    });
  }

  Iterable<LDrawCommand> filterRefCmds() {
    return commands.where((LDrawCommand c) => c is LDrawLine1);
  }

  Iterable<LDrawCommand> filterDrawingCmds() {
    return commands.where((LDrawCommand c) => c is LDrawLine2 ||
			                      c is LDrawLine3 ||
			                      c is LDrawLine4 ||
			                      c is LDrawLine5);
  }

  String toString() => '${header.filename} (${header.name})';

  Map toJson() {
    return {
      'header': header,
      'commands': commands
    };
  }
  
  bool hasPart(String partName) {
    return findPart(partName) != null;
  }
  
  // Find contextual item
  LDrawModel findPart(String partName, {Resolver resolver: null}) {
    if (resolver != null) {
      LDrawModel m = resolver.getPart(partName);
      if (m != null)
	return m;
    }
    return null;
  }
}

class LDrawMultipartModel extends LDrawModel {
  Map<String, LDrawModel> parts;

  LDrawMultipartModel() : super() {
    parts = new Map<String, LDrawModel>();
  }

  LDrawModel findPart(String partName, {Resolver resolver: null}) {
    partName = normalizePath(partName);
    if (parts.containsKey(partName))
      return parts[partName];
    return super.findPart(partName, resolver: resolver);
  }

  Map toJson() {
    return {
      'header': header,
      'commands': commands,
      'parts': parts
    };
  }
}
