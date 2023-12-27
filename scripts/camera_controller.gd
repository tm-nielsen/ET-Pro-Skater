extends Camera3D

@export var target: Node3D
@export var position_offset := Vector3(1, 2, 3)
@export var look_offset := Vector3(0.5, 0, 0)
@export var position_lerp := 0.2
@export var look_lerp := 0.3

@onready var planar_offset := position_offset * Vector3(1, 0, 1)
@onready var position_offset_length := position_offset.length()

var last_position_offset: Vector3
var last_look_offset: Vector3


func _physics_process(_delta):
    if CharacterController.is_grounded:
        var transformed_offset = get_transformed_offset(planar_offset)
        var flattened_offset = Plane(Vector3.UP).project(transformed_offset)
        flattened_offset = flattened_offset.normalized() * position_offset_length
        var target_position = target.position + flattened_offset
        target_position.y += position_offset.y

        last_position_offset = target_position - target.position
        position = lerp(position, target_position, position_lerp)

        var transformed_look_offset = get_transformed_offset(look_offset)
        var look_target = target.position + transformed_look_offset
        var target_basis = Basis.looking_at(look_target - position)

        last_look_offset = transformed_look_offset
        basis = basis.slerp(target_basis, look_lerp)
    else:
        var target_position = target.position + last_position_offset
        position = lerp(position, target_position, position_lerp)

        var look_target = target.position + last_look_offset
        look_at(look_target, Vector3.UP)


func get_transformed_offset(offset: Vector3) -> Vector3:
    var result = target.basis * offset
    if CharacterController.is_backwards:
        result = result.rotated(target.basis.y, PI)
    return result
