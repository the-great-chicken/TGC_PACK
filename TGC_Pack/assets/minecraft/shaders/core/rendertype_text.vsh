#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

bool isAt(int offset, int vID, int pos) {
	return (((vID == 1 || vID == 2) && offset == pos) || ((vID == 0 || vID == 3) && offset == (pos+8)));
}

void main() {
    vec3 pos = Position;

    vec2 pixel = vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
    int guiScale = int(round(pixel.x / (1.0 / ScreenSize.x)));
    vec2 guiSize = ScreenSize / guiScale;
    int vID = gl_VertexID % 4;
    int offset = int(round(guiSize.y - Position.y));

    // Default color
    vertexColor = Color * sample_lightmap(Sampler2, UV2);

    if(Position.z == 0.0 
        && ((length(Color.rgb - vec3(0.501, 1.0, 0.125)) < 0.002 
            && (isAt(offset, vID, 26) || isAt(offset, vID, 27))) 
        || (length(Color.rgb - vec3(0.0, 0.0, 0.0)) < 0.002 
            && (isAt(offset, vID, 25) || isAt(offset, vID, 26) 
                || isAt(offset, vID, 27) || isAt(offset, vID, 28))))) 
    { 
        // Move XP number
        pos += vec3(0.7, 5.0, 0.0);

        // Recolor XP number
        if(length(Color.rgb - vec3(0.0, 0.0, 0.0)) < 0.002) {
            vertexColor = vec4(0.0, 0.0, 0.0, 1.0);
        } else {
            vertexColor = vec4(0.909804, 0.556863, 0.101961, 1.0); // #e88e1a
        }
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    texCoord0 = UV0;
}