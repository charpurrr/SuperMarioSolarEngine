extends AudioStreamPlayer

signal music_changed()

@export var music: Resource:
	set(val):
		music = val

		if not Engine.is_editor_hint() and is_instance_valid(music):
			_play()


var current_song: Song


func _play():
	if music is Song:
		_set_song(music)
	elif music is SongPlaylist:
		_play_playlist(music.shuffle, music.loop)
	else:
		push_error("Music is neither of type Song nor SongPlaylist. Unsupported type.")


func _set_song(song: Song):
	current_song = song
	stream = song.stream
	music_changed.emit()
	play()


func _play_playlist(shuffled: bool, looped: bool):
	var songs: Array[Song] = music.songs.duplicate()

	# Alternative to do... while. Makes sure this code gets ran at least once even when not looped.
	while true:
		if shuffled:
			songs.shuffle()

		for song in songs:
			_set_song(song)
			await finished

		if not looped:
			break
