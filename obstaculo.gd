extends Area2D

var ya_choco = false # Evita procesar el choque múltiples veces
"""
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
		queue_free()"""
func _process(delta):
	var velocidad_base = 300.0
	var velocidad_final = velocidad_base
	
	# Escalado de dificultad normal
	var mundo = get_tree().current_scene
	if mundo and "distancia" in mundo:
		if mundo.distancia >= 400:
			velocidad_final += 400.0
		elif mundo.distancia >= 200:
			velocidad_final += 250.0
		elif mundo.distancia >= 50:
			velocidad_final += 120.0

	# NUEVA LÓGICA: Si el mundo tiene un multiplicador de velocidad, lo aplicamos aquí
	var turbo = 1.0
	if mundo and "multiplicador_velocidad" in mundo:
		turbo = mundo.multiplicador_velocidad

	# MODIFICACIÓN AQUÍ: Añadimos la variable 'turbo' al movimiento
	position.x -= velocidad_final * turbo * delta
	
	# Si es el obstáculo circular, también puedes acelerar su rotación si quieres:
	# rotation_degrees += velocidad_rotacion * turbo * delta
	
	if position.x < -200:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro" or area.is_in_group("Player"):
		verificar_impacto(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_impacto(body)

# Nueva función de control
func verificar_impacto(jugador):
	if ya_choco:
		return
		
	ya_choco = true
	#set_process(false) # Detiene el avance del obstáculo tras el choque
	
	# Llamamos a la nueva lógica de daño por bloque en el jugador
	if jugador.has_method("recibir_impacto_bloque"):
		jugador.recibir_impacto_bloque()
