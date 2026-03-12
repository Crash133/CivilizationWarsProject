extends CharacterBody3D

@export var move_speed := 20.0
@export var acceleration := 10.0

@export var mouse_sensitivity := 0.2
@export var zoom_speed := 1.0

@export var min_zoom := 5.0
@export var max_zoom := 20.0

var rotating := false
var yaw := 0.0
var pitch := -30.0

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D


func _ready():
	camera.current = true
	yaw = pivot.rotation_degrees.y
	pitch = camera.rotation_degrees.x
	camera.position.y = clamp(camera.position.y, min_zoom, max_zoom)

func _unhandled_input(event):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.y -= zoom_speed

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.y += zoom_speed

		camera.position.y = clamp(camera.position.y, min_zoom, max_zoom)


	if event is InputEventMouseMotion and rotating:

		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -80, -10)

		pivot.rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch


func _physics_process(delta):

	var input := Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		input.z -= 1
	if Input.is_key_pressed(KEY_S):
		input.z += 1
	if Input.is_key_pressed(KEY_A):
		input.x -= 1
	if Input.is_key_pressed(KEY_D):
		input.x += 1

	input = input.normalized()

	var basis := pivot.global_transform.basis

	var dir := basis.x * input.x + basis.z * input.z

	var target := dir * move_speed

	velocity = velocity.lerp(target, acceleration * delta)

	move_and_slide()
