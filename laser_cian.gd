extends Area2D

var ya_choco = false # <-- NUEVA VARIABLE: Evita que el choque se procese múltiples veces seguidas

func _process(delta):
	var velocidad_base = 300.0 # Velocidad inicial suave
	var velocidad_final = velocidad_base
	
	# ESCALADO DE DIFICULTAD REAL HASTA LOS 400 KM
	var mundo = get_tree().current_scene
	if mundo and "distancia" in mundo:
		if mundo.distancia >= 400:
			velocidad_final += 400.0 # Extremo a los 400 km
		elif mundo.distancia >= 200:
			velocidad_final += 250.0 # Difícil a los 200 km
		elif mundo.distancia >= 50:
			velocidad_final += 120.0 # Intermedio a los 50 km

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
	print("Argumebnto de polaridad: ", jugador)
	if ya_choco:
		return # Si ya registramos una derrota, ignoramos colisiones extra
		
	print("--- CHOQUE DETECTADO ---")
	if is_in_group("laser_cian") and jugador.es_cian == false:
		jugador.recibir_dano()
	elif is_in_group("laser_naranja") and jugador.es_cian == true:
		jugador.recibir_dano()
	
	# Primero evaluamos las condiciones exactas de Game Over
	var fallo_cian = is_in_group("laser_cian") and jugador.es_cian == false
	var fallo_naranja = is_in_group("laser_naranja") and jugador.es_cian == true
	
	if fallo_cian or fallo_naranja:
		ya_choco = true
		#set_process(false) # Congela el movimiento de este láser para que no siga de largo
		
		# Le indicamos al jugador que ejecute su lógica de daño
		if jugador.has_method("recibir_danio"):
			jugador.recibir_danio()
		
		# Esperamos 1 segundo de manera asíncrona viendo la animación "hurt"
		#await get_tree().create_timer(1.0).timeout
		
		# Cambiamos de escena oficialmente
		#get_tree().change_scene_to_file("res://game_over.tscn")
	else:
		print("Resultado: SALVADO (Ambos son del mismo color)")
