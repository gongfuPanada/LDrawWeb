// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

Map SHADER_MAP = {
  'solid': ['color'],
  'translucent': ['color']
};

class BaseShader {
  Program program;
  Shader vs;
  Shader fs;
  UniformLocation projectionMatrix;
  UniformLocation modelViewMatrix;
  UniformLocation viewMatrix;
  UniformLocation modelMatrix;
  UniformLocation translationFactor;


  BaseShader(String vsText, String fsText) {
    vs = compileShader(VERTEX_SHADER, vsText);
    fs = compileShader(FRAGMENT_SHADER, fsText);

    assert(vs != null && fs != null);

    link();

    projectionMatrix = GL.getUniformLocation(program, 'projection');
    modelViewMatrix = GL.getUniformLocation(program, 'modelView');
    viewMatrix = GL.getUniformLocation(program, 'viewMatrix');
    modelMatrix = GL.getUniformLocation(program, 'modelMatrix');
    translationFactor = GL.getUniformLocation(program, 'translation');
  }

  void use() {
    GL.useProgram(program);
  }

  void link() {
    program = GL.createProgram();
    GL.attachShader(program, vs);
    GL.attachShader(program, fs);
    GL.linkProgram(program);
  }

  Shader compileShader(int type, String shaderText)  {
    Shader shader = GL.createShader(type);
    
    GL.shaderSource(shader, shaderText);
    GL.compileShader(shader);

    if (!GL.getShaderParameter(shader, COMPILE_STATUS)) {
      print('Failed to compile source: ' + GL.getShaderInfoLog(shader));
      return null;
    }

    return shader;
  }

  void unbind();

  static void fromUrl(String vsUrl, String fsUrl,
      void onLoaded(String vsText, String fsText)) {
    Map shaders = {};

    void sendRequest(String url, String output) {
      void check() {
	if (shaders.containsKey('vs') && shaders.containsKey('fs'))
	  onLoaded(shaders['vs'], shaders['fs']);
      }

      HttpRequest.request(url)
	.then((HttpRequest request) {
          if (request.status / 100 >= 4) {
            print('Could not load shader from $url (${request.status})');
          } else {
            shaders[output] = request.responseText;
            check();
          }
        });
    }

    sendRequest(vsUrl, 'vs');
    sendRequest(fsUrl, 'fs');
  }
}

class EdgeShader extends BaseShader {
  int vertexPosition;
  int vertexColor;

  EdgeShader(String vsText, String fsText)
    : super(vsText, fsText) {
    vertexPosition = GL.getAttribLocation(program, 'position');
    vertexColor = GL.getAttribLocation(program, 'color');
  }

  void bind() {
    GL.enableVertexAttribArray(vertexPosition);
    GL.enableVertexAttribArray(vertexColor);
  }

  void unbind() {
    GL.disableVertexAttribArray(vertexPosition);
    GL.disableVertexAttribArray(vertexColor);
  }

  static void fromUrl(String vsUrl, String fsUrl, void onLoaded(EdgeShader s)) {
    BaseShader.fromUrl(vsUrl, fsUrl, (String vsText, String fsText) {
      onLoaded(new EdgeShader(vsText, fsText));
    });
  }
}

class LDrawShader extends BaseShader {
  UniformLocation normalMatrix;
  UniformLocation isBfcCertified;
  int vertexPosition;
  int vertexNormal;
  Map<String, UniformLocation> uniformParameters;

  LDrawShader(String vsText, String fsText, List<String> parameters)
    : super(vsText, fsText) {
    uniformParameters = new Map<String, UniformLocation>();
    for (String s in parameters)
      uniformParameters[s] = GL.getUniformLocation(program, s);
    normalMatrix = GL.getUniformLocation(program, 'normalMatrix');
    isBfcCertified = GL.getUniformLocation(program, 'isBfcCertified');
    
    vertexPosition = GL.getAttribLocation(program, 'position');
    vertexNormal = GL.getAttribLocation(program, 'normal');
  }

  void bind(Color c) {
    Map attrs = c.attrs;

    for (String s in uniformParameters.keys) {
      if (!attrs.containsKey(s))
	continue;
      var attr = attrs[s];
      if (attr is Vec4)
	GL.uniform4fv(uniformParameters[s], attr.val);
      else if (attr is num)
	GL.uniform1f(uniformParameters[s], attr);
    }
    GL.enableVertexAttribArray(vertexPosition);
    GL.enableVertexAttribArray(vertexNormal);
  }

  void unbind() {
    GL.disableVertexAttribArray(vertexPosition);
    GL.disableVertexAttribArray(vertexNormal);
  }

  static void fromUrl(String vsUrl, String fsUrl, List<String> parameters,
      void onLoaded(LDrawShader s)) {
    BaseShader.fromUrl(vsUrl, fsUrl, (String vsText, String fsText) {
      onLoaded(new LDrawShader(vsText, fsText, parameters));
    });
  }
}

class MaterialManager {
  static MaterialManager _instance;
  static MaterialManager get instance {
    if (_instance == null)
      new MaterialManager();
    return _instance;
  }

  BaseShader activeShader;
  Map<String, LDrawShader> shaders;
  EdgeShader edgeShader;

  MaterialManager() {
    _instance = this;

    shaders = new Map<String, LDrawShader>();

    for (String shader in SHADER_MAP.keys) {
      LDrawShader.fromUrl('/s/shaders/$shader.vs', '/s/shaders/$shader.fs',
          SHADER_MAP[shader], (LDrawShader s) {
        shaders[shader] = s;
        print('shader $shader loaded');
      });
    }

    EdgeShader.fromUrl('/s/shaders/edge.vs', '/s/shaders/edge.fs',
        (EdgeShader s) {
      edgeShader = s;
      print('edge shader loaded');
    });
  }

  void bind(Color c) {
    if (activeShader != null)
      activeShader.unbind();

    if (!shaders.containsKey(c.type)) {
      print('Shader for $c could not be found! falling back to default shader...');
      activeShader = shaders['solid'];
    } else {
      activeShader = shaders[c.type];
    }

    activeShader.use();
    (activeShader as LDrawShader).bind(c);
  }

  void bindEdgeShader() {
    activeShader = edgeShader;
    activeShader.use();
    (activeShader as EdgeShader).bind();
  }
}