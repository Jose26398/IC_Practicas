; ----------------------------------------------------------------------------------------- ;
; ---------- 1.- Representación de la casa. Primeras deducciones sobre la misma  ---------- ;
; ----------------------------------------------------------------------------------------- ;

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


(deffacts accion
	(accion pulsador_luz salon apagar)
	(accion pulsador_luz cocina apagar)
	(accion pulsador_luz entrada apagar)
	(accion pulsador_luz pasillo apagar)
	(accion pulsador_luz banio apagar)
	(accion pulsador_luz dormitorio1 apagar)
	(accion pulsador_luz dormitorio2 apagar)
	(accion pulsador_luz dormitorio3 apagar)
)


(deffacts Puertas
	(Puerta entrada cocina)
	(Puerta pasillo banio)
	(Puerta pasillo dormitorio1)
	(Puerta pasillo dormitorio2)
	(Puerta pasillo dormitorio3)
)


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


(deffacts Pasos
	(Paso entrada salon)
	(Paso salon pasillo)
)


(defrule posible_pasar_puerta
	(declare(salience 2))
	(Puerta ?hab1 ?hab2)
	=>
	(assert (posible_pasar ?hab1 ?hab2))
	(assert (posible_pasar ?hab2 ?hab1))
	(printout t ?hab1 " tiene conexion con " ?hab2 crlf)
)


(defrule posible_pasar_paso
	(declare(salience 2))
	(Paso ?hab1 ?hab2)
	=>
	(assert (posible_pasar ?hab1 ?hab2))
	(assert (posible_pasar ?hab2 ?hab1))
	(printout t ?hab1 " tiene conexion con " ?hab2 crlf)
)


(defrule habitacion_interior
	(Habitacion ?hab1)
	(Ventana ?hab1 no)
	=>
	(assert (habitacion_interior ?hab1))
	(printout t ?hab1 " es una habitacion interior" crlf)
)


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


(defrule necesario_pasar
	(Habitacion ?hab1)
	(posible_pasar ?hab1 ?hab2)
	(not(no_necesario_pasar ?hab1))
	=>
	(assert (necesario_pasar ?hab1 ?hab2))
	(printout t "Es necesario pasar de " ?hab1 " a " ?hab2 crlf)
)





; ----------------------------------------------------------------------------------------- ;
; ----------------------- 2.- Registro de los datos de los sensores ----------------------- ;
; ----------------------------------------------------------------------------------------- ;

(defrule registrar_senial
	?var <- (valor ?tipo ?hab ?v)
	=>
	(bind ?t (time))
	(assert (valor_registrado ?t ?tipo ?hab ?v))
	(assert (ultimo_registro ?tipo ?hab ?t))
	(retract ?var)
	(printout t "señal recibida: t="?t" tipo="?tipo" hab="?hab" v="?v crlf)
)


(defrule borrar_ultimo_registro
	?var <- (ultimo_registro ?tipo ?hab ?t1)
	(ultimo_registro ?tipo ?hab ?t2)
	(test (< ?t1 ?t2))
	=>
	(retract ?var)
)


(defrule ultima_activacion
	(valor_registrado ?t movimiento ?hab on)
	(ultimo_registro movimiento ?hab ?t)
	=>
	(assert (ultima_activacion movimiento ?hab ?t))
)


(defrule borrar_ultima_activacion
	(ultima_desactivacion ?tipo ?hab ?t1)
	?var <- (ultima_activacion ?tipo ?hab ?t2)
	(ultima_activacion ?tipo ?hab ?t3)
	(and(test(< ?t2 ?t1)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)


(defrule borrar_ultima_activacion_on_tras_on
	(ultima_desactivacion ?tipo ?hab ?t1)
	(ultima_activacion ?tipo ?hab ?t2)
	?var <- (ultima_activacion ?tipo ?hab ?t3)
	(and(test(< ?t1 ?t2)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)


(defrule ultima_desactivacion
	(valor_registrado ?t movimiento ?hab off)
	(ultimo_registro movimiento ?hab ?t)
	=>
	(assert (ultima_desactivacion movimiento ?hab ?t))
)


(defrule borrar_ultima_desactivacion
	(ultima_activacion ?tipo ?hab ?t1)
	?var <- (ultima_desactivacion ?tipo ?hab ?t2)
	(ultima_desactivacion ?tipo ?hab ?t3)
	(and(test(< ?t2 ?t1)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)


(defrule borrar_ultima_desactivacion_off_tras_off
	(ultima_activacion ?tipo ?hab ?t1)
	(ultima_desactivacion ?tipo ?hab ?t2)
	?var <- (ultima_desactivacion ?tipo ?hab ?t3)
	(and(test(< ?t1 ?t2)) (test(< ?t2 ?t3)) )
	=>
	(retract ?var)
)


(defrule imprimir_informe
	?var <- (informe ?h)
	(valor_registrado ?t ?tipo ?h ?v)
	=>
	(printout t ?t " - El sensor " ?tipo " de la habitacion " ?h " tiene el valor " ?v crlf)
)


(defrule borrar_informe
	(valor_registrado ?t ?tipo ?h ?v)
	?var <- (informe ?h)
	=>
	(retract ?var)
)





; ----------------------------------------------------------------------------------------- ;
; ---------------------------- 3.- Manejo Inteligente de luces ---------------------------- ;
; ----------------------------------------------------------------------------------------- ;


; Calcular si se ha producido un posible paso y registrarlo
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


; Se produce un paso seguro (calculado utilizando los posibles pasos)
(defrule paso_seguro
	(declare(salience -1))
	?var <- (posible_paso ?hab2 ?hab1 ?t1)
	(not(posible_paso ?hab3 & ~?hab2 ?hab1 ?t1))
	=>
	(retract ?var)
	(assert(paso_seguro ?hab2 ?hab1 ?t1))
)




; ---------------------------------- Versión del alumno ----------------------------------- ;

; Si detecta movimiento se activa automáticamente
(defrule encender_luz
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab ?est ?t1)
	?var2 <- (accion pulsador_luz ?hab apagar)
	(valor_registrado ?t2 movimiento ?hab on)
	(test(< ?t1 ?t2))
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab activo ?t2))
	(assert (accion pulsador_luz ?hab encender))
)



; Si una persona activa el pulsador en estado inactivo, enciende la habitacion
(defrule encender_luz_pulsador
	?var <- (Estado ?hab ?est ?t1)
	?var2 <- (accion pulsador_luz_persona ?hab apagar)
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab activo (time)))
	(assert (accion pulsador_luz_persona ?hab encender))
)


; Detecta movimiento negativo
(defrule parece_inactiva
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab activo ?t1)
	(valor_registrado ?t2 movimiento ?hab off)
	(test(< ?t1 ?t2))
	=>
	(retract ?var)
	(assert (Estado ?hab parece ?t2))
)


; Si pasan 10 segundos y se registra un movimiento negativo 
(defrule apagar_luz
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab parece ?t1)
	?var2 <- (accion pulsador_luz ?hab encender)
	(valor_registrado ?t2 & ~?t1 movimiento ?hab off)
	(ultimo_registro movimiento ?hab ?t2 & ~?t1)
	(test(< (+ ?t1 10) ?t2))
	=>
	(retract ?var)
	(retract ?var2)
	(assert(Estado ?hab inactivo ?t2))
	(assert (accion pulsador_luz ?hab apagar))
)


; Si una persona activa el pulsador en estado activo, apaga la habitacion
(defrule apagar_luz_pulsador
	?var <- (Estado ?hab ?est ?t1)
	?var2 <- (accion pulsador_luz_persona ?hab apagar)
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab inactivo (time)))
	(assert (accion pulsador_luz_persona ?hab encender))
)



; --------------------------------- Versión del profesor ---------------------------------- ;

; Si detecta movimiento se activa automáticamente
; (defrule encender_luz
; 	(Manejo_inteligente_luces ?hab)
; 	?var <- (Estado ?hab ?est ?t1)
; 	(valor_registrado ?t2 movimiento ?hab on)
; 	(test(< ?t1 ?t2))
; 	=>
; 	(retract ?var)
; 	(assert (Estado ?hab activo ?t2))
; 	(assert (accion pulsador_luz ?hab encender))
; )

; (defrule encender_luz_pulsador
; 	?var <- (Estado ?hab ?est ?t1)
; 	?var2 <- (accion pulsador_luz_persona ?hab encender)
; 	=>
; 	(retract ?var)
; 	(retract ?var2)
; 	(assert (Estado ?hab activo (time)))
; )


; (defrule encender_tras_3seg
; 	(Manejo_inteligente_luces ?hab1)
; 	?var <- (Estado ?hab1 parece ?t1)
; 	(not(posible_paso ?hab1 ?hab2 & ~?hab1 ?t2))
; 	(test(< (+ ?t1 3) (time)))
; 	=>
; 	(retract ?var)
; 	(assert(Estado ?hab1 activo (time)))
; 	(assert (accion pulsador_luz ?hab encender))
; )


; ; Detecta movimiento negativo
; (defrule parece_inactiva
; 	(Manejo_inteligente_luces ?hab)
; 	?var <- (Estado ?hab activo ?t1)
; 	(valor_registrado ?t2 movimiento ?hab off)
; 	(test(< ?t1 ?t2))
; 	=>
; 	(retract ?var)
; 	(assert (Estado ?hab parece ?t2))
; )


; ; Si pasan 10 segundos y no hay movimiento 
; (defrule apagar_luz
; 	(Manejo_inteligente_luces ?hab)
; 	?var <- (Estado ?hab parece ?t1)
; 	(valor_registrado ?t2 movimiento ?hab off)
; 	(ultimo_registro movimiento ?hab ?t2)
; 	(test(< (+ ?t1 10) (time)))
; 	=>
; 	(retract ?var)
; 	(assert(Estado ?hab inactivo ?t2))
; 	(assert (accion pulsador_luz ?hab apagar))
; )

; ; (defrule apagar_tras_10seg
; ; 	(Manejo_inteligente_luces ?hab)
; ; 	?var <- (Estado ?hab parece ?t1)
; ; 	=>
; ; 	(retract ?var)
; ; 	(assert(Estado ?hab inactivo (time)))
; ; )

; (defrule apagar_luz_pulsador
; 	?var <- (Estado ?hab ?est ?t1)
; 	?var2 <- (accion pulsador_luz_persona ?hab apagar)
; 	=>
; 	(retract ?var)
; 	(retract ?var2)
; 	(assert (Estado ?hab inactivo (time)))
; )

; ; Si se produce un paso reciente
; (defrule apagar_por_paso
; 	(declare(salience -2))
; 	(Manejo_inteligente_luces ?hab1)
; 	?var <- (Estado ?hab1 parece ?t1)
; 	(valor_registrado ?t2 movimiento ?hab2 on)
; 	(paso_seguro ?hab1 ?hab2 ?t2)
; 	(test (< ?t1 ?t2))
; 	=>
; 	(retract ?var)
; 	(assert(Estado ?hab1 inactivo ?t2))
; 	(assert (accion pulsador_luz ?hab1 apagar))
; )

