extends Area2D

var velocidad_base = 300.0
var velocidad_rotacion = 120.0 

func _process(delta: float) -> void:
	var velocidad_final = velocidad_base
	
	# ESCALADO DE DIFICULTAD REAL HASTA LOS 400 KM
	var mundo = get_tree().current_scene
	if mundo and "distancia" in mundo:
		if mundo.distancia >= 400:
			velocidad_final += 400.0
		elif mundo.distancia >= 200:
			velocidad_final += 250.0
		elif mundo.distancia >= 50:
			velocidad_final += 120.0
			
	# Movimiento y rotación
	position.x -= velocidad_final * delta
	rotation_degrees += velocidad_rotacion * delta
	
	if position.x < -100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://game_over.tscn")
