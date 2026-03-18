extends Control

var target = null
@onready var levelLabel = $VBoxContainer/Level
@onready var nameLabel = $VBoxContainer/Name
@onready var factionLabel = $VBoxContainer/Faction
@onready var upgradeButton = $VBoxContainer/UpgradeButton

func open(structure):
	target = structure
	updatePanel()
	show()
	
func updatePanel(): #there's a lot of problems here: 1 - if the last clicked structure is a neutral, the next click on a player structure will make the button hide
	if !target: return
	nameLabel.text = target.data.levels[target.level]["name"]
	levelLabel.text = "Level: " + str(target.level)
	factionLabel.text = "Facção: " + str(StructureData.Owner.keys()[target.faction])
	if target.faction == StructureData.Owner.PLAYER:
		if target.data.levels.has(target.level + 1):
			upgradeButton.text = "Melhorar (" + str(target.data.levels[target.level + 1]["cost"]) + ")"
			upgradeButton.disabled = target.units < target.data.levels[target.level + 1]["cost"]
			upgradeButton.show()
		else:
			upgradeButton.text = "Level Máximo!"
			upgradeButton.disabled = true
	else:
		upgradeButton.hide()
	
func _on_upgrade_button_pressed() -> void:
	target.update_units(target.data.levels[target.level + 1]["cost"], 0, StructureData.Owner.PLAYER)
	target.level += 1
