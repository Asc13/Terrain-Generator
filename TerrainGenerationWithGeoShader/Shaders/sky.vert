#version 330

uniform	mat4 m_pvm;

in vec4 position;
in vec3 normal;

void main() {
	gl_Position = m_pvm * position;	
}