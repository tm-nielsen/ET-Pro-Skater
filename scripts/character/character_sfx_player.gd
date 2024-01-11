class_name CharacterSfxPlayer
extends Node3D

const OllieType = CharacterJumpManager.OllieType
const TrickType = CharacterTrickManager.TrickType

@export_subgroup("references")
@export var character_controller: CharacterController
@export var jump_manager: CharacterJumpManager
@export var trick_manager: CharacterTrickManager

@export_subgroup("audio sources", "audio_source")
@export var audio_source_jump: AudioStreamPlayer3D
@export var audio_source_ollie: AudioStreamPlayer3D
@export var audio_source_push: AudioStreamPlayer3D

@export var audio_source_crash: AudioStreamPlayer3D
@export var audio_source_landing: AudioStreamPlayer3D
@export var audio_source_landed_after_trick: AudioStreamPlayer3D

@export var audio_source_tricks: Array[AudioStreamPlayer3D]
@export var audio_source_christ_air: AudioStreamPlayer3D

@export var audio_source_skateboard_loop: AudioStreamPlayer3D

@export_subgroup("parameters")
@export_range(0, 1) var maximum_skateboard_volume := 0.5
@export var skateboard_loop_scaling_speed := 100.0
@export_range(0, 1) var perfect_ollie_volume := 0.5
@export_range(0, 1) var partial_ollie_volume := 0.2
@export_range(0, 1) var tilt_hop_volume := 0.4

var trick_completed: bool


func _ready():
    character_controller.pushed.connect(_on_pushed)
    jump_manager.jumped.connect(_on_jumped)
    jump_manager.ollied.connect(_on_ollied)
    trick_manager.crashed.connect(_on_crashed)
    trick_manager.landed_successfully.connect(_on_landed_successfully)
    trick_manager.trick_completed.connect(_on_trick_completed)
    trick_manager.christ_air_started.connect(_on_christ_air_started)

func _process(_delta):
    var speed_scale = character_controller.velocity.length() / skateboard_loop_scaling_speed
    speed_scale *= maximum_skateboard_volume
    speed_scale = clampf(speed_scale, 0, maximum_skateboard_volume)
    audio_source_skateboard_loop.volume_db = linear_to_db(speed_scale)


func _on_jumped():
    audio_source_jump.playing = true

func _on_ollied(ollie_type: OllieType):
    var source_volume = perfect_ollie_volume
    if ollie_type == OllieType.PARTIAL:
        source_volume = partial_ollie_volume
    elif ollie_type == OllieType.TILT_HOP:
        source_volume = tilt_hop_volume
    audio_source_ollie.volume_db = linear_to_db(source_volume)
    audio_source_ollie.play()

func _on_pushed():
    audio_source_push.play()

func _on_crashed():
    trick_completed = false
    audio_source_crash.play()

func _on_landed_successfully():
    if trick_completed:
        audio_source_landed_after_trick.play()
    else:
        audio_source_landing.play()

func _on_trick_completed(trick_type: TrickType):
    if trick_type >= TrickType.GROUND_KICKFLIP:
        audio_source_tricks.pick_random().play()
        trick_completed = true

func _on_christ_air_started():
    audio_source_christ_air.play()
