shader_type canvas_item;

uniform bool flip_h = false;
uniform bool flip_v = false;


void vertex() {
	if (flip_h) VERTEX.x = -VERTEX.x;
	if (flip_v) VERTEX.y = -VERTEX.y;
}