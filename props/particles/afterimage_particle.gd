@tool
extends CPUParticles2D

@export var doll: AnimatedSprite2D:
	set(val):
		doll = val
		texture = val.sprite_frames.get_frame_texture(val.animation, val.frame)
		material.set_shader_parameter(&"flip_h", doll.flip_h)

@export var trail_color: Color = Color.WHITE:
	set(val):
		trail_color = val
		material.set_shader_parameter(&"color", val)
