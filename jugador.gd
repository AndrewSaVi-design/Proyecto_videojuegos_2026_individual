extends CharacterBody2D

signal jugador_murio # <--- CORRECCIÓN: Se crea la señal

var gravedad = 600
var potencia_propulsor = 2500 
var es_cian = false 
var esta_herido = false 
var en_moto = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var SonidoElectrocutar = $SonidoElectrocutar
@onready var sprite_moto = $SpriteMoto # Nodo hijo con la moto

var invencible = false 

func _physics_process(delta):
	if esta_herido:
		velocity.y += gravedad * delta
		velocity.y = clamp(velocity.y, -300, 400)
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	if Input.is_action_pressed("ui_select"):
		velocity.y -= potencia_propulsor * delta
		
	velocity.y = clamp(velocity.y, -300, 400)
	move_and_slide()
	
	# Lógica de Animaciones (Solo si NO estamos en moto)
	if not en_moto:
		if abs(velocity.y) == 400: 
			if invencible:
				animated_sprite.play("runInvencible")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("fly")
	
	if Input.is_action_just_pressed("cambiar_color"):
		cambiar_traje()
		
# Función activada específicamente por el obstáculo sólido
func cto_bloque():
	if invencible: return # Ignoramos el choque
	esta_herido = true  
	animated_sprite.play("hurtBlock") # Cambia a la animación de golpe por bloque
	
	# El juego continúa ejecutando las físicas de caída durante 1.5 segundos
	await get_tree().create_timer(1.5).timeout
	
	# <--- CORRECCIÓN: Emitimos la señal en vez de cambiar de escena
	jugador_murio.emit() 

# --- FUNCIONES DE MOTO (CON COLOR SINCRONIZADO) ---

func activar_moto():
	print("🏍️ ¡Transformación activada!")
	en_moto = true
	animated_sprite.hide() # Oculta al jugador normal
	sprite_moto.show()     # Muestra la moto
	sprite_moto.modulate = animated_sprite.modulate # Hereda el color actual

func perder_moto():
	print("💥 ¡Choque! Perdiste la moto.")
	en_moto = false
	sprite_moto.hide()     # Oculta la moto
	animated_sprite.show() # Muestra al jugador normal
	animated_sprite.modulate = sprite_moto.modulate # Recupera el color de la moto

# --- LÓGICA DE IMPACTOS ---

func recibir_impacto_bloque():
	if invencible: return 
	
	if en_moto:
		perder_moto()
	else:
		esta_herido = true
		animated_sprite.play("hurtBlock")
		await get_tree().create_timer(1.5).timeout
		jugador_murio.emit() # <--- CORRECCIÓN

func recibir_danio():
	if invencible: return 
	
	if en_moto:
		perder_moto()
	else:
		esta_herido = true
		velocity = Vector2.ZERO 
		animated_sprite.play("hurt")
		SonidoElectrocutar.play()
		await get_tree().create_timer(1.5).timeout
		jugador_murio.emit() # <--- CORRECCIÓN

# --- LÓGICA DE COLOR ---

func cambiar_traje():
	es_cian = !es_cian
	var color_nuevo = Color(0, 1, 1) if es_cian else Color(1, 0.5, 0)
	
	# Cambiamos ambos por si acaso, así siempre estarán sincronizados
	animated_sprite.modulate = color_nuevo
	if en_moto:
		sprite_moto.modulate = color_nuevo
		
func set_invencible(estado: bool):
	invencible = estado
	if invencible:
		pass
	else:
		animated_sprite.modulate.a = 1.0
		# Al terminar la invencibilidad, aseguramos el color correcto
		es_cian = !es_cian 
		cambiar_traje()

# <--- CORRECCIÓN: Función para revivir cuando ganas la lotería
func revivir():
	esta_herido = false
	invencible = true # Lo hacemos invencible un rato para que no vuelva a chocar al instante
	animated_sprite.play("fly")
	
	# Le quitamos la invencibilidad después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	set_invencible(false)
