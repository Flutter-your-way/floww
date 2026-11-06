#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uRect;
uniform float uRadius;
uniform float uStrength;
uniform float uDark;
uniform sampler2D uTexture;

out vec4 fragColor;

float sdRoundRect(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec4 sampleAt(vec2 px) {
  vec2 uv = px / uSize;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTexture, clamp(uv, vec2(0.0), vec2(1.0)));
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 halfSize = uRect.zw * 0.5;
  vec2 center = uRect.xy + halfSize;
  vec2 p = frag - center;
  float r = min(uRadius, min(halfSize.x, halfSize.y));
  float d = sdRoundRect(p, halfSize, r);

  if (d > 0.0) {
    fragColor = sampleAt(frag);
    return;
  }

  float band = max(6.0, min(halfSize.x, halfSize.y) * 0.45);
  float t = clamp(1.0 + d / band, 0.0, 1.0);
  t = t * t * (3.0 - 2.0 * t);

  float mag = 1.0 + uStrength * t;
  vec2 src = center + p / mag;

  vec2 dir = p / max(length(p), 1e-3);
  float ca = 1.5 * t;
  vec4 base = sampleAt(src);
  vec4 c = vec4(
    sampleAt(src + dir * ca).r,
    base.g,
    sampleAt(src - dir * ca).b,
    base.a
  );

  c.rgb += vec3(0.07 * t) * c.a;

  float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
  float darken = smoothstep(0.6, 0.95, lum) * 0.05 * (1.0 - uDark * 0.5);
  float brighten = (1.0 - smoothstep(0.05, 0.4, lum)) * 0.08;
  c.rgb = c.rgb * (1.0 - darken) + vec3(brighten) * c.a;

  fragColor = c;
}
