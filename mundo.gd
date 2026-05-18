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

func _process(delta: float) -> void:
	distancia += delta * 10.0
	texto_distancia.text = str(int(distancia)) + " km"

func sumar_moneda() -> void:
	monedas += 1
	texto_monedas.text = "Monedas: " + str(monedas)

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 12 # Genera un número del 0 al 11
	
	# REGLA DE DIFICULTAD (ESTO SE MANTIENE IGUAL)
	var tiempo_espera_base = 1.2
	if distancia >= 100:
		tiempo_espera_base = 0.6 
	elif distancia >= 50:
		tiempo_espera_base = 0.9 
	
	# --- RULETA ALEATORIA CORREGIDA ---
	
	if suerte < 4: # 1. OBSTÁCULO NORMAL (MÁS FRECUENTE - 33.3% de probabilidad)
		var nuevo_ob = escena_obstaculo.instantiate()
		nuevo_ob.position = Vector2(1200, randf_range(150, 450))
		add_child(nuevo_ob)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 6: # 2. Laser Cian (16.6% de probabilidad)
		crear_peligro(laserCian, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 8: # 3. Laser Naranja (16.6% de probabilidad)
		crear_peligro(laserNaranja, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 9: # 4. LÁSER HORIZONTALES (MUY RARO - 8.3% de probabilidad)
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
			
		$GeneradorObstaculos.wait_time = 4.5 # Pausa larga fija para los horizontales
		
	else: # 5. MONEDAS (25% de probabilidad)
		var nueva_moneda = escena_moneda.instantiate()
		nueva_moneda.position = Vector2(1200, randf_range(180, 420))
		add_child(nueva_moneda)
		$GeneradorObstaculos.wait_time = 0.5 
		
	$GeneradorObstaculos.start()

func crear_peligro(escena, es_horizontal, altura_especifica = 0):
	var instancia = escena.instantiate()
	
	if es_horizontal:
		instancia.position.x = 570
		instancia.position.y = altura_especifica
	else:
		instancia.position = Vector2(1200, randf_range(100, 500))
		
	add_child(instancia)
