class_name ResultsDisplay
extends Control

const scores_filepath := "user://scores.json"

@export var score_label: Label
@export var score_counter: ScoreCounter

@export_subgroup("high score display")
@export var maximum_highscores := 5
@export var score_entry_parent: Control
@export var score_entry_prefab: PackedScene

@export_subgroup("Name Entry")
@export var maximum_length := 3
@export var name_label: Label
@export var letter_button_parent: Control
@export var confirm_name_button: Button
@export var clear_name_button: Button

var final_score: int
var entered_name: String
var score_entries: Array[HighScoreEntry] = []


func _ready():
    confirm_name_button.pressed.connect(_on_confirm_name_button_pressed)
    clear_name_button.pressed.connect(_on_clear_name_button_pressed)
    for letter_button in letter_button_parent.get_children():
        var callback = func(): _on_letter_button_pressed(letter_button.text)
        letter_button.pressed.connect(callback)


func start_display():
    visible = true
    final_score = score_counter.current_score
    score_label.text = ScoreDisplay.get_seperated_number_string(final_score)
    show_high_scores(read_scores())
    start_name_selection()


func show_high_scores(score_info_list: Array):
    for current_score_entry in score_entries:
        current_score_entry.queue_free()
    score_entries = []

    for score_info in score_info_list:
        var new_score_entry = score_entry_prefab.instantiate()
        new_score_entry.set_attributes(score_info.name, score_info.score)
        score_entries.append(new_score_entry)
        score_entry_parent.add_child(new_score_entry)


func start_name_selection():
    entered_name = ""
    name_label.text = "---"
    set_button_disabled_and_focus_mode(confirm_name_button, true)
    set_button_disabled_and_focus_mode(clear_name_button, true)
    set_letter_buttons_disabled(false)
    letter_button_parent.get_child(0).grab_focus()

func set_letter_buttons_disabled(disabled := true):
    for letter_button in letter_button_parent.get_children():
        set_button_disabled_and_focus_mode(letter_button, disabled)

func set_button_disabled_and_focus_mode(button: Button, disabled: bool):
    button.disabled = disabled
    button.focus_mode = FOCUS_NONE if disabled else FOCUS_ALL


func _on_letter_button_pressed(letter: String):
    entered_name += letter
    name_label.text = entered_name
    set_button_disabled_and_focus_mode(confirm_name_button, false)
    set_button_disabled_and_focus_mode(clear_name_button, false)

    if entered_name.length() >= maximum_length:
        set_letter_buttons_disabled()
        confirm_name_button.grab_focus()

func _on_clear_name_button_pressed():
    start_name_selection()

func _on_confirm_name_button_pressed():
    var saveable_score_info = {"name": entered_name, "score": final_score}
    var score_info_list = read_scores()
    score_info_list.append(saveable_score_info)
    score_info_list.sort_custom(func(a, b): return a.score > b.score)
    if score_info_list.size() > 5:
        score_info_list.pop_back()
    save_scores(score_info_list)
    show_high_scores(score_info_list)

    set_button_disabled_and_focus_mode(confirm_name_button, true)
    set_button_disabled_and_focus_mode(clear_name_button, true)
    set_letter_buttons_disabled()


func read_scores() -> Array:
    if FileAccess.file_exists(scores_filepath):
        var file = FileAccess.open(scores_filepath, FileAccess.READ)
        var text_content = file.get_as_text()

        var json = JSON.new()
        var error = json.parse(text_content)

        file.close()
        if error == OK:
            return json.data
        else:
            push_error('JSON Parse Error: ', json.get_error_message(), ' on line ', json.get_error_line())
    return []

func save_scores(score_info_list: Array):
    var file_string = JSON.stringify(score_info_list, "\t")
    var file = FileAccess.open(scores_filepath, FileAccess.WRITE)
    file.store_string(file_string)
    file.close()


func restart_game():
    get_tree().reload_current_scene()
