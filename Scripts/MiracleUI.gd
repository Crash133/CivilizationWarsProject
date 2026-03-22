extends CanvasLayer

signal miracleSelected(miracle: MiracleData)

@export var avaibleMiracles : Array[MiracleData]

func _ready() -> void:
	for data in avaibleMiracles:
		var btn = Button.new()
		btn.icon = data.icon
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(80, 80)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(func(): miracleSelected.emit(data))
		$Miracles/HBoxContainer.add_child(btn)
