precision highp float;

uniform mat4 modelView;
uniform mat4 projection;
uniform mat3 normalMatrix;
uniform float translation;

attribute vec3 position;
attribute vec3 normal;

varying vec3 vViewPosition;
varying vec3 vNormal;

const mat4 modelMatrix = mat4(1.0);

void main() {
    vec3 objectNormal = normal;

    vec3 transformedNormal = normalMatrix * normal;
    vNormal = normalize( transformedNormal );

    vec4 adjustedPosition = vec4(position, 1.0) + (vec4(0.0, -1.0, 0.0, 1.0) * 1000.0 * translation);
    vec4 mvPosition = modelView * adjustedPosition;

    gl_Position = projection * mvPosition;
    vViewPosition = -mvPosition.xyz;

    vec4 worldPosition = modelMatrix * vec4( position, 1.0 );
}

/*#ifdef GL_ES
precision highp float;
#endif

attribute vec3 normal;
attribute vec3 position;

uniform mat4 projection;
uniform mat4 modelView;
uniform float translation;
uniform mat3 normalMatrix;
uniform bool isBfcCertified;

varying vec3 vLightWeighting;

vec3 lightDirection = vec3(0.2, -1.5, -0.5);

vec3 ambient = vec3(0.2, 0.2, 0.2);
vec3 diffuse = vec3(0.7, 0.7, 0.7);

void main(void) {
     vec4 pos4 = vec4(position, 1.0) + (vec4(0.0, -1.0, 0.0, 1.0) * 1000.0 * translation);
     gl_Position = projection * modelView * pos4;
     vec3 transformedNormal = normalize(normalMatrix * normal);

     float directionalWeighting;
     if (isBfcCertified)
     	directionalWeighting = max(dot(transformedNormal, lightDirection), 0.0);
     else
	directionalWeighting = 1.0;

     vLightWeighting = ambient + diffuse * directionalWeighting;
}*/
