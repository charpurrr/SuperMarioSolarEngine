shader_type canvas_item;

global uniform vec2 VIEWPORT_SIZE;

uniform float scale = 1.0;

uniform sampler2D cutout_texture: filter_nearest_mipmap;


void fragment() {
	const float EPSILON = 0.0001;

	if (!(scale >= 0.0 - EPSILON && scale <= 0.0 + EPSILON)) {
		float aspect_ratio = (VIEWPORT_SIZE.x/VIEWPORT_SIZE.y);
		float cutout_ratio = float(textureSize(cutout_texture, 0).y) / float(textureSize(cutout_texture, 0).x);

		float mask = texture(cutout_texture, ((UV - .5) * (1.0/scale) * vec2(aspect_ratio * cutout_ratio, 1.0)) + .5).a;

		COLOR.a = mask;
	}
}