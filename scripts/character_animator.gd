extends Node3D

@export_group("References")
@export var body: Node3D
@export var board: Node3D
@export var physics_body: CharacterBody3D = get_parent()

@export_group("Parameters")
@export var crouch_scale := 0.5
@export var turn_angle := 0.25
@export var tilt_offset := Vector3(0, 0.2, 0.05)
@export var tilt_angle := 1.0


func _physics_process(_delta):
    rotation = Vector3.ZERO
    position = Vector3.ZERO
    scale = Vector3.ONE

    if Input.is_action_pressed("left"):
        rotation.z = turn_angle
    if Input.is_action_pressed("right"):
        rotation.z -= turn_angle

    var up_is_pressed = Input.is_action_pressed("up")
    var down_is_pressed = Input.is_action_pressed("down")
    if up_is_pressed && !down_is_pressed:
        rotation.x = -turn_angle
        position = tilt_offset
        position.z *= -1
    elif down_is_pressed && !up_is_pressed:
        rotation.x += turn_angle
        position = tilt_offset

    if Input.is_action_pressed("crouch"):
        scale.y = crouch_scale
