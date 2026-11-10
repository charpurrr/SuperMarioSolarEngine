extends Node

## The stored UUID of the last activated checkpoint.
var last_checkpoint: String


func clear() -> void:
	last_checkpoint = ""
