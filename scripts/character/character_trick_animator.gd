class_name CharacterTrickAnimator
extends TweenableNode

signal trick_completed

@export var character_animator: CharacterAnimator
@onready var board_bone := character_animator.board_bone

@export var kickflip_duration := 0.6
@export var kicklip_offset := Vector3(0, -0.5, -0.5)
@export var kickflip_offset_duration := 0.2


func start_kickflip(flick_direction: float):
    var offset = kicklip_offset
    var initial_rotation = -flick_direction * TAU
    if CharacterController.is_backwards:
        offset.z *= -1
        initial_rotation *= -1

    board_bone.rotation.x = initial_rotation
    var rotation_tween = tween_property("rotation:x", 0, kickflip_duration, board_bone)
    rotation_tween.tween_callback(finish_trick)
    
    var offset_tween = tween_property("position", offset, kickflip_offset_duration, board_bone)
    var recovery_duration = kickflip_duration - kickflip_offset_duration
    offset_tween.tween_property(board_bone, "position", Vector3.ZERO, recovery_duration)


func finish_trick():
    trick_completed.emit()
