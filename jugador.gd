extends CharacterBody2D

var gravedad = 600
var potencia_propulsor = 2500 
var es_cian = false 
var en_moto = false 
var invulnerable = false # NUEVO: Variable para evitar el doble choque
var esta_herido = false # <-- NUEVA VARIABLE: Controla si el jugador recibió un golpe

# 1. Cambiamos la referencia al nuevo nodo AnimatedSprite2D
@onready var animated_sprite = $AnimatedSprite2D

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
	if abs(velocity.y) == 400: 
		animated_sprite.play("run")
	else:
		animated_sprite.play("fly")
	
	# Cambio de color
	if Input.is_action_just_pressed("cambiar_color"):
		cambiar_traje()
		
# NUEVA FUNCIÓN: Activada específicamente por el obstáculo sólido
func recibir_impacto_bloque():
	esta_herido = true
	animated_sprite.play("hurtBlock") # Cambia a la animación de golpe por bloque
	
	# El juego continúa ejecutando las físicas de caída durante 1 segundo
	await get_tree().create_timer(1.5).timeout
	
	# Tras el segundo de caída y visualización del daño, cambia la escena
	get_tree().change_scene_to_file("res://game_over.tscn")

# <-- NUEVA FUNCIÓN: El láser llamará a esto cuando el jugador pierda
func recibir_danio():
	esta_herido = true
	velocity = Vector2.ZERO # Detiene en seco cualquier impulso que traiga
	animated_sprite.play("hurt")
	# El jugador ahora maneja su propio tiempo y cambio de escena
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")

func cambiar_traje():
	es_cian = !es_cian
	
	# Cambiamos el color de tu traje normal
	if es_cian:
		sprite.modulate = Color(0, 1, 1) # Cian
		# Si la moto existe, también le cambiamos el color
		if has_node("SpriteMoto"):
			$SpriteMoto.modulate = Color(0, 1, 1)
	else:
		sprite.modulate = Color(1, 0.5, 0) # Naranja
		# Si la moto existe, también le cambiamos el color
		if has_node("SpriteMoto"):
			$SpriteMoto.modulate = Color(1, 0.5, 0)

func activar_moto():
	print("¡Transformación a moto!")
	en_moto = true
	
	# Ocultamos al jugador normal y mostramos la moto
	$Sprite2D.visible = false
	$SpriteMoto.visible = true
	
	# Le aplicamos el color actual a la moto al recogerla
	if es_cian:
		$SpriteMoto.modulate = Color(0, 1, 1)
	else:
		$SpriteMoto.modulate = Color(1, 0.5, 0)
	
	# Aumentamos la potencia para que vuele más rápido
	potencia_propulsor = 3500

func recibir_dano():
	# 1. Si somos invulnerables, ignoramos el choque y salimos de la función
	if invulnerable == true:
		return
		
	# 2. Si tenemos la moto, se rompe pero nos salva
	if en_moto == true:
		print("¡La moto te salvó de la muerte!")
		en_moto = false 
		$SpriteMoto.visible = false 
		$Sprite2D.visible = true 
		potencia_propulsor = 2500 
		
		# --- TIEMPO DE GRACIA ---
		invulnerable = true
		# Esperamos 1 segundo exacto sin que los obstáculos nos hagan daño
		await get_tree().create_timer(1.0).timeout 
		invulnerable = false
		
	# 3. Si no tenemos moto ni invulnerabilidad, morimos de verdad
	else:
		print("¡Estás muerto!")
		get_tree().change_scene_to_file("res://game_over.tscn")
	# 3. Actualizamos la referencia aquí también para que cambie el color del AnimatedSprite2D
	if es_cian:
		animated_sprite.modulate = Color(0, 1, 1) # Cian
	else:
		animated_sprite.modulate = Color(1, 0.5, 0) # Naranja
