# Aero-Rush:

Un videojuego del género *Endless Runner* en dos dimensiones desarrollado en el motor **Godot Engine 4**. El proyecto implementa una arquitectura modular orientada a componentes (Nodos y Escenas), priorizando el desacoplamiento de código, la gestión dinámica de memoria y un sistema de dificultad progresiva escalable.

## Características Clave e Implementación Lógica

* **Arquitectura Modular:** Separación estricta de responsabilidades entre los subsistemas de Interfaz (HUD), Fondo (`Parallax2D`), Entidades Dinámicas (Obstáculos/Lasers/Monedas) y Físicas del Jugador.
* **Sistema de Dualidad y Polaridad:** Implementación de mecánicas de cambio de traje (Cian y Naranja) asociadas a una validación lógica ante láseres de color coincidente, mitigando o aplicando penalizaciones por "Sobrecarga".
* **Dificultad Progresiva Basada en Software:** Escalado físico de la velocidad de traslación global de los obstáculos en tiempo real en la función `_process(delta)`, segmentado en tres fases críticas (0-50 km, 50 km y 200+ km).
* **Obstáculos con Transformación Angular:** Inclusión de barreras de plasma rectangulares con rotación angular aleatoria (`rotation_degrees`) calculada simétricamente sobre su eje central `(0,0)`.

---

## Estructura del Árbol de Escenas (Jerarquía de Nodos)

El diseño del espacio de trabajo en Godot sigue un patrón de composición jerárquico desacoplado:

* **`Node2D` (Mundo):** Nodo controlador raíz que administra el estado global del juego y centraliza el servicio de spawning.
* **`Interfaz` (`CanvasLayer`):** Capa de renderizado aislada para el HUD que fija en pantalla los componentes `TextoDistancia` y `TextoMonedas`.
* **`Parallax2D`:** Controlador de desplazamiento infinito para la simulación de velocidad del entorno mediante el reciclaje cíclico de texturas.
* **`Jugador` (`CharacterBody2D`):** Maneja los vectores de velocidad, gravedad y el impulso vertical del Jetpack.
    * **`DetectorPeligro` (`Area2D`):** Sensor dedicado de forma exclusiva a la captura de señales de colisión (`body_entered`) con amenazas, previniendo conflictos mecánicos con el suelo.
* **`Suelo` / `Techo` (`StaticBody2D`):** Delimitadores estáticos que confinan al personaje al área visible de juego.
* **`GeneradorObstaculos` (`Timer`):** Temporizador encargado de disparar los eventos aleatorios utilizando una ruleta pseudoaleatoria (`randi() % 14`).

---

## Métricas de Rendimiento y Optimización (Profiling)

El software ha sido auditado mediante el Monitorizador nativo de Godot Engine para garantizar una ejecución eficiente en hardware:

* **Tasa de Refresco:** 60 FPS estables (Sincronización vertical y fluidez visual continua).
* **Tiempo de Ciclo (Frame Time):** 24.49 ms de procesamiento CPU/GPU por cuadro.
* **Uso de Memoria Estática (RAM):** 61.62 MiB.
* **Memoria de Video (VRAM):** 68.31 MiB.
