// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

RegExp whitespace = new RegExp(r'[ \t]');

String normalizePath(String path) {
  return path.toLowerCase().replaceAll('\\', '/');
}

List<String> splitBy(String str, [int count = null]) {
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

bool isPrimitive(var obj) {
  return (obj == null) || (obj is String) || (obj is num) || (obj is bool);
}

Object buildJsonPrimitive(Object obj) {
  Object visit(v) {
    if (!isPrimitive(v) && !(v is Map) && !(v is List))
      v = v.toJson();
    
    if (isPrimitive(v)) {
      return v;
    } else if (v is Map) {
      Map m = new HashMap();
      Map lm = v;
      lm.forEach((key, value) {
        var kv;
        if (isPrimitive(key))
          kv = key;
        else
          kv = JSON.encode(visit(key));
        m[kv] = visit(value);
      });
      return m;
    } else if (v is List) {
      List l = new List();
      List ll = v;
      for (int i = 0; i < ll.length; ++i)
        l.add(visit(ll[i]));
      return l;
    } else {
      print('object $v has no toJson() implemented');
      return null;
    }
  }

  var v = visit(obj);
  return v;
}