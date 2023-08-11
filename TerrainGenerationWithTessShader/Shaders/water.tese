#version 410

layout(quads, equal_spacing, ccw) in;

uniform mat4 m_pvm;

uniform vec4 waterColor;
uniform float scale, secondLayer;
uniform float timer;

patch in float tcRadius;
patch in vec3 tcCenter;

out Data {
    vec4 color;
    vec4 vertex;
} DataOut;


float hash1(float n) {
    return fract(sin(n) * 43758.5453);
}

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3))); 
    return fract(sin(p) * 43758.5453);
}

vec4 voronoi(in vec2 x, float w) {
    vec2 n = floor(x);
    vec2 f = fract(x);

	vec4 m = vec4(8.0, 0.0, 0.0, 0.0);
    
    for(int j =- 2; j <= 2; j++)
        for(int i =- 2; i <= 2; i++) {

            vec2 g = vec2(float(i), float(j));
            vec2 o = hash2(n + g);
            
            o = 0.5 + 0.5 * sin((timer / 500) + 6.2831 * o);
		
            float d = length(g - f + o);
            
            vec3 col = 0.5 + 0.5 * sin(hash1(dot(n + g, vec2(7.0, 113.0))) * 2.5 + 3.5 + vec3(2.0, 3.0, 0.0));
            col = col * col;
	
            float h = smoothstep(-1.0, 1.0, (m.x - d) / w);

            m.x = mix(m.x, d, h) - h * (1.0 - h) * w / (1.0 + 3.0 * w);
            m.yzw = mix(m.yzw, col, h) - h * (1.0 - h) * w / (1.0 + 3.0 * w);
        }
	return m;
}


void main() {
    vec3 p = gl_in[0].gl_Position.xyz;

    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

    vec4 vertex = vec4(tcCenter.x + tcRadius * (2 * v - 1), scale * secondLayer * 0.9, tcCenter.z + tcRadius * (2 * u - 1), 1.0);

    vec4 voronoi_color = voronoi(5 * vertex.xz, 0.8);

    DataOut.color = vec4((voronoi_color.x + waterColor.x * 2) / 3, (voronoi_color.y + waterColor.y * 2) / 3 , (voronoi_color.z + waterColor.z * 2) / 3, 1.0);
    DataOut.vertex = vertex;

    gl_Position = m_pvm * vertex;
}