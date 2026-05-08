extends Area2D

# Velocidad a la que el obstáculo viene hacia Michael
var velocidad = 400 

func _process(delta):
	# Mueve el obstáculo hacia la izquierda
	position.x -= velocidad * delta
	
	# Si sale de la pantalla, se borra para ahorrar memoria
	if position.x < -200:
		queue_free()
