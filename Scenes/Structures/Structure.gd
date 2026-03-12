class_name Structure
extends Node

@onready var mesh : MeshInstance3D = $MeshInstance3D
enum Owner {PLAYER, ENEMY, NEUTRAL}

@export var faction : Owner = Owner.NEUTRAL
@export var units : int = 10
@export var production_rate : float = 1.0

var production_timer := 0.0
var selected := false
var originalMaterial : Material
var highlightMaterial : StandardMaterial3D
const highlightColor= {
	Owner.PLAYER: Color(0.3, 1.0, 0.3),
	Owner.NEUTRAL: Color(1.0, 1.0, 0.2),
	Owner.ENEMY: Color(1.0, 0.2, 0.2)
}

func _ready() -> void:
	originalMaterial = mesh.get_active_material(0)
	highlightMaterial = StandardMaterial3D.new()
	pass

func _process(delta) -> void:
	production_timer += delta
	
	if production_timer >= 1.0:
		units += production_rate
		production_timer = 0
		update_label()
		pass

func set_selected(value: bool):
	selected = value
	if selected:
		highlightMaterial.albedo_color = highlightColor[faction]
		mesh.set_surface_override_material(0, highlightMaterial)
	else:
		mesh.set_surface_override_material(0, originalMaterial)
	pass
	
func get_faction():
	return faction

func update_label():
	$Label3D.text = str(units)
