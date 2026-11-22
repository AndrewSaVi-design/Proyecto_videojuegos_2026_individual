extends Area2D

var ya_choco = false # Evita que el choque se procese múltiples veces seguidas

func _process(delta):
	var velocidad_base = 340.0
	var turbo = 1.0
	var mundo = get_tree().current_scene
	if mundo and "multiplicador_velocidad" in mundo:
		turbo = mundo.multiplicador_velocidad

	position.x -= velocidad_base * turbo * delta
	
	if position.x < -200:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro":
		verificar_polaridad(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_polaridad(body)

func verificar_polaridad(jugador):
	if ya_choco:
		return
		
	var fallo_cian = is_in_group("laser_cian") and jugador.es_cian == false
	var fallo_naranja = is_in_group("laser_naranja") and jugador.es_cian == true
	
	if fallo_cian or fallo_naranja:
		ya_choco = true
		if jugador.has_method("recibir_danio"):
			jugador.recibir_danio()
	else:
		print("Resultado: SALVADO (Ambos son del mismo color)")
