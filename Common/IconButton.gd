extends Button

@export var iconName: String:
	set(value):
		iconName = value
		if $Icon != null:
			$Icon.icon_name = value

@export_range(1, 16, 1, "or_greater") var iconSize: int:
	set(value):
		iconSize = value
		if $Icon != null:
			$Icon.icon_size = value
		custom_minimum_size = Vector2(value + 4, value + 4)

@export var activeColor := Color(0.0, 0.766, 0.84, 1.0)
@export var inactiveColor := Color(1, 1, 1, 1.0)

var alpha = 0.75:
	set(value):
		alpha = value
		modulate.a = value

func _ready() -> void:
	if button_pressed:
		var color = activeColor
		activeColor = inactiveColor
		inactiveColor = color
		modulate = Color(inactiveColor.r, inactiveColor.g, inactiveColor.b, alpha)

func onMouseEntered() -> void:
	alpha = lerp(alpha, 1.0, 0.5)

func onMouseExited() -> void:
	alpha = lerp(alpha, 0.75, 0.5)

func onButtonDown() -> void:
	modulate = Color(activeColor.r, activeColor.g, activeColor.b, alpha)

	if toggle_mode:
		var color = activeColor
		activeColor = inactiveColor
		inactiveColor = color

func onButtonUp() -> void:
	modulate = Color(inactiveColor.r, inactiveColor.g, inactiveColor.b, alpha)
