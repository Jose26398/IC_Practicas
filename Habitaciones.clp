; ----------------------------------------------------------------------------------------- ;
; ---------- 1.- Representación de la casa. Primeras deducciones sobre la misma  ---------- ;
; ----------------------------------------------------------------------------------------- ;

(deffacts Habitaciones
	(Habitacion Salon)
	(Habitacion Cocina)
	(Habitacion Entrada)
	(Habitacion Pasillo)
	(Habitacion Banio)
	(Habitacion Dormitorio1)
	(Habitacion Dormitorio2)
	(Habitacion Dormitorio3)
)


(deffacts Estado
	(Estado Salon Inactivo 0)
	(Estado Cocina Inactivo 0)
	(Estado Entrada Inactivo 0)
	(Estado Pasillo Inactivo 0)
	(Estado Banio Inactivo 0)
	(Estado Dormitorio1 Inactivo 0)
	(Estado Dormitorio2 Inactivo 0)
	(Estado Dormitorio3 Inactivo 0)
)


(deffacts accion
	(accion pulsador_luz Salon apagar)
	(accion pulsador_luz Cocina apagar)
	(accion pulsador_luz Entrada apagar)
	(accion pulsador_luz Pasillo apagar)
	(accion pulsador_luz Banio apagar)
	(accion pulsador_luz Dormitorio1 apagar)
	(accion pulsador_luz Dormitorio2 apagar)
	(accion pulsador_luz Dormitorio3 apagar)
)


(deffacts Puertas
	(Puerta Entrada Cocina)
	(Puerta Pasillo Banio)
	(Puerta Pasillo Dormitorio1)
	(Puerta Pasillo Dormitorio2)
	(Puerta Pasillo Dormitorio3)
)


(deffacts Ventanas
	(Ventana Entrada no)
	(Ventana Salon si)
	(Ventana Cocina si)
	(Ventana Pasillo no)
	(Ventana Banio no)
	(Ventana Dormitorio1 si)
	(Ventana Dormitorio2 si)
	(Ventana Dormitorio3 si)
)


(deffacts Pasos
	(Paso Entrada Salon)
	(Paso Salon Pasillo)
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
        ;(printout t "No es necesario pasar de " ?hab1 " a " ?hab2 " o " ?hab3 crlf)
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


; ----------------------------------- Versión del alumno ---------------------------------- ;

(defrule encender_luz
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab Inactivo ?t1)
	?var2 <- (accion pulsador_luz ?hab apagar)
	(valor_registrado ?t2 movimiento ?hab on)
	(test(< ?t1 ?t2))
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab Activo ?t2))
	(assert (accion pulsador_luz ?hab encender))
)


(defrule apagar_luz
	(Manejo_inteligente_luces ?hab)
	?var <- (Estado ?hab Activo ?t1)
	?var2 <- (accion pulsador_luz ?hab encender)
	(valor_registrado ?t2 movimiento ?hab off)
	(test(< ?t1 ?t2))
	=>
	(retract ?var)
	(retract ?var2)
	(assert (Estado ?hab Inactivo ?t2))
	(assert (accion pulsador_luz ?hab apagar))
)