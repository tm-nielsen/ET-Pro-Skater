class_name BobbleHead
extends Node3D

@export var character_skeleton: Skeleton3D
@export var neck_bone_name := "Neck"
@onready var neck_node_index := character_skeleton.find_bone(neck_bone_name)

@export var movement_sensitivity := Vector3(1.0, 0.5, 1.0)
@export var elasticity := 0.1
@export_range(0, 1) var damping := 0.9


var angular_velocity: Vector3
var y_scale_velocity: float

var previous_position: Vector3
var previous_velocity: Vector3


func _physics_process(_delta):
    var neck_transform = character_skeleton.get_bone_global_pose(neck_node_index)
    global_position = get_parent().global_transform * neck_transform.origin

    var velocity = global_position - previous_position
    rotation += angular_velocity
    angular_velocity -= rotation * elasticity
    angular_velocity *= damping

    scale.y += y_scale_velocity
    y_scale_velocity += (1.0 - scale.y) * elasticity
    y_scale_velocity *= damping

    var acceleration = velocity - previous_velocity

    var neck_basis = neck_transform.basis
    var vertical_acceleration = acceleration.dot(neck_basis.y)
    y_scale_velocity += vertical_acceleration * movement_sensitivity.y

    var longitudinal_acceleration = acceleration.dot(neck_basis.z)
    angular_velocity.x += longitudinal_acceleration * movement_sensitivity.z

    var transverse_acceleration = acceleration.dot(neck_basis.x)
    angular_velocity.z += transverse_acceleration * movement_sensitivity.z

    previous_position = global_position
    previous_velocity = velocity
