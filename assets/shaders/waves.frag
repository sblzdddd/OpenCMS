#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution;
uniform float uTime;
uniform vec3 uColor;
out vec4 fragColor;

float uAmp = 0.1;         // distortion amplitude
float uFreq = 1.0;        // frequency multiplier
float uSpeed = 0.3;       // time speed
float uColorSpread = 0.7; // RGB separation strength

void main()
{
    vec2 uv = (2.0 * FlutterFragCoord().xy - uResolution.xy) 
              / min(uResolution.x, uResolution.y);

    float t = uTime * uSpeed;

    for (float i = 1.0; i < 8.0; i++)
    {
        float fi = i * i * uFreq;
        uv.y += uAmp *
            sin(uv.x * fi + t) *
            sin(uv.y * fi + t);
    }

    vec3 col = uColor - vec3(.1) + uColorSpread * uv.y;

    fragColor = vec4(col, 1.0);
}
