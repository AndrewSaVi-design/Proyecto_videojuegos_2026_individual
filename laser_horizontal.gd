extends Area2D

# Tiempos ajustados: 2.5 segundos de aviso (2 segundos más que antes)
const TIEMPO_AVISO = 2.5
const TIEMPO_DISPARO = 1.5

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

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DetectorPeligro":
		print("¡GAME OVER - Michael electrocutado!")
		get_tree().reload_current_scene()

func crear_parpadeo(tiempo):
	var tween = get_tree().create_tween()
	tween.set_loops(int(tiempo * 10))
	tween.tween_property(sprite, "modulate:a", 0.1, 0.05)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.05)
