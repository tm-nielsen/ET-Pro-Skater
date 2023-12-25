extends Node3D

@export_group("References")
@export var crouch_bone: Node3D
@export var physics_body: CharacterBody3D = get_parent()

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


func _physics_process(_delta):
    update_axis("left", "right", start_turn_tween)
    update_axis("up", "down", start_tilt_tween)
    process_crouch_tweens()


func update_axis(action_a_name: StringName, action_b_name: StringName, update_method: Callable):
    var a_toggled = Input.is_action_just_pressed(action_a_name) || Input.is_action_just_released(action_a_name)
    var b_toggled = Input.is_action_just_pressed(action_b_name) || Input.is_action_just_released(action_b_name)
    if a_toggled || b_toggled:
        update_method.call()


func start_turn_tween():
    var turn_direction = Input.get_axis("right", "left")
    if !physics_body.is_on_floor():
        turn_direction = 0
    tween_property("rotation:z", turn_direction * turn_angle, turn_tween_duration)


func start_tilt_tween():
    var tilt_direction = Input.get_axis("up", "down")
    tween_property("rotation:x", tilt_angle * tilt_direction, tilt_tween_duration)
    var offset_position = position
    offset_position.y = tilt_offset.y * abs(tilt_direction)
    offset_position.z = tilt_direction * tilt_offset.x
    tween_property("position", offset_position, tilt_tween_duration)


func process_crouch_tweens():
    if Input.is_action_just_pressed("crouch"):
        tween_property("scale", crouch_scale, crouch_tween_duration, crouch_bone)
    elif Input.is_action_just_released("crouch"):
        var tween = tween_property("scale", jump_scale, crouch_tween_duration, crouch_bone)
        tween.tween_property(crouch_bone, "scale", Vector3.ONE, crouch_tween_duration)


func tween_property(property_name: String, final_value, duration: float, target_node = self) -> Tween:
    return tween_property_with_delay(property_name, final_value, duration, 0, target_node)

func tween_property_with_delay(property_name: String, final_value, duration: float, delay: float, target_node = self) -> Tween:
    var tween = create_and_initialize_tween()
    if delay > 0:
        tween.tween_delay(delay)
    tween.tween_property(target_node, property_name, final_value, duration)
    return tween

func create_and_initialize_tween() -> Tween:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    return tween
