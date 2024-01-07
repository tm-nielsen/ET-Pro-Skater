class_name TweenableNode
extends Node3D

var active_tweens: Array[Tween] = []


func tween_property(property_name: String, final_value, duration: float, target_node = self) -> Tween:
    return tween_property_with_delay(property_name, final_value, duration, 0, target_node)

func tween_property_with_delay(property_name: String, final_value, duration: float, delay: float, target_node = self) -> Tween:
    var tween = create_and_initialize_tween()
    if delay > 0:
        tween.tween_delay(delay)
    tween.tween_property(target_node, property_name, final_value, duration)
    return tween

func create_and_initialize_tween() -> Tween:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    active_tweens = active_tweens.filter(func(element): return element)
    active_tweens.append(tween)
    return tween

func kill_all_active_tweens():
    for tween in active_tweens:
        if tween:
            tween.kill()
    active_tweens = []
