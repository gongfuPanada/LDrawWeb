#ifdef GL_ES
precision highp float;
#endif

uniform vec4 color;

varying vec3 vLightWeighting;

void main(void) {
     gl_FragColor = vec4(color.rgb * vLightWeighting, color.a);
}
