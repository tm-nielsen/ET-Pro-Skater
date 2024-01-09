class_name ScoreDisplay
extends Control

# TODO: implement combo duration bar
@export_subgroup("references")
@export var score_label: Label
@export var multiplier_label: Label
@export var increment_list_parent: Control


func _ready():
    score_label.text = str(0)
    reset_multiplier_display()
    _clear_increment_list()


func start_held_trick(trick_name: String):
    pass

func end_held_trick():
    pass

func update_held_trick_score(score: float):
    pass


func add_potential_score(trick_name: String, score: int):
    var increment_label = Label.new()
    increment_label.text = "+%d %s" %[score, trick_name]
    increment_list_parent.add_child(increment_label)

func bank_score(added_score: int, total_score: int):
    # TODO: clear incrment list after delay
    # TODO: clearly display score increase
    score_label.text = str(total_score)
    _clear_increment_list()

func _clear_increment_list():
    for child in increment_list_parent.get_children():
        child.queue_free()


func update_multiplier_display(multiplier: float):
    # TODO: add animated size bump
    multiplier_label.text = "%.1fx" % multiplier

func reset_multiplier_display():
    multiplier_label.text = "1.0x"

func on_crash():
    reset_multiplier_display()
    _clear_increment_list()
