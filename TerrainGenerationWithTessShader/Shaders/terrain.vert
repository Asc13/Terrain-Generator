#version 410

uniform mat4 m_pvm, m_view;
uniform vec4 cam_pos;

const float chunk_half = 0.5;
const float chunk_tam = 1.0;
const int chunks_count_edge = 25;

in vec4 position;

out vec3 center_v;
out float chunk_half_v;

int chunkSearch(float p) {
	int i = 0;
	int c = -1;

	while(c != 0) {
		if(-chunk_half - (chunk_tam * i) < p && p <= chunk_half - (chunk_tam * i)) {
			i = -i;
			break;
		}
		if(-chunk_half + (chunk_tam * i) < p && p <= chunk_half + (chunk_tam * i))
			break;
		i++;
	}

	return i;
}

void main() {
	int i_x = chunkSearch(cam_pos.x);
	int i_z = chunkSearch(cam_pos.z);
	
	vec4 pos;

	pos.x = gl_InstanceID / chunks_count_edge - (chunk_half * chunks_count_edge) + (i_x * chunk_tam);
	pos.z = gl_InstanceID % chunks_count_edge - (chunk_half * chunks_count_edge) + (i_z * chunk_tam);
	pos.y = 0.0, pos.w = 1.0;
	
	center_v = pos.xyz;
	chunk_half_v = chunk_half;
	gl_Position = pos;
}