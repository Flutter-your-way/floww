#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec4  uTexRect;
uniform vec4  uBar;
uniform float uBarRadius;
uniform float uBarScale;
uniform vec4  uLens;
uniform float uLensRadius;
uniform float uGlass;
uniform float uItemZoom;
uniform float uRefraction;
uniform float uProfileScale;
uniform float uDispersion;
uniform vec4  uBarColor;
uniform vec4  uPillColor;
uniform vec4  uGlassTint;
uniform vec4  uRim;
uniform float uIridescence;
uniform vec2  uTexPx;
uniform vec4  uBarRim;
uniform vec4  uItems;
uniform float uBlur;
uniform sampler2D uContent;

out vec4 fragColor;

const vec2  LIGHT = vec2(-0.5523, -0.8336);

float sdRoundBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + vec2(r);
  return min(max(q.x, q.y), 0.0) + length(max(q, vec2(0.0))) - r;
}

vec2 roundBoxNormal(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + vec2(r);
  vec2 g;
  if (q.x > 0.0 && q.y > 0.0) {
    g = normalize(q);
  } else if (q.x > q.y) {
    g = vec2(1.0, 0.0);
  } else {
    g = vec2(0.0, 1.0);
  }
  vec2 s = vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
  return g * s;
}

vec4 sampleContent(vec2 uv) {
  vec2 px  = uv * uTexPx - 0.5;
  vec2 f   = fract(px);
  vec2 i0  = floor(px);
  vec2 inv = 1.0 / uTexPx;
  vec4 a = texture(uContent, (i0 + vec2(0.5, 0.5)) * inv);
  vec4 b = texture(uContent, (i0 + vec2(1.5, 0.5)) * inv);
  vec4 c = texture(uContent, (i0 + vec2(0.5, 1.5)) * inv);
  vec4 d = texture(uContent, (i0 + vec2(1.5, 1.5)) * inv);
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec4 scene(vec2 q, vec4 fill) {
  float dB = sdRoundBox(q - uBar.xy, uBar.zw, uBarRadius);
  float barA = clamp(0.5 - dB, 0.0, 1.0);
  vec4 bar = uBarColor * barA;

  vec2  nb = roundBoxNormal(q - uBar.xy, uBar.zw, uBarRadius);
  float sb = pow(abs(dot(nb, LIGHT)), 1.5);
  float rimFall = pow(clamp(1.0 - (-dB) / 1.1, 0.0, 1.0), 0.7);
  float ra = clamp(uBarRim.a * rimFall * barA * (0.2 + 0.8 * sb), 0.0, 1.0);
  bar = vec4(uBarRim.rgb * ra, ra) + bar * (1.0 - ra);

  vec4 under = fill + bar * (1.0 - fill.a);

  vec2  c    = uBar.xy + (q - uBar.xy) / uBarScale;
  float slot = clamp(floor((c.x - uItems.x) / uItems.y), 0.0, uItems.z - 1.0);
  vec2  anchor = vec2(uItems.x + uItems.y * (slot + 0.5), uItems.w);
  c = anchor + (c - anchor) / max(uItemZoom, 0.01);

  vec2 uv = (c - uTexRect.xy) / uTexRect.zw;
  vec4 glyph = sampleContent(uv);
  float inTex = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
  glyph *= inTex;

  return glyph + under * (1.0 - glyph.a);
}

vec4 blurred(vec2 q, vec2 n, vec2 t, float s, vec4 fill) {
  return 0.4  * scene(q, fill)
       + 0.15 * (scene(q + n * s, fill) + scene(q - n * s, fill)
               + scene(q + t * s, fill) + scene(q - t * s, fill));
}

float flatProfile(float e) {
  float a = (e - 2.4038) / 7.6052;
  float b = e / 3.5303;
  return 5.2046 * exp(-a * a) - 9.1597 * exp(-b * b);
}
float capProfile(float e) {
  float u = max(1.0 - e / 13.211, 0.0);
  float v = max(1.0 - e / 0.7266, 0.0);
  return -11.658 * pow(u, 1.5647) - 2.855 * v * v;
}
float rimDisplacement(float e, vec2 n, float ps) {
  float es = e / ps;
  return mix(flatProfile(es), capProfile(es), abs(n.x)) * ps;
}

void main() {
  vec2 p  = FlutterFragCoord().xy;
  vec2 lp = p - uLens.xy;

  float d = sdRoundBox(lp, uLens.zw, uLensRadius);
  float cover = clamp(0.5 - d, 0.0, 1.0);
  if (cover <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  vec2  n = roundBoxNormal(lp, uLens.zw, uLensRadius);
  vec2  t = vec2(-n.y, n.x);
  float e = max(-d, 0.0);
  float g = clamp(uGlass, 0.0, 1.0);
  float ps = max(uProfileScale, 0.01);

  float disp = rimDisplacement(e, n, ps) * uRefraction * g;
  vec4  fill = mix(uPillColor, uGlassTint, g);

  vec4 col;
  if (g < 0.002) {
    col = scene(p, fill);
  } else {
    float k  = uDispersion * g;
    float s  = uBlur * abs(disp) + 0.1;
    vec4 sR = blurred(p + n * disp * (1.0 + 0.25 * k), n, t, s, fill);
    vec4 sG = blurred(p + n * disp,                    n, t, s, fill);
    vec4 sB = blurred(p + n * disp * (1.0 - 0.25 * k), n, t, s, fill);
    col = vec4(sR.r, sG.g, sB.b, (sR.a + sG.a + sB.a) / 3.0);
    col.rgb = min(col.rgb, vec3(col.a));
  }

  float spec = abs(dot(n, LIGHT));
  spec = spec * spec * spec;

  float rimBand = 1.0 - smoothstep(0.0, 1.3, e);
  float sheen   = (1.0 - smoothstep(0.0, 4.0 * ps, e)) * 0.10;

  float ang  = atan(n.y, n.x);
  float w1   = 0.5 + 0.5 * sin(2.0 * ang);
  float w2   = 0.5 + 0.5 * cos(3.0 * ang + 1.0);
  vec3  irid = mix(mix(vec3(0.40, 0.85, 0.90), vec3(0.80, 0.82, 0.55), w1),
                   vec3(0.55, 0.70, 1.00), w2 * 0.6);
  vec3  rimRGB = mix(uRim.rgb, irid, uIridescence * (1.0 - 0.5 * spec));

  float rimA   = clamp(uRim.a * g * rimBand * (0.55 + 0.45 * spec), 0.0, 1.0);
  float sheenA = clamp(uRim.a * g * sheen * (0.25 + 0.75 * spec), 0.0, 1.0);

  col = vec4(rimRGB * sheenA, sheenA) + col * (1.0 - sheenA);
  col = vec4(rimRGB * rimA,   rimA)   + col * (1.0 - rimA);

  fragColor = col * cover;
}
