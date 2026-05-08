extends Node2D

# 1. Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn") 

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 10
	
	if suerte < 3: # 30% de probabilidad para LÁSERES ESTÁTICOS
		# Aparecen dos láseres a la vez en posiciones fijas de la pantalla
		crear_peligro(laserHorizontal, true, 200) 
		crear_peligro(laserHorizontal, true, 450)
		
		# IMPORTANTE: Damos 3 segundos de espacio para que el láser cumpla su ciclo y desaparezca
		$GeneradorObstaculos.wait_time = 3.0
		
	elif suerte < 5: # 20% Cian
		crear_peligro(laserCian, false)
		$GeneradorObstaculos.wait_time = 1.2
		
	elif suerte < 7: # 20% Naranja
		crear_peligro(laserNaranja, false)
		$GeneradorObstaculos.wait_time = 1.2
		
	else: # 30% Obstáculo normal
		var nuevo_ob = escena_obstaculo.instantiate()
		# Estos siempre nacen en la derecha (1200)
		nuevo_ob.position = Vector2(1200, randf_range(150, 450))
		add_child(nuevo_ob)
		$GeneradorObstaculos.wait_time = 1.2
	
	# Reiniciamos el reloj para aplicar el nuevo tiempo
	$GeneradorObstaculos.start()

# 2. Función que controla DÓNDE aparece cada cosa
func crear_peligro(escena, es_horizontal, altura_fija = 0):
	var instancia = escena.instantiate()
	
	if es_horizontal:
		# Lógica para el láser tipo Jetpack Joyride:
		# Aparece directamente en el medio del mapa (X=570 aprox)
		# No necesita venir desde la derecha porque es estático
		var pos_x_centro = 570 
		
		if altura_fija != 0:
			instancia.position = Vector2(pos_x_centro, altura_fija)
		else:
			instancia.position = Vector2(pos_x_centro, 300)
	else:
		# Los obstáculos que SÍ se mueven nacen fuera de la pantalla a la derecha
		instancia.position = Vector2(1200, randf_range(100, 500))
		
	add_child(instancia)
