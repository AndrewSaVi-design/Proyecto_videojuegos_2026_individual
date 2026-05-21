extends Area2D

func _process(delta):
	var velocidad_base = 300.0 # Velocidad inicial suave
	var velocidad_final = velocidad_base
	
	# ESCALADO DE DIFICULTAD REAL HASTA LOS 400 KM
	var mundo = get_tree().current_scene
	if mundo and "distancia" in mundo:
		if mundo.distancia >= 400:
			velocidad_final += 400.0 # Extremo a los 400 km (Velocidad: 700)
		elif mundo.distancia >= 200:
			velocidad_final += 250.0 # Difícil a los 200 km (Velocidad: 550)
		elif mundo.distancia >= 50:
			velocidad_final += 120.0 # Intermedio a los 50 km (Velocidad: 420)

	# Se mueve con la velocidad calculada
	position.x -= velocidad_final * delta
	
	if position.x < -100:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro":
		verificar_polaridad(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_polaridad(body)

func verificar_polaridad(jugador):
	print("--- CHOQUE DETECTADO ---")
	if is_in_group("laser_cian") and jugador.es_cian == false:
		get_tree().change_scene_to_file("res://game_over.tscn")
	elif is_in_group("laser_naranja") and jugador.es_cian == true:
		get_tree().change_scene_to_file("res://game_over.tscn")
	else:
		print("Resultado: SALVADO (Ambos son del mismo color)")
