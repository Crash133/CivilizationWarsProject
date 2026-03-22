extends Node3D

@onready var decal = $Decal

func set_radius(radius: float) -> void:
	decal.size = Vector3(radius*2, decal.size.y, radius*2)
