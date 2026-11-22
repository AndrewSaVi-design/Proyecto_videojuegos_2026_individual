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

# VARIABLES DE LA ALCANCÍA INTEGRADA
@onready var alcancia_area = $AlcanciaArea
@onready var colision_alcancia = $AlcanciaArea/CollisionShape2D
var alcancia_generada: bool = false
var alcancia_activa: bool = false

# Cargamos las escenas
var laserCian = preload("res://laserCian.tscn")
var laserNaranja = preload("res://laserNaranja.tscn")
var escena_obstaculo = preload("res://obstaculo.tscn")
var laserHorizontal = preload("res://laser_horizontal.tscn")
var escena_moneda = preload("res://moneda.tscn") 
var objetoCircular = preload("res://obstaculo_circular.tscn")
var escena_moto = preload("res://item_moto.tscn") 

# REFERENCIA DIRECTA A LA RULETA ACTIVA
var loto_actual: Node = null

# CONTROL DE APARICIÓN DE LA MOTO
var ultima_distancia_moto: float = -200.0

func _ready() -> void:
	texto_monedas.text = "" + str(Global.monedas)
	panel_compra.hide()
	
	# ESCONDEMOS LA ALCANCÍA AL INICIAR
	if alcancia_area:
		alcancia_area.hide()
		colision_alcancia.set_deferred("disabled", true)
	
	if Global.monedas >= 5:
		mostrar_ventana_compra()
		
	jugador.jugador_murio.connect(_on_jugador_choca)

# --- INTEGRACIÓN LOTERÍA: FUNCIÓN PARA CUANDO PIERDES ---
func _on_jugador_choca():
	if loto_actual != null:
		return
		
	get_tree().paused = true
	
	var escena_loto = load("res://slot_machine.tscn")
	loto_actual = escena_loto.instantiate()
	
	$Interfaz.add_child(loto_actual) 
	loto_actual.resultado_decision.connect(_gestionar_resultado_loto)

func _gestionar_resultado_loto(decision: String):
	if decision == "vida_extra":
		await get_tree().create_timer(2.5).timeout 
		
		if is_instance_valid(loto_actual):
			loto_actual.queue_free()
		loto_actual = null
		
		get_tree().paused = false 
		
		if jugador.has_method("revivir"):
			jugador.revivir()
		print("¡Vida extra concedida!")
			
	else:
		loto_actual = null
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game_over.tscn")
# --------------------------------------------------------

func _process(delta: float) -> void:
	# ACELERACIÓN PROGRESIVA SEGÚN KILÓMETROS (sube de 1.0x hasta 2.2x)
	var escala_km = clamp(1.0 + (distancia / 600.0), 1.0, 2.2)
	
	if poder_activo:
		multiplicador_velocidad = 10.0
	elif jugador and jugador.en_moto:
		multiplicador_velocidad = 2.2 * escala_km
	else:
		multiplicador_velocidad = escala_km
	
	distancia += delta * 10.0 * multiplicador_velocidad
	texto_distancia.text = str(int(distancia)) + " km"
	
	if poder_activo and distancia >= meta_distancia_poder:
		desactivar_poder()
		
	if parallax_fondo:
		parallax_fondo.scroll_offset.x -= 220.0 * delta * multiplicador_velocidad
		
	# --- LÓGICA DE ACTIVACIÓN ALCANCÍA ---
	if distancia >= 100.0 and not alcancia_generada:
		activar_alcancia()
		
	if alcancia_activa:
		var velocidad_base = 500.0 
		alcancia_area.position.x -= velocidad_base * multiplicador_velocidad * delta
		
		if alcancia_area.position.x < -200:
			alcancia_activa = false
			alcancia_area.hide()
			colision_alcancia.set_deferred("disabled", true)

func activar_alcancia():
	alcancia_generada = true
	alcancia_activa = true
	alcancia_area.position = Vector2(1300, 300)
	alcancia_area.show()
	colision_alcancia.set_deferred("disabled", false)	

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
	# El tiempo entre obstáculos también se reduce conforme aceleras
	var tiempo_espera_base = clamp(1.3 / multiplicador_velocidad, 0.45, 1.3)
	
	# PREMIO POCO COMÚN: 1 de 45 intentos, después de 150 km y mínimo 300 km desde la última moto
	var probabilidad_moto = (randi() % 45 == 0)
	if probabilidad_moto and not jugador.en_moto and distancia >= 150.0 and (distancia - ultima_distancia_moto) >= 300.0:
		ultima_distancia_moto = distancia
		var instancia_moto = escena_moto.instantiate()
		instancia_moto.position = Vector2(1200, 480) 
		add_child(instancia_moto)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 4: 
		# OBSTÁCULO NEUTRO: 60% de las veces aparece a ras del suelo para obligar a saltar
		var nuevo_ob = escena_obstaculo.instantiate()
		var altura_ob = randf_range(470, 535) if randf() < 0.6 else randf_range(160, 420)
		nuevo_ob.position = Vector2(1200, altura_ob)
		add_child(nuevo_ob)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 6: 
		crear_peligro(laserCian, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 8: 
		crear_peligro(laserNaranja, false)
		$GeneradorObstaculos.wait_time = tiempo_espera_base
		
	elif suerte < 9: 
		var y_min = 160
		var y_max = 510 # Llega hasta el suelo para obligar a saltar
		var cantidad = randi_range(1, 2)
		if cantidad == 1:
			# 50% de probabilidad de salir justo en el piso
			var altura_laser = randf_range(470, 515) if randf() < 0.5 else randf_range(y_min, 380)
			crear_peligro(laserHorizontal, true, altura_laser)
		else:
			var h1 = randf_range(y_min, 280)
			var h2 = randf_range(450, y_max)
			crear_peligro(laserHorizontal, true, h1)
			crear_peligro(laserHorizontal, true, h2)
		$GeneradorObstaculos.wait_time = clamp(3.8 / multiplicador_velocidad, 1.8, 3.8)
		
	elif suerte < 11: 
		var nueva_moneda = escena_moneda.instantiate()
		nueva_moneda.position = Vector2(1200, randf_range(180, 480))
		add_child(nueva_moneda)
		$GeneradorObstaculos.wait_time = 0.5 
		
	else: 
		var instancia_circular = objetoCircular.instantiate()
		instancia_circular.position = Vector2(1200, randf_range(160, 510))
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
		instancia.position = Vector2(1200, randf_range(120, 520))
	add_child(instancia)

func _on_alcancia_area_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		alcancia_activa = false
		alcancia_area.hide()
		colision_alcancia.set_deferred("disabled", true)
		generar_fila_monedas()

func generar_fila_monedas():
	for i in range(10):
		var nueva_moneda = escena_moneda.instantiate()
		var distancia_x = randf_range(50, 600)
		var variacion_y = randf_range(-150, 150) 
		var x_moneda = alcancia_area.global_position.x + distancia_x
		var y_moneda = clamp(alcancia_area.global_position.y + variacion_y, 120, 500)
		nueva_moneda.position = Vector2(x_moneda, y_moneda)
		call_deferred("add_child", nueva_moneda)
