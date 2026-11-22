extends Area2D

var ya_choco = false # Evita procesar el choque múltiples veces

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
	if area.name == "DetectorPeligro" or area.is_in_group("Player"):
		verificar_impacto(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_impacto(body)

func verificar_impacto(jugador):
	if ya_choco:
		return
		
	ya_choco = true
	
	if jugador.has_method("recibir_impacto_bloque"):
		jugador.recibir_impacto_bloque()
