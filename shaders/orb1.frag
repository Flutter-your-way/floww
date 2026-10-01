#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// Faithful port of the WebGL orb in floww_orb_preview.html.
// The maths is the preview's, line for line; only the hard-coded lime colours
// became uniforms so Flow / Steady / Restore can share one shader.
// With OrbPalette.flow the output equals the preview.
//
// ---- uniforms: set with setFloat() in exactly this order ----
uniform vec2  uSize;      // 0,1   widget size (square box = the preview's 500 px canvas)
uniform float uTime;      // 2     t, seconds
uniform float uAppear;    // 3     appear 0..1 (intro grow-in)
uniform float uEnergy;    // 4     energy ~0.8..1.45
uniform float uSpeak;     // 5     speak 0..1
uniform float uFlash;     // 6     flash 0..1.4
uniform vec3  uDark;      // 7-9
uniform vec3  uMid;       // 10-12
uniform vec3  uHi;        // 13-15
uniform vec3  uWhite;     // 16-18
uniform vec3  uSheen;     // 19-21  specular tint
uniform vec3  uHalo;      // 22-24  outer glow
uniform vec3  uFlashCol;  // 25-27

out vec4 fragColor;

float h(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float n(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(h(i), h(i + vec2(1, 0)), f.x),
               mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * n(p);
        p = p * 2.03 + vec2(1.7, 9.2);
        a *= 0.5;
    }
    return v;
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

void main() {
    float t = uTime;

    // preview uv: -1..1, y up
    vec2 fc = FlutterFragCoord().xy;
    vec2 uv = vec2(fc.x / uSize.x * 2.0 - 1.0, 1.0 - fc.y / uSize.y * 2.0);

    vec2 p = uv * 1.5;                       // canvas spans 3x orb radius
    float R = 0.52 * (0.25 + 0.75 * uAppear)
            * (1.0 + 0.035 * sin(t * 2.1) + 0.05 * uSpeak * sin(t * 9.0) * sin(t * 3.7));
    float d = length(p);

    // sphere surface coordinates
    float r = d / R;
    float z = sqrt(max(0.0, 1.0 - r * r));
    vec3 N = vec3(p / R, z);

    // swirling liquid inside
    vec2 q = N.xy * rot(t * 0.35) * 1.6;
    vec2 w = vec2(fbm(q + vec2(t * 0.25, 0.0)), fbm(q + vec2(3.1, t * 0.2)));
    float f = fbm(q * 1.3 + w * 2.2 + vec2(0.0, -t * 0.3));

    // darker hollow swirling around the core
    vec2 c2 = vec2(-0.18, 0.08) * rot(t * 0.6);
    float hole = smoothstep(0.75, 0.0, length(N.xy - c2) + 0.3 * (f - 0.5));
    vec2 b1 = vec2(0.35, -0.45) * rot(t * 0.8);
    vec2 b2 = vec2(-0.4, 0.35) * rot(-t * 0.55);
    float blobs = exp(-dot(N.xy - b1, N.xy - b1) * 5.0)
                + 0.7 * exp(-dot(N.xy - b2, N.xy - b2) * 6.0);
    float body = 0.12 + 0.75 * f + 0.55 * blobs;
    body *= 1.0 - 0.85 * hole * (1.0 - 0.35 * uSpeak);

    float fres = pow(1.0 - z, 2.2);
    float bottom = smoothstep(-0.2, -0.9, N.y);

    float lum = clamp(body * 0.8 + fres * 1.1 + bottom * 0.3, 0.0, 1.6);
    vec3 col = mix(uDark, uMid, smoothstep(0.0, 0.6, lum));
    col = mix(col, uHi, smoothstep(0.55, 1.05, lum));
    col = mix(col, uWhite, smoothstep(1.05, 1.5, lum) * 0.8);

    // specular top-left sheen
    col += uSheen * pow(max(0.0, dot(N, normalize(vec3(-0.5, 0.6, 0.6)))), 18.0) * 0.35;
    col *= uEnergy;
    float inside = smoothstep(1.02, 0.82, r);

    // outer glow halo
    float glw = exp(-max(d - R, 0.0) * (6.0 - 2.0 * uSpeak)) * 0.55
              + exp(-max(d - R, 0.0) * 18.0) * 0.35;
    vec3 halo = uHalo * glw * uEnergy * (0.8 + 0.25 * sin(t * 2.1));
    vec3 outc = mix(halo, col, inside);
    outc += uFlashCol * uFlash * exp(-d * 3.0);
    outc *= uAppear;

    // The preview writes an opaque colour to an 8-bit canvas (clamped) and
    // CSS-screens it onto the page, so black means "nothing". Flutter has no
    // per-channel alpha, so emit it premultiplied with alpha = max channel:
    // identical where the orb is bright, black becomes fully transparent,
    // and no square can ever show. The corner-to-corner falloff also reaches
    // zero before the box edge.
    outc = clamp(outc, 0.0, 1.0);
    float a = max(max(outc.r, outc.g), outc.b);
    fragColor = vec4(outc, a);
}
