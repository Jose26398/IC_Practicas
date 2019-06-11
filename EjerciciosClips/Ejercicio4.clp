;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Ejercicio 4 ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule iniciar_bucle
	(not(ultimo_time ?t1))
	(not(pasa_minuto ?t2))
	=>
	(assert (ultimo_time (time)))
	(assert (pasa_minuto (time)))
)


(defrule bucle_espera
	(declare (salience -1000))
	?var <- (ultimo_time ?t1)
	=>
	(retract ?var)
	(assert (ultimo_time (time)))
)


(defrule llega_minuto
	(ultimo_time ?t1)
	?var <- (pasa_minuto ?t2)
	(test(< (+ ?t2 60) ?t1))
	=>
	(retract ?var)
	(assert (pasa_minuto ?t1))
	(printout t "Estoy esperando nueva informacion" crlf)
)