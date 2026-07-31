extends VBoxContainer

@export var level_name: Label
@export var mission_name: Label
@export var mission_info: Label


func _ready():
	var wm: WorldMachine = owner.world_machine
	if wm == null: return

	var level: Level = wm.level_node

	level_name.text = level.level_name
	mission_name.text = level.mission_name
	mission_info.text = level.mission_info
