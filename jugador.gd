extends CharacterBody2D

var gravedad = 600
var potencia_propulsor = 2500 # Fuerza continua para el jetpack
var es_cian = false 

@onready var sprite = $Sprite2D

func _physics_process(delta):
	# 1. Gravedad constante (empuja hacia abajo)
	velocity.y += gravedad * delta
	
	# 2. Propulsor Suave (empuja hacia arriba)
	if Input.is_action_pressed("ui_select"):
		velocity.y -= potencia_propulsor * delta
	velocity.y = clamp(velocity.y, -300, 400)
	move_and_slide()
	
	# 3. Cambio de color
	if Input.is_action_just_pressed("cambiar_color"):
		cambiar_traje()

func cambiar_traje():
	es_cian = !es_cian
	if es_cian:
		sprite.modulate = Color(0, 1, 1) # Cian
	else:
		sprite.modulate = Color(1, 0.5, 0) # Naranja
