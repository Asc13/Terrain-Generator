#version 410 

in float vRadius[];
in vec3 vCenter[];

uniform int noWater;

patch out float tcRadius;
patch out vec3 tcCenter;

uniform int uDetail;

layout(vertices = 1) out;

void main() {
    gl_out[gl_InvocationID].gl_Position = gl_in[0].gl_Position;

    tcCenter = vCenter[0];
    tcRadius = vRadius[0];

    gl_TessLevelOuter[0] = noWater * (uDetail / 10);
    gl_TessLevelOuter[1] = noWater * (uDetail / 10);
    gl_TessLevelOuter[2] = noWater * (uDetail / 10);
    gl_TessLevelOuter[3] = noWater * (uDetail / 10);
    gl_TessLevelInner[0] = noWater * (uDetail / 10);
    gl_TessLevelInner[1] = noWater * (uDetail / 10);
}