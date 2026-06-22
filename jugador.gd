extends CharacterBody2D

var gravedad = 600
var potencia_propulsor = 2500 
var es_cian = false 
var en_moto = false 
var invulnerable = false # Evita el doble choque
var esta_herido = false # Controla si el jugador recibió un golpe

# Referencia al nuevo nodo de animaciones
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Si el personaje está herido, no hace nada más que caer
	if esta_herido:
		velocity.y += gravedad * delta
		velocity.y = clamp(velocity.y, -300, 400)
		move_and_slide()
		return
		
	# Gravedad constante
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	# Propulsor
	if Input.is_action_pressed("ui_select"):
		velocity.y -= potencia_propulsor * delta
		
	velocity.y = clamp(velocity.y, -300, 400)
	move_and_slide()
	
	# Lógica de Animaciones
	if abs(velocity.y) == 400: 
		animated_sprite.play("run")
	else:
		animated_sprite.play("fly")
	
	# Cambio de color
	if Input.is_action_just_pressed("cambiar_color"):
		cambiar_traje()

# Función de tu amigo: Activada por obstáculo sólido
func recibir_impacto_bloque():
	if invulnerable or esta_herido: return 
	
	esta_herido = true
	animated_sprite.play("hurtBlock")
	
	await get_tree().create_timer(1.5).timeout
	
	# Verificamos que el jugador sigue en escena para cambiar de nivel
	if is_inside_tree():
		get_tree().change_scene_to_file("res://game_over.tscn")

# Función de tu amigo: El láser llama a esto
func recibir_danio():
	if invulnerable or esta_herido: return 
	
	esta_herido = true
	velocity = Vector2.ZERO 
	animated_sprite.play("hurt")
	
	await get_tree().create_timer(1.5).timeout
	
	if is_inside_tree():
		get_tree().change_scene_to_file("res://game_over.tscn")

func cambiar_traje():
	es_cian = !es_cian
	
	if es_cian:
		animated_sprite.modulate = Color(0, 1, 1) # Cian
		if has_node("SpriteMoto"):
			$SpriteMoto.modulate = Color(0, 1, 1)
	else:
		animated_sprite.modulate = Color(1, 0.5, 0) # Naranja
		if has_node("SpriteMoto"):
			$SpriteMoto.modulate = Color(1, 0.5, 0)

func activar_moto():
	print("¡Transformación a moto!")
	en_moto = true
	
	# Ocultamos al jugador normal y mostramos la moto
	$AnimatedSprite2D.visible = false
	$SpriteMoto.visible = true
	
	# Colores para la moto
	if es_cian:
		$SpriteMoto.modulate = Color(0, 1, 1)
	else:
		$SpriteMoto.modulate = Color(1, 0.5, 0)
	
	potencia_propulsor = 3500

func recibir_dano():
	# Si somos invulnerables o ya estamos muriendo, ignoramos
	if invulnerable or esta_herido:
		return
		
	# Si tenemos la moto, se rompe pero nos salva
	if en_moto == true:
		print("¡La moto te salvó de la muerte!")
		en_moto = false 
		$SpriteMoto.visible = false 
		$AnimatedSprite2D.visible = true 
		potencia_propulsor = 2500 
		
		# --- TIEMPO DE GRACIA ---
		invulnerable = true
		await get_tree().create_timer(1.0).timeout 
		invulnerable = false
		
	# Si no tenemos moto, llamamos a la muerte animada
	else:
		print("¡Estás muerto!")
		recibir_danio()
