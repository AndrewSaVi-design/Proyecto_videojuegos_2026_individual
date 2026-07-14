extends Node2D

# VARIABLES DEL CONTADOR DE KILÓMETROS
var distancia: float = 0.0
@onready var texto_distancia = $Interfaz/TextoDistancia

# VARIABLES DEL CONTADOR DE MONEDAS
@onready var texto_monedas = $Interfaz/TextoMonedas

# NUEVAS VARIABLES PARA LA TIENDA
@onready var panel_compra = $Interfaz/PanelCompra
var tienda_abierta: bool = false 

var poder_activo: bool = false
var meta_distancia_poder: float = 0.0
@onready var jugador = $Jugador 

var multiplicador_velocidad: float = 1.0
@onready var parallax_fondo = $Parallax2D 

# Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn")
var escena_moneda = preload("res://moneda.tscn") 
var objetoCircular = preload("res://obstaculo_circular.tscn")
var escena_moto = preload("res://item_moto.tscn") 

func _ready() -> void:
	texto_monedas.text = "" + str(Global.monedas)
	panel_compra.hide()
	
	if Global.monedas >= 5:
		mostrar_ventana_compra()
		
	# <--- CORRECCIÓN: Conectamos la señal de muerte con tu función de la lotería
	jugador.jugador_murio.connect(_on_jugador_choca)

# --- INTEGRACIÓN LOTERÍA: FUNCIÓN PARA CUANDO PIERDES ---
func _on_jugador_choca():
	get_tree().paused = true # Pausar el juego
	
	var escena_loto = load("res://slot_machine.tscn")
	var instancia_loto = escena_loto.instantiate()
	
	# --- EL CAMBIO ESTÁ EN ESTA LÍNEA ---
	# Lo añadimos a la Interfaz para que se dibuje por encima de todo
	$Interfaz.add_child(instancia_loto) 
	
	# Conectamos la señal definida en SlotMachine.gd
	instancia_loto.resultado_decision.connect(_gestionar_resultado_loto)

func _gestionar_resultado_loto(decision: String):
	get_tree().paused = false # SIEMPRE despausamos antes de cambiar de escena o revivir
	
	if decision == "vida_extra":
		if jugador.has_method("revivir"):
			jugador.revivir()
		print("¡Vida extra concedida!")
	else:
		# Cambiamos a la escena de Game Over. 
		get_tree().change_scene_to_file("res://game_over.tscn")
# --------------------------------------------------------

func _process(delta: float) -> void:
	distancia += delta * 10.0 * multiplicador_velocidad
	texto_distancia.text = str(int(distancia)) + " km"
	
	if poder_activo and distancia >= meta_distancia_poder:
		desactivar_poder()
		
	if parallax_fondo:
		parallax_fondo.scroll_offset.x -= 150.0 * delta * multiplicador_velocidad

func sumar_moneda() -> void:
	Global.monedas += 1
	Global.guardar_datos()
	texto_monedas.text = "" + str(Global.monedas)

func mostrar_ventana_compra():
	tienda_abierta = true
	panel_compra.show()
	
func _input(event: InputEvent) -> void:
	if tienda_abierta:
		if event.is_action_pressed("comprar"):
			realizar_compra()
		elif event.is_action_pressed("escapar"):
			cerrar_ventana_compra()
			
func realizar_compra():
	Global.monedas -= 5
	Global.guardar_datos()
	texto_monedas.text = "Monedas: " + str(Global.monedas)
	cerrar_ventana_compra()
	
	poder_activo = true
	meta_distancia_poder = distancia + 400.0 
	multiplicador_velocidad = 10.0
	
	if jugador and jugador.has_method("set_invencible"):
		jugador.set_invencible(true)
		
func desactivar_poder():
	poder_activo = false
	multiplicador_velocidad = 1.0
	if jugador and jugador.has_method("set_invencible"):
		jugador.set_invencible(false)

func cerrar_ventana_compra():
	tienda_abierta = false
	panel_compra.hide()

func _on_generador_obstaculos_timeout() -> void:
	var suerte = randi() % 15 
	var tiempo_espera_base = 1.2 
	if distancia >= 400:
		tiempo_espera_base = 0.4 
	elif distancia >= 200:
		tiempo_espera_base = 0.7 
	elif distancia >= 50:
		tiempo_espera_base = 0.9 
	
	if suerte == 14 and not jugador.en_moto:
		var instancia_moto = escena_moto.instantiate()
		instancia_moto.position = Vector2(1200, 450) 
		add_child(instancia_moto)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 4: 
		var nuevo_ob = escena_obstaculo.instantiate()
		nuevo_ob.position = Vector2(1200, randf_range(150, 450))
		add_child(nuevo_ob)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 6: 
		crear_peligro(laserCian, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 8: 
		crear_peligro(laserNaranja, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 9: 
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
		
	elif suerte < 11: 
		var nueva_moneda = escena_moneda.instantiate()
		nueva_moneda.position = Vector2(1200, randf_range(180, 420))
		add_child(nueva_moneda)
		$GeneradorObstaculos.wait_time = 0.5 
		
	else: 
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
