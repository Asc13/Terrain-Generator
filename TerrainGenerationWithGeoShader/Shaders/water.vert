#version 330

uniform int noWater;
uniform	mat4 m_pvm;
uniform mat3 m_normal;

uniform vec4 cam_pos;

uniform float scale, secondLayer;

in vec4 position;
in vec3 normal;

out Data {
    vec3 normal;
	vec4 vertex;
} DataOut;


void main() {	
	if(noWater == 1) {
		DataOut.normal = normalize(m_normal * normal);

		vec4 vertex = (position + vec4(0.0, scale * secondLayer * 0.90, 0.0, 1.0));
		DataOut.vertex = vertex;

		gl_Position = m_pvm * vertex;
	}
}