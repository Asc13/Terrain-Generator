#version 330

uniform vec4 fogColor;
uniform vec4 cam_pos;
uniform float fog_density;

in Data {
	vec3 normal;
	vec3 lightDir;
	vec4 color;
	vec4 vertex;
} DataIn;

out vec4 colorOut;


vec4 fog(in vec3 color) {
	float distance = distance(cam_pos, DataIn.vertex);
	float amount = 1.0 - exp(-distance * fog_density);

    return vec4(mix(color, fogColor.xyz, amount), 1.0);
}


void main() {
	vec3 n = normalize(DataIn.normal);
	vec3 l = normalize(DataIn.lightDir);

	float intensity = max(dot(n, l), 0.0);

	colorOut = fog(max(intensity, 0.25) * DataIn.color.xyz);
}