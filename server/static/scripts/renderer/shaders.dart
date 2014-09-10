// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of renderer;

Map SHADER_MAP = {
  'solid': ['color'],
  'translucent': ['color']
};

class BaseShader {
  GlobalUniformValues uniformValues;
  Program program;
  Shader vs;
  Shader fs;
  UniformLocation uProjectionMatrix;
  UniformLocation uModelViewMatrix;
  UniformLocation uViewMatrix;
  UniformLocation uModelMatrix;
  UniformLocation uTranslationFactor;
  RenderingContext gl;

  BaseShader(Renderer context, String vsText, String fsText) {
    gl = context.gl;
    vs = compileShader(VERTEX_SHADER, vsText);
    fs = compileShader(FRAGMENT_SHADER, fsText);
    uniformValues = context.uniformValues;

    assert(vs != null && fs != null);

    link();

    uProjectionMatrix = gl.getUniformLocation(program, 'projection');
    uModelViewMatrix = gl.getUniformLocation(program, 'modelView');
    uViewMatrix = gl.getUniformLocation(program, 'viewMatrix');
    uModelMatrix = gl.getUniformLocation(program, 'modelMatrix');
    uTranslationFactor = gl.getUniformLocation(program, 'translation');
  }

  void use() {
    gl.useProgram(program);
  }

  void link() {
    program = gl.createProgram();
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
  }

  Shader compileShader(int type, String shaderText)  {
    Shader shader = gl.createShader(type);
    
    gl.shaderSource(shader, shaderText);
    gl.compileShader(shader);

    if (!gl.getShaderParameter(shader, COMPILE_STATUS)) {
      print('Failed to compile source: ' + gl.getShaderInfoLog(shader));
      return null;
    }

    return shader;
  }

  void bindCommonUniforms() {
    GlobalUniformValues g = uniformValues;

    gl.uniformMatrix4fv(uProjectionMatrix, false, g.projectionMatrix.val);
    gl.uniformMatrix4fv(uModelViewMatrix, false, g.modelViewMatrix.val);
    gl.uniformMatrix4fv(uModelMatrix, false, g.modelMatrix.val);
    gl.uniformMatrix4fv(uViewMatrix, false, g.viewMatrix.val);
  }

  void unbind() {}

  static void fromUrl(RenderingContext gl, String vsUrl, String fsUrl,
      void onLoaded(RenderingContext gl, String vsText, String fsText)) {
    Map shaders = {};

    void sendRequest(String url, String output) {
      void check() {
	if (shaders.containsKey('vs') && shaders.containsKey('fs'))
	  onLoaded(gl, shaders['vs'], shaders['fs']);
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

  EdgeShader(Renderer context, String vsText, String fsText)
    : super(context, vsText, fsText) {
    vertexPosition = gl.getAttribLocation(program, 'position');
    vertexColor = gl.getAttribLocation(program, 'color');
  }

  void bind() {
    gl.enableVertexAttribArray(vertexPosition);
    gl.enableVertexAttribArray(vertexColor);
  }

  void unbind() {
    gl.disableVertexAttribArray(vertexPosition);
    gl.disableVertexAttribArray(vertexColor);
  }

  static void fromUrl(Renderer context, String vsUrl, String fsUrl, void onLoaded(EdgeShader s)) {
    BaseShader.fromUrl(context, vsUrl, fsUrl, (Renderer context, String vsText, String fsText) {
      onLoaded(new EdgeShader(context, vsText, fsText));
    });
  }
}

class LDrawShader extends BaseShader {
  UniformLocation normalMatrix;
  UniformLocation isBfcCertified;
  int vertexPosition;
  int vertexNormal;
  Map<String, UniformLocation> uniformParameters;

  LDrawShader(Renderer context, String vsText, String fsText, List<String> parameters)
    : super(context, vsText, fsText) {
    uniformParameters = new Map<String, UniformLocation>();
    for (String s in parameters)
      uniformParameters[s] = gl.getUniformLocation(program, s);
    normalMatrix = gl.getUniformLocation(program, 'normalMatrix');
    isBfcCertified = gl.getUniformLocation(program, 'isBfcCertified');
    
    vertexPosition = gl.getAttribLocation(program, 'position');
    vertexNormal = gl.getAttribLocation(program, 'normal');
  }

  void bind(Color c) {
    Map attrs = c.attrs;

    for (String s in uniformParameters.keys) {
      if (!attrs.containsKey(s))
	continue;
      var attr = attrs[s];
      if (attr is Vec4)
	gl.uniform4fv(uniformParameters[s], attr.val);
      else if (attr is num)
	gl.uniform1f(uniformParameters[s], attr);
    }
    gl.enableVertexAttribArray(vertexPosition);
    gl.enableVertexAttribArray(vertexNormal);
  }

  void unbind() {
    gl.disableVertexAttribArray(vertexPosition);
    gl.disableVertexAttribArray(vertexNormal);
  }

  static void fromUrl(Renderer context, String vsUrl, String fsUrl, List<String> parameters,
      void onLoaded(LDrawShader s)) {
    BaseShader.fromUrl(context, vsUrl, fsUrl, (Renderer context, String vsText, String fsText) {
      onLoaded(new LDrawShader(context, vsText, fsText, parameters));
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

  Renderer context;
  BaseShader activeShader;
  Map<String, LDrawShader> shaders;
  EdgeShader edgeShader;

  MaterialManager(Renderer renderer) {
    _instance = this;

    context = renderer;
    shaders = new Map<String, LDrawShader>();

    for (String shader in SHADER_MAP.keys) {
      LDrawShader.fromUrl(context, '/s/shaders/$shader.vs', '/s/shaders/$shader.fs',
          SHADER_MAP[shader], (LDrawShader s) {
        shaders[shader] = s;
        print('shader $shader loaded');
      });
    }

    EdgeShader.fromUrl(context, '/s/shaders/edge.vs', '/s/shaders/edge.fs',
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