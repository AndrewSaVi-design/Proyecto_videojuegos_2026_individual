extends CharacterBody2D

var gravedad = 600
var potencia_propulsor = 2500 # Fuerza continua para el jetpack
var es_cian = false 

@onready var sprite = $Sprite2D

func _physics_process(delta):
	# 1. Gravedad constante (empuja hacia abajo)
	velocity.y += gravedad * delta
	
	# 2. Propulsor Suave (empuja hacia arriba)
	# Al restar aceleración por delta, logramos el vuelo fluido
	if Input.is_action_pressed("ui_select"):
		velocity.y -= potencia_propulsor * delta
	velocity.y = clamp(velocity.y, -300, 400)
	move_and_slide()
	
	# 3. Cambio de color (Restaurado a tu versión funcional)
	if Input.is_action_just_pressed("cambiar_color"):
		cambiar_traje()

func cambiar_traje():
	es_cian = !es_cian
	if es_cian:
		sprite.modulate = Color(0, 1, 1) # Cian
	else:
		sprite.modulate = Color(1, 0.5, 0) # Naranja

# --- DETECCIÓN DE COLISIÓN (REGLA DE ORO) ---
func _on_detector_peligro_area_entered(area: Area2D) -> void:
	if area.is_in_group("laser_cian"):
		if not es_cian: # Si vas de naranja, mueres
			morir()
		return # El return corta la función para que no mueras por error
	
	if area.is_in_group("laser_naranja"):
		if es_cian: # Si vas de cian, mueres
			morir()
		return
	
	# Si toca cualquier otra cosa (escombros)
	if area.is_in_group("peligro"):
		morir()

func morir():
	get_tree().reload_current_scene()
