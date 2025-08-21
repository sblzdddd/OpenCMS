#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution;
uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;
out vec4 fragColor;

#define filmGrainIntensity 0.1;

mat2 Rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(2127.1, 81.17)), dot(p, vec2(1269.5, 283.37)));
    return fract(sin(p)*43758.5453);
}

float noise(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    vec2 u = f*f*(3.0-2.0*f);

    float n = mix(mix(dot(-1.0+2.0*hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
    dot(-1.0+2.0*hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
    mix(dot(-1.0+2.0*hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
    dot(-1.0+2.0*hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
    return 0.5 + 0.5*n;
}

float filmGrainNoise(in vec2 uv) {
    return length(hash(vec2(uv.x, uv.y)));
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    float aspectRatio = uResolution.x / uResolution.y;
    vec2 tuv = uv - .5;

    float degree = noise(vec2(uTime*.1, tuv.x*tuv.y));

    tuv.y *= 1./aspectRatio;
    tuv *= Rot(radians((degree-.5)*720.+180.));
    tuv.y *= aspectRatio;

    float frequency = 5.;
    float amplitude = 30.;
    float speed = uTime * 2.;
    tuv.x += sin(tuv.y*frequency+speed)/amplitude;
    tuv.y += sin(tuv.x*frequency*1.5+speed)/(amplitude*.5);
    
    vec3 color1 = uColor1;
    vec3 color2 = uColor2;
    vec3 color3 = uColor3;
    vec3 color4 = uColor4;

    // Blend the gradient colors and apply transformations
    vec3 layer1 = mix(color3, color2, smoothstep(-.3, .2, (tuv*Rot(radians(-5.))).x));
    vec3 layer2 = mix(color4, color1, smoothstep(-.3, .2, (tuv*Rot(radians(-5.))).x));
    
    vec3 color = mix(layer1, layer2, smoothstep(.5, -.3, tuv.y));

    // Apply film grain
    color = color - filmGrainNoise(uv) * filmGrainIntensity;
    
    fragColor = vec4(color, 1.0);  
}
