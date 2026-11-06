// ─────────────────────────────────────────────────────────────────────────────
//  liquid_glass_backdrop.frag  —  the glass itself, over your real content
//
//  Runs as a BackdropFilter (ImageFilter.shader, Impeller). Inside the bar it
//  frosts, saturates and veils the page behind; at the bar's rim and at the
//  selection lens it bends the page with the profile fitted to iOS 26
//  (fold + magnifying ring on the curved ends, stretched strip on the flat
//  top/bottom); the lens adds chromatic dispersion. Everywhere else in the
//  filter region the page passes through untouched.
//
//  The tab glyphs are NOT drawn here — liquid_glass_lens.frag draws them on
//  top with the same displacement field, so glyphs and page bend together.
// ─────────────────────────────────────────────────────────────────────────────
#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2  u_size;          //  0– 1  set by the engine: input texture size (px)
uniform vec4  uOrigins;        //  2– 5  local (0,0) in texture px: clip-relative.xy, global.zw
uniform vec2  uClipPx;         //  6– 7  filter region size in px (to detect the mode)
uniform float uDpr;            //  8
uniform vec4  uBar;            //  9–12  bar centre.xy, half-size.zw (local, swollen)
uniform float uBarRadius;      // 13
uniform vec4  uLens;           // 14–17  lens centre.xy, half-size.zw
uniform float uLensRadius;     // 18
uniform float uGlass;          // 19     0 resting pill … 1 lens
uniform float uLensRefraction; // 20     1 = iOS
uniform float uBarRefraction;  // 21     refraction at the bar's own rim
uniform float uProfileScale;   // 22     bar height / 61.5
uniform float uDispersion;     // 23
uniform float uFrost;          // 24     frost radius (pt)
uniform vec4  uVeil;           // 25–28  premultiplied colour laid over the frost
uniform float uSaturation;     // 29     vibrancy (1 = none)
uniform sampler2D u_texture;

out vec4 fragColor;

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

// ── iOS 26 rim profile (fitted to 10 frames of a 240fps recording) ─────────
// Outward displacement (pt) at depth e into the glass. The flat top/bottom
// bend the strip just outside the glass over the lip; the curved ends pull
// inward over a wide ring (magnifying, "circling") and fold at the very rim.
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

vec4 tex(vec2 q, vec2 origin) {
  vec2 uv = (q * uDpr + origin) / u_size;
  uv = clamp(uv, 0.5 / u_size, 1.0 - 0.5 / u_size);
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(u_texture, uv);
}

// 25-tap golden-angle frost (Gaussian-weighted disk of radius r).
vec4 frost(vec2 q, vec2 origin, float r) {
  if (r < 0.05) {
    return tex(q, origin);
  }
  vec4 acc = tex(q, origin) * 0.12;
  float wsum = 0.12;
  for (int i = 0; i < 24; i++) {
    float fi = float(i);
    float a = fi * 2.39996323;
    float rr = r * sqrt((fi + 0.5) / 24.0);
    float w = exp(-2.0 * (rr * rr) / (r * r));
    acc += tex(q + vec2(cos(a), sin(a)) * rr, origin) * w;
    wsum += w;
  }
  return acc / wsum;
}

// The glass "material" at q: frosted page, more saturated, under the veil.
vec4 glassAt(vec2 q, vec2 origin) {
  vec4 c = frost(q, origin, uFrost);
  float luma = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
  c.rgb = clamp(mix(vec3(luma), c.rgb, uSaturation), vec3(0.0), vec3(c.a));
  return uVeil + c * (1.0 - uVeil.a);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  // Clip-relative texture (u_size == region) or render-target-relative.
  bool clipMode = abs(u_size.x - uClipPx.x) < 4.0 && abs(u_size.y - uClipPx.y) < 4.0;
  vec2 origin = clipMode ? uOrigins.xy : uOrigins.zw;
  vec2 p = (frag - origin) / uDpr;

  vec4 raw = tex(p, origin);

  float dB = sdRoundBox(p - uBar.xy, uBar.zw, uBarRadius);
  float dL = sdRoundBox(p - uLens.xy, uLens.zw, uLensRadius);
  float inBar  = clamp(0.5 - dB, 0.0, 1.0);
  float inLens = clamp(0.5 - dL, 0.0, 1.0);
  if (inBar <= 0.0 && inLens <= 0.0) {
    fragColor = raw;
    return;
  }

  float ps = max(uProfileScale, 0.01);
  vec4 col = raw;

  if (inBar > 0.0) {
    vec2  nb = roundBoxNormal(p - uBar.xy, uBar.zw, uBarRadius);
    float eb = max(-dB, 0.0);
    float db = rimDisplacement(eb, nb, ps) * uBarRefraction;
    col = mix(col, glassAt(p + nb * db, origin), inBar);
  }

  if (inLens > 0.0) {
    float g = clamp(uGlass, 0.0, 1.0);
    vec2  nl = roundBoxNormal(p - uLens.xy, uLens.zw, uLensRadius);
    float el = max(-dL, 0.0);
    float dl = rimDisplacement(el, nl, ps) * uLensRefraction * g;
    vec4 lensCol;
    if (g < 0.002) {
      lensCol = col;                                   // resting pill
    } else {
      float k = uDispersion * g;
      vec4 r = glassAt(p + nl * dl * (1.0 + 0.25 * k), origin);
      vec4 gg = glassAt(p + nl * dl, origin);
      vec4 b = glassAt(p + nl * dl * (1.0 - 0.25 * k), origin);
      lensCol = vec4(r.r, gg.g, b.b, (r.a + gg.a + b.a) / 3.0);
      lensCol.rgb = min(lensCol.rgb, vec3(lensCol.a));
    }
    col = mix(col, lensCol, inLens);
  }

  fragColor = col;
}
