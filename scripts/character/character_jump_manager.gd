class_name CharacterJumpManager
extends Resource

@export var jump_force := 10.0
@export var ollie_force := Vector2(1.0, 8.0)

@export var ollie_window_duration := 0.5
@export var ollie_window_curve : Curve

var ollie_window_tween: Tween

var stored_ollie_direction: float
var ollie_potential: float

var is_crouched: bool


func process_jumps(character_body: CharacterBody3D):
    if character_body.is_on_floor():
        if is_crouched:
            store_ollie_potential(character_body)
        if Input.is_action_just_released("crouch"):
            character_body.velocity += jump_force * Vector3.UP
        if Input.is_action_just_pressed("crouch"):
            end_ollie_window()
            stored_ollie_direction = Input.get_axis("down", "up")
            
    if ollie_potential != 0:
        var vertical_input_axis = Input.get_axis("down", "up")
        if vertical_input_axis != stored_ollie_direction:
            var ollie_impulse = ollie_force.y * Vector3.UP
            ollie_impulse -= CharacterController.forward * ollie_force.x * stored_ollie_direction

            var curved_ollie_strength = ollie_window_curve.sample(1.0 - ollie_potential)

            character_body.velocity += ollie_impulse * curved_ollie_strength
            end_ollie_window()
    
    is_crouched = Input.is_action_pressed("crouch")


func store_ollie_potential(character_body: CharacterBody3D):
    var current_tilt = Input.get_axis("down", "up")
    if current_tilt != 0 && current_tilt != stored_ollie_direction:
        start_ollie_window(current_tilt, character_body)


func start_ollie_window(current_tilt: float, binding_node: Node):
    stored_ollie_direction = current_tilt

    if ollie_window_tween:
        ollie_window_tween.kill()
    
    ollie_window_tween = binding_node.create_tween()
    ollie_window_tween.tween_method(_set_ollie_potential, 1.0, 0.0, ollie_window_duration)
    ollie_window_tween.tween_callback(end_ollie_window)

func _set_ollie_potential(value: float):
    ollie_potential = value

func end_ollie_window():
    if ollie_window_tween:
        ollie_window_tween.kill()
    
    stored_ollie_direction = 0
    ollie_potential = 0
