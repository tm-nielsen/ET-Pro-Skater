extends Node3D

@export_group("References")
@export var crouch_bone: Node3D
@export var physics_body: CharacterBody3D = get_parent()

@export_group("Parameters")
@export var crouch_scale := Vector3(1.2, 0.4, 1.6)
@export var crouch_duration := 0.15
@export var jump_scale := Vector3(0.6, 1.8, 0.4)
@export var jump_duration := 0.05
@export var turn_angle := 0.25
@export var tilt_offset := Vector3(0, 0.4, 0.1)
@export var tilt_angle := 0.6


func _physics_process(_delta):
    var horizontal_input_axis = Input.get_axis("left", "right")
    if !physics_body.is_on_floor():
        horizontal_input_axis = 0
    rotation.z = -horizontal_input_axis * turn_angle

    var vertical_input_axis = Input.get_axis("down", "up")
    rotation.x = tilt_angle * -vertical_input_axis
    position.y = tilt_offset.y if (vertical_input_axis != 0) else 0.0
    position.z = -vertical_input_axis * tilt_offset.z

    if Input.is_action_just_pressed("crouch"):
        tween_property("scale", crouch_scale, crouch_duration, crouch_bone)
    elif Input.is_action_just_released("crouch"):
        var tween = tween_property("scale", jump_scale, crouch_duration, crouch_bone)
        tween.tween_property(crouch_bone, "scale", Vector3.ONE, crouch_duration)


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
