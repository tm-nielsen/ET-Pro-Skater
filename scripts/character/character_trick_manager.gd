class_name CharacterTrickManager
extends TweenableNode

@export var rotation_node: Node3D
@export var trick_animator: CharacterTrickAnimator

@export var rotation_speed := 12
@export var landing_safe_margin := PI / 3

var initial_y_rotation: float
var trick_in_progress: bool


func _ready():
    trick_animator.trick_completed.connect(on_trick_completed)

func _physics_process(delta):
    if CharacterController.is_grounded || trick_in_progress:
        return

    if InputProxy.is_crouched:
        process_grab_tricks(delta)
    elif InputProxy.is_pushing:
        process_push_tricks()
    else:
        process_neutral_tricks()


func process_grab_tricks(delta):
    var horizontal_input = InputProxy.horizontal_axis
    rotation_node.rotation.y -= rotation_speed * horizontal_input * delta

    # var vertical_input = InputProxy.vertical_axis
    # rotation_node.rotation.x += rotation_speed * vertical_input * delta


func process_push_tricks():
    pass


func process_neutral_tricks():
    pass


func on_character_ollied(flick_direction: float):
    if flick_direction != 0:
        trick_in_progress = true
        trick_animator.start_kickflip(flick_direction)

func on_trick_completed():
    trick_in_progress = false


func on_character_left_ground():
    initial_y_rotation = get_small_angle(rotation_node.rotation.y)


func on_character_landed():
    var y_rotation = get_small_angle(rotation_node.rotation.y)
    var rotation_delta = y_rotation - initial_y_rotation
    var snapped_rotation_delta = snappedf(rotation_delta, PI)
    var snapped_rotation = get_small_angle(initial_y_rotation + snapped_rotation_delta)

    if abs(y_rotation - snapped_rotation) < landing_safe_margin:
        rotation_node.rotation.y = snapped_rotation
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
