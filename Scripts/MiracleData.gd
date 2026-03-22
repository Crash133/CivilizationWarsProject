class_name MiracleData extends Resource

enum Type {METEOR} #add some more shit

@export var name: String = "New Miracle"
@export var miracleType: Type
@export var damage: float = 0
@export var cooldown: int = 0
@export var icon: AtlasTexture
@export var radius: float = 0
@export var cost: int
