shader_type canvas_item;

global uniform vec2 VIEWPORT_SIZE;

uniform vec2 cell_size = vec2(32.0);
uniform vec2 line_thickness = vec2(2.0);

uniform vec4 line_color : source_color = vec4(0.5);
uniform vec4 bg_color : source_color = vec4(0);
uniform float grid_fade_threshold : hint_range(0.0, 4.0) = 2.0;

uniform vec2 grid_offset = vec2(0.0);
uniform vec2 camera_position = vec2(0.0);
uniform vec2 camera_zoom = vec2(1.0);

// Function to get the color of grid at a given UV. Grid repeats every 1, 1 UV
vec4 grid(vec2 uv) {
	// We will be working within a tile, since they repeat
	vec2 uv_within_tile = mod(uv, 1);
	
	// Measure distance of tile_uv from 0.5 (center of the tile)
	vec2 uv_distance_from_center = abs(vec2(0.5) - uv_within_tile);
	
	// This distance must be less than this to lie on the line.
	vec2 line_uv_thickness = line_thickness/(2.0*cell_size);
	
	bool is_on_horizontal_line = uv_distance_from_center.y < line_uv_thickness.y;
	bool is_on_vertical_line = uv_distance_from_center.x < line_uv_thickness.x;
	
	if (is_on_horizontal_line || is_on_vertical_line) {
		return line_color;
	} else {
		return bg_color;
	}
}

void fragment() {
	// Find the tiled UV at this world position.
	vec2 world_pos = (UV * VIEWPORT_SIZE) / camera_zoom + camera_position - (VIEWPORT_SIZE * 0.5) / camera_zoom;
	vec2 offset_pos = world_pos - grid_offset + cell_size;
	vec2 tiled_uv = offset_pos / cell_size;

	// BG is made more transparent when zoomed out
	float bg_alpha = smoothstep(0.0, grid_fade_threshold, camera_zoom.x);
	// The grid function gets the color at this UV. 
	// This is multiplied with the alpha value above.
	COLOR = grid(tiled_uv) * vec4(1.0, 1.0, 1.0, bg_alpha);
}