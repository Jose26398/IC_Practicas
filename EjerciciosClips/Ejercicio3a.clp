;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Ejercicio 3 - Aparatado a ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffacts Ciudades
  (Ciudad Granada 100)
  (Ciudad Jaen 200)
  (Ciudad Malaga 300)
)


(defrule abrir_fichero
	(declare (salience 3))
	=>
	(open "DatosCiudad.txt" datos "w")
)

(defrule escribir
	(declare (salience 2))
	(Ciudad ?x ?h)
	=>
	(printout datos ?x " " ?h crlf)
)

(defrule cerrar_fichero
	(declare (salience 0))
	=>
	(close datos)
)
