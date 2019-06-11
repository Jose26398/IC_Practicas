; PRACTICAS INGENIERIA DEL CONOCIMIENTO 2018/19
; AUTOR: José Maria Sánchez Guerrero


; ----------------------------------------------------------------------------------------- ;
; ---------------- 1.- Definición de los tiestos y estado de los sensores  ---------------- ;
; ----------------------------------------------------------------------------------------- ;



; Tiestos

(deffacts Tiestos
	(Tiesto cactus)
	(Tiesto verduras)
	(Tiesto flores)
)


; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Humedades
	(humedad cactus 900)
	(humedad verduras 600)
	(humedad flores 550)
)


; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts HumedadIdeal
	(hideal cactus 700 900) 
	(hideal verduras 400 600)
	(hideal flores 350 550)
)

; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Temperaturas
	(temperatura cactus 0)
	(temperatura verduras 0)
	(temperatura flores 0)
)

; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts TemperaturaLimite
	(tlimite cactus 100) 
	(tlimite verduras 50)
	(tlimite flores 40)
)

; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Luminosidades
	(luminosidad cactus 500)
	(luminosidad verduras 500)
	(luminosidad flores 500)
)


; (deffacts Vaporizador
; 	(vaporizador cactus off)
; 	(vaporizador verduras off)
; 	(vaporizador flores off)
; )


(defrule cargardatosasimular
=>
(load-facts DatosSimulados.txt) 
)



(defrule siguienteHora
	(declare(salience 9999))
	?var1 <- (Siguientehora)
	?var2 <- (datosensor ?x ?tipo ?planta ?valor)
	?var3 <- (datoactivo ?y)
	(test (= ?x (+ ?y 0)))
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
	(bind ?y (+ ?y 1))
	(assert (datoactivo ?y))
)

(defrule datosensor
	(declare (salience 9998))
	?f <-  (datosensor ?x ?tipo ?habitacion ?val)
	(datoactivo ?x)
	=>
	(assert (valor ?tipo ?habitacion ?val))
)


(defrule asignarTemperaturaVaporizador
	?var1 <- (Temperatura ?t)
	?var2 <- (temperatura ?planta ?valor)
	(tlimite ?planta ?limite)
	(test (> ?t ?limite))
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Temperatura de " ?planta " asignada al minimo gracias al vaporizador" crlf)
	(assert (temperatura ?planta ?limite))
)

(defrule asignarTemperatura
	?var1 <- (Temperatura ?t)
	?var2 <- (temperatura ?planta ?valor)
	(tlimite ?planta ?limite)
	(test (<= ?t ?limite))
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Temperatura de " ?planta " asignada a " ?t crlf)
	(assert (temperatura ?planta ?t))
)


(defrule regarPlanta
	?var <- (valor humedad ?planta ?valor)
	(humedad planta ?x)
	(hideal ?planta ?min ?max)
	=>
	(assert (regarPlanta ?planta ?x))
	(retract ?var)
)


(defrule humedadCritica
	(declare (salience -1))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(test (> ?val (+ ?max 100)))
	=>
	(retract ?var)
	(printout t "Se riega la planta " ?planta " por situacion critica" crlf)
)


(defrule posponerRiegoLuminosidad
	(declare (salience -2))
	?var <- (regarPlanta ?planta ?val)
	(luminosidad ?planta ?valor)
	(Luminosidad ?lux)
	(test (> ?lux ?valor))
	=>
	(retract ?var)
	(printout t "Se regara la planta " ?planta " mas tarde" crlf)
)


(defrule print
	(declare (salience -4))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(test(< 500 ?min))
	=>
	(retract ?var)
	(printout t "Se ha regado la planta " ?planta " hasta su humedad ideal " ?min crlf)
)



