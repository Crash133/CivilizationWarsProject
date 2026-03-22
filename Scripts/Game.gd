extends Node3D

@onready var camera: Camera3D = $FlyCamera/CameraPivot/Camera3D
enum interactionMode {SELECT, TARGETING}
var currentMode = interactionMode.SELECT
const targetIndicator = preload("res://Scenes/TargetElipse.tscn")
var activeIndicator = null
var selectedMiracle: MiracleData
var selectedStructure = null
var attackedStructure = null

signal structureClicked(Structure)
signal structureUpdated(Structure)

@export var aiDecisionTime: float = 3.0
var aiTimer: Timer

func _ready() -> void:
	set_process(false)
	add_to_group("Game")
	production_loop()
	ai_enemy()
	pass
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if currentMode == interactionMode.SELECT:
				select_structure()
			if currentMode == interactionMode.TARGETING and activeIndicator:
				var pos = activeIndicator.global_position
				$MiracleManager.cast(selectedMiracle, pos)
				_remove_miracle_mode()
		if event.button_index == MOUSE_BUTTON_MIDDLE and selectedStructure:
			if selectedStructure.faction == StructureData.Owner.PLAYER:
				attack_structure()
func _process(_delta: float) -> void:
	if !is_instance_valid(activeIndicator):
		set_process(false)
		return
	var pos = ray_cast_ground()
	if pos:
		activeIndicator.global_position = pos + Vector3(0, 0.1, 0)
func production_loop():
	while true:
		await get_tree().create_timer(1.0).timeout
		update_struc_prod()
func update_struc_prod():
	var structures = get_tree().get_nodes_in_group("Structures")
	for s in structures:
		if s.faction != StructureData.Owner.NEUTRAL:
			if s.units < s.data.levels[s.level]["maxUnits"]:
				s.units = min(s.units + s.data.levels[s.level]["productionRate"], s.data.levels[s.level]["maxUnits"])
			else:
				s.units = max(s.units - s.data.levels[s.level]["productionRate"], s.data.levels[s.level]["maxUnits"])
		structureUpdated.emit()
func ray_cast_structure() -> Structure:
	var mouse_pos = camera.get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_dir * 2000
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 2 #structures
	var result = camera.get_world_3d().direct_space_state.intersect_ray(query)
	
	if result:
		var node = result.collider
		while node and not node.has_method("set_selected"):
			node = node.get_parent()
		return node
	return null
func ray_cast_ground() -> Variant: #I FUCKING NEED TO JOIN THESE TWO TOGETHER
	var mouse_pos = camera.get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_dir * 2000
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 1 
	var result = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		return result.position
	return null
func select_structure(): #can be a little better on the logic side, nothing to worry
	var structure = ray_cast_structure()
	if structure:
		if selectedStructure:
			selectedStructure.set_selected(false) #deseleciona primeiro
		selectedStructure = structure
		selectedStructure.set_selected(true) #seleciona a nova
		structureClicked.emit(selectedStructure)
		return
	if selectedStructure:
		selectedStructure.set_selected(false)
		selectedStructure = null
		structureClicked.emit(false)
func attack_structure():
	attackedStructure = ray_cast_structure()
	if attackedStructure:
		selectedStructure.send_troops(attackedStructure)
func ai_enemy():
	aiTimer = Timer.new()
	add_child(aiTimer)
	aiTimer.wait_time = aiDecisionTime
	aiTimer.timeout.connect(ai_decision_tick)
	aiTimer.start()
func ai_decision_tick():
	var enemyStructures = get_tree().get_nodes_in_group("Enemy")
	var potentialTargets = get_tree().get_nodes_in_group("Neutral") + get_tree().get_nodes_in_group("Player")
	if enemyStructures.is_empty() or potentialTargets.is_empty():
		return
	var chosenStructure = enemyStructures.pick_random()
	if chosenStructure.units < 10:
		return
	var minScore = 999999
	var bestTarget = null
	
	for target in potentialTargets:
		var distance = chosenStructure.global_position.distance_to(target.global_position)
		var score = distance + (target.units * 10)
		if target.faction == StructureData.Owner.NEUTRAL:
			score /= 3
		if score < minScore:
			minScore = score
			bestTarget = target
			
	if bestTarget:
		chosenStructure.send_troops(bestTarget)
func _on_miracle_selected(miracle: MiracleData) -> void:
	if selectedStructure:
		selectedStructure.set_selected(false)
		selectedStructure = null
		structureClicked.emit(false)
	selectedMiracle = miracle
	currentMode = interactionMode.TARGETING
	if !is_instance_valid(activeIndicator):
		activeIndicator = targetIndicator.instantiate()
		get_tree().current_scene.add_child(activeIndicator)
		activeIndicator.set_radius(miracle.radius)
		set_process(true)
func _remove_miracle_mode():
	if is_instance_valid(activeIndicator):
		activeIndicator.queue_free()
		activeIndicator = null
	currentMode = interactionMode.SELECT
	set_process(false)
