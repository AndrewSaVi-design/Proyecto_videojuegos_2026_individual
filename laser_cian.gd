extends Area2D

# Esta es la velocidad a la que el láser viajará hacia la izquierda
var velocidad = 400 

func _process(delta):
	# Movemos la posición X hacia la izquierda constantemente
	position.x -= velocidad * delta
	
	# Si el láser sale de la pantalla por la izquierda (X < -100), se borra
	if position.x < -100:
		queue_free() # Esto es para que el juego no se ponga lento
