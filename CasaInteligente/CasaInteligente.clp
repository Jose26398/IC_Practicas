; PRACTICAS INGENIERIA DEL CONOCIMIENTO 2018/19
; AUTOR: José Maria Sánchez Guerrero


; ----------------------------------------------------------------------------------------- ;
; ---------- 1.- Representación de la casa. Primeras deducciones sobre la misma  ---------- ;
; ----------------------------------------------------------------------------------------- ;



; Habitaciones

(deffacts Habitaciones
	(Habitacion salon)
	(Habitacion cocina)
	(Habitacion entrada)
	(Habitacion pasillo)
	(Habitacion banio)
	(Habitacion dormitorio1)
	(Habitacion dormitorio2)
	(Habitacion dormitorio3)
)



; Inicialización de los estados de cada habitación (inactivas por defecto)

(deffacts Estado
	(Estado salon inactivo 0)
	(Estado cocina inactivo 0)
	(Estado entrada inactivo 0)
	(Estado pasillo inactivo 0)
	(Estado banio inactivo 0)
	(Estado dormitorio1 inactivo 0)
	(Estado dormitorio2 inactivo 0)
	(Estado dormitorio3 inactivo 0)
)



; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts Luminosidad
	(lmedia salon 300) 
	(lmedia cocina 200)
	(lmedia entrada 200)
	(lmedia banio 200)
	(lmedia pasillo 200)
	(lmedia dormitorio1 150)
	(lmedia dormitorio2 150)
	(lmedia dormitorio3 150)
)



; Habitaciones con puerta

(deffacts Puertas
	(Puerta entrada cocina)
	(Puerta pasillo banio)
	(Puerta pasillo dormitorio1)
	(Puerta pasillo dormitorio2)
	(Puerta pasillo dormitorio3)
)



; Habitaciones con ventanas

(deffacts Ventanas
	(Ventana entrada no)
	(Ventana salon si)
	(Ventana cocina si)
	(Ventana pasillo no)
	(Ventana banio no)
	(Ventana dormitorio1 si)
	(Ventana dormitorio2 si)
	(Ventana dormitorio3 si)
)



; Habitaciones con pasos

(deffacts Pasos
	(Paso entrada salon)
	(Paso salon pasillo)
)



; Regla que permite conocer las habitaciones por las que se puede
; pasar mediante una puerta. Tiene prioridad 2 ya que se tiene que
; ejecutar antes que la regla "no_necesario_pasar"

(defrule posible_pasar_puerta
	(declare(salience 2))
	(Puerta ?hab1 ?hab2)
	=>
	(assert (posible_pasar ?hab1 ?hab2))
	(assert (posible_pasar ?hab2 ?hab1))
)



; Regla que permite conocer las habitaciones por las que se puede
; pasar mediante un paso. Tiene prioridad 2 ya que se tiene que
; ejecutar antes que la regla "no_necesario_pasar"

(defrule posible_pasar_paso
	(declare(salience 2))
	(Paso ?hab1 ?hab2)
	=>
	(assert (posible_pasar ?hab1 ?hab2))
	(assert (posible_pasar ?hab2 ?hab1))
)



; Incluye las habitaciones que no tienen ventanas

(defrule habitacion_interior
	(Habitacion ?hab1)
	(Ventana ?hab1 no)
	=>
	(assert (habitacion_interior ?hab1))
)



; Incluye las habitaciones que tienen más de una acceso, ya sea a
; través de una puerta o un paso. Tiene prioridad 1 porque tiene
; que ejecutarse antes que la regla "necesario_pasar"

(defrule no_necesario_pasar
	(declare(salience 1))
	(Habitacion ?hab1)
	(Habitacion ?hab2 & ~?hab1)
	(Habitacion ?hab3 & ~?hab1 & ~?hab2)
	(posible_pasar ?hab1 ?hab2)
	(posible_pasar ?hab1 ?hab3)
	=>
	(assert (no_necesario_pasar ?hab1))
)



; Para las habitaciones con una sola entrada, indica cuál es su
; única habitación con la que conecta

(defrule necesario_pasar
	(Habitacion ?hab1)
	(posible_pasar ?hab1 ?hab2)
	(not(no_necesario_pasar ?hab1))
	=>
	(assert (necesario_pasar ?hab1 ?hab2))
)






; ----------------------------------------------------------------------------------------- ;
; ----------------------- 2.- Registro de los datos de los sensores ----------------------- ;
; ----------------------------------------------------------------------------------------- ;



; Registramos las señales recibidas por los sensores con una marca de tiempo.
; También borraremos los datos ya recibidos y registraremos el último registro
; de un determinado sensor

(defrule registrar_senial
	?var <- (valor ?tipo & ~luminosidad ?hab ?v)
	=>
	(bind ?t (momento))
	(assert (valor_registrado ?t ?tipo ?hab ?v))
	(assert (ultimo_registro ?tipo ?hab ?t))
	(retract ?var)
)



; Registramos valores del tipo luminosidad a partir de los cambios producidos
; en sus hechos, ya 1ue son estos los que se modifican y de los cuales podemos
; extraer el conocimiento (predefinidos por el profesor en "DatosSimulados.txt")

(defrule registrar_luminosidad
	(luminosidad ?hab ?v)
	=>
	(bind ?t (momento))
	(assert (valor_registrado ?t luminosidad ?hab ?v))
	(assert (ultimo_registro luminosidad ?hab ?t))
)



; Si ya hay un último registro en una habitación, lo elimina y mete el nuevo

(defrule borrar_ultimo_registro
	?var <- (ultimo_registro ?tipo ?hab ?t1)
	(ultimo_registro ?tipo ?hab ?t2)
	(test (< ?t1 ?t2))
	=>
	(retract ?var)
)



; Regla para guardar si el último valor registrado es una activación

(defrule ultima_activacion
	(valor_registrado ?t movimiento ?hab on)
	(ultimo_registro movimiento ?hab ?t)
	=>
	(assert (ultima_activacion movimiento ?hab ?t))
)



; Si hay una última activación ya existente, la elimina y registra la nueva

(defrule borrar_ultima_activacion
	(ultima_desactivacion ?tipo ?hab ?t1)
	?var <- (ultima_activacion ?tipo ?hab ?t2)
	(ultima_activacion ?tipo ?hab ?t3)
	(and(test(< ?t2 ?t1)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)



; Si la última activación registrada viene precedida de otra activación, no
; registra la nueva. Si la habitación ya está activada no la puedes volver
; a activar, asi que este valor no nos servirá

(defrule borrar_ultima_activacion_on_tras_on
	(ultima_desactivacion ?tipo ?hab ?t1)
	(ultima_activacion ?tipo ?hab ?t2)
	?var <- (ultima_activacion ?tipo ?hab ?t3)
	(and(test(< ?t1 ?t2)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)



; Regla para guardar si el último valor registrado es una desactivación

(defrule ultima_desactivacion
	(valor_registrado ?t movimiento ?hab off)
	(ultimo_registro movimiento ?hab ?t)
	=>
	(assert (ultima_desactivacion movimiento ?hab ?t))
)



; Si hay una última desactivación ya existente, la elimina y registra la nueva

(defrule borrar_ultima_desactivacion
	(ultima_activacion ?tipo ?hab ?t1)
	?var <- (ultima_desactivacion ?tipo ?hab ?t2)
	(ultima_desactivacion ?tipo ?hab ?t3)
	(and(test(< ?t2 ?t1)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)



; Si la última desactivación registrada viene precedida de otra desactivación,
; no registra la nueva. Si la habitación ya está desactivada no la puedes volver
; a desactivar, asi que este valor no nos servirá

(defrule borrar_ultima_desactivacion_off_tras_off
	(ultima_activacion ?tipo ?hab ?t1)
	(ultima_desactivacion ?tipo ?hab ?t2)
	?var <- (ultima_desactivacion ?tipo ?hab ?t3)
	(and(test(< ?t1 ?t2)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)



; Regla que imprime un informe de los valores registrados en una habitación
;  indexados por el tiempo en el que se produjeron (del más reciente al más antiguo)

(defrule imprimir_informe
	?var <- (informe ?h)
	(valor_registrado ?t ?tipo ?h ?v)
	=>
	(printout t ?t " - El sensor " ?tipo " de la habitacion " ?h " tiene el valor " ?v crlf)
)



; Borra el assert del informe para poder volver a ejecutarlo

(defrule borrar_informe
	(valor_registrado ?t ?tipo ?h ?v)
	?var <- (informe ?h)
	=>
	(retract ?var)
)






; ----------------------------------------------------------------------------------------- ;
; ---------------------------- 3.- Manejo Inteligente de luces ---------------------------- ;
; ----------------------------------------------------------------------------------------- ;



; Regla 1 del profesor
; Calcula si se ha producido un posible paso entre dos habitaciones y registrarlo

(defrule posible_paso
	(Manejo_inteligente_luces ?hab1)
	(Manejo_inteligente_luces ?hab2)
	(valor_registrado ?t1 movimiento ?hab1 on)
	(posible_pasar ?hab1 ?hab2)
	(Estado ?hab2 ~inactivo ?t2)
	(test(> ?t1 ?t2))
	=>
	(assert (posible_paso ?hab2 ?hab1 ?t1))
)



; Regla 2 del profesor
; Regla que registra si se produce un paso seguro, es decir, sólo hay un posible
; paso. Esto lo hace utilizando los posibles pasos, por eso su prioridad es de -1

(defrule paso_seguro
	(declare(salience -1))
	?var <- (posible_paso ?hab2 ?hab1 ?t1)
	(not(posible_paso ?hab3 & ~?hab2 ?hab1 ?t1))
	=>
	(retract ?var)
	(assert(paso_seguro ?hab2 ?hab1 ?t1))
)





; ---------------------------------- Versión del alumno ----------------------------------- ;


; ; Si detecta movimiento positivo en una habitación y éste cumple que;
; ; · Es más actual que el registrado como estado actual de la habitación
; ; · La luminosidad de la habitación es menor que la media fijada antes
; ; Automáticamente las luces de la habitación se activarán

; (defrule encender_luz
; 	(Manejo_inteligente_luces ?hab)
; 	?var <- (Estado ?hab ?est ?t1)
; 	(valor_registrado ?t2 movimiento ?hab on)
; 	(test(< ?t1 ?t2))
; 	(ultimo_registro luminosidad ?h ?t3)
; 	(valor_registrado ?t3 luminosidad ?h ?l)
; 	(lmedia ?h ?lux)
; 	(test (< ?l (/ ?lux 2)))
; 	=>
; 	(retract ?var)
; 	(assert (Estado ?hab activo ?t2))
; 	(assert (accion pulsador_luz ?hab encender))
; )



; ; En caso de que se encienda la luz mediante el pulsador

; (defrule encender_luz_pulsador
; 	?var <- (Estado ?hab ?est ?t1)
; 	?var2 <- (accion pulsador_luz_persona ?hab encender)
; 	=>
; 	(retract ?var)
; 	(retract ?var2)
; 	(assert (Estado ?hab activo (momento)))
; )



; ; Pasa de activa a parece inactiva si detecta movimiento negativo en la
; ; habitación, pero todavía no sabemos si sigue dentro y no se mueve, o es
; ; que la habitación está vacía

; (defrule parece_inactiva
; 	(Manejo_inteligente_luces ?hab)
; 	?var <- (Estado ?hab activo ?t1)
; 	(valor_registrado ?t2 movimiento ?hab off)
; 	(test(< ?t1 ?t2))
; 	=>
; 	(retract ?var)
; 	(assert (Estado ?hab parece ?t2))
; )



; ; Pasa de parece inactiva a inactiva si pasan 10 segundos y no hay movimiento
; ; dentro de la habitación (no se activará a menos que haya un posible paso en
; ; esta habitación, ya que la Regla 4 impide que llege a este punto)

; (defrule apagar_luz
; 	(Manejo_inteligente_luces ?hab)
; 	?var <- (Estado ?hab parece ?t1)
; 	(ultimo_registro movimiento ?hab ?t1)
; 	(HoraActualizada ?tA)
; 	(test(eq (+ ?t1 10) ?tA))
; 	=>
; 	(retract ?var)
; 	(assert(Estado ?hab inactivo ?tA))
; 	(assert (accion pulsador_luz ?hab apagar))
; )



; ; En caso de que se apage la luz mediante el pulsador

; (defrule apagar_luz_pulsador
; 	?var <- (Estado ?hab ?est ?t1)
; 	?var2 <- (accion pulsador_luz_persona ?hab apagar)
; 	=>
; 	(retract ?var)
; 	(retract ?var2)
; 	(assert (Estado ?hab inactivo (momento)))
; )





; --------------------------------- Versión del profesor ---------------------------------- ;


; Regla 3 del profesor
; Si detecta movimiento positivo en una habitación y éste cumple que;
; · Es más actual que el registrado como estado actual de la habitación
; · La luminosidad de la habitación es menor que la media fijada antes
; Automáticamente las luces de la habitación se activarán

(defrule encender_luz
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab ?est ?t1)
	(valor_registrado ?t2 movimiento ?hab on)
	(test(< ?t1 ?t2))
	(ultimo_registro luminosidad ?h ?t3)
	(valor_registrado ?t3 luminosidad ?h ?l)
	(lmedia ?h ?lux)
	(test (< ?l (/ ?lux 2)))
	=>
	(retract ?var)
	(assert (Estado ?hab activo ?t2))
	(assert (accion pulsador_luz ?hab encender))
)



; En caso de que se encienda la luz mediante el pulsador

(defrule encender_luz_pulsador
	?var <- (Estado ?hab ?est ?t1)
	?var2 <- (accion pulsador_luz_persona ?hab encender)
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab activo (momento)))
)



; Regla 4 del profesor
; Pasa de parece inactiva a activa si pasan 3 segundos y no se ha producido
; ningún posible paso entre ésta y otra habitación (sigue dentro de la
; habitación pero no se ha movido)

(defrule encender_tras_3seg
	(Manejo_inteligente_luces ?hab1)
	?var <- (Estado ?hab1 parece ?t1)
	(HoraActualizada ?tA)
	(not(posible_paso ?hab1 ?hab2 & ~?hab1 ?t2))
	(test(eq (+ ?t1 3) ?tA))
	=>
	(retract ?var)
	(assert(Estado ?hab1 activo ?tA))
)



; Regla 5 del profesor
; Pasa de activa a parece inactiva si detecta movimiento negativo en la
; habitación, pero todavía no sabemos si sigue dentro y no se mueve, o es
; que la habitación está vacía

(defrule parece_inactiva
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab activo ?t1)
	(valor_registrado ?t2 movimiento ?hab off)
	(test(< ?t1 ?t2))
	=>
	(retract ?var)
	(assert (Estado ?hab parece ?t2))
)



; Regla 6 del profesor
; Pasa de parece inactiva a inactiva si pasan 10 segundos y no hay movimiento
; dentro de la habitación (no se activará a menos que haya un posible paso en
; esta habitación, ya que la Regla 4 impide que llege a este punto)

(defrule apagar_luz
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab parece ?t1)
	(ultimo_registro movimiento ?hab ?t1)
	(HoraActualizada ?tA)
	(test(eq (+ ?t1 10) ?tA))
	=>
	(retract ?var)
	(assert(Estado ?hab inactivo ?tA))
	(assert (accion pulsador_luz ?hab apagar))
)



; En caso de que se apage la luz mediante el pulsador

(defrule apagar_luz_pulsador
	?var <- (Estado ?hab ?est ?t1)
	?var2 <- (accion pulsador_luz_persona ?hab apagar)
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab inactivo (momento)))
)



; Regla 7 del profesor
; Si se produce un paso seguro en una habitación, automáticamente pasaré de parece
; inactiva a inactiva. Tiene baja prioridad porque primero tiene que calcular los
; posibles pasos

(defrule apagar_por_paso
	(declare(salience -2))
	(Manejo_inteligente_luces ?hab1)
	?var <- (Estado ?hab1 parece ?t1)
	(valor_registrado ?t2 movimiento ?hab2 on)
	(paso_seguro ?hab1 ?hab2 ?t2)
	(test (< ?t1 ?t2))
	=>
	(retract ?var)
	(assert(Estado ?hab1 inactivo ?t2))
	(assert (accion pulsador_luz ?hab1 apagar))
)


