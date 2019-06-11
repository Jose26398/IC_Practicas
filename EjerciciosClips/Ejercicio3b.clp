;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Ejercicio 3 - Apartado b ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule abrir_archivo
	(declare (salience 2))
	=>
	(open "DatosCiudad.txt" datos)
	(assert (noEOF))
)


(defrule leer_linea
	(declare (salience 1))
	?var <- (noEOF)
	=>
	(bind ?x (read datos))
	(retract ?var)
	(if (neq ?x EOF) then
	(assert (Ciudad ?x (read datos) ))
	(assert (noEOF)))
)


(defrule cerrar_archivo
	(declare (salience 0))
	=>
	(close datos)
)