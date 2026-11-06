// ─────────────────────────────────────────────────────────────────────────────
//  liquid_glass_lens.frag
//
//  iOS 26 "Liquid Glass" selection lens (Photos / Files tab bar).
//
//  The optics were fitted pixel-by-pixel to a 240fps screen recording of the
//  iOS 26 Photos tab bar (6 frames: held still, dragging, mid-switch). What
//  that recording shows, and what this shader reproduces:
//
//  1. Per-item magnification. Under the lens every tab item (icon + label) is
//     magnified ×1.17 about ITS OWN tab centre, not about the lens. The
//     glyphs stay put while the lens slides over them.
//  2. A folded rim. Displacement along the outward normal, as a function of
//     depth e into the glass (logical pt, for a 62pt bar):
//         d(e) = 3.77·exp(-((e-7.06)/4.35)²) − 4.84·exp(-(e/2.01)²)
//     • e ≈ 0…2pt : negative → samples INWARD → a mirrored copy of nearby
//       content wraps around the rim (the blue crescents at the caps)
//     • e ≈ 3…12pt: positive (peak ≈3.8pt at 7pt) → samples OUTWARD → a thin
//       strip just outside the lens is stretched over the lip (the dark
//       stadium bands, the blobs of neighbouring icons)
//     • e > 14pt  : ~0 → flat, undistorted centre
//  3. Blur that grows with the bend (≈0.33 × |d|), so the bands are soft.
//  4. Chromatic dispersion and a ~0.8pt specular rim in the thin-film colours
//     measured off the iOS rim (teal / olive / pale blue).
//  At uGlass = 0 it draws the resting pill (no bend, no blur, no zoom).
//
//  All coordinates are the painter's local logical pixels. Colours are
//  premultiplied alpha (Flutter's convention).
// ─────────────────────────────────────────────────────────────────────────────
#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec4  uTexRect;      //  0– 3  content texture rect: left, top, width, height
uniform vec4  uBar;          //  4– 7  bar centre.xy, half-size.xy (already swollen)
uniform float uBarRadius;    //  8     bar corner radius (already swollen)
uniform float uBarScale;     //  9     bar swell factor (texture is unswollen)
uniform vec4  uLens;         // 10–13  lens centre.xy, half-size.xy
uniform float uLensRadius;   // 14     lens corner radius
uniform float uGlass;        // 15     0 = resting pill … 1 = full glass lens
uniform float uItemZoom;     // 16     per-item magnification (1 … 1.17)
uniform float uRefraction;   // 17     multiplier on the fitted rim profile (1 = iOS)
uniform float uProfileScale; // 18     bar height / 61.5 (profile is in iOS points)
uniform float uDispersion;   // 19     chromatic spread, 0 … 1
uniform vec4  uBarColor;     // 20–23  bar fill (premultiplied)
uniform vec4  uPillColor;    // 24–27  resting pill fill (premultiplied)
uniform vec4  uGlassTint;    // 28–31  glass body tint (premultiplied)
uniform vec4  uRim;          // 32–35  rim rgb, a = rim strength
uniform float uIridescence;  // 36     0 … 1 soap-bubble colour in the rim
uniform vec2  uTexPx;        // 37–38  content texture size in physical pixels
uniform vec4  uBarRim;       // 39–42  bar rim-light rgb, a = strength
uniform vec4  uItems;        // 43–46  slot inset, slot width, slot count, anchor y
uniform float uBlur;         // 47     blur per px of bend (iOS ≈ 0.33)
uniform sampler2D uContent;

out vec4 fragColor;

const vec2  LIGHT = vec2(-0.5523, -0.8336);        // top-left key light

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

// Manual bilinear filtering (image samplers default to nearest on many SDKs).
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

// What lies behind the glass at local point q (premultiplied).
vec4 scene(vec2 q, vec4 fill) {
  float dB = sdRoundBox(q - uBar.xy, uBar.zw, uBarRadius);
  float barA = clamp(0.5 - dB, 0.0, 1.0);
  vec4 bar = uBarColor * barA;

  // the bar's own rim light (so it refracts too)
  vec2  nb = roundBoxNormal(q - uBar.xy, uBar.zw, uBarRadius);
  float sb = pow(abs(dot(nb, LIGHT)), 1.5);
  float rimFall = pow(clamp(1.0 - (-dB) / 1.1, 0.0, 1.0), 0.7);
  float ra = clamp(uBarRim.a * rimFall * barA * (0.2 + 0.8 * sb), 0.0, 1.0);
  bar = vec4(uBarRim.rgb * ra, ra) + bar * (1.0 - ra);

  vec4 under = fill + bar * (1.0 - fill.a);

  // glyphs: undo the bar swell, then magnify each item about its own slot
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

// Five-tap blur along the normal and tangent, radius s.
vec4 blurred(vec2 q, vec2 n, vec2 t, float s, vec4 fill) {
  return 0.4  * scene(q, fill)
       + 0.15 * (scene(q + n * s, fill) + scene(q - n * s, fill)
               + scene(q + t * s, fill) + scene(q - t * s, fill));
}

// Fitted iOS rim profile, logical pt (see header).
float rimProfile(float e) {
  float a = (e - 7.06) / 4.35;
  float b = e / 2.01;
  return 3.77 * exp(-a * a) - 4.84 * exp(-b * b);
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

  float disp = rimProfile(e / ps) * ps * uRefraction * g;
  vec4  fill = mix(uPillColor, uGlassTint, g);

  vec4 col;
  if (g < 0.002) {
    col = scene(p, fill);                           // resting pill: exact
  } else {
    float k  = uDispersion * g;
    float s  = uBlur * abs(disp) + 0.1;
    vec4 sR = blurred(p + n * disp * (1.0 + 0.25 * k), n, t, s, fill);
    vec4 sG = blurred(p + n * disp,                    n, t, s, fill);
    vec4 sB = blurred(p + n * disp * (1.0 - 0.25 * k), n, t, s, fill);
    col = vec4(sR.r, sG.g, sB.b, (sR.a + sG.a + sB.a) / 3.0);
    col.rgb = min(col.rgb, vec3(col.a));
  }

  // ── light ────────────────────────────────────────────────────────────────
  float spec = abs(dot(n, LIGHT));                 // lit edge + opposite edge
  spec = spec * spec * spec;

  float rimBand = 1.0 - smoothstep(0.0, 1.3, e);
  float sheen   = (1.0 - smoothstep(0.0, 4.0 * ps, e)) * 0.10;

  // Thin-film palette sampled off the iOS rim: teal, olive, pale blue.
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
