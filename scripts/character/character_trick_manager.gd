class_name CharacterTrickManager
extends TweenableNode

@export_subgroup("references")
@export var rotation_node: Node3D
@export var trick_animator: CharacterTrickAnimator

@export_subgroup("grab tricks")
@export var rotation_speed := 12
@export var landing_safe_margin := PI / 3

# @export var tilt_angle := 1.4
# @export var tilt_tween_duration := 0.4

var initial_y_rotation: float
var trick_in_progress: bool


func _ready():
    trick_animator.trick_completed.connect(on_trick_completed)
    InputProxy.direction_changed.connect(on_input_direction_changed)

func _physics_process(delta):
    if CharacterController.is_grounded || trick_in_progress:
        return

    process_grab_tricks(delta)
    process_push_tricks()


func process_grab_tricks(delta):
    if InputProxy.is_crouched:
        var horizontal_input = InputProxy.horizontal_axis
        rotation_node.rotation.y -= rotation_speed * horizontal_input * delta

    # if InputProxy.just_uncrouched:
    #     start_tilt_grab(0)


func process_push_tricks():
    pass


func on_input_direction_changed(input_direction: Vector2i):
    if CharacterController.is_grounded || trick_in_progress:
        return

    if InputProxy.is_crouched:
        # start_tilt_grab(input_direction.y)
        pass
    elif InputProxy.is_pushing:
        pass
    else:
        process_neutral_trick_inputs(input_direction)


# func start_tilt_grab(tilt_direction: int):
#     tween_property("rotation:x", -tilt_angle * tilt_direction, tilt_tween_duration, rotation_node)


func process_neutral_trick_inputs(input_direction: Vector2i):
    var old_input_direction = InputProxy.direction

    var vertical_axis_changed = old_input_direction.y != input_direction.y
    var horizontal_axis_changed = old_input_direction.x != input_direction.x

    if horizontal_axis_changed && input_direction.x != 0:
        if old_input_direction.y < 0:
            trick_animator.start_shuvit(input_direction.x)
            trick_in_progress = true
            return

        trick_in_progress = true
        trick_animator.start_kickflip(input_direction.x)
        return

    if vertical_axis_changed:
        if input_direction.y > 0:
            trick_animator.start_dolphin_flip(input_direction.y)
            trick_in_progress = true
            return

        elif input_direction.y < 0:
            trick_animator.prep_shuvit()
        elif old_input_direction.y < 0:
            trick_animator.unprep_shuvit()


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
