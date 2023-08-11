#version 330

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 m_pvm;
uniform	mat3 m_normal;

uniform vec4 firstColor, secondColor, thirdColor, fourthColor;
uniform float scale, amplitude, lacunarity, gain, frequency;
uniform float min_h, firstLayer, secondLayer, thirdLayer;
uniform int octaves;

vec4 v[3];
float h[3];
vec4 c[3];


in Data {
	vec3 lightDir;
    vec4 positionV;
} DataIn[3];

out Data {
	vec3 normal;
	vec3 lightDir;
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


void produceVertex(vec4 pos, int index) {
    h[index] = fbm(pos.xz);

    float factor = scale * h[index];

    if(factor > thirdLayer * scale) {
        v[index] = (pos + vec4(0.0, factor, 0.0, 0.0));
        c[index] = fourthColor;
    }
    else if(factor <= thirdLayer * scale && factor > secondLayer * scale) {
        v[index] = (pos + vec4(0.0, factor, 0.0, 0.0));
        c[index] = thirdColor;
    }
    else if(factor <= secondLayer * scale && factor > firstLayer * scale) {
        v[index] = (pos + vec4(0.0, factor, 0.0, 0.0));
        c[index] = secondColor;
    }
    else {
        v[index] = (pos + vec4(0.0, factor, 0.0, 0.0));
        c[index] = firstColor;

    }
}


void main() {
    produceVertex(DataIn[0].positionV, 0);
    produceVertex(DataIn[1].positionV, 1);
    produceVertex(DataIn[2].positionV, 2);

    vec3 U = v[1].xyz - v[0].xyz;
    vec3 V = v[2].xyz - v[0].xyz;

    vec3 triangleNormal = vec3(U.y * V.z - U.z * V.y, 
                               U.z * V.x - U.x * V.z,
                               U.x * V.y - U.y * V.x);

    for(int i = 0; i < 3; ++i) {
        gl_Position = m_pvm * v[i];
        DataOut.normal = normalize(m_normal * triangleNormal);
        DataOut.lightDir = DataIn[i].lightDir;
        DataOut.color = c[i];
        DataOut.vertex = v[i];
        EmitVertex();
    }

    EndPrimitive();
}
