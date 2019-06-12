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
	(temperatura cactus 25)
	(temperatura verduras 25)
	(temperatura flores 25)
)

; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts TemperaturaLimite
	(tlimite cactus 100) 
	(tlimite verduras 40)
	(tlimite flores 30)
)

; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Luminosidades
	(luminosidad cactus 800)
	(luminosidad verduras 800)
	(luminosidad flores 800)
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


; ------------------------------------------------------------------------------------------------- ;
(defrule siguienteHora
	(declare(salience 9999))
	?var1 <- (Siguientehora)
	?var2 <- (datosensor ?x ?tipo ?planta ?valor)
	?var3 <- (datoactivo ?y)
	(test (= ?x ?y))
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
	(bind ?y (+ ?y 1))
	(assert (datoactivo ?y))
)

(defrule datosensor
	(declare (salience 9998))
	?f <-  (datosensor ?x ?tipo ?planta ?val)
	(datoactivo ?x)
	=>
	(assert (valor ?tipo ?planta ?val))
)



; ------------------------------------------------------------------------------------------------- ;
(defrule asignarTemperatura
	?var1 <- (valor temperatura ?planta ?valor)
	?var2 <- (temperatura ?planta ?grados)
	(tlimite ?planta ?limite)
	(test (<= ?valor ?limite))
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Temperatura de " ?planta " asignada a " ?valor crlf)
	(assert (temperatura ?planta ?valor))
)

(defrule asignarTemperaturaVaporizador
	?var1 <- (valor temperatura ?planta ?valor)
	?var2 <- (temperatura ?planta ?grados)
	(tlimite ?planta ?limite)
	(test (> ?valor ?limite))
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Temperatura no soportada por " ?planta
				". El vaporizador la mantendra en su minimo " ?limite " hasta que baje" crlf)
	(assert (temperatura ?planta ?limite))
)



(defrule asignarLuminosidad
	?var1 <- (valor luminosidad ?planta ?valor)
	?var2 <- (luminosidad ?planta ?lux)
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Luminosidad de " ?planta " asignada a " ?valor crlf)
	(assert (luminosidad ?planta ?valor))
)




; ------------------------------------------------------------------------------------------------- ;
(defrule regarPlanta
	?var <- (valor humedad ?planta ?valor)
	(humedad ?planta ?x)
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


(defrule riegoIntenso
	(declare (salience -100))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (< 100 ?lux) (< 35 ?grados)) )
	=>
	(retract ?var)
	(printout t "Se ha regado mucho la planta " ?planta " hasta su humedad ideal " ?min " por la posible evaporacion del agua " crlf)
)

(defrule riegoNormal
	(declare (salience -100))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (or (< 100 ?lux) (< 35 ?grados)) )
	=>
	(retract ?var)
	(printout t "Se ha regado la planta de manera normal " ?planta " hasta su humedad ideal " ?min crlf)
)


(defrule riegoEscaso
	(declare (salience -100))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (>= 100 ?lux) (>= 35 ?grados)) )
	=>
	(retract ?var)
	(printout t "Se ha regado poco la planta " ?planta " hasta su humedad ideal " ?min " porque no se evaporara el agua" crlf)
)

