#ifdef GL_ES
precision highp float;
#endif

attribute vec3 normal;
attribute vec3 position;

uniform mat4 projection;
uniform mat4 modelView;
uniform mat3 normalMatrix;
uniform bool isBfcCertified;

varying vec3 vLightWeighting;

vec3 lightDirection = vec3(0.2, -1.5, -0.5);

vec3 ambient = vec3(0.2, 0.2, 0.2);
vec3 diffuse = vec3(0.7, 0.7, 0.7);

void main(void) {
     vec4 pos4 = vec4(position, 1.0);
     gl_Position = projection * modelView * pos4;
     vec3 transformedNormal = normalize(normalMatrix * normal);

     float directionalWeighting;
     if (isBfcCertified)
     	directionalWeighting = max(dot(transformedNormal, lightDirection), 0.0);
     else
	directionalWeighting = 1.0;

     vLightWeighting = ambient + diffuse * directionalWeighting;
}
