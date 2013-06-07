// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

RegExp whitespace = new RegExp(r'[ \t]');

String normalizePath(String path) {
  return path.toLowerCase().replaceAll('\\', '/');
}

String splitBy(String str, [int count = null]) {
  List<String> output = new List<String>();
  int hit = 0;
  String trailing = '';

  for (String shard in str.split(whitespace)) {
    if (count != null && hit >= count) {
      if (shard.isEmpty)
        trailing += ' ';
      else
        trailing += shard + ' ';
    } else {
      if (!shard.isEmpty) {
        output.add(shard);
        ++hit;
      }
    }
  }
  if (!trailing.isEmpty)
    output.add(trailing.trim());
  return output;
}