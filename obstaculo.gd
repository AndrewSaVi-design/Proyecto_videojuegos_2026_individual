extends Area2D

# Velocidad a la que el obstáculo viene hacia Michael
var velocidad = 400 

func _process(delta):
	# Mueve el obstáculo hacia la izquierda
	position.x -= velocidad * delta
	
	# Si sale de la pantalla, se borra para ahorrar memoria
	if position.x < -200:
		queue_free()

# Esta es la función que detecta el choque con Michael para mandarlo al Game Over
func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro" or area.is_in_group("Player"):
		print("¡GAME OVER - Michael chocó contra el obstáculo cuadrado!")
		# Te redirige inmediatamente a tu pantalla de Game Over
		get_tree().change_scene_to_file("res://game_over.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://game_over.tscn")
