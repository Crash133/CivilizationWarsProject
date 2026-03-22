extends Node3D

@onready var MMInstance: MultiMeshInstance3D = $MultiMeshInstance3D
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

var targetBase: Node3D
var selfStructure: Node3D
var targetFaction: int
var faction: int
var speed: float = 4.0
var health: float = 1.0
var troopsOffsets = []

func setup(origin: Vector3, target: Node3D, ownerFaction: int, count: int, source: Node3D):
	MMInstance.multimesh = MMInstance.multimesh.duplicate()
	add_to_group("Troops")
	global_position = origin
	targetBase = target
	faction = ownerFaction
	targetFaction = target.faction
	MMInstance.multimesh.instance_count = count
	selfStructure = source
	for i in range(count):
		var offset = Vector3(randf_range(-2,2), 0, randf_range(-2,2))
		troopsOffsets.append(offset)
	await get_tree().process_frame
	if targetBase:
		navAgent.target_position = targetBase.global_position

func _physics_process(delta: float) -> void:
	if !targetBase or health <= 0:
		queue_free()
		return
	var nextPathPos = navAgent.get_next_path_position()
	var dir = (nextPathPos - global_position).normalized()
	global_position += dir * speed * delta
	_updateMultimesh(dir)

func _updateMultimesh(dir: Vector3):
	if dir.is_zero_approx():
		return
	var visibleCount = int(troopsOffsets.size() * health)
	MMInstance.multimesh.instance_count = visibleCount
	
	for i in range(visibleCount):
		var posLocal = troopsOffsets[i]
		var t = Transform3D(Basis.looking_at(dir, Vector3.UP),posLocal)
		MMInstance.multimesh.set_instance_transform(i, t)
	
func _on_navigation_agent_3d_navigation_finished() -> void:
	if targetFaction == faction:
		targetBase.update_units(troopsOffsets.size() * health, 1, faction)
	else:
		targetBase.update_units(troopsOffsets.size() * health, 0, faction)
	queue_free()
	
func _exit_tree() -> void:
	selfStructure.activeWave = false
