class_name CharacterAnimator
extends TweenableNode

@export_group("References")
@export var character_skeleton: Skeleton3D
@export var animation_player: AnimationPlayer
@export var body_bone_name := "Back"
@onready var body_bone_index := character_skeleton.find_bone(body_bone_name)
@export var board_bone: BoneAttachment3D

@export_group("Parameters")
@export_subgroup("crouch", "crouch")
@export var crouch_scale := Vector3(1.2, 0.4, 1.6)
@export var crouch_tween_duration := 0.15

@export_subgroup("jump", "jump")
@export var jump_scale := Vector3(0.6, 1.8, 0.4)
@export var jump_tween_duration := 0.05

@export_subgroup("turn", "turn")
@export var turn_angle := 0.25
@export var turn_tween_duration := 0.3

@export_subgroup("tilt", "tilt")
@export var tilt_offset := Vector2(0.1, 0.4)
@export var tilt_angle := 0.6
@export var tilt_tween_duration := 0.2

var body_scale: Vector3: set = _set_body_scale


func _ready():
    InputProxy.crouch_pressed.connect(on_crouch_pressed)
    InputProxy.crouch_released.connect(on_crouch_released)
    InputProxy.direction_changed.connect(on_input_direction_changed)
    animation_player.play("Idle")

func on_crouch_pressed():
    if CharacterController.input_disabled:
        return
    tween_property("body_scale", crouch_scale, crouch_tween_duration)

func on_crouch_released():
    if CharacterController.input_disabled:
        return
    var tween = tween_property("body_scale", jump_scale, crouch_tween_duration)
    tween.tween_property(self, "body_scale", Vector3.ONE, crouch_tween_duration)


func on_input_direction_changed(input_direction: Vector2i):
    if !CharacterController.is_grounded || CharacterController.input_disabled:
        return

    var old_input_direction = InputProxy.direction

    if input_direction.x != old_input_direction.x:
        start_turn_tween(input_direction.x * CharacterController.is_forward_sign)
    if input_direction.y != old_input_direction.y:
        start_tilt_tween(input_direction.y * CharacterController.is_forward_sign)


func start_turn_tween(turn_direction: float):
    tween_property("rotation:z", -turn_direction * turn_angle, turn_tween_duration)


func start_tilt_tween(tilt_direction: float):
    tween_property("rotation:x", -tilt_angle * tilt_direction, tilt_tween_duration)
    var offset_position = position
    offset_position.y = tilt_offset.y * abs(tilt_direction)
    offset_position.z = -tilt_direction * tilt_offset.x
    tween_property("position", offset_position, tilt_tween_duration)


func _on_character_left_ground():
    start_turn_tween(0)
    start_tilt_tween(0)

func _on_character_landed():
    var input_direction = InputProxy.direction
    animation_player.play(get_aligned_animation_name("Idle"))
    animation_player.advance(1)
    input_direction *= CharacterController.is_forward_sign
    start_turn_tween(input_direction.x)
    start_tilt_tween(input_direction.y)

    if InputProxy.is_crouched:
        body_scale = crouch_scale


func reset():
    kill_all_active_tweens()
    position = Vector3.ZERO
    rotation = Vector3.ZERO


func uncrash():
    animation_player.play("Idle")
    animation_player.advance(1)
    if InputProxy.is_crouched:
        body_scale = crouch_scale


func _on_character_pushed():
    animation_player.play(get_aligned_animation_name("Push"))
    animation_player.animation_finished.connect(_on_push_animation_finished, CONNECT_ONE_SHOT)

func _on_push_animation_finished(_animation_name):
    if InputProxy.is_crouched:
        body_scale = crouch_scale


func get_aligned_animation_name(base_name: String) -> String:
    if CharacterController.is_backwards:
        base_name += " Reverse"
    return base_name


func _set_body_scale(new_scale: Vector3):
    character_skeleton.set_bone_pose_scale(body_bone_index, new_scale)
