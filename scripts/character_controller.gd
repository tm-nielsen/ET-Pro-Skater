extends CharacterBody3D

@export var push_force := 10.0
@export var push_delay := 1.0
@export var turn_force := 10.0
@export_range(0, 1) var ground_friction := 0.005
@export var gravity := 9.81


func _physics_process(delta):
    if Input.is_action_just_pressed("push"):
        velocity += push_force * -basis.z


    if is_on_floor():
        turn(delta)
        align_to_ground()

    velocity *= (1 - ground_friction)
    velocity += gravity * Vector3.DOWN * delta
    move_and_slide()


func turn(delta):
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
