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
	(Habitacion dormitorio)
)



; Inicialización de los estados de cada habitación (inactivas por defecto)

(deffacts Estado
	(Estado salon inactivo 0)
	(Estado cocina inactivo 0)
	(Estado entrada inactivo 0)
	(Estado pasillo inactivo 0)
	(Estado banio inactivo 0)
	(Estado dormitorio inactivo 0)
)



; Habitaciones con puerta

(deffacts Puertas
	(Puerta entrada cocina)
	(Puerta pasillo banio)
	(Puerta pasillo dormitorio)
)



; Habitaciones con ventanas

(deffacts Ventanas
	(Ventana entrada no)
	(Ventana salon si)
	(Ventana cocina si)
	(Ventana pasillo no)
	(Ventana banio no)
	(Ventana dormitorio si)
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
	?var <- (valor ?tipo ?hab ?v)
	=>
	(bind ?t (momento))
	(assert (valor_registrado ?t ?tipo ?hab ?v))
	(assert (ultimo_registro ?tipo ?hab ?t))
	(retract ?var)
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
