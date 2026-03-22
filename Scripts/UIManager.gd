extends CanvasLayer

@onready var upgradePanel = $StructurePanel
@onready var camera: Camera3D
var unitsLabels = {}
var labelScene = preload("res://Scenes/UnitsLabel.tscn")

func _ready() -> void:
	camera = get_tree().get_nodes_in_group("MainCamera")[0]
	upgradePanel.hide()
	var gameNode = get_tree().get_nodes_in_group("Game")[0]
	gameNode.structureClicked.connect(_on_structure_clicked)
	gameNode.structureUpdated.connect(_on_structure_update)
	
	for structures in get_tree().get_nodes_in_group("Structures"):
		var unitLabel = labelScene.instantiate()
		$UnitsLabels.add_child(unitLabel)
		unitsLabels[structures] = unitLabel

func _on_structure_clicked(structure):
	if structure:
		upgradePanel.open(structure)
	else:
		upgradePanel.hide()
		
func _on_structure_update():
	upgradePanel.updatePanel()

func _process(_delta: float) -> void:
	var viewportSize = camera.get_viewport().size
	var containerSize = get_node("../PixelArtEffectContainer").size # O tamanho dele na tela
	var containerPos = get_node("../PixelArtEffectContainer").global_position
	var scaleFactor = Vector2(
		containerSize.x / viewportSize.x,
		containerSize.y / viewportSize.y)
	
	if upgradePanel.visible and upgradePanel.target:
		var basePos = upgradePanel.target.global_position
		_update_ui_element_position(upgradePanel, basePos, scaleFactor, containerPos, Vector2(0, -160))
	
	for base in unitsLabels.keys():
		if is_instance_valid(base):
			var label = unitsLabels[base]
			_update_ui_element_position(label, base.global_position, scaleFactor, containerPos, Vector2(0, -50))
			label.set_text(str(base.units))

func _update_ui_element_position(element: Control, worldPos: Vector3, scaleFactor: Vector2, containerPos: Vector2, offsetDir: Vector2):
	if not camera.is_position_behind(worldPos):
		element.visible = true
		var screenPos = camera.unproject_position(worldPos)
		var finalPos = (screenPos * scaleFactor) + containerPos
		element.position = finalPos - (element.size / 2) + offsetDir
	else:
		element.visible = false
