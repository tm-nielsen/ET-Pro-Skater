extends Node

signal crouch_pressed
signal crouch_released
signal push_pressed
signal direction_changed(new_direction: Vector2i)

var is_crouched: bool
var just_crouched: bool
var just_uncrouched: bool

var is_pushing: bool
var just_pushed: bool

var direction: Vector2i
var horizontal_axis: int
var vertical_axis: int

var horizontal_axis_just_changed: bool
var vertical_axis_just_changed: bool


func _process(_delta):
    process_buttons()
    process_direction()

func process_buttons():
    just_crouched = false
    just_uncrouched = false
    if Input.is_action_just_pressed("crouch"):
        crouch_pressed.emit()
        just_crouched = true
        is_crouched = true
    elif Input.is_action_just_released("crouch"):
        crouch_released.emit()
        just_uncrouched = true
        is_crouched = false

    just_pushed = false
    if Input.is_action_just_pressed("push"):
        push_pressed.emit()
        just_pushed = true
        is_pushing = true
    elif Input.is_action_just_released("push"):
        is_pushing = false


func process_direction():
    horizontal_axis = snap_raw_axis(get_raw_horizontal_axis())
    vertical_axis = snap_raw_axis(get_raw_vertical_axis())

    var new_direction = Vector2i(horizontal_axis, vertical_axis)
    if new_direction != direction:
        direction_changed.emit(new_direction)
    direction = new_direction


func get_raw_horizontal_axis() -> float:
    return Input.get_axis("left", "right")

func get_raw_vertical_axis() -> float:
    return Input.get_axis("down", "up")


func snap_raw_axis(raw_axis: float) -> int:
    if raw_axis > 0:
        return 1
    elif raw_axis < 0:
        return -1
    return 0
