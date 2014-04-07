precision highp float;

#define MAX_DIR_LIGHTS 1
#define MAX_POINT_LIGHTS 0
#define MAX_SPOT_LIGHTS 0
#define MAX_HEMI_LIGHTS 0
#define MAX_SHADOWS 0

#define PHONG_PER_PIXEL

uniform mat4 viewMatrix;
uniform vec4 color;
uniform bool isBfcCertified;

vec3 diffuse;
float opacity;

const vec3 ambient = vec3(1.0, 1.0, 1.0);
const vec3 emissive = vec3(0.0, 0.0, 0.0);
const float shininess = 100.0;

const vec3 ambientLightColor = vec3(0.133, 0.133, 0.133);


#if MAX_DIR_LIGHTS > 0
    const vec3 directionalLightColor = vec3(1.0, 1.0, 1.0);
    const vec3 directionalLightDirection = normalize(vec3(0.3, -1.0, -1.0));
    //uniform vec3 directionalLightColor[ MAX_DIR_LIGHTS ];
    //uniform vec3 directionalLightDirection[ MAX_DIR_LIGHTS ];
#endif

#if MAX_HEMI_LIGHTS > 0
    uniform vec3 hemisphereLightSkyColor[ MAX_HEMI_LIGHTS ];
    uniform vec3 hemisphereLightGroundColor[ MAX_HEMI_LIGHTS ];
    uniform vec3 hemisphereLightDirection[ MAX_HEMI_LIGHTS ];
#endif

#if MAX_POINT_LIGHTS > 0
    uniform vec3 pointLightColor[ MAX_POINT_LIGHTS ];
    #ifdef PHONG_PER_PIXEL
        uniform vec3 pointLightPosition[ MAX_POINT_LIGHTS ];
        uniform float pointLightDistance[ MAX_POINT_LIGHTS ];
    #else
        varying vec4 vPointLight[ MAX_POINT_LIGHTS ];
    #endif
#endif

varying vec3 vViewPosition;
varying vec3 vNormal;

void main() {
    if (!isBfcCertified) {
        gl_FragColor = color;
        return;
    }

    diffuse = color.xyz;
    opacity = color.w;

    gl_FragColor = vec4( vec3 ( 1.0 ), opacity );
    
    float specularStrength;

    specularStrength = 1.0;

    vec3 normal = normalize( vNormal );
    vec3 viewPosition = normalize( vViewPosition );

    #if MAX_POINT_LIGHTS > 0
        vec3 pointDiffuse = vec3( 0.0 );
        vec3 pointSpecular = vec3( 0.0 );
        for ( int i = 0; i < MAX_POINT_LIGHTS; i ++ ) {
            #ifdef PHONG_PER_PIXEL
                vec4 lPosition = viewMatrix * vec4( pointLightPosition[ i ], 1.0 );
                vec3 lVector = lPosition.xyz + vViewPosition.xyz;
                float lDistance = 1.0;
                if ( pointLightDistance[ i ] > 0.0 )
                    lDistance = 1.0 - min( ( length( lVector ) / pointLightDistance[ i ] ), 1.0 );
                lVector = normalize( lVector );
            #else
                vec3 lVector = normalize( vPointLight[ i ].xyz );
                float lDistance = vPointLight[ i ].w;
            #endif

            float dotProduct = dot( normal, lVector );
            float pointDiffuseWeight = max( dotProduct, 0.0 );

            pointDiffuse  += diffuse * pointLightColor[ i ] * pointDiffuseWeight * lDistance;
            vec3 pointHalfVector = normalize( lVector + viewPosition );
            float pointDotNormalHalf = max( dot( normal, pointHalfVector ), 0.0 );
            float pointSpecularWeight = specularStrength * max( pow( pointDotNormalHalf, shininess ), 0.0 );

            #ifdef PHYSICALLY_BASED_SHADING
                float specularNormalization = ( shininess + 2.0001 ) / 8.0;
                vec3 schlick = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVector, pointHalfVector ), 5.0 );
                pointSpecular += schlick * pointLightColor[ i ] * pointSpecularWeight * pointDiffuseWeight * lDistance * specularNormalization;
            #else
                pointSpecular += specular * pointLightColor[ i ] * pointSpecularWeight * pointDiffuseWeight * lDistance;
            #endif
        }
    #endif

    #if MAX_DIR_LIGHTS > 0
        vec3 dirDiffuse  = vec3( 0.0 );
        vec3 dirSpecular = vec3( 0.0 );
        for( int i = 0; i < MAX_DIR_LIGHTS; i ++ ) {
            vec4 lDirection = viewMatrix * vec4( directionalLightDirection[ i ], 0.0 );
            vec3 dirVector = normalize( lDirection.xyz );
            float dotProduct = dot( normal, dirVector );
            float dirDiffuseWeight = max( dotProduct, 0.0 );

            dirDiffuse  += diffuse * directionalLightColor[ i ] * dirDiffuseWeight;
            vec3 dirHalfVector = normalize( dirVector + viewPosition );
            float dirDotNormalHalf = max( dot( normal, dirHalfVector ), 0.0 );
            float dirSpecularWeight = specularStrength * max( pow( dirDotNormalHalf, shininess ), 0.0 );

            #ifdef PHYSICALLY_BASED_SHADING
                float specularNormalization = ( shininess + 2.0001 ) / 8.0;
                vec3 schlick = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( dirVector, dirHalfVector ), 5.0 );
                dirSpecular += schlick * directionalLightColor[ i ] * dirSpecularWeight * dirDiffuseWeight * specularNormalization;
            #else
                dirSpecular += specular * directionalLightColor[ i ] * dirSpecularWeight * dirDiffuseWeight;
            #endif

        }
    #endif

    #if MAX_HEMI_LIGHTS > 0
        vec3 hemiDiffuse  = vec3( 0.0 );
        vec3 hemiSpecular = vec3( 0.0 );
        for( int i = 0; i < MAX_HEMI_LIGHTS; i ++ ) {
            vec4 lDirection = viewMatrix * vec4( hemisphereLightDirection[ i ], 0.0 );
            vec3 lVector = normalize( lDirection.xyz );
            float dotProduct = dot( normal, lVector );
            float hemiDiffuseWeight = 0.5 * dotProduct + 0.5;
            vec3 hemiColor = mix( hemisphereLightGroundColor[ i ], hemisphereLightSkyColor[ i ], hemiDiffuseWeight );
            hemiDiffuse += diffuse * hemiColor;
            vec3 hemiHalfVectorSky = normalize( lVector + viewPosition );
            float hemiDotNormalHalfSky = 0.5 * dot( normal, hemiHalfVectorSky ) + 0.5;
            float hemiSpecularWeightSky = specularStrength * max( pow( hemiDotNormalHalfSky, shininess ), 0.0 );
            vec3 lVectorGround = -lVector;
            vec3 hemiHalfVectorGround = normalize( lVectorGround + viewPosition );
            float hemiDotNormalHalfGround = 0.5 * dot( normal, hemiHalfVectorGround ) + 0.5;
            float hemiSpecularWeightGround = specularStrength * max( pow( hemiDotNormalHalfGround, shininess ), 0.0 );

            #ifdef PHYSICALLY_BASED_SHADING
                float dotProductGround = dot( normal, lVectorGround );
                float specularNormalization = ( shininess + 2.0001 ) / 8.0;
                vec3 schlickSky = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVector, hemiHalfVectorSky ), 5.0 );
                vec3 schlickGround = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVectorGround, hemiHalfVectorGround ), 5.0 );
                hemiSpecular += hemiColor * specularNormalization * ( schlickSky * hemiSpecularWeightSky * max( dotProduct, 0.0 ) + schlickGround * hemiSpecularWeightGround * max( dotProductGround, 0.0 ) );
            #else
                hemiSpecular += specular * hemiColor * ( hemiSpecularWeightSky + hemiSpecularWeightGround ) * hemiDiffuseWeight;
            #endif
        }
    #endif

    vec3 totalDiffuse = vec3( 0.0 );
    vec3 totalSpecular = vec3( 0.0 );

    #if MAX_DIR_LIGHTS > 0
        totalDiffuse += dirDiffuse;
        totalSpecular += dirSpecular;
    #endif

    #if MAX_HEMI_LIGHTS > 0
        totalDiffuse += hemiDiffuse;
        totalSpecular += hemiSpecular;
    #endif

    #if MAX_POINT_LIGHTS > 0
        totalDiffuse += pointDiffuse;
        totalSpecular += pointSpecular;
    #endif

    #ifdef METAL
        gl_FragColor.xyz = gl_FragColor.xyz * ( emissive + totalDiffuse + ambientLightColor * ambient + totalSpecular );
    #else
        gl_FragColor.xyz = gl_FragColor.xyz * ( emissive + totalDiffuse + ambientLightColor * ambient ) + totalSpecular;
    #endif
}