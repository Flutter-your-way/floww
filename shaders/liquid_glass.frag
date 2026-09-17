#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uRadius;
uniform float uThickness;
uniform float uRefraction;
uniform float uDispersion;
uniform float uGlare;
uniform float uBrightness;

uniform sampler2D uTexture;

out vec4 fragColor;

float roundedBoxDistance(vec2 point, vec2 halfSize, float radius) {
  vec2 q = abs(point) - halfSize + radius;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

vec2 edgeNormal(vec2 point, vec2 halfSize, float radius) {
  vec2 eps = vec2(1.0, 0.0);
  float dx = roundedBoxDistance(point + eps.xy, halfSize, radius) -
      roundedBoxDistance(point - eps.xy, halfSize, radius);
  float dy = roundedBoxDistance(point + eps.yx, halfSize, radius) -
      roundedBoxDistance(point - eps.yx, halfSize, radius);
  vec2 gradient = vec2(dx, dy);
  float len = length(gradient);
  return len < 0.0001 ? vec2(0.0) : gradient / len;
}

vec4 sampleBackdrop(vec2 point) {
  vec2 uv = clamp(point / uSize, vec2(0.0), vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTexture, uv);
}

void main() {
  vec2 point = FlutterFragCoord().xy;
  vec2 halfSize = uSize * 0.5;
  vec2 local = point - halfSize;
  float radius = min(uRadius, min(halfSize.x, halfSize.y));

  float dist = roundedBoxDistance(local, halfSize, radius);
  vec2 normal = edgeNormal(local, halfSize, radius);

  float mask = 1.0 - smoothstep(-1.0, 1.0, dist);
  float edge = clamp(1.0 + dist / uThickness, 0.0, 1.0) * mask;
  float bend = pow(edge, 2.5) * uRefraction;

  vec2 offset = normal * bend;
  vec4 color = sampleBackdrop(point + offset);

  float shift = bend * uDispersion;
  color.r = sampleBackdrop(point + offset + normal * shift).r;
  color.b = sampleBackdrop(point + offset - normal * shift).b;

  vec2 light = normalize(vec2(-0.35, -1.0));
  float facing = max(dot(normal, light), 0.0) +
      0.45 * max(dot(normal, -light), 0.0);
  float glare = pow(edge, 5.0) * facing * uGlare;

  float lift = mix(1.0, uBrightness, mask);
  vec3 rgb = color.rgb * lift + glare * color.a;

  fragColor = vec4(rgb, color.a);
}
