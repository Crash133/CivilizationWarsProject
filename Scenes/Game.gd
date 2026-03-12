extends Node3D

@onready var camera: Camera3D = $FlyCamera/CameraPivot/Camera3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
var selectedStructure = null
var attackedStructure = null
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_structure()
		if event.button_index == MOUSE_BUTTON_MIDDLE and selectedStructure and selectedStructure.faction == Structure.Owner.PLAYER:
			attack_structure()
	pass
	
func select_structure():
	var mouse_pos = camera.get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_dir * 10000
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 2 #structures
	
	var result = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		var node = result.collider
		
		while node and not node.has_method("set_selected"):
			node = node.get_parent()
		
		if node:
			if selectedStructure:
				selectedStructure.set_selected(false)
			
			selectedStructure = node
			selectedStructure.set_selected(true)
			return
	if selectedStructure:
		selectedStructure.set_selected(false)
		selectedStructure = null

func attack_structure():
	
	pass
