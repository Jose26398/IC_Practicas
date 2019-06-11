;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Ejercicio 2 - Apartado a ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate Ciudades
	(slot Ciudad)
	(slot Habitantes)
)

(deffacts Ciudades
	(Ciudades
		(Ciudad Granada)
		(Habitantes 100))
	(Ciudades
		(Ciudad Jaen)
		(Habitantes 200))
	(Ciudades
		(Ciudad Malaga)
		(Habitantes 300))
)


(defrule primer_minimo
	(declare (salience 5))
	(Ciudades
		(Ciudad ?c)
		(Habitantes ?h)
	)
	(not (min_hab $?))
	=>
	(assert (min_hab ?h))
)

(defrule buscar_minimo
	?var <- (min_hab ?h1)
	(Ciudades
		(Ciudad ?)
		(Habitantes ?h2))
	(test (< ?h2 ?h1))
	=>
	(retract ?var)
	(assert (min_hab ?h2))
)
