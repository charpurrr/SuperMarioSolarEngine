@tool
class_name OptionsScreen
extends Screen
## Submenu in the pause menu for setting various variables.[br][br]
## If you're looking for the actual option functionalities,
## consider looking in the GameState global.


func _ready() -> void:
	visible = true


func _on_reset_data_pressed() -> void:
	var warning_screen: WarningScreen = manager.get_screen(&"WarningScreen")

	warning_screen.text = """
	[center]Are you sure you want to clear all data?
	(This will [color=red]RESET[/color] all your settings.)"""

	warning_screen.return_screen = &"OptionsScreen"
	warning_screen.confirm_behaviour = warning_screen.reset_settings

	manager.switch_screen(self, warning_screen)
