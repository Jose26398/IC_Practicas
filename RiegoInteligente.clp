; PRACTICAS INGENIERIA DEL CONOCIMIENTO 2018/19
; AUTOR: José Maria Sánchez Guerrero


; ----------------------------------------------------------------------------------------- ;
; ---------------- 1.- Definición de los tiestos y estado de los sensores  ---------------- ;
; ----------------------------------------------------------------------------------------- ;



; Habitaciones

(deffacts Tiestos
	(Tiesto cactus)
	(Tiesto helechos)
	(Tiesto flores)
)


; Inicialización de los estados de cada tiesto (secos por defecto)

(deffacts Estado
	(Estado cactus seco)
	(Estado helechos seco)
	(Estado flores seco)
	(Estado vaporizador desactivado)
)



; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts Humedad
	(hideal cactus 10) 
	(hideal helechos 100)
	(hideal flores 150)
)

; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts Temperaturas
	(tlimite cactus 100) 
	(tlimite helechos 50)
	(tlimite flores 40)
)

; Conocimiento de las luminosidades de cada habitación proporcionada por el profesor

(deffacts Luminosidad
	(lideal cactus 100) 
	(lideal helechos 60)
	(lideal flores 40)
)