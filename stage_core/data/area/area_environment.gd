class_name AreaEnvironment
extends SerializedResource
## Configuration for an [Area]'s environment.

enum WeatherType {
	CLEAR,
	RAIN,
	SNOW,
	STORM,
}

@export var weather: WeatherType
#@export var background: Variant
@export var music: Song


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
