extends Node2D

# VARIABLES DEL CONTADOR DE KILÓMETROS
var distancia: float = 0.0
@onready var texto_distancia = $Interfaz/TextoDistancia

# VARIABLES DEL CONTADOR DE MONEDAS
var monedas: int = 0
@onready var texto_monedas = $Interfaz/TextoMonedas

# --- NUEVA VARIABLE: Guarda en qué kilómetro salió la última moto ---
var kilometro_ultima_moto: float = -100.0 

# Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn")
var escena_moneda = preload("res://moneda.tscn") 
var objetoCircular = preload("res://obstaculo_circular.tscn")
var escena_moto = preload("res://item_moto.tscn") 

func _process(delta: float) -> void:
	distancia += delta * 10.0
	texto_distancia.text = str(int(distancia)) + " km"

func sumar_moneda() -> void:
	monedas += 1
	texto_monedas.text = "Monedas: " + str(monedas)

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 16 
	
	var tiempo_espera_base = 1.2 
	if distancia >= 400:
		tiempo_espera_base = 0.4
	elif distancia >= 200:
		tiempo_espera_base = 0.7 
	elif distancia >= 50:
		tiempo_espera_base = 0.9 
	
	if suerte < 4: # 1. OBSTÁCULO NORMAL
		var nuevo_ob = escena_obstaculo.instantiate()
		nuevo_ob.position = Vector2(1200, randf_range(150, 450))
		add_child(nuevo_ob)
		
	elif suerte < 6: # 2. Laser Cian
		crear_peligro(laserCian, false)
		
	elif suerte < 8: # 3. Laser Naranja
		crear_peligro(laserNaranja, false)
		
	elif suerte < 9: # 4. LÁSER HORIZONTALES
		var y_min = 150
		var y_max = 400
		var cantidad = randi_range(1, 2)
		if cantidad == 1:
			crear_peligro(laserHorizontal, true, randf_range(y_min, y_max))
		else:
			crear_peligro(laserHorizontal, true, randf_range(y_min, 250))
			crear_peligro(laserHorizontal, true, randf_range(300, y_max))
			
	elif suerte < 11: # 5. MONEDAS
		var nueva_moneda = escena_moneda.instantiate()
		nueva_moneda.position = Vector2(1200, randf_range(180, 420))
		add_child(nueva_moneda)
		
	elif suerte < 13: # 6. MOTO (Logica inteligente de reaparición)
		# Buscamos al jugador de forma segura para saber su estado
		var jugador = get_node_or_null("Jugador")
		var jugador_ya_tiene_moto = false
		if jugador and jugador.en_moto == true:
			jugador_ya_tiene_moto = true
			
		# "Tiempo prudente": Definimos que deben pasar al menos 60 km desde la última moto
		var paso_tiempo_prudente = (distancia - kilometro_ultima_moto) >= 60.0
		
		# SI NO TIENE LA MOTO Y YA PASÓ EL TIEMPO PRUDENTE, LA REAPARECEMOS
		if not jugador_ya_tiene_moto and paso_tiempo_prudente:
			var nueva_moto = escena_moto.instantiate()
			nueva_moto.position = Vector2(1200, randf_range(180, 420))
			add_child(nueva_moto)
			kilometro_ultima_moto = distancia # Guardamos el kilómetro actual
		else:
			# Si ya tiene moto o apareció hace muy poco, ponemos una moneda en su lugar
			var nueva_moneda = escena_moneda.instantiate()
			nueva_moneda.position = Vector2(1200, randf_range(180, 420))
			add_child(nueva_moneda)
			
	else: # 7. OBSTÁCULO ROTATORIO
		var instancia_circular = objetoCircular.instantiate()
		instancia_circular.position = Vector2(1200, randf_range(150, 450))
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
