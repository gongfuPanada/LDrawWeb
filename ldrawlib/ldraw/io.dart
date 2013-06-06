// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

bool parseHeader(LDrawModel model, String cmd) {
  if (model.header.name == null) {
    // Name
    model.header.name = cmd;
    return true;
  }

  List<String> header = splitBy(cmd, count: 1);
  if (header.isEmpty) {
    // Omit empty
    return true;
  }

  String name = header[0].toLowerCase();
  String value;
  if (header.length == 2)
    value = header[1];

  if (name == 'author:') {
    model.header.author = value;
  } else if (name == 'name:') {
    model.header.filename = value;
  } else if (name == 'bfc') {

  } else if (name.startsWith('!')) {
    model.header.metadata.add(cmd);
  } else {
    return false;
  }
  
  return true;
}

LDrawCommand parseLine0(String line) {
  if (line == null || line.trim().length == 0)
    return new LDrawComment('');

  List<String> cmd = splitBy(line, count: 1);

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
      print('Invalid BFC directive: ${cmd[1]}');
      return null;
    }

    return new LDrawBfc(type);
  } else if (type == 'write' || type == 'print') {
    return new LDrawWrite(cmd[1]);
  }

  return new LDrawComment(line);
}

LDrawCommand parseLine1(String line) {

}

LDrawCommand parseLine2(String line) {

}

LDrawCommand parseLine3(String line) {

}

LDrawCommand parseLine4(String line) {

}

LDrawCommand parseLine5(String line) {

}

Map parsers = {
  '0': parseLine0,
  '1': parseLine1,
  '2': parseLine2,
  '3': parseLine3,
  '4': parseLine4,
  '5': parseLine5,
};

LDrawModel parseModel(Iterable<String> stream) {
  bool isHeader = true;
  LDrawModel model = new LDrawModel();

  for (String line in stream) {
    line = line.trim();
    List<String> strings = splitBy(line, count: 1);

    if (strings.length == 0)
      continue;

    String id = strings[0];
    String cmd;
    if (strings.length > 1)
      cmd = strings[1];

    if (id == '0' && cmd != null && isHeader) {
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
        print('Unknown line type $id!');
        continue;
      }

      LDrawCommand command = parsers[id](cmd);
      if (command != null)
        model.commands.add(command);
    }
  }

  return model;
}

LDrawMultipartModel parseMultipartModel(Iterable<String> stream) {

}
