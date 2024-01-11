class_name GameManager
extends Control

enum GameState { PREGAME, GAME, RESULTS }

@export var game_duration := 120.0
@export var timer_label: Label
@export var starting_screen: Control
@export var results_screen: ResultsDisplay
@export var hud_root: Control

@export_subgroup("music")
@export var pause_loop_player: AudioStreamPlayer
@export var game_track_player: AudioStreamPlayer

var game_time_remaining: float
var game_state: GameState


func _ready():
    get_tree().paused = true
    starting_screen.visible = true
    results_screen.visible = false
    hud_root.visible = false
    pause_loop_player.play()

func _process(delta):
    match game_state:
        GameState.PREGAME:
            process_game_start()
        GameState.GAME:
            process_timer(delta)


func process_game_start():
    var input_actions = ["crouch", "push", "left", "right", "up", "down"]
    for action_name in input_actions:
        if Input.is_action_just_pressed(action_name):
            start_game()

func start_game():
    game_time_remaining = game_duration
    get_tree().paused = false
    starting_screen.visible = false
    hud_root.visible = true
    game_state = GameState.GAME
    pause_loop_player.stop()
    game_track_player.play(110)
    game_time_remaining -=110
    InputProxy._process(0)


func process_timer(delta):
    game_time_remaining -= delta
    timer_label.text = _get_clock_text(game_time_remaining)
    if game_time_remaining < 0:
        end_game()

func _get_clock_text(seconds: float) -> String:
    var minutes = floor(seconds / 60)
    var partial_seconds = seconds - int(seconds)
    seconds = floori(seconds - minutes * 60)
    return "%01d:%02d:%02d" % [minutes, seconds, floori(partial_seconds * 100)]
    
func end_game():
    get_tree().paused = true
    hud_root.visible = false
    results_screen.start_display()
    game_state = GameState.RESULTS
    game_track_player.stop()
    pause_loop_player.play()
