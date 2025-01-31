#pragma glslify: voronoi = require('./voronoi3d.glsl')
#pragma glslify: cnoise = require('./perlin3d.glsl')

float PI = 3.141592653589793238;
uniform float u_time;
uniform int noiseAlgo;
uniform int renderMode;
uniform int numOctaves;
uniform float noiseRange;
uniform float randomFactor;
uniform float pointSize;
attribute vec2 reference;
varying float noiseVal;

float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
  float rF = randomFactor;
  vec3 tweakedPos = position + vec3(random(reference.xy), random(reference.yx * vec2(3.0)), random(reference.xy * vec2(5.0))) * rF;
  vec4 mvPosition = modelViewMatrix * vec4(tweakedPos, 1.);

  float fF = 3.0;
  float ps = 0.;
  float ps2 = 0.;
  float edgeFactor = 2.0;
  float scrollSpeed = 0.1;
  float xy = abs(position.x) * abs(position.y);
  float xz = abs(position.x) * abs(position.z);
  float yz = abs(position.z) * abs(position.y);
  // approximate a consistent point size for cube edges
  // float tmp = max(xy,xz);
  // tmp = max(tmp,yz);
  // ps2 = smoothstep(0.8, 1.0, tmp);

  noiseVal = 0.0;
  float normalizeSum = 0.0;
  for(int i = 0; i < numOctaves; i++) {
    float octaveScale = 1.0/pow(2.0, float(i));
    if(noiseAlgo == 1) {
      noiseVal += octaveScale*(cnoise(position * (noiseRange*float(i+1) + sin(0.0)) + vec3(0.0, (u_time * scrollSpeed), 0.0) * fF) + 1.0);
    } else {
      vec2 res = voronoi(position * (noiseRange + sin(u_time / 3.0)), u_time);
      noiseVal += octaveScale*(res.x);
    }
    normalizeSum += octaveScale;
  }
  noiseVal = pointSize*noiseVal/normalizeSum;

  // point size from the noise
  ps = smoothstep(0.6, 2.0, noiseVal) * 5.;
  gl_PointSize = mix(ps, ps2 * edgeFactor, ps2);

  gl_Position = projectionMatrix * mvPosition;
}