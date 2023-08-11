#version 410 

in float chunk_half_v[];
in vec3 center_v[];

patch out float chunk_half_t;
patch out vec3 center_t;

uniform int uDetail;

layout(vertices = 1) out;

void main() {
    gl_out[gl_InvocationID].gl_Position = gl_in[0].gl_Position;

    center_t = center_v[0];
    chunk_half_t = chunk_half_v[0];

    gl_TessLevelOuter[0] = uDetail;
    gl_TessLevelOuter[1] = uDetail;
    gl_TessLevelOuter[2] = uDetail;
    gl_TessLevelOuter[3] = uDetail;
    gl_TessLevelInner[0] = uDetail;
    gl_TessLevelInner[1] = uDetail;
}