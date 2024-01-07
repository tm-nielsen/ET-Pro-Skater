class_name CharacterTrickAnimator
extends TweenableNode

signal trick_completed

@export var character_animator: CharacterAnimator
@onready var board_bone := character_animator.board_bone

@export_subgroup("kickflip", "kickflip")
@export var kickflip_duration := 0.6
@export var kickflip_commitment := 0.45
@export var kickflip_offset := Vector3(0.1, -0.3, 0)
@export var kickflip_offset_duration := 0.2

@export_subgroup("shuvit", "shuvit")
@export var shuvit_duration := 0.7
@export var shuvit_commitment := 0.6
@export var shuvit_offset := Vector3(-0.05, -0.1, 0.1)
@export var shuvit_offset_duration := 0.4
@export var shuvit_prep_offset := Vector3(-0.1, 0, 0)
@export var shuvit_prep_duration := 0.1

@export_subgroup("dolphin flip", "dolphin_flip")
@export var dolphin_flip_duration := 0.8
@export var dolphin_flip_commitment := 0.7
@export var dolphin_flip_offset := Vector3(0.1, -0.6, 0)
@export var dolphin_flip_offset_duration := 0.2


var active_tweens: Array[Tween] = []


func start_kickflip(flick_direction: float):
    _start_board_flip(flick_direction, Vector3.RIGHT, "x",
            kickflip_duration, kickflip_offset, kickflip_offset_duration)
    _tween_commitment(kickflip_commitment)

func start_shuvit(flick_direction: float):
    _start_board_flip(flick_direction, Vector3.UP, "y",
            shuvit_duration, shuvit_offset, shuvit_offset_duration)
    _tween_commitment(shuvit_commitment)

func start_dolphin_flip(flick_direction: float):
    _start_board_flip(flick_direction, Vector3.FORWARD, "z",
            dolphin_flip_duration, dolphin_flip_offset, dolphin_flip_offset_duration)
    _tween_commitment(dolphin_flip_commitment)


func _start_board_flip(flick_direction: float, rotation_axis: Vector3, axis_string: String,
            duration: float,offset: Vector3, offset_duration: float):
    kill_all_active_tweens()
    var initial_rotation = -flick_direction * TAU
    if CharacterController.is_backwards:
        offset.z *= -1
        initial_rotation *= -1

    board_bone.rotation = initial_rotation * rotation_axis
    var rotation_property_string = "rotation:%s" % axis_string
    tween_property(rotation_property_string, 0, duration, board_bone)
    
    var offset_tween = tween_property("position", offset, offset_duration, board_bone)
    var recovery_duration = duration - offset_duration
    offset_tween.tween_property(board_bone, "position", Vector3.ZERO, recovery_duration)


func prep_shuvit():
    tween_property("position", shuvit_prep_offset, shuvit_prep_duration, board_bone)

func unprep_shuvit():
    tween_property("position", Vector3.ZERO, shuvit_prep_duration, board_bone)


func _tween_commitment(commitment_time: float):
    var commitment_tween = create_tween()
    commitment_tween.tween_interval(commitment_time)
    commitment_tween.tween_callback(_finish_trick)

func _finish_trick():
    trick_completed.emit()


func kill_all_active_tweens():
    for tween in active_tweens:
        if tween:
            tween.kill()
    active_tweens = []

func create_and_initialize_tween() -> Tween:
    var new_tween = super()
    active_tweens.append(new_tween)
    return new_tween
