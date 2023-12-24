extends CharacterBody3D

@export var push_force := 20.0
@export var push_delay := 1.0
@export var turn_force := 10.0
@export var jump_manager: CharacterJumpManager
@export_range(0, 1) var ground_friction := 0.005
@export var gravity := 20.0

var can_push := true


func _physics_process(delta):
    jump_manager.process_jumps(self)

    if is_on_floor():
        velocity *= (1 - ground_friction)
        process_pushing()
        process_turning(delta)
        align_to_ground()

    velocity += gravity * Vector3.DOWN * delta
    move_and_slide()


func process_pushing():
    if can_push and Input.is_action_just_pressed("push"):
        velocity += push_force * -basis.z

        can_push = false
        var push_tween = create_tween()
        push_tween.tween_interval(push_delay)
        push_tween.tween_callback(_enable_pushing)

func _enable_pushing():
    can_push = true


func process_turning(delta):
    if Input.is_action_pressed("left"):
        _turn(turn_force * delta)
    if Input.is_action_pressed("right"):
        _turn(-turn_force * delta)

func _turn(turn_angle: float):
    rotate_y(turn_angle)
    velocity = velocity.rotated(Vector3.UP, turn_angle)


func align_to_ground():
    var floor_normal = get_floor_normal()
    var body_forward = Plane(floor_normal).project(-basis.z)
    basis = Basis.looking_at(body_forward, floor_normal)
