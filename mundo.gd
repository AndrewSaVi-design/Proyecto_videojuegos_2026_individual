extends Node2D

# VARIABLES DEL CONTADOR DE KILÓMETROS
var distancia: float = 0.0
@onready var texto_distancia = $Interfaz/TextoDistancia

# VARIABLES DEL CONTADOR DE MONEDAS
var monedas: int = 0
@onready var texto_monedas = $Interfaz/TextoMonedas

# Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn")
var escena_moneda = preload("res://moneda.tscn") 

# NUEVO: Cargamos tu barra de contención que rota
var objetoCircular = preload("res://obstaculo_circular.tscn")

func _process(delta: float) -> void:
	distancia += delta * 10.0
	texto_distancia.text = str(int(distancia)) + " km"

func sumar_moneda() -> void:
	monedas += 1
	texto_monedas.text = "Monedas: " + str(monedas)

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 14 # Ampliado a 14 para meter el nuevo peligro
	
	# --- CAMBIO AQUÍ: FRECUENCIA AJUSTADA HASTA LOS 400 KM ---
	var tiempo_espera_base = 1.2 # Ritmo inicial (0 a 50 km)
	if distancia >= 400:
		tiempo_espera_base = 0.4 # Ritmo frenético extremo a los 400 km
	elif distancia >= 200:
		tiempo_espera_base = 0.7 # Ritmo rápido a los 200 km
	elif distancia >= 50:
		tiempo_espera_base = 0.9 # Ritmo intermedio a los 50 km
	
	# --- RULETA ALEATORIA ACTUALIZADA ---
	
	if suerte < 4: # 1. OBSTÁCULO NORMAL (MÁS FRECUENTE)
		var nuevo_ob = escena_obstaculo.instantiate()
		nuevo_ob.position = Vector2(1200, randf_range(150, 450))
		add_child(nuevo_ob)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 6: # 2. Laser Cian
		crear_peligro(laserCian, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 8: # 3. Laser Naranja
		crear_peligro(laserNaranja, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 9: # 4. LÁSER HORIZONTALES
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
			
		$GeneradorObstaculos.wait_time = 4.5 
		
	elif suerte < 11: # 5. MONEDAS (25% de probabilidad)
		var nueva_moneda = escena_moneda.instantiate()
		nueva_moneda.position = Vector2(1200, randf_range(180, 420))
		add_child(nueva_moneda)
		$GeneradorObstaculos.wait_time = 0.5 
		
	else: # 6. NUEVO: OBSTÁCULO ROTATORIO (Se activa con los números 11, 12 y 13)
		var instancia_circular = objetoCircular.instantiate()
		instancia_circular.position = Vector2(1200, randf_range(150, 450))
		# Le damos una inclinación sorpresa al nacer
		instancia_circular.rotation_degrees = randf_range(0.0, 360.0)
		add_child(instancia_circular)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	$GeneradorObstaculos.start()

func crear_peligro(escena, es_horizontal, altura_specifica = 0):
	var instancia = escena.instantiate()
	
	if es_horizontal:
		instancia.position.x = 570
		instancia.position.y = altura_specifica
	else:
		instancia.position = Vector2(1200, randf_range(100, 500))
		
	add_child(instancia)
