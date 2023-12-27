class_name CharacterTrickManager
extends TweenableNode

@export var rotation_node: Node3D

@export var rotation_speed := 12
@export var landing_snap_tween_duration := 0.1
@export var landing_safe_margin := PI / 3

var initial_y_rotation: float


func _physics_process(delta):
    if CharacterController.is_grounded:
        return

    if Input.is_action_pressed("crouch"):
        process_grab_tricks(delta)
    elif Input.is_action_pressed("push"):
        process_push_tricks()
    else:
        process_neutral_tricks()


func process_grab_tricks(delta):
    var horizontal_input = Input.get_axis("right", "left")
    rotation_node.rotation.y += rotation_speed * horizontal_input * delta

    var vertical_input = Input.get_axis("up", "down")
    rotation_node.rotation.x += rotation_speed * vertical_input * delta


func process_push_tricks():
    pass


func process_neutral_tricks():
    pass


func on_character_left_ground():
    initial_y_rotation = get_small_angle(rotation_node.rotation.y)


func on_character_landed():
    var y_rotation = get_small_angle(rotation_node.rotation.y)
    var rotation_delta = y_rotation - initial_y_rotation
    var snapped_rotation_delta = snappedf(rotation_delta, PI)
    var snapped_rotation = get_small_angle(initial_y_rotation + snapped_rotation_delta)

    if abs(y_rotation - snapped_rotation) < landing_safe_margin:
        tween_property("rotation:y", snapped_rotation, landing_snap_tween_duration, rotation_node)
        if int(snapped_rotation_delta / PI) % 2:
            CharacterController.is_backwards = !CharacterController.is_backwards
    else:
        push_warning("Would be a crash, needs to be implemented")
        rotation_node.rotation.y = 0
        CharacterController.is_backwards = false
        rotation_node.velocity = Vector3.ZERO


func get_small_angle(angle: float) -> float:
    while angle > PI:
        angle -= TAU
    while angle <= -PI:
        angle += TAU
    return angle
