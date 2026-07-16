extends Control

signal resultado_decision(decision)

# Asegúrate de que las rutas de abajo sean exactamente tus imágenes de la ruleta
var iconos = [
	preload("res://sigue_intentando.jpg"), 
	preload("res://ruleta.png") 
]

@onready var carretes = [
	$HBoxContainer/Carrete1/TextureRect, 
	$HBoxContainer/Carrete2/TextureRect, 
	$HBoxContainer/Carrete3/TextureRect
]

# Referencias a las etiquetas
@onready var label_monedas = $LabelMonedas
@onready var label_costo = $LabelCosto

var costo_partida = 1

# --- NUEVO CANDADO DE SEGURIDAD ---
var bloqueado = false 

func _ready():
	actualizar_textos()

func actualizar_textos():
	label_monedas.text = "Tus Monedas: " + str(Global.monedas)
	label_costo.text = "Costo por giro: " + str(costo_partida)

func _on_girar_pressed():
	# Si ya ganamos o la máquina está bloqueada, ignoramos los clics
	if bloqueado: 
		return
		
	if Global.monedas >= costo_partida:
		Global.monedas -= costo_partida
		Global.guardar_datos()
		
		actualizar_textos()
		
		for rect in carretes:
			rect.texture = iconos.pick_random()
		
		verificar_resultado()
	else:
		print("No tienes suficientes monedas para jugar")

func verificar_resultado():
	if carretes[0].texture == carretes[1].texture and carretes[1].texture == carretes[2].texture:
		if carretes[0].texture == iconos[1]: 
			
			# --- LA CLAVE ESTÁ AQUÍ ---
			bloqueado = true # Bloqueamos para que el jugador no pueda tocar nada más
			resultado_decision.emit("vida_extra")
			
			# ELIMINADO EL queue_free() AQUÍ. 
			# Ahora dejamos que Mundo.gd borre la máquina después de los 2.5 segundos.

func _on_cancelar_pressed(): 
	# Si la máquina está bloqueada celebrando tu victoria, no puedes cancelar
	if bloqueado:
		return
		
	resultado_decision.emit("game_over")
	queue_free()
