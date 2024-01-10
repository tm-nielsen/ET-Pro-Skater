class_name CharacterTrickAnimator
extends TweenableNode

signal trick_completed

@export_subgroup("references")
@export var board_animator: CharacterBoardAnimator
@export var rotation_node: Node3D
@export var character_animator: CharacterAnimator

@export_subgroup("commitments")
@export var kickflip_commitment := 0.45
@export var shuvit_commitment := 0.6
@export var dolphin_flip_commitment := 0.7
@export var body_flip_commitment := 0.8
@export var christ_air_commitment := 0.2

@export_subgroup("grab tilt", "grab_tilt")
@export var grab_tilt_angle := 1.0
@export var grab_tilt_tween_duration := 0.3

@export_subgroup("body flip", "body_flip")
@export var body_flip_duration := 1.0
@export var body_flip_curve: Curve
var body_flip_initial_rotation: float

var skeletal_animation_player: AnimationPlayer
var commitment_tween: Tween


func _ready():
    skeletal_animation_player = character_animator.animation_player
    skeletal_animation_player.animation_finished.connect(on_animation_finished)


func start_kickflip(flick_direction: float):
    board_animator.start_kickflip(flick_direction)
    _tween_commitment(kickflip_commitment)

func start_shuvit(flick_direction: float):
    board_animator.start_shuvit(flick_direction)
    _tween_commitment(shuvit_commitment)

func start_dolphin_flip(flick_direction: float):
    board_animator.start_dolphin_flip(flick_direction)
    _tween_commitment(dolphin_flip_commitment)


func prep_shuvit():
    board_animator.prep_shuvit()

func unprep_shuvit():
    board_animator.unprep_shuvit()


func start_grab_tilt(tilt_direction: float):
    var tilt_angle = grab_tilt_angle * tilt_direction
    tilt_angle *= CharacterController.is_forward_sign
    tween_property("rotation:x", -tilt_angle, grab_tilt_tween_duration, rotation_node)


func start_body_flip(flip_direction: float):
    kill_all_active_tweens()

    body_flip_initial_rotation = grab_tilt_angle + TAU
    body_flip_initial_rotation *= flip_direction
    body_flip_initial_rotation *= CharacterController.is_forward_sign

    var body_flip_tween = create_tween()
    body_flip_tween.tween_method(_set_body_flip_rotation, 0.0, 1.0, body_flip_duration)
    active_tweens.append(body_flip_tween)
    _tween_commitment(body_flip_commitment)

func _set_body_flip_rotation(t: float):
    var curved_t = body_flip_curve.sample(t)
    rotation_node.rotation.x = lerpf(body_flip_initial_rotation, 0, curved_t)


func start_christ_air():
    character_animator.board_bone.override_pose = false
    skeletal_animation_player.play("Christ Air")

func end_christ_air():
    skeletal_animation_player.play_backwards("Christ Air")
    _tween_commitment(christ_air_commitment)


func crash():
    kill_all_active_tweens()
    board_animator.reset()
    character_animator.board_bone.override_pose = false
    skeletal_animation_player.play("Crash")

func on_animation_finished(animation_name: String):
    if animation_name == "Crash":
        skeletal_animation_player.play("Idle")
        board_animator.reset()


func reset():
    kill_all_active_tweens()
    rotation_node.rotation.x = 0
    board_animator.reset()

func kill_all_active_tweens():
    super()
    if commitment_tween:
        commitment_tween.kill()


func _tween_commitment(commitment_time: float):
    commitment_tween = create_tween()
    commitment_tween.tween_interval(commitment_time)
    commitment_tween.tween_callback(_finish_trick)

func _finish_trick():
    trick_completed.emit()
