extends Camera3D

@export var target: Node3D
@export var position_offset := Vector3(1, 2, 3)
@export var look_offset := Vector3(0.5, 0, 0)
@export var position_lerp := 0.2

@onready var planar_offset := position_offset * Vector3(1, 0, 1)
@onready var position_offset_length := position_offset.length()


func _physics_process(_delta):
    var transformed_offset = target.basis * planar_offset
    var flattened_offset = Plane(Vector3.UP).project(transformed_offset)
    flattened_offset = flattened_offset.normalized() * position_offset_length
    var target_position = target.position + flattened_offset
    target_position.y += position_offset.y

    position = lerp(position, target_position, position_lerp)

    transformed_offset = target.transform * look_offset
    look_at(transformed_offset, Vector3.UP)
