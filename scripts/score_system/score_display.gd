class_name ScoreDisplay
extends Control

@export_subgroup("references")
@export var score_label: Label
@export var score_addition_label: Label
@export var multiplier_label: Label
@export var multiplier_lifetime_bar: ProgressBar
@export var increment_list_parent: Control

@export_subgroup("parameters")
@export var addition_label_display_duration := 0.8
@export var score_increase_duration := 0.25

var previous_score: int
var score_tween: Tween
var score_addition_tween: Tween


func _ready():
    score_label.text = str(0)
    reset_multiplier_display()
    _hide_score_addition_display()
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
    _show_score_addition(added_score)
    update_score_display(total_score)
    _clear_increment_list()

func update_score_display(score: int):
    if score_tween:
        score_tween.kill()
    score_tween = create_tween()
    score_tween.tween_method(_update_score_display, previous_score, score, score_increase_duration)
    previous_score = score

func _update_score_display(score: int):
    score_label.text = _get_seperated_number_string(score)


func _show_score_addition(added_score: int):
    if added_score <= 0:
        return

    var addition_text = _get_seperated_number_string(added_score)
    score_addition_label.text = addition_text + " +"
    score_addition_label.visible = true
    _hide_score_addition_display_after_delay()

func _hide_score_addition_display_after_delay():
    if score_addition_tween:
        score_addition_tween.kill()
    score_addition_tween = create_tween()
    score_addition_tween.tween_interval(addition_label_display_duration)
    score_addition_tween.tween_callback(_hide_score_addition_display)

func _hide_score_addition_display():
    score_addition_label.visible = false


func _clear_increment_list():
    for child in increment_list_parent.get_children():
        child.queue_free()


func update_multiplier_display(multiplier: float):
    # TODO: add animated size bump
    multiplier_lifetime_bar.visible = true
    multiplier_lifetime_bar.value = 1
    multiplier_label.text = "%.1fx" % multiplier

func update_multiplier_lifetime_display(normalized_lifetime: float):
    multiplier_lifetime_bar.value = normalized_lifetime

func reset_multiplier_display():
    multiplier_label.text = "1.0x"
    multiplier_lifetime_bar.visible = false

func on_crash():
    reset_multiplier_display()
    _clear_increment_list()


func _get_seperated_number_string(number: float):
    var text = str(int(number))
    var i = 3
    while text.length() > i:
        text = text.insert(text.length() - i, ",")
        i += 4
    return text
