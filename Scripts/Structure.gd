class_name Structure
extends Node

#@export var data: StructureData
@export var data: StructureData = preload("res://Scripts/Resources/Caserna.tres")
@onready var mesh : MeshInstance3D = $MeshInstance3D
@export var faction: StructureData.Owner
@export var units: int = 10
var level: int = 1

var selected := false
var originalMaterial : Material
var highlightMaterial : StandardMaterial3D
const highlightColor= {
	StructureData.Owner.PLAYER: Color(0.3, 1.0, 0.3),
	StructureData.Owner.NEUTRAL: Color(1.0, 1.0, 0.2),
	StructureData.Owner.ENEMY: Color(1.0, 0.2, 0.2)
}

func _ready() -> void:
	add_to_group("Structures")
	match faction:
		StructureData.Owner.PLAYER:
			add_to_group("Player")
		StructureData.Owner.NEUTRAL:
			add_to_group("Neutral")
		StructureData.Owner.ENEMY:
			add_to_group("Enemy")
	originalMaterial = mesh.get_active_material(0)
	highlightMaterial = StandardMaterial3D.new()
	pass

func set_selected(value: bool):
	selected = value
	if selected:
		highlightMaterial.albedo_color = highlightColor[faction]
		mesh.set_surface_override_material(0, highlightMaterial)
	else:
		mesh.set_surface_override_material(0, originalMaterial)
	pass

func update_units(value: int, add: bool, fac: StructureData.Owner):#address this elephant, please
	if add: #stacking
		units += value
	else: #attacking
		if units - value <= 0:
			match faction:
				StructureData.Owner.PLAYER: remove_from_group("Player")
				StructureData.Owner.NEUTRAL: remove_from_group("Neutral")
				StructureData.Owner.ENEMY: remove_from_group("Enemy")
			faction = fac
			match fac:
				StructureData.Owner.PLAYER: add_to_group("Player")
				StructureData.Owner.NEUTRAL: add_to_group("Neutral")
				StructureData.Owner.ENEMY: add_to_group("Enemy")
		var newValue = abs(units - value)
		units = newValue
