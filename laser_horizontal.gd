extends Area2D

func _ready():
	# --- 1. AVISO (El láser aparece clarito) ---
	modulate.a = 0.3  # Muy transparente
	
	# Espera medio segundo parpadeando (puedes ajustar el tiempo)
	await get_tree().create_timer(0.5).timeout
	
	# --- 2. ACTIVACIÓN (El láser se pone sólido y peligroso) ---
	modulate.a = 1.0  # Opaco (rojo fuerte)
	
	# Se queda encendido 1.5 segundos para intentar matar al jugador
	await get_tree().create_timer(1.5).timeout
	
	# --- 3. DESAPARECER ---
	queue_free()

func _process(_delta):
	# Dejamos esto vacío. Al no tener "position.x -=", el láser NO se moverá.
	pass
