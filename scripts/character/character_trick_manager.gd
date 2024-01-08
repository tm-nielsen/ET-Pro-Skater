class_name CharacterTrickManager
extends TweenableNode

@export_subgroup("references")
@export var character_body: CharacterBody3D
@export var trick_animator: CharacterTrickAnimator

@export_subgroup("grab tricks")
@export var rotation_speed := 12
@export var landing_safe_margin := PI / 3

@export var body_flip_input_window_duration := 100

@export_subgroup("wall jump", "wall_jump")
@export var wall_jump_force := Vector2(12, 22)
@export var wall_jump_input_window_duration := 200

var body_tilt_timestamp: float
var stored_body_tilt: int

var wall_touch_timestamp: float
var wall_jump_direction: Vector3

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
        character_body.rotation.y -= rotation_speed * horizontal_input * delta

    if InputProxy.just_crouched:
        start_grab_tilt(InputProxy.vertical_axis)
    if InputProxy.just_uncrouched:
        trick_animator.start_grab_tilt(0)
        if wall_jump_direction != Vector3.ZERO:
            var wall_jump_input_window_offset = Time.get_ticks_msec() - wall_touch_timestamp
            if wall_jump_input_window_offset < wall_jump_input_window_duration:
                execute_wall_jump()

func start_grab_tilt(tilt_direction: int):
    trick_animator.start_grab_tilt(tilt_direction)
    if tilt_direction != 0:
        start_body_flip_input_window(tilt_direction)

func start_body_flip_input_window(tilt_direction: int):
    stored_body_tilt = tilt_direction
    body_tilt_timestamp = Time.get_ticks_msec()


func process_push_tricks():
    pass


func on_input_direction_changed(input_direction: Vector2i):
    if CharacterController.is_grounded || trick_in_progress:
        return

    if InputProxy.is_crouched:
        process_crouched_direction_changed(input_direction)
    elif InputProxy.is_pushing:
        pass
    else:
        process_neutral_direction_changed(input_direction)


func process_crouched_direction_changed(input_direction: Vector2i, ingore_unchanged_axis := true):
    if input_direction.y == InputProxy.direction.y && ingore_unchanged_axis:
        return
    
    var tilt_direction = input_direction.y
    var previous_tilt_direction = InputProxy.direction.y

    if previous_tilt_direction != 0:
        stored_body_tilt = previous_tilt_direction
        body_tilt_timestamp = Time.get_ticks_msec()

    if tilt_direction != 0 && tilt_direction != stored_body_tilt:
        if Time.get_ticks_msec() - body_tilt_timestamp < body_flip_input_window_duration:
            trick_animator.start_body_flip(tilt_direction)
            trick_in_progress = true
        else:
            start_grab_tilt(tilt_direction)
    else:
        start_grab_tilt(tilt_direction)


func process_neutral_direction_changed(input_direction: Vector2i):
    var old_input_direction = InputProxy.direction

    var vertical_axis_changed = old_input_direction.y != input_direction.y
    var horizontal_axis_changed = old_input_direction.x != input_direction.x

    if horizontal_axis_changed && input_direction.x != 0:
        if old_input_direction.y * CharacterController.is_forward_sign < 0:
            trick_animator.start_shuvit(input_direction.x)
            trick_in_progress = true
            return

        trick_in_progress = true
        trick_animator.start_kickflip(input_direction.x)
        return

    if vertical_axis_changed:
        var aligned_vertical_input = input_direction.y * CharacterController.is_forward_sign
        if aligned_vertical_input > 0:
            trick_animator.start_dolphin_flip(input_direction.y)
            trick_in_progress = true
            return

        elif aligned_vertical_input < 0:
            trick_animator.prep_shuvit()
        elif old_input_direction.y * CharacterController.is_forward_sign < 0:
            trick_animator.unprep_shuvit()


func on_character_ollied(flick_direction: float):
    if flick_direction != 0:
        trick_in_progress = true
        trick_animator.start_kickflip(flick_direction)

func on_trick_completed():
    trick_in_progress = false
    if InputProxy.is_crouched:
        process_crouched_direction_changed(InputProxy.direction, false)


func on_character_left_ground():
    initial_y_rotation = get_small_angle(character_body.rotation.y)


func on_character_landed():
    wall_jump_direction = Vector3.ZERO
    if trick_in_progress:
        crash()
        return

    var y_rotation = get_small_angle(character_body.rotation.y)
    var rotation_delta = y_rotation - initial_y_rotation
    var snapped_rotation_delta = snappedf(rotation_delta, PI)
    var snapped_rotation = get_small_angle(initial_y_rotation + snapped_rotation_delta)

    if abs(y_rotation - snapped_rotation) < landing_safe_margin:
        trick_animator.reset()
        character_body.rotation.y = snapped_rotation
        if int(snapped_rotation_delta / PI) % 2:
            CharacterController.is_backwards = !CharacterController.is_backwards
    else:
        crash()

func crash():
    push_warning("Would be a crash, needs to be implemented")
    CharacterController.is_backwards = false
    character_body.rotation = Vector3.ZERO
    character_body.velocity = Vector3.ZERO
    trick_animator.reset()


func on_character_hit_wall(wall_normal: Vector3):
    var tilt_direction = InputProxy.direction.y
    if (tilt_direction * CharacterController.forward).dot(wall_normal) > 0:
        var wall_angle = Vector3.FORWARD.signed_angle_to(wall_normal, Vector3.UP)
        if !CharacterController.is_backwards:
            wall_angle -= PI
        
        character_body.rotation.y = get_small_angle(wall_angle)
        wall_touch_timestamp = Time.get_ticks_msec()
        wall_jump_direction = wall_normal


func execute_wall_jump():
    var impulse = wall_jump_direction * wall_jump_force.x
    impulse.y += wall_jump_force.y
    character_body.velocity.y = 0
    character_body.velocity += impulse
    trick_animator.start_grab_tilt(0)

    wall_jump_direction = Vector3.ZERO


func get_small_angle(angle: float) -> float:
    while angle > PI:
        angle -= TAU
    while angle <= -PI:
        angle += TAU
    return angle
