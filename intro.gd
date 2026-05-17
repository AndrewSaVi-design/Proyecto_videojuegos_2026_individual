extends Control

func _input(event):
	# Si presionas cualquier tecla o haces clic, se salta el video e ingresas al juego
	if event is InputEventKey or event is InputEventMouseButton:
		_ir_al_juego()

func _on_video_stream_player_finished():
	# Si el video termina solo, también entras directo al juego
	_ir_al_juego()

func _ir_al_juego():
	# Revisa si tu escena se llama "Mundo.tscn" con M mayúscula o minúscula y ponlo igual aquí:
	get_tree().change_scene_to_file("res://Mundo.tscn")
