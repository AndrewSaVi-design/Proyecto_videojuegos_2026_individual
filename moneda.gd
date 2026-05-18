extends Area2D

var velocidad = 400

func _process(delta: float) -> void:
	# Mueve la moneda hacia la izquierda
	position.x -= velocidad * delta
	
	# Se elimina si sale por completo de la pantalla
	if position.x < -100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		if get_tree().current_scene.has_method("sumar_moneda"):
			get_tree().current_scene.sumar_moneda()
		
		queue_free()
