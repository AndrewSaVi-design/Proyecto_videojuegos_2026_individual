extends Node2D

# VARIABLES DEL CONTADOR DE KILÓMETROS
var distancia: float = 0.0
@onready var texto_distancia = $Interfaz/TextoDistancia

# VARIABLES DEL CONTADOR DE MONEDAS
@onready var texto_monedas = $Interfaz/TextoMonedas

# NUEVAS VARIABLES PARA LA TIENDA
@onready var panel_compra = $Interfaz/PanelCompra
var tienda_abierta: bool = false # Controla si el cuadro está en pantalla

var poder_activo: bool = false
var meta_distancia_poder: float = 0.0
@onready var jugador = $Jugador # Asegúrate de que el nodo se llame "Jugador" en tu escena

# NUEVA VARIABLE: Controla el turbo del mundo entero
var multiplicador_velocidad: float = 1.0
@onready var parallax_fondo = $Parallax2D # Cambia el nombre si tu nodo se llama distinto

# Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn")
var escena_moneda = preload("res://moneda.tscn") 
var objetoCircular = preload("res://obstaculo_circular.tscn")
var escena_moto = preload("res://item_moto.tscn") # <-- NUEVO: Cargamos la moto

func _ready() -> void:
	# Al iniciar la escena, mostramos las monedas que estaban guardadas globalmente
	texto_monedas.text = "Monedas: " + str(Global.monedas)
	panel_compra.hide() # Lo ocultamos por defecto
	
	# NUEVO: Revisamos el dinero solo al arrancar la partida
	if Global.monedas >= 5:
		mostrar_ventana_compra()

func _process(delta: float) -> void:
	distancia += delta * 10.0 * multiplicador_velocidad
	texto_distancia.text = str(int(distancia)) + " km"
	
	# Revisamos constantemente si el jugador ya recorrió los 400 km de ventaja
	if poder_activo and distancia >= meta_distancia_poder:
		desactivar_poder()
		
	# NUEVA LÍNEA: Aceleramos el fondo
	if parallax_fondo:
		# Cambia '150.0' por la velocidad normal a la que se movía tu fondo
		parallax_fondo.scroll_offset.x -= 150.0 * delta * multiplicador_velocidad

func sumar_moneda() -> void:
	# Usamos la variable del Autoload
	Global.monedas += 1
	Global.guardar_datos() # Guarda permanentemente cada vez que agarras una moneda
	
	texto_monedas.text = "Monedas: " + str(Global.monedas)

# --- NUEVA LÓGICA DE LA VENTANA DE COMPRA ---

func mostrar_ventana_compra():
	tienda_abierta = true
	panel_compra.show()
	
# La función _input detecta cuando presionas cualquier tecla
func _input(event: InputEvent) -> void:
	# Solo escuchamos el teclado si la ventana de compra está en pantalla
	if tienda_abierta:
		# Si presiona ENTER (ui_accept es la acción por defecto para Enter/Espacio en Godot)
		if event.is_action_pressed("comprar"):
			realizar_compra()
		# Si presiona ESCAPE (ui_cancel es la acción por defecto para Esc)
		elif event.is_action_pressed("escapar"):
			cerrar_ventana_compra()
			
func realizar_compra():
	# 1. Descontamos las monedas y guardamos
	Global.monedas -= 5
	Global.guardar_datos()
	texto_monedas.text = "Monedas: " + str(Global.monedas)
	
	# 2. Desaparecemos el cuadro
	cerrar_ventana_compra()
	
	poder_activo = true
	meta_distancia_poder = distancia + 400.0 
	
	# MODIFICACIÓN AQUÍ: Activamos el turbo de velocidad (3 veces más rápido)
	multiplicador_velocidad = 10.0
	
	if jugador and jugador.has_method("set_invencible"):
		jugador.set_invencible(true)
		
# NUEVA FUNCIÓN: Apaga el poder
func desactivar_poder():
	poder_activo = false
	multiplicador_velocidad = 1.0
	if jugador and jugador.has_method("set_invencible"):
		jugador.set_invencible(false)

func cerrar_ventana_compra():
	tienda_abierta = false
	panel_compra.hide()

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 15 # <-- CAMBIO: Ampliado a 15 para la moto
	
	# --- CAMBIO AQUÍ: FRECUENCIA AJUSTADA HASTA LOS 400 KM ---
	var tiempo_espera_base = 1.2 # Ritmo inicial (0 a 50 km)
	if distancia >= 400:
		tiempo_espera_base = 0.4 # Ritmo frenético extremo a los 400 km
	elif distancia >= 200:
		tiempo_espera_base = 0.7 # Ritmo rápido a los 200 km
	elif distancia >= 50:
		tiempo_espera_base = 0.9 # Ritmo intermedio a los 50 km
	
	# --- RULETA ALEATORIA ACTUALIZADA ---
	
	# NUEVO: Lógica de aparición de la moto (Solo si no tiene moto ya)
	if suerte == 14 and not jugador.en_moto:
		var instancia_moto = escena_moto.instantiate()
		# Ajusta el '450' si necesitas que la moto aparezca más arriba o más abajo
		instancia_moto.position = Vector2(1200, 450) 
		add_child(instancia_moto)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 4: # 1. OBSTÁCULO NORMAL (MÁS FRECUENTE)
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
