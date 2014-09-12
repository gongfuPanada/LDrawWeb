precision highp float;

uniform mat4 modelView;
uniform mat4 projection;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat3 normalMatrix;
uniform float translation;

attribute vec3 position;
attribute vec3 normal;

varying vec3 vViewPosition;
varying vec3 vNormal;

void main() {
    vec3 objectNormal = normal;

    vec3 transformedNormal = normalMatrix * objectNormal;
    vNormal = normalize( transformedNormal );

    vec4 adjustedPosition = vec4(position, 1.0) + (vec4(0.0, -1.0, 0.0, 1.0) * 1000.0 * translation);
    vec4 mvPosition = modelView * adjustedPosition;

    gl_Position = projection * mvPosition;
    vViewPosition = -mvPosition.xyz;
}
