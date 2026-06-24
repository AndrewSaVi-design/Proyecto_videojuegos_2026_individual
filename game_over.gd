extends Control
@onready var musica_game = $MusicaGame
func _ready() -> void:
	musica_game.play()

func _on_button_1_pressed() -> void:
	print("Cargando el juego otra vez...")
	get_tree().change_scene_to_file("res://Mundo.tscn")


func _on_button_2_pressed() -> void:
	print("Regresando a la intro...")
	get_tree().change_scene_to_file("res://menu_principal.tscn")
