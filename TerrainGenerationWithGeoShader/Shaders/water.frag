#version 330

uniform vec4 waterColor, fogColor;
uniform mat4 m_view;
uniform vec4 cam_pos;
uniform vec4 l_dir;
uniform float fog_density;
uniform float opacity;

in Data {
	vec3 normal;
	vec4 vertex;
} DataIn;

out vec4 colorOut;


vec4 fog(in vec3 color) {
	float distance = distance(cam_pos, DataIn.vertex);
	float amount = 1.0 - exp(-distance * fog_density);

    return vec4(mix(color, fogColor.xyz, amount), opacity);
}


void main() {
	vec3 n = normalize(DataIn.normal);
	vec3 l = normalize(vec3(m_view * l_dir));

	float intensity = max(dot(n, l), 0.0);
	
	colorOut = fog(max(intensity, 0.25) * waterColor.xyz);
}