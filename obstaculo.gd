extends Area2D

func _process(delta):
	var velocidad_base = 300.0
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

	# Mueve el obstáculo hacia la izquierda
	position.x -= velocidad_final * delta
	
	if position.x < -200:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro" or area.is_in_group("Player"):
		area.get_parent().recibir_dano()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		body.recibir_dano()
