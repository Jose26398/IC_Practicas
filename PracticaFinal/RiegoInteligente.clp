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
	(humedad cactus 700)
	(humedad verduras 400)
	(humedad flores 350)
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
	(luminosidad cactus 500)
	(luminosidad verduras 500)
	(luminosidad flores 500)
)

; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Riego
	(riego cactus off)
	(riego verduras off)
	(riego flores off)
)

; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Vaporizador
	(vaporizador cactus off)
	(vaporizador verduras off)
	(vaporizador flores off)
)



; ------------------------------------------------------------------------------------------------- ;

(defrule cargardatosasimular
=>
(load-facts DatosSimulados.txt) 
)


(defrule siguienteOrden
	(declare(salience 9999))
	?var1 <- (siguienteOrden)
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

(defrule datosensorManual
	(declare (salience 9998))
	?f <-  (datosensor ?tipo ?planta ?val)
	=>
	(retract ?f)
	(assert (valor ?tipo ?planta ?val))
)

(defrule borrarSensores
	?var <- (datosensor ?x ?tipo ?planta ?valor)
	(datoactivo ?y)
	(test (< ?x ?y))
	=>
	(retract ?var)
)



; ------------------------------------------------------------------------------------------------- ;
(defrule asignarHumedad
	?var1 <- (valor humedad ?planta ?valor)
	?var2 <- (humedad ?planta ?lux)
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Humedad de " ?planta " asignada a " ?valor crlf)
	(assert (humedad ?planta ?valor))
)

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

(defrule encenderVaporizador
	(declare (salience 1))
	?var1 <- (valor temperatura ?planta ?valor)
	?var2 <- (temperatura ?planta ?grados)
	?var3 <- (vaporizador ?planta off)
	(tlimite ?planta ?limite)
	(test (> ?valor ?limite))
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
	(printout t "Temperatura no soportada por " ?planta ". " crlf
				"Se activa el vaporizador que la mantendra en su minimo " ?limite "." crlf)
	(assert (temperatura ?planta ?limite))
	(assert (vaporizador ?planta on))
)


(defrule apagarVaporizador
	(declare (salience 1))
	?var1 <- (valor temperatura ?planta ?valor)
	?var2 <- (temperatura ?planta ?grados)
	?var3 <- (vaporizador ?planta on)
	(tlimite ?planta ?limite)
	(test (<= ?valor ?limite))
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
	(printout t "La temperatura para la planta " ?planta " ha bajado lo suficiente. " crlf
				"El vaporizador deja de funcionar." crlf)
	(assert (temperatura ?planta ?limite))
	(assert (vaporizador ?planta off))
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
	(humedad ?planta ?x)
	(hideal ?planta ?min ?max)
	(test (<= ?max ?x))
	=>
	(assert (regarPlanta ?planta ?x))
)


(defrule activarRiego
	(activarRiego ?planta)
	?var <- (riego ?planta off)
	=>
	(retract ?var)
	(assert (riego ?planta on))
)


(defrule desactivarRiego
	(declare (salience 1))
	?var1 <- (valor humedad ?planta ?valor)
	?var2 <- (activarRiego ?planta)
	?var3 <- (riego ?planta on)
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
	(printout t "Humedad deseada alcanzada. Se descativa el riego de " ?planta crlf)
	(assert (riego ?planta off))
)



; ------------------------------------------------------------------------------------------------- ;

(defrule humedadCritica
	(declare (salience -1))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(test (> ?val (+ ?max 100)))
	=>
	(retract ?var)
	(assert (regadoCritico ?planta ?val))
)


(defrule posponerRiegoLuminosidad
	(declare (salience -12))
	?var <- (regarPlanta ?planta ?val)
	(luminosidad ?planta ?valor)
	(test (< 600 ?valor))  ; valor > 600
	=>
	(retract ?var)
	(assert (regarDespues ?planta))
	(printout t "Se regara la planta " ?planta " de noche (cuando la luminosidad baje)" crlf)
)


(defrule riegoNocturno
	(declare (salience -14))
	?var <- (regarDespues ?planta)
	(luminosidad ?planta ?valor)
	(test (< ?valor 600))
	(humedad ?planta ?x)
	(hideal ?planta ?min ?max)
	=>
	(retract ?var)
	(assert (regarPlanta ?planta ?x))
)


(defrule riegoCriticoIntenso
	(declare (salience -50))
	(vaporizador ?planta off)
	?var <- (regadoCritico ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (< 600 ?lux) (< 35 ?grados)) ) ; Lux > 600 y grados > 35
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa un riego intenso para la planta " ?planta " por la posible evaporacion del agua " crlf)
	(assert (activarRiego ?planta))
)

(defrule riegoCriticoNormal
	(declare (salience -50))
	(vaporizador ?planta off)
	?var <- (regadoCritico ?planta ?val)
	(hideal ?planta ?min ?max)
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa el riego para la planta " ?planta crlf)
	(assert (activarRiego ?planta))
)


(defrule riegoCriticoIntensoVaporizador
	(declare (salience -50))
	(vaporizador ?planta on)
	?var <- (regadoCritico ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (< 600 ?lux) (< 35 ?grados)) ) ; Lux > 600 y grados > 35
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa un riego intenso para la planta " ?planta " por la posible evaporacion del agua. " crlf
				"El riego esta combinado con vaporizadores debido a las altas temperaturas." crlf)
	(assert (activarRiego ?planta))
)

(defrule riegoCriticoNormalVaporizador
	(declare (salience -50))
	(vaporizador ?planta on)
	?var <- (regadoCritico ?planta ?val)
	(hideal ?planta ?min ?max)
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa el riego para la planta " ?planta ". " crlf
				"El riego esta combinado con vaporizadores debido a las altas temperaturas." crlf)
	(assert (activarRiego ?planta))
)


(defrule riegoNormal
	(declare (salience -100))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (or (< 400 ?lux) (< 20 ?grados)) ) ; Lux > 400 o grados > 20
	=>
	(retract ?var)
	(printout t "Se activa el riego para la planta " ?planta crlf)
	(assert (activarRiego ?planta))
)


(defrule riegoEscaso
	(declare (salience -100))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (>= 400 ?lux) (>= 20 ?grados)) ) ; Lux < 400 y grados < 20
	=>
	(retract ?var)
	(printout t "Se activa un riego ligero para la planta " ?planta " porque no se evaporara el agua." crlf)
	(assert (activarRiego ?planta))
)



; (defrule comprobarLluviaLigera
; 	(declare (salience -70))
; 	(Lluvia prediccion ?intensidad)
; 	(humedad ?planta ?h)
; 	(hideal ?planta ?min ?max)
; 	(test (< ?intensidad 6.5) )
; 	(test (and (> ?h ?min) (< ?h ?max)))
; 	=>
; 	(retract ?var)
; 	(printout t "No se activara el riego para " ?planta " porque se prevee poca lluvia." crlf)
; )

; (defrule comprobarLluviaModerada
; 	(declare (salience -70))
; 	(Lluvia prediccion ?intensidad)
; 	(humedad ?planta ?h)
; 	(hideal ?planta ?min ?max)
; 	(test (and (>= ?intensidad 6.5) (< ?intensidad 15)) )
; 	(test (and (>= ?h ?min) (< ?h ?max)))
; 	=>
; 	(retract ?var)
; 	(printout t "Se ha cumplido le prevision de lluvia, por lo que no hace falta regar " ?planta "." crlf)
; )



(defrule riegoNormalPorLluviaLigera
	(declare (salience -70))
	(humedad ?planta ?h)
	(hideal ?planta ?min ?max)
	(Lluvia prediccion ?intensidad)
	(test (< ?intensidad 6.5))
	=>
	(printout t "Se prepara un riego normal (si lo necesita) para la planta " ?planta " porque se prevee una lluvia ligera." crlf)
	(assert (riegoNormal))
)


(defrule riegoEscasoPorLluviaModerada
	(declare (salience -70))
	(Tiesto ?planta)
	(Lluvia prediccion ?intensidad)
	(test (and (>= ?intensidad 6.5) (< ?intensidad 15)) )
	=>
	(printout t "Se prepara un riego escaso (si lo necesita) para la planta " ?planta " porque se prevee una lluvia moderada." crlf)
	(assert (riegoEscaso))
)


(defrule riegoNuloPorLluviaTorrencial
	(declare (salience -70))
	(Tiesto ?planta)
	?var2 <- (Lluvia prediccion ?intensidad)
	(test (>= ?intensidad 15) )
	=>
	(printout t "No se regara la planta " ?planta " porque se prevee una lluvia intensa." crlf)
	(assert (riegoNulo))
)




(defrule comprobacionLluviaEnRango
	(declare (salience -7))
	?var1 <- (regarPlanta ?planta ?val)
	(riegoNormal)
	(Lluvia prediccion ?intensidad)
	=>
	(retract ?var1)
	(printout t "La planta " ?planta " tiene un valor alto de humedad (necesita ser regada). " crlf
				"Como se prevee una lluvia de intensidad " ?intensidad ", se regará de forma normal." crlf)
	(assert (activarRiego ?planta))
)


(defrule comprobacionLluviaInferior
	(declare (salience -7))
	?var1 <- (regarPlanta ?planta ?val)
	(riegoEscaso)
	(Lluvia prediccion ?intensidad)
	=>
	(retract ?var1)
	(printout t "La planta " ?planta " tiene un valor alto de humedad (necesita ser regada). " crlf
				"Como se prevee una lluvia de intensidad " ?intensidad ", se regara de forma ligera." crlf)
	(assert (activarRiego ?planta))
)


(defrule comprobacionLluviaSuperior
	(declare (salience -7))
	?var1 <- (regarPlanta ?planta ?val)
	(riegoNulo)
	(Lluvia prediccion ?intensidad)
	=>
	(retract ?var1)
	(printout t "La planta " ?planta " tiene un valor alto de humedad (necesita ser regada). " crlf
				"Como se prevee una lluvia de intensidad " ?intensidad ", no se va a ragar." crlf)
)


(defrule borrarRiegoEscaso
	?var1 <- (Lluvia prediccion ?intensidad)
	?var2 <- (Lluvia prediccion 0)
	?var3 <- (riegoEscaso)
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
)

(defrule borrarRiegoNormal
	?var1 <- (Lluvia prediccion ?intensidad)
	?var2 <- (Lluvia prediccion 0)
	?var3 <- (riegoNormal)
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
)

(defrule borrarRiegoEscaso
	?var1 <- (Lluvia prediccion ?intensidad)
	?var2 <- (Lluvia prediccion 0)
	?var3 <- (riegoNulo)
	=>
	(retract ?var1)
	(retract ?var2)
	(retract ?var3)
)