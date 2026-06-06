class_name OptionsScreen
extends Screen
## Submenu in the pause menu for setting various variables.[br][br]
## If you're looking for the actual option functionalities,
## consider looking in the GameState global.
## If you're looking for the different settings stored on the user's
## system, consider looking in the LocalSettings global. 

@export var tabs: TabContainer
@export var clear_controls: HBoxContainer
@export var reset_controls: HBoxContainer


func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_gui_focus_changed)
	clear_controls.hide()
	reset_controls.hide()


func _gui_focus_changed(node: Control) -> void:
	clear_controls.visible = node is UIBindButton
	reset_controls.visible = (
		node is OptionBase or
		node is HSlider or
		node is UIBindButton or
		node is UISelector
	)


func on_load() -> void:
	tabs.grab_focus_for_tab(tabs.current_tab)


func _on_reset_data_pressed() -> void:
	var warning_screen: WarningScreen = manager.get_screen(&"WarningScreen")

	warning_screen.text = """
	[center]Are you sure you want to clear all data?
	(This will [color=red]RESET[/color] all your settings.)"""

	warning_screen.return_screen = &"OptionsScreen"
	warning_screen.confirm_behaviour = warning_screen.reset_settings

	manager.switch_screen(self, warning_screen)
