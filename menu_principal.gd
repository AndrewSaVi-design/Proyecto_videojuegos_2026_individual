extends Control

@onready var musica_menu = $MusicaMenu

func _ready() -> void:
	musica_menu.play()
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://intro.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://niveles_control.tscn")

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://creditos.tscn")

func _on_button_4_pressed() -> void:
	get_tree().quit()
