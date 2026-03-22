extends Node3D

func cast(data: MiracleData, pos: Vector3):
	match data.miracleType:
		MiracleData.Type.METEOR:
			castMeteor(data, pos)
			
func castMeteor(data: MiracleData, pos: Vector3):
	var troops = get_tree().get_nodes_in_group("Troops")
	for troop in troops:
		if troop.global_position.distance_to(pos) < data.radius:
			troop.health -= data.damage
	pass
