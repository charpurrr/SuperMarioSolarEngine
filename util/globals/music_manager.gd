extends AudioStreamPlayer

signal music_changed()

var music: Resource:
	set(val):
		music = val

		if is_instance_valid(music):
			_play()

var current_song: Song

var play_id: int = 0


func _ready() -> void:
	StageCache.area_loaded.connect(_on_area_load)


func _on_area_load() -> void:
	var new_music: Resource = StageManager.stage.music

	if new_music == music and playing:
		return

	music = StageManager.stage.music


func _play() -> void:
	play_id += 1

	if music is Song:
		_set_song(music)
	elif music is SongPlaylist:
		_play_playlist(music.shuffle, music.loop)
	else:
		push_error("Music is neither of type Song nor SongPlaylist. Unsupported type.")


func _set_song(song: Song) -> void:
	current_song = song
	stream = song.stream
	music_changed.emit()
	play()


func _play_playlist(shuffled: bool, looped: bool) -> void:
	var id: int = play_id
	var songs: Array[Song] = music.songs.duplicate()

	# Alternative to do... while. Makes sure this code gets ran at least once even when not looped.
	while true:
		if shuffled:
			songs.shuffle()

		for song in songs:
			_set_song(song)
			await finished

			if id != play_id:
				return

		if not looped:
			break
