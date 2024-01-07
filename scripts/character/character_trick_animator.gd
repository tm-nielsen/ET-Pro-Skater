class_name CharacterTrickAnimator
extends TweenableNode

signal trick_completed

@export var character_animator: CharacterAnimator
@onready var board_bone := character_animator.board_bone

@export_subgroup("kickflip", "kickflip")
@export var kickflip_duration := 0.5
@export var kickflip_offset := Vector3(-0.1, -0.3, 0)
@export var kickflip_offset_duration := 0.2

@export_subgroup("shuvit", "shuvit")
@export var shuvit_duration := 0.6
@export var shuvit_offset := Vector3(0.2, -0.1, 0)
@export var shuvit_offset_duration := 0.4
@export var shuvit_prep_offset := Vector3(0, -0.2, 0)
@export var shuvit_prep_duration := 0.2

@export_subgroup("dolphin flip", "dolphin_flip")
@export var dolphin_flip_duration := 0.8
@export var dolphin_flip_offset := Vector3(0.1, -0.6, 0)
@export var dolphin_flip_offset_duration := 0.2


func start_kickflip(flick_direction: float):
    _start_board_flip(flick_direction, Vector3.RIGHT, "x",
            kickflip_duration, kickflip_offset, kickflip_offset_duration)

func start_shuvit(flick_direction: float):
    _start_board_flip(flick_direction, Vector3.UP, "y",
            shuvit_duration, shuvit_offset, shuvit_offset_duration)

func start_dolphin_flip(flick_direction: float):
    _start_board_flip(flick_direction, Vector3.FORWARD, "z",
            dolphin_flip_duration, dolphin_flip_offset, dolphin_flip_offset_duration)


func _start_board_flip(flick_direction: float, rotation_axis: Vector3, axis_string: String,
            duration: float,offset: Vector3, offset_duration: float):
    var initial_rotation = -flick_direction * TAU
    if CharacterController.is_backwards:
        offset.z *= -1
        initial_rotation *= -1

    board_bone.rotation = initial_rotation * rotation_axis
    var rotation_property_string = "rotation:%s" % axis_string
    var rotation_tween = tween_property(rotation_property_string, 0, duration, board_bone)
    rotation_tween.tween_callback(finish_trick)
    
    var offset_tween = tween_property("position", offset, offset_duration, board_bone)
    var recovery_duration = duration - offset_duration
    offset_tween.tween_property(board_bone, "position", Vector3.ZERO, recovery_duration)


func prep_shuvit():
    tween_property("position", shuvit_prep_offset, shuvit_prep_duration, board_bone)

func unprep_shuvit():
    tween_property("position", Vector3.ZERO, shuvit_prep_duration, board_bone)


func finish_trick():
    trick_completed.emit()
