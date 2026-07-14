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

var costo_partida = 3

func _ready():
	# Actualizamos los textos al cargar la escena
	actualizar_textos()

func actualizar_textos():
	# Muestra las monedas actuales y el costo
	label_monedas.text = "Tus Monedas: " + str(Global.monedas)
	label_costo.text = "Costo por giro: " + str(costo_partida)

func _on_girar_pressed():
	if Global.monedas >= costo_partida:
		Global.monedas -= costo_partida
		Global.guardar_datos()
		
		# Actualizamos el texto de monedas inmediatamente después de gastar
		actualizar_textos()
		
		# Animación y cambio de imágenes de los carretes
		for rect in carretes:
			rect.texture = iconos.pick_random()
		
		verificar_resultado()
	else:
		print("No tienes suficientes monedas para jugar")
		# Aquí podrías añadir una pequeña animación o mensaje en pantalla para avisar al jugador

func verificar_resultado():
	# Comprobamos si coinciden
	if carretes[0].texture == carretes[1].texture and carretes[1].texture == carretes[2].texture:
		if carretes[0].texture == iconos[1]: # Si coincide en el icono premio (ruleta.png)
			resultado_decision.emit("vida_extra")
			queue_free()

func _on_cancelar_pressed(): 
	# Enviamos la señal para ir a Game Over y cerramos la ruleta
	resultado_decision.emit("game_over")
	queue_free()
