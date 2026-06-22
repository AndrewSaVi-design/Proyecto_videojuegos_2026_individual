extends Area2D

# Tiempos ajustados: 2.5 segundos de aviso (2 segundos más que antes)
const TIEMPO_AVISO = 2.5
const TIEMPO_DISPARO = 1.5

var ya_choco = false # <-- Evita que el impacto se registre varias veces por segundo

@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

func _ready():
	# Aviso (transparente e inofensivo)
	sprite.modulate.a = 0.3
	shape.set_deferred("disabled", true) 
	
	crear_parpadeo(TIEMPO_AVISO)
	
	await get_tree().create_timer(TIEMPO_AVISO).timeout
	
	# Activación (sólido y letal)
	sprite.modulate.a = 1.0
	shape.set_deferred("disabled", false)
	
	await get_tree().create_timer(TIEMPO_DISPARO).timeout
	
	# Desaparece
	queue_free()

func crear_parpadeo(tiempo):
	var tween = get_tree().create_tween()
	tween.set_loops(int(tiempo * 10))
	tween.tween_property(sprite, "modulate:a", 0.1, 0.05)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.05)


# --- NUEVA LÓGICA DE COLISIÓN ---

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro" or area.is_in_group("Player"):
		verificar_impacto(area.get_parent())

# Añadí también esta función por seguridad, para mantenerlo idéntico a tus otros scripts
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("Player"):
		verificar_impacto(body)

func verificar_impacto(jugador):
	if ya_choco:
		return
		
	ya_choco = true
	print("¡GAME OVER - Michael electrocutado!")
	
	# En lugar de cambiar de escena, llamamos a la función de tu jugador
	# Esta función ya tiene programada la animación "hurt" y la espera de 1 segundo
	if jugador.has_method("recibir_danio"):
		jugador.recibir_danio()
