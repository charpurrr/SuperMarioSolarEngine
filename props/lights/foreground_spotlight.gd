class_name ForegroundSpotlight
extends PointLight2D
## Light that gets enabled based on whether or not
## [member LevelEnvironment.foreground_spotlights] is turned on.


func _ready() -> void:
	await get_tree().process_frame
	enabled = GameState.spotlights_enabled
