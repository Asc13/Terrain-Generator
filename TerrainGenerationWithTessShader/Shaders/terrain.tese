#version 410

layout(quads, equal_spacing, ccw) in;

uniform mat4 m_pvm;
uniform	mat3 m_normal;

uniform vec4 firstColor, secondColor, thirdColor, fourthColor;
uniform float scale, amplitude, lacunarity, gain, frequency;
uniform float min_h, firstLayer, secondLayer, thirdLayer;
uniform int octaves;
uniform int uDetail;

vec4 vertexP;
vec4 colorP;

patch in float chunk_half_t;
patch in vec3 center_t;


out Data {
	vec3 normal;
    vec4 color;
    vec4 vertex;
} DataOut;


float random(in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noised(in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}


float fbm(in vec2 xz) {
    float value = min_h;
    float lacunarityI = lacunarity;
    float gainI = gain;
    
    float amplitudeI = amplitude;
    float frequencyI = frequency;
    
    for(int i = 0; i < octaves; ++i) {
        value += amplitudeI * noised(frequencyI * xz);
        frequencyI *= lacunarityI;
        xz *= 2.;
        amplitudeI *= gainI;
    }
    return value;
}


void produceVertex(vec4 pos) {
    float h = fbm(pos.xz);

    float factor = scale * h;

    if(factor > thirdLayer * scale) {
        vertexP = (pos + vec4(0.0, factor, 0.0, 0.0));
        colorP = fourthColor;
    } 
    else if(factor <= thirdLayer * scale && factor > secondLayer * scale) {
        vertexP = (pos + vec4(0.0, factor, 0.0, 0.0));
        colorP = thirdColor;
    }
    else if(factor <= secondLayer * scale && factor > firstLayer * scale) {
        vertexP = (pos + vec4(0.0, factor, 0.0, 0.0));
        colorP = secondColor;
    }
    else {
        vertexP = (pos + vec4(0.0, factor, 0.0, 0.0));
        colorP = firstColor;
    }
}


void main() {
    vec3 p = gl_in[0].gl_Position.xyz;

    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

    vec4 vertex = vec4(center_t.x + chunk_half_t * (2 * v - 1), 0.0, center_t.z + chunk_half_t * (2 * u - 1), 1.0);
    produceVertex(vertex);

    float f = (chunk_half_t * 2) / uDetail;

    vec3 p1 = vec3(vertex.x, fbm(vec2(vertex.x, vertex.z - f)), vertex.z - f);
    vec3 p2 = vec3(vertex.x, fbm(vec2(vertex.x, vertex.z + f)), vertex.z + f);
    vec3 p3 = vec3(vertex.x - f, fbm(vec2(vertex.x - f, vertex.z)), vertex.z);
    vec3 p4 = vec3(vertex.x + f, fbm(vec2(vertex.x + f, vertex.z)), vertex.z);

    vec3 v1 = p2 - p1;
    vec3 v2 = p4 - p3;
    
    DataOut.normal = normalize(m_normal * normalize(cross(v1, v2)));
    DataOut.color = colorP;
    DataOut.vertex = vertexP;

    gl_Position = m_pvm * vertexP;
}