; PRACTICA FINAL INGENIERIA DEL CONOCIMIENTO 2018/19
; AUTOR: José Maria Sánchez Guerrero


; ----------------------------------------------------------------------------------------- ;
; ------------------ Definición de los tiestos y estado de los sensores  ------------------ ;
; ----------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Tiestos y plantas

(deffacts Tiestos
	(Tiesto cactus)
	(Tiesto verduras)
	(Tiesto flores)
)


; ------------------------------------------------------------------------------------------------- ;
; Inicialización de la humedad de cada tiesto (húmedos por defecto)

(deffacts Humedades
	(humedad cactus 700)
	(humedad verduras 400)
	(humedad flores 350)
)


; ------------------------------------------------------------------------------------------------- ;
; Conocimiento de la humedad ideal de cada planta, siendo 0 muy húmedo y 1023 muy seco,
; proporcionado por el profesor en el guión de prácticas

(deffacts HumedadIdeal
	(hideal cactus 700 900) 
	(hideal verduras 400 600)
	(hideal flores 350 550)
)


; ------------------------------------------------------------------------------------------------- ;
; Inicialización de las temperaturas de cada tiesto (25 grados por defecto)

(deffacts Temperaturas
	(temperatura cactus 25)
	(temperatura verduras 25)
	(temperatura flores 25)
)


; ------------------------------------------------------------------------------------------------- ;
; Conocimiento de la temperatura límite de cada planta.
; Como no se proporciona, he considerado los siguientes valores

(deffacts TemperaturaLimite
	(tlimite cactus 100) 
	(tlimite verduras 40)
	(tlimite flores 30)
)


; ------------------------------------------------------------------------------------------------- ;
; Inicialización de las luminosidades de cada tiesto, siendo 0 de noche y 1000 de día
; (por defecto a 500 lux).

(deffacts Luminosidades
	(luminosidad cactus 500)
	(luminosidad verduras 500)
	(luminosidad flores 500)
)


; ------------------------------------------------------------------------------------------------- ;
; Inicialización del estado de los riegos de cada tiesto (apagados por defecto)

(deffacts Riego
	(riego cactus off)
	(riego verduras off)
	(riego flores off)
)


; ------------------------------------------------------------------------------------------------- ;
; Inicialización del estado de los vaporizadores de cada tiesto (apagados por defecto)

(deffacts Vaporizador
	(vaporizador cactus off)
	(vaporizador verduras off)
	(vaporizador flores off)
)




; ----------------------------------------------------------------------------------------- ;
; ----------------------------------- Simulador propio  ----------------------------------- ;
; ----------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Función para cargar los DatosSimulados proporcionados, con unas órdenes que simulan todas
; o casi todas las situaciones que nos podemos encontrar

(defrule cargardatosasimular
	=>
	(load-facts DatosSimulados.txt) 
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Pasa al siguiente o los siguientes datosensores de la lista por orden numérico.
; Tiene una prioridad tan alta ya que tiene que ser lo primero en ejecutar

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
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Transforma el dato del sensor en un valor que podemos manejar. También tiene una
; prioridad muy alta, pero tiene que ejecutarse justo después de 'siguienteOrden'
; para no confundir los datos de los sensores

(defrule datosensor
	(declare (salience 9998))
	(datosensor ?x ?tipo ?planta ?val)
	(datoactivo ?x)
	=>
	(assert (valor ?tipo ?planta ?val))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Borra los datos recibidos de los sensores anteriores

(defrule borrarSensores
	(declare (salience 9997))
	?var <- (datosensor ?x ?tipo ?planta ?valor)
	(datoactivo ?y)
	(test (< ?x ?y))
	=>
	(retract ?var)
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Esta regla sirve para introducir los datos de los sensores manualmente, es decir,
; sin listarlos por orden numérico. También tiene que tener una prioridad alta y
; borra los datos automáticamente tras transformarlos en valor

(defrule datosensorManual
	(declare (salience 9998))
	?f <- (datosensor ?tipo ?planta ?val)
	=>
	(retract ?f)
	(assert (valor ?tipo ?planta ?val))
)
; ------------------------------------------------------------------------------------------------- ;





; ----------------------------------------------------------------------------------------- ;
; -------------------------- Registro de los datos de los sensores ------------------------ ;
; ----------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Registramos las humedades recibidas por los sensores de cada planta y con un valor determinado.
; También borraremos los datos ya recibidos y los previamente registrados.
; Imprimiremos un mensaje que muestre por pantalla esta asignación

(defrule asignarHumedad
	?var1 <- (valor humedad ?planta ?valor)
	?var2 <- (humedad ?planta ?lux)
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Humedad de " ?planta " asignada a " ?valor crlf)
	(assert (humedad ?planta ?valor))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Registramos las temperaturas recibidas por los sensores de cada planta y con un valor determinado.
; También borraremos los datos ya recibidos y los previamente registrados. Si la temperatura supera
; el límite recomendado para esa planta, no se ejecutará la orden (se ejecutarán las ordenes siguientes
; que encienden el vaporizador). Imprimiremos un mensaje que muestre por pantalla esta asignación

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
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Registramos las luminosidades recibidas por los sensores de cada planta y con un valor determinado.
; También borraremos los datos ya recibidos y los previamente registrados.
; Imprimiremos un mensaje que muestre por pantalla esta asignación

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


; ------------------------------------------------------------------------------------------------- ;
; Registramos la lluvia prevista recibida por el sensor de meteorología y la intensidad de esta.
; Esta regla servirá para cuando la intensidad de esta lluvia sea 0. Para cuando no lo sea
; tendremos unas reglas personalizadas para cada caso al final del código.
; Imprimiremos un mensaje que muestre por pantalla esta asignación 

(defrule asignarLLuvia
	?var1 <- (valor lluvia prediccion ?intensidad & ~0)
	?var2 <- (valor lluvia prediccion 0)
	=> 
	(retract ?var1)
	(retract ?var2)
	(printout t "Ya no hay prevision de lluvia para las proximas horas. " crlf)
	(assert (borrarRiegosPrevistos))
)
; ------------------------------------------------------------------------------------------------- ;





; ----------------------------------------------------------------------------------------- ;
; -------------------- Activación y desactivación del riego automático  ------------------- ;
; ----------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Esta regla será la que de pie a las dos siguientes, es decir, si llega una valor adecuado para
; proceder al riego de la planta, se ejecutará esta orden, pero todavia no podremos activarlo.
; Para ello tendremos que aplicar nuestro conocimiento y decidir si lo encendemos o no.

(defrule regarPlanta
	(humedad ?planta ?x)
	(hideal ?planta ?min ?max)
	(test (<= ?max ?x))
	=>
	(assert (regarPlanta ?planta ?x))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Activa el riego de un determinado cultivo si así lo ha considerado el sistema. Si el riego ya
; estaba activado, lo dejerá como está (aunque no debería de darse esta situación).
; No se cambia la humedad de la planta ya que no se puede. El dato de humedad lo proporciona
; el sensor de dicha planta, no nosotros.

(defrule activarRiego
	(activarRiego ?planta)
	?var <- (riego ?planta off)
	=>
	(retract ?var)
	(assert (riego ?planta on))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Regla igual que la anterior 'activarRiego' pero que elimina de la base de hechos el riego pospuesto,
; debido obviamente a que se está regando por situación crítica.

(defrule activarRiegoCritico
	(declare (salience 1))
	(activarRiego ?planta)
	?var1 <- (riego ?planta off)
	?var2 <- (regarDespues ?planta)
	=>
	(retract ?var1)
	(retract ?var2)
	(assert (riego ?planta on))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Desactiva el riego de un determinado cultivo cuando ha llegado a la humedad deseada. Si el riego
; estaba desactivado, lo dejerá como está (aunque no debería de darse esta situación).
; Como hemos dicho antes, la humedad no la cambiamos nosotros, asi que tiene que llegarnos una señal
; del sensor con la humedad ideal para que se desactive (no se hará manualmente).
; Imprimiremos un mensaje que muestre por pantalla el proceso.

(defrule desactivarRiego
	(declare (salience 1))
	(valor humedad ?planta ?valor)
	(hideal ?planta ?min ?max)
	?var1 <- (activarRiego ?planta)
	?var2 <- (riego ?planta on)
	(test (>= ?min ?valor))
	=>
	(retract ?var1)
	(retract ?var2)
	(printout t "Humedad deseada alcanzada. Se desactiva el riego de " ?planta "." crlf)
	(assert (riego ?planta off))
)
; ------------------------------------------------------------------------------------------------- ;





; ----------------------------------------------------------------------------------------- ;
; ------------------------------------ Riego inteligente ---------------------------------- ;
; ----------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Si el valor que nos llega ha sido mayor que el valor de húmedad crítico de esa planta (al cual le
; he dado un valor del máximo mas 100) realizará un regado crítico. Todavía no se activa el riego
; porque tiene que comprobar si se hace un regado normal o intenso.
; Se le pone una prioridad alta, ya que la humedad crítica es lo más importante del riego.

(defrule humedadCritica
	(declare (salience 3))
	?var <- (regarPlanta ?planta ?val)
	(hideal ?planta ?min ?max)
	(test (> ?val (+ ?max 100)))
	=>
	(retract ?var)
	(assert (regadoCritico ?planta ?val))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Si el valor que nos llega no es crítico pero ya se sale del límite de humedad ideal, comprobamos
; la luminosidad. Si esta es mayor de 600 lux (no es por la noche) posponemos este riego.
; Si la situación es crítica, se ejecutará antes la regla anteerior, ya que tiene más prioridad.
; Imprimiremos un mensaje que muestre por pantalla el proceso.

(defrule posponerRiegoLuminosidad
	(declare (salience -2))
	?var <- (regarPlanta ?planta ?val)
	(luminosidad ?planta ?valor)
	(test (< 600 ?valor))  ; valor > 600
	=>
	(retract ?var)
	(assert (regarDespues ?planta))
	(printout t "Se regara la planta " ?planta " de noche (cuando la luminosidad baje)" crlf)
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Si el valor que nos llega no es crítico pero ya se sale del límite de humedad ideal, comprobamos
; la luminosidad. Si esta es mayor de 600 lux (no es por la noche) posponemos este riego.
; Si la situación es crítica, se ejecutará antes la regla anteerior, ya que tiene más prioridad.
; Imprimiremos un mensaje que muestre por pantalla el proceso.

(defrule riegoNocturno
	(declare (salience -3))
	?var <- (regarDespues ?planta)
	(luminosidad ?planta ?valor)
	(test (< ?valor 600))
	(humedad ?planta ?x)
	(hideal ?planta ?min ?max)
	=>
	(retract ?var)
	(assert (regarPlanta ?planta ?x))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Regla posterior a 'humedadCrítica'. En esta se comprueba si la luminosidad es mayor de 600 lux y
; la temperatura es mayor de 35 grados. En caso afirmativo se activará un riego intenso por la posible
; evaporación del agua.
; Imprimiremos un mensaje que muestre por pantalla que el riego está activado.

(defrule riegoCriticoIntenso
	(declare (salience -4))
	(vaporizador ?planta off)
	?var <- (regadoCritico ?planta ?val)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (< 600 ?lux) (< 35 ?grados)) ) ; Lux > 600 y grados > 35
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa un riego intenso para la planta " ?planta " por la posible evaporacion del agua " crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Esta regla es la opuesta a la anterior 'riegoCriticoIntenso'. Si no se cumplen esos valores, se
; ejecutará esta que tiene una prioridad un poco más baja. Realizará un riego normal, ya que no se
; evaporará excesiva agua.
; Imprimiremos un mensaje que muestre por pantalla que el riego está activado.

(defrule riegoCriticoNormal
	(declare (salience -5))
	(vaporizador ?planta off)
	?var <- (regadoCritico ?planta ?val)
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa el riego para la planta " ?planta crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Esta regla comprueba si, o bien la luminosidad es mayor de 400 lux, o bien la temperatura es superior
; a 20 grados, ya que he considerado que cualquiera de las dos podría causar algo de evaporación de agua.
; Se ejecutará después de comprobar todas las posibilidadesdde riegos críticos, y por eso tiene
; una prioridad tan baja.
; Imprimiremos un mensaje que muestre por pantalla que el riego está activado

(defrule riegoNormal
	(declare (salience -8))
	?var <- (regarPlanta ?planta ?val)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (or (< 400 ?lux) (< 20 ?grados)) ) ; Lux > 400 o grados > 20
	=>
	(retract ?var)
	(printout t "Se activa el riego para la planta " ?planta crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Regla similar a la anterior, pero en este caso comprueba si la luminosidad es menor de 200 lux
; y la temperatura es inferior a los 20 grados, ya que causa poca evaporación del agua.
; Se ejecutará después de comprobar todas las posibilidadesdde riegos críticos, y por eso tiene
; una prioridad tan baja.
; Imprimiremos un mensaje que muestre por pantalla que el riego está activado

(defrule riegoEscaso
	(declare (salience -8))
	?var <- (regarPlanta ?planta ?val)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (>= 400 ?lux) (>= 20 ?grados)) ) ; Lux < 400 y grados < 20
	=>
	(retract ?var)
	(printout t "Se activa un riego ligero para la planta " ?planta " porque no se evaporara el agua." crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;





; ----------------------------------------------------------------------------------------- ;
; ------------------------------------ Vaporizadores ---------------------------------- ;
; ----------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Esta regla hace lo mismo que la regla 'asignarTemperatura' previamente vista, con la única diferencia
; de que activará el vaporizador (si está apagado) de la planta para mantenerla en su temperatura límite.
; Se decide poner en su temperatura límite para no gastar excesiva energía con el vaporizador.
; Imprimiremos un mensaje que muestre por pantalla el proceso y la asignación

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
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Esta regla es igual a la anterior pero en el caso contrario. Si el vaporizador está encendido
; lo apaga, ya que esta temperatura sí la podrá soportar la planta.
; Imprimiremos un mensaje que muestre por pantalla el proceso y la asignación.

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
	(assert (temperatura ?planta ?valor))
	(assert (vaporizador ?planta off))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Regla exactamente igual a 'riegoCriticoIntenso', salvo que en esta comprueba si usa el vaporizador
; Imprimiremos un mensaje que muestre por pantalla que se ha combinado el riego y el vaporizador.

(defrule riegoCriticoIntensoVaporizador
	(declare (salience -4))
	(vaporizador ?planta on)
	?var <- (regadoCritico ?planta ?val)
	(temperatura ?planta ?grados)
	(luminosidad ?planta ?lux)
	(test (and (< 600 ?lux) (< 35 ?grados)) ) ; Lux > 600 y grados > 35
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa un riego intenso para la planta " ?planta " por la posible evaporacion del agua. " crlf
				"El riego esta combinado con vaporizadores debido a las altas temperaturas." crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; Regla exactamente igual a 'riegoCriticoNormal', salvo que en esta comprueba si usa el vaporizador
; Imprimiremos un mensaje que muestre por pantalla que se ha combinado el riego y el vaporizador.

(defrule riegoCriticoNormalVaporizador
	(declare (salience -5))
	(vaporizador ?planta on)
	?var <- (regadoCritico ?planta ?val)
	=>
	(retract ?var)
	(printout t "Por situacion critica, se activa el riego para la planta " ?planta ". " crlf
				"El riego esta combinado con vaporizadores debido a las altas temperaturas." crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;





; ----------------------------------------------------------------------------------------- ;
; --------------------------------- Gestión de las lluvias -------------------------------- ;
; ----------------------------------------------------------------------------------------- ;

; ------------------------------------------------------------------------------------------------- ;
; Antes de explicar la regla, comentar que la prioridad está puesta para que tenga la lluvia en cuenta
; por delante de los riegos normales, pero después de los críticos, que son más importantes.
; Esta regla se activa cuando nos llega un aviso de lluvia con una intensidad menor que 6.5 mm/h
; para que prepare (no que empiece a regar) un riego normal a las plantas. En caso de que se necesite
; regar, se explicará en reglas posteriores.

(defrule prediccionLluviaLigera
	(declare (salience -6))
	(Tiesto ?planta)
	(valor lluvia prediccion ?intensidad)
	(riego ?planta off)
	(test (< ?intensidad 6.5))
	=>
	(printout t "Se prepara un riego normal (si lo necesita) para la planta " ?planta " porque se prevee una lluvia ligera." crlf)
	(assert (riegoNormal))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; La prioridad de esta regla es igual que la de la regla anterior.
; Esta regla se activa cuando nos llega un aviso de lluvia con una intensidad mayor que 6.5 mm/h y
; menor que 15 mm/h, para que prepare (no que empiece a regar) un riego ligero a las plantas. En caso
; de que se necesite regar, se explicará en reglas posteriores.

(defrule prediccionLluviaModerada
	(declare (salience -6))
	(Tiesto ?planta)
	(valor lluvia prediccion ?intensidad)
	(riego ?planta off)
	(test (and (>= ?intensidad 6.5) (< ?intensidad 15)) )
	=>
	(printout t "Se prepara un riego escaso (si lo necesita) para la planta " ?planta " porque se prevee una lluvia moderada." crlf)
	(assert (riegoEscaso))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; La prioridad de esta regla es igual que la de la regla anterior.
; Esta regla se activa cuando nos llega un aviso de lluvia con una intensidad mayor que 15 mm/h 
; para que no se prepare ningún riego a las plantas. En caso de que se necesite
; regar, se explicará en reglas posteriores.

(defrule prediccionLluviaTorrencial
	(declare (salience -6))
	(Tiesto ?planta)
	(valor lluvia prediccion ?intensidad)
	(riego ?planta off)
	(test (>= ?intensidad 15) )
	=>
	(printout t "No se regara la planta " ?planta " porque se prevee una lluvia intensa." crlf)
	(assert (riegoNulo))
)
; ------------------------------------------------------------------------------------------------- ;



; ------------------------------------------------------------------------------------------------- ;
; La prioridad de esta regla es menor que las anteriores, porque tiene que ejecutarse después.
; Si se ha ejecutado la regla 'prediccionLluviaLigera' y alguna planta necesita ser regada, esta
; será la regla que se ejecute, ya que activa un riego normal teniendo en cuenta que apenas se
; va a humedecer la planta.
; Imprimiremos un mensaje que muestre por pantalla que el riego está activado y por que.

(defrule riegoNormalPorLluviaLigera
	(declare (salience -7))
	?var1 <- (regarPlanta ?planta ?val)
	(riegoNormal)
	(valor lluvia prediccion ?intensidad)
	=>
	(retract ?var1)
	(printout t "La planta " ?planta " tiene un valor alto de humedad (necesita ser regada). " crlf
				"Como se prevee una lluvia de intensidad " ?intensidad ", se regara de forma normal." crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; La prioridad de esta regla está determinada por lo mismo que la anterior 'riegoNormalPorLluviaLigera'
; Si se ha ejecutado la regla 'prediccionLluviaModerada' y alguna planta necesita ser regada, esta
; será la regla que se ejecute, ya que activa un riego ligero que complemente la humedad que le
; proporciona la lluvia.
; Imprimiremos un mensaje que muestre por pantalla que se ha activado un riego ligero y por que.

(defrule riegoLigeroPorLluviaModerada
	(declare (salience -7))
	?var1 <- (regarPlanta ?planta ?val)
	(riegoEscaso)
	(valor lluvia prediccion ?intensidad)
	=>
	(retract ?var1)
	(printout t "La planta " ?planta " tiene un valor alto de humedad (necesita ser regada). " crlf
				"Como se prevee una lluvia de intensidad " ?intensidad ", se regara de forma ligera." crlf)
	(assert (activarRiego ?planta))
)
; ------------------------------------------------------------------------------------------------- ;


; ------------------------------------------------------------------------------------------------- ;
; La prioridad de esta regla está determinada por lo mismo que la anterior 'riegoNormalPorLluviaLigera'
; Si se ha ejecutado la regla 'prediccionLluviaTorrencial' y alguna planta necesita ser regada, esta
; será la regla que se ejecute, ya que no se podrá activar ningún riego por la intensidad de la lluvia.
; Imprimiremos un mensaje que muestre por pantalla que no se ha activado el riego y por que.

(defrule riegoNuloPorLluviaTorrencial
	(declare (salience -7))
	?var1 <- (regarPlanta ?planta ?val)
	(riegoNulo)
	(valor lluvia prediccion ?intensidad)
	=>
	(retract ?var1)
	(printout t "La planta " ?planta " tiene un valor alto de humedad (necesita ser regada). " crlf
				"Como se prevee una lluvia de intensidad " ?intensidad ", no se va a regar." crlf)
)
; ------------------------------------------------------------------------------------------------- ;

; ------------------------------------------------------------------------------------------------- ;
; Como ya he dicho anteriormente, estas reglas no modifican la humedad de la planta, ya que es el
; propio sensor de humedad el que nos tiene que decir su verdadero valor. Estos datos de sensores
; tienen que ser insertados manualmente, por lo que el no hacerlo correctamente puede llevar a
; que el sistema falle. Por ejemplo, si se ejecutan estas reglas que predicen lluvia, regamos y
; el sensor de humedad no ha cambiado, no tendría sentido.
; Para que no haya fallos, puede ver y ejecutarlo con DatosSimulados.txt. No obstante, se permite
; su uso manualmente, pero hay que hacerlo coherentemente.
; ------------------------------------------------------------------------------------------------- ;

; ------------------------------------------------------------------------------------------------- ;
; Regla complementaria que se ejecuta cuando la previsión de lluvia pasa a ser de 0 mm/h (sin lluvia)

(defrule borrarRiegoEscaso
	(declare (salience 2))
	?var1 <- (borrarRiegosPrevistos)
	?var2 <- (riegoEscaso)
	=>
	(retract ?var1)
	(do-for-all-facts ((?var riegoEscaso)) (retract ?var))
)


; ------------------------------------------------------------------------------------------------- ;
; Regla complementaria que se ejecuta cuando la previsión de lluvia pasa a ser de 0 mm/h (sin lluvia)

(defrule borrarRiegoNormal
	(declare (salience 2))
	?var1 <- (borrarRiegosPrevistos)
	?var2 <- (riegoNormal)
	=>
	(retract ?var1)
	(do-for-all-facts ((?var riegoNormal)) (retract ?var))
)


; ------------------------------------------------------------------------------------------------- ;
; Regla complementaria que se ejecuta cuando la previsión de lluvia pasa a ser de 0 mm/h (sin lluvia)

(defrule borrarRiegoNulo
	(declare (salience 2))
	?var1 <- (borrarRiegosPrevistos)
	?var2 <- (riegoNulo)
	=>
	(retract ?var1)
	(do-for-all-facts ((?var riegoNulo)) (retract ?var))
)
; ------------------------------------------------------------------------------------------------- ;


