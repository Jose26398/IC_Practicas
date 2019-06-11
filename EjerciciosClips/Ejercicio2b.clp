;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Ejercicio 2 - Apartado b ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffacts Ciudades
	(Ciudad Granada 100)
	(Ciudad Jaen 200)
	(Ciudad Malaga 300)
)

(defrule primer_valor
	(declare (salience 5))
	(Ciudad ?c ?h)
	(not (min_hab $?))
	=>
	(assert (min_hab ?h))
)

(defrule min_menor_actual
	?var <- (min_hab ?h1)
	(Ciudad ?c ?h2)
	(test (< ?h2 ?h1))
	=>
	(retract ?var)
	(assert (min_hab ?h2))
)
