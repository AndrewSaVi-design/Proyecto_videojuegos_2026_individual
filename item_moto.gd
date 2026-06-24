extends Area2D

var velocidad = 400 

func _process(delta):
	position.x -= velocidad * delta
	
	# Si el jugador NO la tomó y salió de la pantalla, la borramos del mapa
	if position.x < -200:
		queue_free()

func _on_body_entered(body):
	if body.name == "Jugador": 
		body.activar_moto()
		queue_free()
