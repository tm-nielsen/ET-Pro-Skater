class_name ResultsDisplay
extends Control

@export var score_label: Label
@export var score_counter: ScoreCounter

var final_score: int


func start_display():
    visible = true
    final_score = score_counter.current_score
    score_label.text = "Final Score: " + ScoreDisplay.get_seperated_number_string(final_score)


func restart_game():
    get_tree().reload_current_scene()
