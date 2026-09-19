#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// ---- uniforms: set with setFloat() in exactly this order ----
uniform vec2  uSize;      // 0,1  widget size in logical px
uniform float uTime;      // 2    seconds, monotonically increasing
uniform vec2  uCenter;    // 3,4  orb centre in uv          -> 0.5185, 0.5000
uniform float uCoreR;     // 5    sphere radius, height-units -> 0.247
uniform float uSpin;      // 6    sphere rotation rad/s  0.2 .. 1.2  (try 0.55)
uniform float uTilt;      // 7    sphere axis tilt rad  -0.5 .. 0.5  (try 0.18)
uniform float uPulse;     // 8    glow breathing        0.0 .. 1.0   (try 1.0)
uniform float uOrbit;     // 9    bubble speed multiplier 0.3 .. 2.0 (try 1.0)
uniform float uRingGlow;  // 10   overall ring intensity 0.4 .. 1.6  (try 0.85)
uniform vec3  uColDark;   // 11,12,13  palette: deepest shadow
uniform vec3  uColMid;    // 14,15,16  palette: body colour
uniform vec3  uColHot;    // 17,18,19  palette: hottest highlight
uniform vec3  uColRing;   // 20,21,22  palette: orbit lines

uniform sampler2D uTexture; // restore.png

out vec4 fragColor;

const int RING_COUNT = 8;

// radius, sin(inclination), roll, angular speed
vec4 ringA(int i) {
    if (i == 0) return vec4(0.300, 0.62, -0.28, 0.85);
    if (i == 1) return vec4(0.355, 0.30,  0.18, 0.62);
    if (i == 2) return vec4(0.395, 0.48, -0.52, 0.74);
    if (i == 3) return vec4(0.430, 0.16,  0.34, 0.50);
    if (i == 4) return vec4(0.465, 0.38, -0.12, 0.66);
    if (i == 5) return vec4(0.500, 0.24,  0.52, 0.44);
    if (i == 6) return vec4(0.345, 0.70,  0.40, 0.92);
    return vec4(0.425, 0.55, -0.66, 0.56);
}

// brightness, line width -- deliberately uneven, so some lines read as hot
// foreground streaks and others as faint background threads
vec2 ringB(int i) {
    if (i == 0) return vec2(1.00, 0.0115);
    if (i == 1) return vec2(0.40, 0.0070);
    if (i == 2) return vec2(0.72, 0.0125);
    if (i == 3) return vec2(0.26, 0.0060);
    if (i == 4) return vec2(0.55, 0.0095);
    if (i == 5) return vec2(0.20, 0.0055);
    if (i == 6) return vec2(0.85, 0.0105);
    return vec2(0.33, 0.0075);
}

float hash11(float n) { return fract(sin(n) * 43758.5453); }

vec2 rot2(vec2 p, float a) {
    float c = cos(a), s = sin(a);
    return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

vec4 texStraight(vec2 uv) {
    vec4 t = texture(uTexture, uv);
    return vec4(t.rgb / max(t.a, 1e-5), t.a);
}

// disc-space (-1..1 across the sphere) -> texture uv
vec2 discToUv(vec2 d, vec2 size, vec2 centre, float R) {
    return centre + vec2(d.x * R * size.y / size.x, d.y * R);
}

// ---------------------------------------------------------------------
// Orbit rings. Each is a real 3D circle on a tilted plane, projected to an
// ellipse. A bright head travels around every ring, so no line is static,
// and each ring carries its own brightness and width.
// ---------------------------------------------------------------------
vec3 orbitRings(vec2 q, float coreR, float t, vec3 tint) {
    vec3 acc = vec3(0.0);
    float pixelR = length(q);

    for (int i = 0; i < RING_COUNT; i++) {
        vec4 ra = ringA(i);
        vec2 rb = ringB(i);
        float R = ra.x, si = ra.y, roll = ra.z, spd = ra.w;
        float bright = rb.x, width = rb.y;

        vec2 p = rot2(q, -roll);
        float A = R;
        float B = max(R * si, 0.012);
        vec2 e = vec2(p.x / A, p.y / B);
        float s = length(e);

        // analytic distance to the ellipse: implicit value over its gradient
        vec2 grad = vec2(p.x / (A * A), p.y / (B * B)) / max(s, 1e-4);
        float dist = (s - 1.0) / max(length(grad), 1e-4);

        float line = exp(-pow(dist / width, 2.0))
                   + 0.34 * exp(-pow(dist / (width * 5.0), 2.0));

        // where this pixel sits along the ring, and how deep it is
        float ph = atan(-e.y, e.x);
        float z = R * sin(ph) * sqrt(max(1.0 - si * si, 0.0));

        // travelling head: the whole ring stays visible, one arc glows hot
        float head = 0.5 + 0.5 * cos(ph - t * spd);
        float mHead = 0.38 + 0.62 * head * head;

        float hidden = step(z, 0.0) * step(pixelR, coreR * 0.97);
        float vis = mix(mix(0.5, 1.0, step(0.0, z)), 0.0, hidden);

        acc += line * mHead * vis * bright * tint;
    }
    return acc;
}

// ---------------------------------------------------------------------
// Bubbles riding the same tracks, so they follow the lines instead of
// drifting independently of them.
// ---------------------------------------------------------------------
vec3 orbitBubbles(vec2 q, float coreR, float t, float speed, vec3 tint) {
    vec3 acc = vec3(0.0);
    for (int k = 0; k < 26; k++) {
        float fk = float(k);
        float h1 = hash11(fk * 127.1);
        float h2 = hash11(fk * 311.7 + 1.7);
        float h3 = hash11(fk * 74.7 + 4.1);

        int i = int(mod(fk, float(RING_COUNT)));
        vec4 ra = ringA(i);
        float bright = ringB(i).x;

        float R = ra.x * (0.97 + 0.06 * h1);
        float si = ra.y, roll = ra.z;
        float ci = sqrt(max(1.0 - si * si, 0.0));

        float ph = h2 * 6.28318 + t * ra.w * speed * (0.8 + 0.4 * h3);
        vec2 p0 = vec2(R * cos(ph), -R * si * sin(ph));
        float z = R * sin(ph) * ci;
        vec2 sp = rot2(p0, roll);

        float size = (0.011 + 0.017 * h3) * (1.0 + 0.32 * z / max(R, 1e-3));
        float d = length(q - sp);
        float dn = d / size;

        float g = 0.85 * exp(-dn * dn * 2.2)                     // body
                + 0.55 * exp(-(dn - 0.55) * (dn - 0.55) * 9.0)   // glass shell
                + 0.20 * exp(-pow(d / (size * 3.4), 2.0) * 2.0); // halo

        float hidden = step(z, 0.0) * step(length(sp), coreR * 0.97);
        float vis = mix(mix(0.5, 1.0, step(0.0, z)), 0.0, hidden);

        acc += g * vis * tint * (0.45 + 0.75 * bright);
    }
    return acc;
}

void main() {
    vec2 px = FlutterFragCoord().xy;
    vec2 q = (px - uCenter * uSize) / uSize.y;
    float r = length(q);
    float t = uTime;

    // ================= 3D sphere core =================
    float rn = clamp(r / uCoreR, 0.0, 1.0);
    float nz = sqrt(max(1.0 - rn * rn, 0.0));
    vec3 n = vec3(q / uCoreR, nz);

    float ct = cos(uTilt), st = sin(uTilt);
    n.yz = mat2(ct, -st, st, ct) * n.yz;

    float th = t * uSpin;
    float cs = cos(th), sn = sin(th);
    vec3 m = vec3(n.x * cs - n.z * sn, n.y, n.x * sn + n.z * cs);

    vec4 fT = texStraight(discToUv(vec2( m.x, m.y), uSize, uCenter, uCoreR));
    vec4 bT = texStraight(discToUv(vec2(-m.x, m.y), uSize, uCenter, uCoreR));

    // flatten the artwork's baked shading so the orb does not dim each half turn
    vec3 lp = vec3(0.0);
    float o = 0.34;
    lp += texStraight(discToUv(vec2(m.x + o, m.y), uSize, uCenter, uCoreR)).rgb;
    lp += texStraight(discToUv(vec2(m.x - o, m.y), uSize, uCenter, uCoreR)).rgb;
    lp += texStraight(discToUv(vec2(m.x, m.y + o), uSize, uCenter, uCoreR)).rgb;
    lp += texStraight(discToUv(vec2(m.x, m.y - o), uSize, uCenter, uCoreR)).rgb;
    float baked = clamp(dot(lp * 0.25, vec3(0.3333)), 0.22, 1.4);

    float w = smoothstep(-0.10, 0.10, m.z);
    vec3 core = mix(bT.rgb / baked * 0.62 * 0.80, fT.rgb / baked * 0.62, w);
    float coreAlpha = mix(bT.a, fT.a, w);

    // Map the artwork's luminance onto the mode palette. Going through
    // luminance rather than tinting the original colour is what lets the same
    // texture read as cyan, lime or orange without any hue-shift artefacts.
    float v = clamp((dot(core, vec3(0.3333)) - 0.18) / 0.72, 0.0, 1.0);
    core = uColDark
         + (uColMid - uColDark) * smoothstep(0.00, 0.55, v)
         + (uColHot - uColMid) * smoothstep(0.55, 1.00, v);
    core *= 1.10;

    core *= 0.46 + 0.54 * n.z;
    vec3 L = normalize(vec3(-0.42, -0.58, 0.70));
    core += uColHot * pow(max(dot(n, L), 0.0), 26.0) * 0.42;
    core += uColMid * pow(1.0 - n.z, 3.0) * 0.52;

    float coreMask = smoothstep(uCoreR * 1.02, uCoreR * 0.94, r);

    float beat  = 0.5 + 0.5 * sin(t * 1.30);
    float beat2 = 0.5 + 0.5 * sin(t * 0.47 + 1.9);
    core *= 1.0 + uPulse * (0.09 * beat + 0.05 * beat2);

    // ================= everything outside the sphere =================
    vec3 halo = mix(uColMid, uColHot, 0.25)
              * exp(-pow((r - uCoreR * 0.99) / (uCoreR * 0.30), 2.0)) * 0.30;

    vec3 rings   = orbitRings(q, uCoreR, t, uColRing) * uRingGlow;
    vec3 bubbles = orbitBubbles(q, uCoreR, t, uOrbit,
                               mix(uColRing, uColHot, 0.20)) * 0.85;

    // ================= composite (premultiplied) =================
    float coreA = clamp(coreAlpha, 0.0, 1.0) * coreMask;
    // Rings, bubbles and halo all add together. Where several overlap the sum
    // ran past 1.0 and clipped to flat white, so roll it off softly instead.
    vec3 glow = halo + rings + bubbles;
    glow = glow / (1.0 + glow * 0.55);

    vec3 outRgb = core * coreA + glow;
    float outA = clamp(coreA + max(max(glow.r, glow.g), glow.b), 0.0, 1.0);

    fragColor = vec4(clamp(outRgb, 0.0, 4.0), outA);
}
