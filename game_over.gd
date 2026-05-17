extends Control

# Esta función se ejecuta al presionar el botón Reintentar
func _on_reintentar_pressed() -> void:
	print("Cargando el juego otra vez...")
	get_tree().change_scene_to_file("res://Mundo.tscn")

# Esta función se ejecuta al presionar el botón de Volver al Menú
func _on_menu_pressed() -> void:
	print("Regresando a la intro...")
	get_tree().change_scene_to_file("res://intro.tscn")
