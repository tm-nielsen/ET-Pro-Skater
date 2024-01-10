class_name ScoreCounter
extends Control

const TrickType = CharacterTrickManager.TrickType

@export_subgroup("references")
@export var trick_manager: CharacterTrickManager
@export var display: ScoreDisplay
@export_file("*.json") var trick_info_filepath

@export_subgroup("parameters")
@export var combo_duration := 5.0
@export var half_spin_score := 3
@export var half_spin_multiplier_increase := 0.5
@export var grab_tilt_score_frequency := 2.0
@export var christ_air_score_frequency := 16.0

var trick_info_array

var trick_held: bool
var held_trick_start_timestamp: int
var held_trick_score_frequency: float

var current_score: int
var potential_score: int
var score_multiplier := 1.0
var multiplier_lifetime: float


func _ready():
    read_trick_info_file()
    trick_manager.trick_completed.connect(on_trick_completed)
    trick_manager.crashed.connect(on_crashed)
    trick_manager.landed_successfully.connect(on_landed_successfully)
    trick_manager.half_spins_landed.connect(on_half_spins_landed)
    trick_manager.grab_tilt_started.connect(on_grab_tilt_started)
    trick_manager.grab_tilt_ended.connect(on_grab_tilt_ended)
    trick_manager.christ_air_started.connect(on_christ_air_started)


func _process(delta):
    process_held_tricks()
    if multiplier_lifetime > 0:
        multiplier_lifetime -= delta
        display.update_multiplier_lifetime_display(multiplier_lifetime / combo_duration)
        if multiplier_lifetime < 0:
            score_multiplier = 1
            display.reset_multiplier_display()


func process_held_tricks():
    if trick_held:
        var held_score = get_held_trick_score()
        display.update_held_trick_score(held_score)


func on_trick_completed(trick_type: TrickType):
    if trick_type == TrickType.CHRIST_AIR:
        on_christ_air_ended()
        return
    if trick_type >= trick_info_array.size():
        return
    var trick_info = trick_info_array[trick_type]

    potential_score += trick_info.score
    display.add_potential_score(trick_info.name, trick_info.score)

    var multiplier_increase = trick_info.multiplier_increase
    if multiplier_increase > 0:
        score_multiplier += multiplier_increase
        multiplier_lifetime = combo_duration
        display.update_multiplier_display(score_multiplier)


func on_half_spins_landed(half_spin_count: int):
    var absolute_half_spin_count = abs(half_spin_count)
    var score_increase = half_spin_score * absolute_half_spin_count
    potential_score += score_increase
    var spin_string = "%d Spin" % (180 * half_spin_count)
    display.add_potential_score(spin_string, score_increase)

    score_multiplier += half_spin_multiplier_increase * absolute_half_spin_count
    display.update_multiplier_display(score_multiplier)


func on_grab_tilt_started(_tilt_direction: int):
    held_trick_start_timestamp = Time.get_ticks_msec()
    held_trick_score_frequency = grab_tilt_score_frequency
    trick_held = true
    display.start_held_trick("Grab Tilt")

func on_grab_tilt_ended():
    if !trick_held:
        return
    var score = get_held_trick_score()
    potential_score += round(score)
    trick_held = false
    display.end_held_trick()

func on_christ_air_started():
    held_trick_start_timestamp = Time.get_ticks_msec()
    held_trick_score_frequency = christ_air_score_frequency
    trick_held = true
    display.start_held_trick("Christ Air")

func on_christ_air_ended():
    potential_score += round(get_held_trick_score())
    trick_held = false
    display.end_held_trick()
    

func get_held_trick_score() -> float:
    var hold_duration = Time.get_ticks_msec() - held_trick_start_timestamp
    hold_duration /= 1000.0
    return hold_duration * held_trick_score_frequency


func on_crashed():
    trick_held = false
    score_multiplier = 1
    display.on_crash()
    display.end_held_trick()


func on_landed_successfully():
    if trick_held:
        potential_score += round(get_held_trick_score())
        trick_held = false
    var score_increase = round(potential_score * score_multiplier)
    potential_score = 0
    current_score += score_increase
    display.bank_score(score_increase, current_score)
    display.end_held_trick()


func read_trick_info_file():
    if FileAccess.file_exists(trick_info_filepath):
        var file = FileAccess.open(trick_info_filepath, FileAccess.READ)
        var text_content = file.get_as_text()

        var json = JSON.new()
        var error = json.parse(text_content)

        file.close()
        if error == OK:
            trick_info_array = json.data
        else:
            push_error('JSON Parse Error: ', json.get_error_message(), ' on line ', json.get_error_line())
    else:
        push_error("Error: trick info file does not exist")
