extends Area2D

var velocidad = 400 

func _process(delta):
	position.x -= velocidad * delta
	
	# Si el jugador NO la tomó y salió de la pantalla, la borramos del mapa
	if position.x < -200:
		queue_free()

func _on_body_entered(body):
	print("🚨 ALGO CHOCÓ CON LA MOTO. Se llama: ", body.name)
	if body.name == "Jugador":
		print("✅ ¡Es el Jugador! Mandando orden de activar moto...")
		body.activar_moto()
		queue_free()
