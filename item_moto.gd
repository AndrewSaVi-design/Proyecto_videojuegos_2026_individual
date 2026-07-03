extends Area2D

var velocidad = 400 

func _process(delta):
	position.x -= velocidad * delta
	
	if position.x < -200:
		queue_free()

func _on_body_entered(body):
	# Verificamos que sea el Jugador
	if body.name == "Jugador":
		body.activar_moto()
		queue_free()
