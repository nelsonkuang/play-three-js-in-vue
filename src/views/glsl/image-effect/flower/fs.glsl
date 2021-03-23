precision mediump float;
uniform sampler2D s_baseMap;
varying vec2 v_texCoord;
uniform float time;

#define STARFIELD_LAYERS_COUNT 12.0

float PI = 3.1415;
float MIN_DIVIDE = 64.0;
float MAX_DIVIDE = 0.01;

mat2 Rotate(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

float Star(vec2 uv, float flaresize, float rotAngle, float randomN) {
    float d = length(uv);

    float starcore = 0.05/d;
    uv *= Rotate(-2.0 * PI * rotAngle);
    float flareMax = 1.0;

    float starflares = max(0.0, flareMax - abs(uv.x * uv.y * 3000.0));
    starcore += starflares * flaresize;
    uv *= Rotate(PI * 0.25);

    starflares = max(0.0, flareMax - abs(uv.x * uv.y * 3000.0));
    starcore += starflares * 0.3 * flaresize;
    starcore *= smoothstep(1.0, 0.05, d);

    return starcore;
}

float PseudoRandomizer(vec2 p) {
    p = fract(p*vec2(123.45, 345.67));
    p += dot(p, p+45.32);

    return (fract(p.x * p.y));
}

vec3 StarFieldLayer(vec2 uv, float rotAngle) {
    vec3 col = vec3(0);
    vec2 gv = fract(uv) -0.5;
    vec2 id = floor(uv);

    float deltaTimeTwinkle = time * 0.35;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(x, y);

            float randomN = PseudoRandomizer(id + offset);
            float randoX = randomN - 0.5;
            float randoY = fract(randomN * 45.0) - 0.5;
            vec2 randomPosition = gv - offset - vec2(randoX, randoY);

            float size = fract(randomN * 1356.33);
            float flareSwitch = smoothstep(0.9, 1.0, size);

            float star = Star(randomPosition, flareSwitch, rotAngle, randomN);

            float randomStarColorSeed = fract(randomN * 2150.0) * (3.0 * PI) * deltaTimeTwinkle;
            vec3 color = sin(vec3(0.7, 0.3, 0.9) * randomStarColorSeed);

            color = color * (0.4 * sin(deltaTimeTwinkle)) + 0.6;

            color = color * vec3(1, 0.1,  0.9 + size);
            float dimByDensity = 15.0/STARFIELD_LAYERS_COUNT;
            col += star * size * color * dimByDensity;
         }
    }
    return col;
}

void main() {
    gl_FragColor = texture2D(s_baseMap, v_texCoord);

    float deltaTime = time * 0.0001;
    vec3 col = vec3(0.0);
    float rotAngle = deltaTime * 0.09;

    vec2 uv = v_texCoord;

    for (float i=0.0; i < 1.0; i += (1.0/STARFIELD_LAYERS_COUNT)) {
        float layerDepth = fract(i + deltaTime);
        float layerScale = mix(MIN_DIVIDE,MAX_DIVIDE,layerDepth);
        float layerFader = layerDepth * smoothstep(0.1, 1.1, layerDepth);
        float layerOffset = i * (3430.00 + fract(i));
        mat2 layerRot = Rotate(rotAngle * i * -10.0);
        uv *= layerRot;
        vec2 starfieldUv = uv * layerScale + layerOffset;
        col += StarFieldLayer(starfieldUv, rotAngle) * layerFader;
    }

    gl_FragColor += vec4(col, 1.0);
}