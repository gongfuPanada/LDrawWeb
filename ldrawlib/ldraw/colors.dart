// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

class Color {
  int id;
  String name;
  String type;
  Map attrs;

  Color.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    attrs = json['attrs'];
    attrs.forEach((key, value) {
      if (value is List && value.length == 4) {
        attrs[key] = new Vec4.xyzw(value[0], value[1], value[2], value[3]);
      } else if (value is List && value.length == 3) {
        attrs[key] = new Vec4.xyz(value[0], value[1], value[2]);
      } else {
        attrs[key] = value;
      }
    });
  }

  Color.fromMap(this.id, Map map) {
    attrs = new Map();

    this.name = map['name'];
    this.type = map['type'];

    map['material'].forEach((key, value) {
      if (value is List && value.length == 4) {
        attrs[key] = new Vec4.xyzw(value[0] / 255.0, value[1] / 255.0,
            value[2] / 255.0, value[3] / 255.0);
      } else if (value is List && value.length == 3) {
        attrs[key] = new Vec4.xyz(value[0] / 255.0, value[1] / 255.0,
            value[2] / 255.0);
      } else {
        attrs[key] = value;
      }
    });
  }

  Color.solid(this.id, Vec4 color, {Vec4 edge: null,
	String name: null}) {
    if (name != null)
      this.name = name;
    this.type = 'solid';

    attrs = new Map();

    if (edge == null)
      edge = new Vec4.xyz(0.35, 0.35, 0.35);
    attrs['edge'] = edge;
    attrs['color'] = color;
  }

  Vec4 get color => attrs['color'];
  Vec4 get edge => attrs['edge'];

  String toString() => '[$type] $name ($id)';

  int get hashCode => id.hashCode;

  bool operator == (Color other) {
    return id == other.id;
  }

  bool get isMainColor => id == 16;
  bool get isEdgeColor => id == 24;
  bool get isTransparent => color.a < 1.0;

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'attrs': attrs
    };
  }
}

class ColorMap {
  Map<int, Color> colors;
  Map rawData;

  static ColorMap instance = null;

  ColorMap.fromJson(this.rawData, {bool registerGlobal: true}) {
    colors = new HashMap<int, Color>();

    rawData.forEach((k, v) {
      colors[int.parse(k)] = new Color.fromMap(int.parse(k), v);
    });

    if (registerGlobal)
      instance = this;
  }

  Map toJson() => rawData;

  Color get mainColor => query(16);
  Color get edgeColor => query(24);

  Color query(int id) {
    if (id >= 256 && id <= 512) {
      int n1 = ((id - 256) / 16).floor();
      int n2 = (id - 256) % 16;
      Vec4 c1 = colors[n1].color;
      Vec4 c2 = colors[n2].color;

      Vec4 blended = new Vec4.xyz((c1.r + c2.r) * 0.5,
				  (c1.g + c2.g) * 0.5,
				  (c1.b + c2.b) * 0.5);

      return new Color.solid(id, blended, name: 'Blended color');
    } else if ((id & 0xff000000) == 0x04000000) {
      int v = id & 0xfff;

      Vec4 color = new Vec4.xyz(((v & 0xf00) >> 8) / 15.0,
				((v & 0x0f0) >> 4) / 15.0,
				((v & 0x00f)     ) / 15.0);
      Vec4 edge = new Vec4.xyz(((v & 0xf00000) >> 20) / 15.0,
			       ((v & 0x0f0000) >> 16) / 15.0,
			       ((v & 0x00f000) >> 12) / 15.0);

      return new Color.solid(id, color, edge: edge, name: 'MLCad custom color');
    } else if ((id & 0xff000000) == 0x02000000) {
      Vec4 color = new Vec4.xyz(((id & 0xff0000) >> 16) / 255.0,
				((id & 0x00ff00) >>  8) / 255.0,
				((id & 0x0000ff)      ) / 255.0);
      Vec4 edge = new Vec4.xyz(color.r * 0.5, color.g * 0.5, color.b * 0.5);
      
      return new Color.solid(id, color, edge: edge, name: 'Direct color');
    } else {
      if (colors.containsKey(id))
	return colors[id];
      
      // default fallback
      print('could not find color $id');
      return colors[0];
    }
  }
}

