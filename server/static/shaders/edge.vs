#ifdef GL_ES
precision highp float;
#endif

attribute vec3 position;
attribute vec3 color;

uniform mat4 projection;
uniform mat4 modelView;

varying vec3 vColor;

void main(void) {
     vec4 pos4 = vec4(position, 1.0);
     gl_Position = projection * modelView * pos4;
     vColor = color;
}