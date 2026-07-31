class_name PauseScreen
extends Screen
## Main pause screen functionality.

@export var retry: UIButton
@export var reset: UIButton


func _ready() -> void:
	if owner.world_machine == null:
		retry.toggle_disable(true)
		reset.toggle_disable(true)


func _on_resume_pressed() -> void:
	GameState.paused.emit()
	manager.switch_screen(self)


func _on_retry_pressed() -> void:
	ui.world_machine.reload_level()
	manager.switch_screen(self)


func _on_reset_pressed() -> void:
	var warning_screen: WarningScreen = manager.get_screen(&"WarningScreen")

	warning_screen.text = """
	[center]Restart the level from the beginning?
	(Any unsaved progress will be [color=red]LOST[/color].)"""

	warning_screen.confirm_behaviour = warning_screen.restart

	manager.switch_screen(self, warning_screen)


func _on_action_guide_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	manager.switch_screen(self, manager.get_screen(&"OptionsScreen"))


func _on_quit_pressed() -> void:
	var warning_screen: WarningScreen = manager.get_screen(&"WarningScreen")

	warning_screen.text = """
	[center]Exit to title screen?
	(Any unsaved progress will be [color=red]LOST[/color].)"""

	warning_screen.confirm_behaviour = warning_screen.quit

	manager.switch_screen(self, warning_screen)
