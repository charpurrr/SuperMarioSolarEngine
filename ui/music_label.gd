extends Label

@export var anime: AnimationPlayer


func _ready() -> void:
	MusicManager.music_changed.connect(animate_label)


func animate_label():
	if GameState.buses[&"Music"].muted:
		return

	text = "♪ %s - %s" % [MusicManager.current_song.song_name, MusicManager.current_song.artist]
	anime.play(&"fade_past")
