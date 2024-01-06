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


func process_jumps(character_controller: CharacterController):
    if CharacterController.is_grounded:
        if is_crouched:
            process_tilt_hops(character_controller)
            store_ollie_potential(character_controller)
        if Input.is_action_just_released("crouch"):
            character_controller.velocity += jump_force * Vector3.UP
        if Input.is_action_just_pressed("crouch"):
            end_ollie_window()
            stored_ollie_direction = Input.get_axis("down", "up")
            
    if ollie_potential != 0:
        var vertical_input_axis = Input.get_axis("down", "up")
        if vertical_input_axis != stored_ollie_direction:
            execute_ollie(character_controller)
    
    is_crouched = Input.is_action_pressed("crouch")


func process_tilt_hops(character_controller: CharacterController):
    var vertical_input_axis = Input.get_axis("down", "up")
    if stored_ollie_direction != 0 && vertical_input_axis != stored_ollie_direction:
        execute_ollie(character_controller, false)


func execute_ollie(character_controller: CharacterController, curve_with_stored_potential := true):
    var ollie_impulse = ollie_force.y * Vector3.UP
    ollie_impulse -= CharacterController.forward * ollie_force.x * stored_ollie_direction

    if curve_with_stored_potential:
        var curved_ollie_strength = ollie_window_curve.sample(1.0 - ollie_potential)
        ollie_impulse *= curved_ollie_strength

    character_controller.velocity += ollie_impulse
    end_ollie_window()

    var horizontal_input_axis = Input.get_axis("left", "right")
    character_controller.ollied.emit(horizontal_input_axis)


func store_ollie_potential(character_controller: CharacterController):
    var current_tilt = Input.get_axis("down", "up")
    if current_tilt == 0:
        stored_ollie_direction = 0
    elif current_tilt != stored_ollie_direction:
        start_ollie_window(current_tilt, character_controller)


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
