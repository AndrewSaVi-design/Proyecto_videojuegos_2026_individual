extends CharacterBody2D

var gravedad = 600
var potencia_propulsor = 2500 # Fuerza continua para el jetpack
var es_cian = false 
var esta_herido = false # <-- NUEVA VARIABLE: Controla si el jugador recibió un golpe
var en_moto = false

# 1. Cambiamos la referencia al nuevo nodo AnimatedSprite2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var SonidoElectrocutar = $SonidoElectrocutar

var invencible = false # <-- NUEVA VARIABLE

# Funciones para la física
func _physics_process(delta):
	# Si el personaje está herido, salimos de la función inmediatamente
	# Esto evita que se mueva o que cambie su animación a "run" o "fly"
	if esta_herido:
		velocity.y += gravedad * delta
		velocity.y = clamp(velocity.y, -300, 400)
		move_and_slide()
		return
		
	# Gravedad constante (empuja hacia abajo)
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	# Propulsor Suave (empuja hacia arriba)
	if Input.is_action_pressed("ui_select"):
		velocity.y -= potencia_propulsor * delta
		
	velocity.y = clamp(velocity.y, -300, 400)
	move_and_slide()
	
	# 2. Lógica de Animaciones
	# --- 2. LÓGICA DE ANIMACIONES ACTUALIZADA ---
	if abs(velocity.y) == 400: 
		# Revisamos si el poder está activo mientras corre
		if invencible:
			animated_sprite.play("runInvencible")
		else:
			animated_sprite.play("run")
	else:
		# Si está en el aire flotando
		animated_sprite.play("fly")
		# Nota: Si también creaste una animación para volar invencible, 
		# podrías poner un if/else aquí igual que arriba llamando a "flyInvencible".
	
	# Cambio de color
	if Input.is_action_just_pressed("cambiar_color"):
		cambiar_traje()
		
# NUEVA FUNCIÓN: Activada específicamente por el obstáculo sólido
func    cto_bloque():
	if invencible: return # Ignoramos el choque
	esta_herido = true  
	animated_sprite.play("hurtBlock") # Cambia a la animación de golpe por bloque
	
	# El juego continúa ejecutando las físicas de caída durante 1 segundo
	await get_tree().create_timer(1.5).timeout
	
	# Tras el segundo de caída y visualización del daño, cambia la escena
	get_tree().change_scene_to_file("res://game_over.tscn")

# <-- NUEVA FUNCIÓN: El láser llamará a esto cuando el jugador pierda
func recibir_danio():
	if invencible: return # Si el escudo está activo, ignoramos el daño
	esta_herido = true
	velocity = Vector2.ZERO # Detiene en seco cualquier impulso que traiga
	animated_sprite.play("hurt")
	
	SonidoElectrocutar.play()
	# El jugador ahora maneja su propio tiempo y cambio de escena
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")

func cambiar_traje():
	es_cian = !es_cian
	# 3. Actualizamos la referencia aquí también para que cambie el color del AnimatedSprite2D
	if es_cian:
		animated_sprite.modulate = Color(0, 1, 1) # Cian
	else:
		animated_sprite.modulate = Color(1, 0.5, 0) # Naranja
		
		
# <-- NUEVA FUNCIÓN: Controla el efecto visual del poder
func set_invencible(estado: bool):
	invencible = estado
	if invencible:
		# Hacemos que el sprite brille o se vea ligeramente transparente 
		# para que el jugador sepa que el poder está activo
		#animated_sprite.modulate.a = 0.5 
		pass
	else:
		# Cuando se apaga el poder, le devolvemos su visibilidad normal
		animated_sprite.modulate.a = 1.0
		# Llamamos a cambiar_traje para asegurarnos de que recupere su color (Cian o Naranja)
		es_cian = !es_cian 
		cambiar_traje()

func activar_moto():
	print("🏍️ ¡El jugador recibió la orden! Cambiando animación...")
	en_moto = true
	$AnimatedSprite2D.play("moto")
