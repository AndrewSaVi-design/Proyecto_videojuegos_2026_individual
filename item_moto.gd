extends Area2D

var velocidad = 400 

func _process(delta):
	position.x -= velocidad * delta

func _on_body_entered(body):
	# ¡Cambiamos "Player" por "Jugador"!
	if body.name == "Jugador": 
		body.activar_moto()
		queue_free()
