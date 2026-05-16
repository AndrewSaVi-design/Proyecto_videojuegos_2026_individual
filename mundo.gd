extends Node2D

# Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn")

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 10
	
	if suerte < 3: # 30% LÁSERES HORIZONTALES
		var y_min = 150
		var y_max = 400
		var cantidad = randi_range(1, 2)
		
		if cantidad == 1:
			crear_peligro(laserHorizontal, true, randf_range(y_min, y_max))
		else:
			var h1 = randf_range(y_min, 250)
			var h2 = randf_range(300, y_max)
			crear_peligro(laserHorizontal, true, h1)
			crear_peligro(laserHorizontal, true, h2)
			
		# Pausa de 4.5 segundos exclusiva para el ciclo del láser horizontal
		$GeneradorObstaculos.wait_time = 4.5
		
	elif suerte < 5: # 20% Cian
		crear_peligro(laserCian, false)
		$GeneradorObstaculos.wait_time = 1.2
		
	elif suerte < 7: # 20% Naranja
		crear_peligro(laserNaranja, false)
		$GeneradorObstaculos.wait_time = 1.2
		
	else: # 30% Obstáculo normal
		var nuevo_ob = escena_obstaculo.instantiate()
		nuevo_ob.position = Vector2(1200, randf_range(150, 450))
		add_child(nuevo_ob)
		$GeneradorObstaculos.wait_time = 1.2
		
	# Inicia el reloj con el tiempo que se haya elegido
	$GeneradorObstaculos.start()

# Función para posicionar los obstáculos
func crear_peligro(escena, es_horizontal, altura_especifica = 0):
	var instancia = escena.instantiate()
	
	if es_horizontal:
		instancia.position.x = 570 
		instancia.position.y = altura_especifica
	else:
		instancia.position = Vector2(1200, randf_range(100, 500))
		
	add_child(instancia)
