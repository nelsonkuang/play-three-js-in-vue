// #extension GL_EXT_shader_texture_lod : enable
precision highp float;
precision highp int;

// Rendering parameters
#define RAY_LENGTH_MAX		20.0
#define RAY_BOUNCE_MAX		10
#define RAY_STEP_MAX		40
#define COLOR				vec3 (0.8, 0.8, 0.9)
#define ALPHA				0.9
#define REFRACT_INDEX		vec3 (2.407, 2.426, 2.451)
#define LIGHT				vec3 (1.0, 1.0, -1.0)
#define AMBIENT				0.2
#define SPECULAR_POWER		3.0
#define SPECULAR_INTENSITY	0.5

// Math constants
#define DELTA	0.001
#define PI		3.14159265359

uniform mat4 viewMatrix;
uniform vec3 cameraPosition;
uniform float toneMappingExposure;
uniform float toneMappingWhitePoint;

#define GLSLIFY 1
varying vec2 vUv;
varying vec3 Normal;
varying vec3 worldNormal;
varying vec3 vecPos;
varying vec3 viewPos;
uniform samplerCube tCubeMapNormals;
uniform samplerCube envMap;
uniform samplerCube envRefractionMap;
uniform float envMapIntensity;
uniform float tanAngleSqCone;
uniform float coneHeight;
uniform int maxBounces;
uniform mat4 modelMatrix;
uniform mat4 InverseModelMatrix;
uniform float n2;
uniform float radius;
uniform bool bDebugBounces;
uniform float rIndexDelta;
uniform float normalOffset;
uniform float squashFactor;
uniform float distanceOffset;
uniform float geometryFactor;
uniform vec3 Absorbption;
uniform vec3 colorCorrection;
uniform vec3 boostFactors;
uniform vec3 centreOffset;
uniform float opacity;
uniform float i_toneMappingExposure;
uniform float i_toneMappingWhitePoint;
uniform float colorRGBIntencity;
uniform sampler2D sphereMap;

uniform vec2 iResolution;
uniform vec3 iMouse;

// Rotation matrix
mat3 mRotate (in vec3 angle) {
	float c = cos (angle.x);
	float s = sin (angle.x);
	mat3 rx = mat3 (1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c);

	c = cos (angle.y);
	s = sin (angle.y);
	mat3 ry = mat3 (c, 0.0, -s, 0.0, 1.0, 0.0, s, 0.0, c);

	c = cos (angle.z);
	s = sin (angle.z);
	mat3 rz = mat3 (c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0);

	return rz * ry * rx;
}

// Rotation matrix (rotation on the Y axis)
vec3 vRotateY (in vec3 p, in float angle) {
	float c = cos (angle);
	float s = sin (angle);
	return vec3 (c * p.x - s * p.z, p.y, c * p.z + s * p.x);
}

// Distance to the scene
vec3 normalTopA = normalize (vec3 (0.0, 1.0, 1.4));
vec3 normalTopB = normalize (vec3 (0.0, 1.0, 1.0));
vec3 normalTopC = normalize (vec3 (0.0, 1.0, 0.5));
vec3 normalBottomA = normalize (vec3 (0.0, -1.0, 1.0));
vec3 normalBottomB = normalize (vec3 (0.0, -1.0, 1.6));
float getDistance (in vec3 p) {
	float topCut = p.y - 1.0;
	float angleStep = PI / (iMouse.z < 0.5 ? 8.0 : 2.0 + floor (18.0 * iMouse.x / iResolution.x));
	float angle = angleStep * (0.5 + floor (atan (p.x, p.z) / angleStep));
	vec3 q = vRotateY (p, angle);
	float topA = dot (q, normalTopA) - 2.0;
	float topC = dot (q, normalTopC) - 1.5;
	float bottomA = dot (q, normalBottomA) - 1.7;
	q = vRotateY (p, -angleStep * 0.5);
	angle = angleStep * floor (atan (q.x, q.z) / angleStep);
	q = vRotateY (p, angle);
	float topB = dot (q, normalTopB) - 1.85;
	float bottomB = dot (q, normalBottomB) - 1.9;

	return max (topCut, max (topA, max (topB, max (topC, max (bottomA, bottomB)))));
}

// Normal at a given point
vec3 getNormal (in vec3 p) {
	const vec2 h = vec2 (DELTA, -DELTA);
	return normalize (
		h.xxx * getDistance (p + h.xxx) +
		h.xyy * getDistance (p + h.xyy) +
		h.yxy * getDistance (p + h.yxy) +
		h.yyx * getDistance (p + h.yyx)
	);
}

// Cast a ray for a given color channel (and its corresponding refraction index)
vec3 lightDirection = normalize (LIGHT);
float raycast (in vec3 origin, in vec3 direction, in vec4 normal, in float color, in vec3 channel) {

	// The ray continues...
	color *= 1.0 - ALPHA;
	float intensity = ALPHA;
	float distanceFactor = 1.0;
	float refractIndex = dot (REFRACT_INDEX, channel);
	for (int rayBounce = 1; rayBounce < RAY_BOUNCE_MAX; ++rayBounce) {

		// Interface with the material
		vec3 refraction = refract (direction, normal.xyz, distanceFactor > 0.0 ? 1.0 / refractIndex : refractIndex);
		if (dot (refraction, refraction) < DELTA) {
			direction = reflect (direction, normal.xyz);
			origin += direction * DELTA * 2.0;
		} else {
			direction = refraction;
			distanceFactor = -distanceFactor;
		}

		// Ray marching
		float dist = RAY_LENGTH_MAX;
		for (int rayStep = 0; rayStep < RAY_STEP_MAX; ++rayStep) {
			dist = distanceFactor * getDistance (origin);
			float distMin = max (dist, DELTA);
			normal.w += distMin;
			if (dist < 0.0 || normal.w > RAY_LENGTH_MAX) {
				break;
			}
			origin += direction * distMin;
		}

		// Check whether we hit something
		if (dist >= 0.0) {
			break;
		}

		// Get the normal
		normal.xyz = distanceFactor * getNormal (origin);

		// Basic lighting
		if (distanceFactor > 0.0) {
			float relfectionDiffuse = max (0.0, dot (normal.xyz, lightDirection));
			float relfectionSpecular = pow (max (0.0, dot (reflect (direction, normal.xyz), lightDirection)), SPECULAR_POWER) * SPECULAR_INTENSITY;
			float localColor = (AMBIENT + relfectionDiffuse) * dot (COLOR, channel) + relfectionSpecular;
			color += localColor * (1.0 - ALPHA) * intensity;
			intensity *= ALPHA;
		}
	}

	// Get the background color
	float backColor = dot (textureCube(tCubeMapNormals, direction).rgb, channel);

	// Return the intensity of this color channel
	return color + backColor * intensity;
}


void main() {
    // Get the normal
    vec3 normal = normalize(worldNormal);
    vec3 origin = vecPos;
    vec3 direction = normalize(vecPos - cameraPosition);

    // Basic lighting
    float relfectionDiffuse = max (0.0, dot (normal.xyz, lightDirection));
    float relfectionSpecular = pow (max (0.0, dot (reflect (direction, normal.xyz), lightDirection)), SPECULAR_POWER) * SPECULAR_INTENSITY;
    vec4 fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    fragColor.rgb = (AMBIENT + relfectionDiffuse) * COLOR + relfectionSpecular;

    // Cast a ray for each color channel
    vec4 v4Normal = vec4(normal.xyz, 0.0);
    fragColor.r = raycast (origin, direction, v4Normal, fragColor.r, vec3 (1.0, 0.0, 0.0));
    fragColor.g = raycast (origin, direction, v4Normal, fragColor.g, vec3 (0.0, 1.0, 0.0));
    fragColor.b = raycast (origin, direction, v4Normal, fragColor.b, vec3 (0.0, 0.0, 1.0));
    gl_FragColor = fragColor;
}