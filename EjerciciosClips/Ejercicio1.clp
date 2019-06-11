;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Ejercicio 1 ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule primeros_hechos
	(declare (salience 5))
	(ContarHechos ?x)
	(not(NumeroHechos ?x ?n))
	=>
	(assert (NumeroHechos ?x 0))
)


(defrule contar_hechos
	?var <- (ContarHechos ?x)
	?var2 <- (NumeroHechos ?x ?n)
	=>
	(bind ?n 0)
	(do-for-all-facts((?xn ?x)) TRUE
		(bind ?n (+ 1 ?n))
	)
	(retract ?var2)
	(assert (NumeroHechos ?x ?n))
	(retract ?var)
)