#ifdef GL_ES
precision highp float;
#endif

attribute vec3 position;
attribute vec3 color;

uniform mat4 projection;
uniform mat4 modelView;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform float translation;

/* not used */
uniform vec4 lightColor;
uniform vec4 lightDirection;

varying vec4 vColor;

void main(void) {
     vec4 pos4 = vec4(position, 1.0);
     pos4.y -= (translation * translation) * 500.0;
     gl_Position = projection * modelView * pos4;
     vColor = color;
     vColor.w = 1.0 - translation;
}
