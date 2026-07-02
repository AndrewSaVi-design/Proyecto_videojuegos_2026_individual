extends Node

var monedas: int = 0
var ruta_guardado = "user://datos_juego.dat"

func _ready():
	# Carga las monedas guardadas apenas se abre el juego
	cargar_datos()

func guardar_datos():
	# Abre (o crea) un archivo para escribir los datos
	var archivo = FileAccess.open(ruta_guardado, FileAccess.WRITE)
	if archivo:
		archivo.store_var(monedas)

func cargar_datos():
	# Verifica si el archivo existe antes de intentar leerlo
	if FileAccess.file_exists(ruta_guardado):
		var archivo = FileAccess.open(ruta_guardado, FileAccess.READ)
		if archivo:
			monedas = archivo.get_var()
