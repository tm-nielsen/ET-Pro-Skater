class_name HighScoreEntry
extends Control

@export var name_label: Label
@export var score_label: Label

var score: int

func set_attributes(p_name: String, p_score: int):
    name_label.text = p_name
    score = p_score
    score_label.text = ScoreDisplay.get_seperated_number_string(score)
