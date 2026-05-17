extends Area2D

var velocidad = 400 

func _process(delta):
	position.x -= velocidad * delta
	if position.x < -100:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro":
		verificar_polaridad(area.get_parent())

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_polaridad(body)

# Función que decide si Michael sobrevive o va al Game Over
# Función que decide si Michael sobrevive o va al Game Over
func verificar_polaridad(jugador):
	# EL CHISMOSO: Imprimirá los datos exactos del choque en la consola
	print("--- CHOQUE DETECTADO ---")
	print("Grupos de este láser: ", get_groups())
	print("¿El traje de Michael es Cian? (es_cian): ", jugador.es_cian)
	
	if is_in_group("laser_cian") and jugador.es_cian == false:
		print("Resultado: MUERTE (Láser Cian chocó con Traje Naranja)")
		get_tree().change_scene_to_file("res://game_over.tscn")
		
	elif is_in_group("laser_naranja") and jugador.es_cian == true:
		print("Resultado: MUERTE (Láser Naranja chocó con Traje Cian)")
		get_tree().change_scene_to_file("res://game_over.tscn")
		
	else:
		print("Resultado: SALVADO (Ambos son del mismo color)")
