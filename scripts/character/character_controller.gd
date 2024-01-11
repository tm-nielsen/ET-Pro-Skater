class_name CharacterController
extends CharacterBody3D

signal left_ground
signal landed
signal hit_wall(wall_normal: Vector3)
signal pushed

static var is_grounded: bool = true
static var is_backwards: bool
static var is_forward_sign: get = _get_forward_sign
static var forward: Vector3
static var input_disabled: bool

@export var push_force := 20.0
@export var push_delay := 1.0
@export var turn_force := 10.0
@export_range(0, 1) var ground_friction := 0.005
@export var gravity := 20.0
@export var slope_force := 20.0
@export var slope_force_crouch_multiplier := 2.0

var can_push := true


func _ready():
    is_grounded = true
    is_backwards = false
    forward = -basis.z
    input_disabled = false
    velocity += Vector3.DOWN
    move_and_slide()

func _physics_process(delta):
    process_landings()
    if is_on_floor():
        if !InputProxy.is_crouched || InputProxy.vertical_axis == 0:
            process_pushing()
            process_turning(delta)
        apply_slope_force(delta)
        velocity *= (1 - ground_friction)
        align_body()

    velocity += gravity * Vector3.DOWN * delta
    move_and_slide()
    process_wall_touching()


func process_landings():
    if is_on_floor() && !is_grounded:
        landed.emit()
    elif !is_on_floor() && is_grounded:
        left_ground.emit()
    is_grounded = is_on_floor()

func process_wall_touching():
    if is_on_wall():
        hit_wall.emit(get_wall_normal())


func process_pushing():
    if input_disabled:
        return
    if can_push and InputProxy.just_pushed:
        if is_backwards:
            velocity -= push_force * -basis.z
        else:
            velocity += push_force * -basis.z

        can_push = false
        var push_tween = create_tween()
        push_tween.tween_interval(push_delay)
        push_tween.tween_callback(_enable_pushing)
        pushed.emit()

func _enable_pushing():
    can_push = true


func process_turning(delta):
    if input_disabled:
        return
    if InputProxy.horizontal_axis != 0:
        _turn(-turn_force * InputProxy.horizontal_axis * delta)

func _turn(turn_angle: float):
    rotate_y(turn_angle)
    velocity = velocity.rotated(Vector3.UP, turn_angle)
    
    if is_backwards: forward = basis.z
    else: forward = -basis.z


func align_body():
    var floor_normal = get_floor_normal()
    if velocity.length_squared() > 0:
        var planar_velocity = Plane(floor_normal).project(velocity)
        if planar_velocity.length_squared() > 0:
            basis = Basis.looking_at(planar_velocity.normalized(), floor_normal, is_backwards)
            return
    
    var body_forward = Plane(floor_normal).project(-basis.z)
    if body_forward.length_squared() > 0:
        basis = Basis.looking_at(body_forward, floor_normal, is_backwards)


func apply_slope_force(delta):
    var floor_normal = get_floor_normal()
    var slope_vector = floor_normal * Vector3(1, 0, 1)
    var force_direction = Plane(floor_normal).project(slope_vector)
    var force = force_direction * slope_force * delta
    if InputProxy.is_crouched:
        force *= slope_force_crouch_multiplier
    velocity += force


static func _get_forward_sign() -> int:
    return -1 if is_backwards else 1
