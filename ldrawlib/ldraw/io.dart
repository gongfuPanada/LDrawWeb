// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

class ParsingException implements Exception {
  String message;

  ParsingException(this.message);

  String toString() => this.message;
}

class ParsingError implements Error {
  String message;

  ParsingError(this.message);

  String toString() => this.message;
}

class NextPart implements Exception {
  String filename;

  NextPart(this.filename);

  String toString() => 'Next part \'$filename\'';
}

bool parseHeader(LDrawModel model, String cmd) {
  List<String> header = splitBy(cmd, 1);
  if (header.isEmpty) {
    // Omit empty
    return true;
  }

  String name = header[0].toLowerCase();
  String value;
  if (header.length == 2)
    value = header[1];

  if (name == 'file') {
    // omit MPD header
  } else if (name == 'author:') {
    model.header.author = value;
  } else if (name == 'name:') {
    model.header.filename = value;
  } else if (name == 'bfc' && model.header.bfc == LDrawHeader.BFC_UNSPECIFIED) {
    value = value.toLowerCase();
    if (value == 'nocertify')
      model.header.bfc = LDrawHeader.BFC_NOCERTIFY;
    else if (value == 'certify' || value == 'certify ccw')
      model.header.bfc = LDrawHeader.BFC_CERTIFIED_CCW; /* CCW is implied */
    else if (value == 'certify cw')
      model.header.bfc = LDrawHeader.BFC_CERTIFIED_CW;
    else
      print('Unrecognized BFC certification status: $value');
  } else if (name.startsWith('!')) {
    model.header.metadata.add(cmd);
  } else {
    if (model.header.name == null)
      model.header.name = cmd; 
    else
      return false; /* which means there is no more header */
  }
  
  return true;
}

LDrawCommand parseLine0(String line) {
  if (line == null || line.trim().length == 0)
    return new LDrawComment('');

  List<String> cmd = splitBy(line, 1);

  String type = cmd[0].toLowerCase();
  if (type == 'step') {
    return new LDrawStep();
  } else if (type == 'clear') {
    return new LDrawClear();
  } else if (type == 'pause') {
    return new LDrawPause();
  } else if (type == 'save') {
    return new LDrawSave();
  } else if (type == 'bfc') {
    String bfc = cmd[1].toLowerCase();
    int type;

    if (bfc == 'cw') {
      type = LDrawBfc.CW;
    } else if (bfc == 'ccw') {
      type = LDrawBfc.CCW;
    } else if (bfc == 'clip') {
      type = LDrawBfc.CLIP;
    } else if (bfc == 'clip cw') {
      type = LDrawBfc.CLIP_CW;
    } else if (bfc == 'clip ccw') {
      type = LDrawBfc.CLIP_CCW;
    } else if (bfc == 'noclip') {
      type = LDrawBfc.NOCLIP;
    } else if (bfc == 'invertnext') {
      type = LDrawBfc.INVERTNEXT;
    } else {
      throw new ParsingException('Invalid BFC directive: ${cmd[1]}');
    }

    return new LDrawBfc(type);
  } else if (type == 'write' || type == 'print') {
    return new LDrawWrite(cmd[1]);
  }

  return new LDrawComment(line);
}

LDrawCommand parseLine1(String line) {
  List<String> t = splitBy(line, 13);
  if (t.length < 14)
    throw new ParsingException('Parameter count does not match. 14 expected, ${t.length} found.');

  try {
    int color = int.parse(t[0]);
    Mat4 matrix = new Mat4.init(
        double.parse(t[4]), double.parse(t[5]), double.parse(t[6]),
        double.parse(t[7]), double.parse(t[8]), double.parse(t[9]),
        double.parse(t[10]), double.parse(t[11]), double.parse(t[12]),
        double.parse(t[1]), double.parse(t[2]), double.parse(t[3]));

    return new LDrawLine1(color, matrix, t[13]);
  } on FormatException catch (e) {
    throw new ParsingException('Invalid token: ${e.message}');
  }
}

LDrawCommand parseLine2(String line) {
  List<String> t = splitBy(line, 7);
  if (t.length < 7)
    throw new ParsingException('Parameter count does not match. 7 expected, ${t.length} found.');

  try {
    int color = int.parse(t[0]);
    Vec4 v1 = new Vec4.xyz(double.parse(t[1]), double.parse(t[2]), double.parse(t[3]));
    Vec4 v2 = new Vec4.xyz(double.parse(t[4]), double.parse(t[5]), double.parse(t[6]));

    return new LDrawLine2(color, v1, v2);
  } on FormatException catch (e) {
    throw new ParsingException('Invalid token: ${e.message}');
  }
}

LDrawCommand parseLine3(String line) {
  List<String> t = splitBy(line, 10);
  if (t.length < 10)
    throw new ParsingException('Parameter count does not match. 10 expected, ${t.length} found.');

  try {
    int color = int.parse(t[0]);
    Vec4 v1 = new Vec4.xyz(double.parse(t[1]), double.parse(t[2]), double.parse(t[3]));
    Vec4 v2 = new Vec4.xyz(double.parse(t[4]), double.parse(t[5]), double.parse(t[6]));
    Vec4 v3 = new Vec4.xyz(double.parse(t[7]), double.parse(t[8]), double.parse(t[9]));

    return new LDrawLine3(color, v1, v2, v3);
  } on FormatException catch (e) {
    throw new ParsingException('Invalid token: ${e.message}');
  }
}

LDrawCommand parseLine4(String line) {
  List<String> t = splitBy(line, 13);
  if (t.length < 13)
    throw new ParsingException('Parameter count does not match. 13 expected, ${t.length} found.');

  try {
    int color = int.parse(t[0]);
    Vec4 v1 = new Vec4.xyz(double.parse(t[1]), double.parse(t[2]), double.parse(t[3]));
    Vec4 v2 = new Vec4.xyz(double.parse(t[4]), double.parse(t[5]), double.parse(t[6]));
    Vec4 v3 = new Vec4.xyz(double.parse(t[7]), double.parse(t[8]), double.parse(t[9]));
    Vec4 v4 = new Vec4.xyz(double.parse(t[10]), double.parse(t[11]), double.parse(t[12]));

    return new LDrawLine4(color, v1, v2, v3, v4);
  } on FormatException catch (e) {
    throw new ParsingException('Invalid token: ${e.message}');
  }
}

LDrawCommand parseLine5(String line) {
  List<String> t = splitBy(line, 13);
  if (t.length < 13)
    throw new ParsingException('Parameter count does not match. 13 expected, ${t.length} found.');

  try {
    int color = int.parse(t[0]);
    Vec4 v1 = new Vec4.xyz(double.parse(t[1]), double.parse(t[2]), double.parse(t[3]));
    Vec4 v2 = new Vec4.xyz(double.parse(t[4]), double.parse(t[5]), double.parse(t[6]));
    Vec4 v3 = new Vec4.xyz(double.parse(t[7]), double.parse(t[8]), double.parse(t[9]));
    Vec4 v4 = new Vec4.xyz(double.parse(t[10]), double.parse(t[11]), double.parse(t[12]));

    return new LDrawLine5(color, v1, v2, v3, v4);
  } on FormatException catch (e) {
    throw new ParsingException('Invalid token: ${e.message}');
  }
}

Map parsers = {
  '0': parseLine0,
  '1': parseLine1,
  '2': parseLine2,
  '3': parseLine3,
  '4': parseLine4,
  '5': parseLine5,
};

void parseModel(LDrawModel model, Iterator<String> iterator,
		{bool multipart: false}) {
  bool isHeader = true;
  int lineno = 0;

  String line;
  while (iterator.moveNext()) {
    ++lineno;
    line = iterator.current.trim();
    List<String> strings = splitBy(line, 1);

    if (strings.length == 0)
      continue;

    try {
      String id = strings[0];
      String cmd;
      if (strings.length > 1)
	cmd = strings[1];
      
      if (id == '0' && cmd != null && cmd.startsWith('FILE ')) {
	if (multipart)
	  throw new NextPart(cmd.substring(4).trim());
	else
	  throw new ParsingError('Attempted to decode multipart document.');
      } else if (id == '0' && cmd != null && isHeader) {
	if (!parseHeader(model, cmd)) {
	  // This is not header
	  isHeader = false;
	  LDrawCommand command = parseLine0(cmd);
	  if (command != null)
	    model.commands.add(command);
	}
      } else {
	if (isHeader)
	  isHeader = false;
	if (parsers[id] == null) {
	  throw new ParsingException('Unknown line type $id!');
	}
	
	LDrawCommand command = parsers[id](cmd);
	if (command != null)
	  model.commands.add(command);
      }
    } on ParsingException catch (e) {
      print('Parsing error in line $lineno: ${e.message}');
      continue;
    }
  }
}

void parseMultipartModel(LDrawMultipartModel model, Iterator<String> iterator) {
  String nextPart = null;
  String line;

  while (true) {
    try {
      if (nextPart != null) {
	// Read subpart
	LDrawModel subpart = new LDrawModel();
	model.parts[nextPart] = subpart;
	parseModel(subpart, iterator, multipart: true);
      } else {
	if (!iterator.moveNext())
	  break;
	line = iterator.current.trim();
	parseModel(model, iterator, multipart: true);
      }
    } on NextPart catch (e) {
      nextPart = normalizePath(e.filename);
      continue;
    }
    break;
  }
}
