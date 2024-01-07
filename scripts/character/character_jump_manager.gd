class_name CharacterJumpManager
extends Resource

@export var jump_force := 10.0
@export var ollie_force := Vector2(1.0, 8.0)

@export var ollie_window_duration := 0.5
@export var ollie_window_curve : Curve

var character_controller: CharacterController

var ollie_window_tween: Tween

var stored_ollie_direction: float
var ollie_potential: float
var has_ollied: bool

var was_crouched_last_frame: bool


func setup(p_character_controller: CharacterController):
    character_controller = p_character_controller
    character_controller.landed.connect(_on_character_landed)
    InputProxy.direction_changed.connect(_on_input_direction_changed)

func process_jumps():
    if CharacterController.is_grounded:
        if was_crouched_last_frame && !has_ollied:
            store_ollie_potential()
        if InputProxy.just_uncrouched:
            character_controller.velocity += jump_force * Vector3.UP
        if InputProxy.just_crouched:
            end_ollie_window()
            
    if ollie_potential != 0 && !has_ollied:
        var vertical_input_axis = InputProxy.vertical_axis
        if vertical_input_axis != stored_ollie_direction:
            var curved_ollie_strength = ollie_window_curve.sample(1.0 - ollie_potential)
            execute_ollie(curved_ollie_strength)
    
    was_crouched_last_frame = InputProxy.is_crouched


func execute_ollie(force_scale := 1.0):
    var ollie_impulse = ollie_force.y * Vector3.UP
    ollie_impulse -= CharacterController.forward * ollie_force.x * stored_ollie_direction

    character_controller.velocity += ollie_impulse * force_scale
    has_ollied = true
    end_ollie_window()
    stored_ollie_direction = InputProxy.vertical_axis

    var horizontal_input_axis = InputProxy.horizontal_axis
    character_controller.ollied.emit(horizontal_input_axis)


func store_ollie_potential():
    var current_tilt = InputProxy.vertical_axis
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
    
    ollie_potential = 0


func _on_character_landed():
    has_ollied = false


func _on_input_direction_changed(input_direction: Vector2i):
    if CharacterController.is_grounded && InputProxy.is_crouched:
        var old_tilt = InputProxy.direction.y
        if input_direction.y != old_tilt && old_tilt != 0:
            execute_ollie()
