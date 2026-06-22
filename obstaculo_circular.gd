extends Area2D

var velocidad_base = 300.0
var velocidad_rotacion = 120.0 
var ya_choco = false # <-- Evita que el choque se cuente múltiples veces

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

# (Opcional) Si en tu jugador tienes un Area2D llamado "DetectorPeligro" como en los láseres
func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro" or area.is_in_group("Player"):
		verificar_impacto(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_impacto(body)

# NUEVA FUNCIÓN: Maneja el impacto de forma segura
func verificar_impacto(jugador):
	if ya_choco:
		return
		
	ya_choco = true
	#set_process(false) # Detiene el avance en X y también detiene la rotación
	
	# Llamamos a la función que ya programamos en el jugador
	if jugador.has_method("recibir_impacto_bloque"):
		jugador.recibir_impacto_bloque()
