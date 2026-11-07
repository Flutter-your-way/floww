#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2  u_size;
uniform vec4  uOrigins;
uniform vec2  uClipPx;
uniform float uDpr;
uniform vec4  uBar;
uniform float uBarRadius;
uniform vec4  uLens;
uniform float uLensRadius;
uniform float uGlass;
uniform float uLensRefraction;
uniform float uBarRefraction;
uniform float uProfileScale;
uniform float uDispersion;
uniform float uFrost;
uniform vec4  uVeil;
uniform float uSaturation;
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

vec4 frost(vec2 q, vec2 origin, float r) {
  if (r < 0.05) {
    return tex(q, origin);
  }
  vec4 acc = tex(q, origin) * 0.12;
  acc += tex(q + vec2(0.14433757, 0.00000000) * r, origin) * 0.95918946;
  acc += tex(q + vec2(-0.18434222, 0.16887257) * r, origin) * 0.88249690;
  acc += tex(q + vec2(0.02821653, -0.32151282) * r, origin) * 0.81193635;
  acc += tex(q + vec2(0.23235143, 0.30306129) * r, origin) * 0.74701750;
  acc += tex(q + vec2(-0.42639345, -0.07542300) * r, origin) * 0.68728928;
  acc += tex(q + vec2(0.40391710, -0.25693899) * r, origin) * 0.63233666;
  acc += tex(q + vec2(-0.13510236, 0.50257406) * r, origin) * 0.58177781;
  acc += tex(q + vec2(-0.25765486, -0.49609875) * r, origin) * 0.53526143;
  acc += tex(q + vec2(0.55900798, 0.20414882) * r, origin) * 0.49246429;
  acc += tex(q + vec2(-0.58155466, 0.24005731) * r, origin) * 0.45308902;
  acc += tex(q + vec2(0.28034778, -0.59908691) * r, origin) * 0.41686202;
  acc += tex(q + vec2(0.20716987, 0.66049020) * r, origin) * 0.38353157;
  acc += tex(q + vec2(-0.62441240, -0.36185975) * r, origin) * 0.35286608;
  acc += tex(q + vec2(0.73250683, -0.16103957) * r, origin) * 0.32465247;
  acc += tex(q + vec2(-0.44703752, 0.63586486) * r, origin) * 0.29869469;
  acc += tex(q + vec2(-0.10327601, -0.79697390) * r, origin) * 0.27481238;
  acc += tex(q + vec2(0.63401345, 0.53434721) * r, origin) * 0.25283960;
  acc += tex(q + vec2(-0.85318337, 0.03528181) * r, origin) * 0.23262366;
  acc += tex(q + vec2(0.62233178, -0.61930323) * r, origin) * 0.21402410;
  acc += tex(q + vec2(-0.04163641, 0.90042568) * r, origin) * 0.19691168;
  acc += tex(q + vec2(-0.59215068, -0.70959442) * r, origin) * 0.18116749;
  acc += tex(q + vec2(0.93803206, 0.12621089) * r, origin) * 0.16668213;
  acc += tex(q + vec2(-0.79479267, 0.55299603) * r, origin) * 0.15335497;
  acc += tex(q + vec2(0.21718308, -0.96540053) * r, origin) * 0.14109338;
  return acc * 0.09530186;
}

vec4 glassAt(vec2 q, vec2 origin) {
  vec4 c = frost(q, origin, uFrost);
  float luma = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
  c.rgb = clamp(mix(vec3(luma), c.rgb, uSaturation), vec3(0.0), vec3(c.a));
  return uVeil + c * (1.0 - uVeil.a);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
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
  float g = clamp(uGlass, 0.0, 1.0);
  vec4 col = raw;
  bool lensCovers = inLens >= 1.0 && g >= 0.002;

  if (inBar > 0.0 && !lensCovers) {
    vec2  nb = roundBoxNormal(p - uBar.xy, uBar.zw, uBarRadius);
    float eb = max(-dB, 0.0);
    float db = rimDisplacement(eb, nb, ps) * uBarRefraction;
    col = mix(col, glassAt(p + nb * db, origin), inBar);
  }

  if (inLens > 0.0) {
    vec2  nl = roundBoxNormal(p - uLens.xy, uLens.zw, uLensRadius);
    float el = max(-dL, 0.0);
    float dl = rimDisplacement(el, nl, ps) * uLensRefraction * g;
    vec4 lensCol;
    if (g < 0.002) {
      lensCol = col;
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
