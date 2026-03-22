extends Resource
class_name StructureData

enum Owner {PLAYER, NEUTRAL, ENEMY}
@export var levels: Dictionary = {
	1: {"cost": 0, "productionRate": 1, "maxUnits": 40, "name": "Caserna"},
	2: {"cost": 30, "productionRate": 2, "maxUnits": 60, "name": "Quartel"},
}
