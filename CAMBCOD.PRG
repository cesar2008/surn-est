CLEAR
SET DATE BRITISH
SET TALK OFF

wait "paso PLANILLAS Y COMPRAS" TO OP
IF UPPER(OP) == "S"
	CLEAR
	SELECT 1
	USE PROD ALIAS PRD
	INDEX ON LEFT(PRD->DESCPROD,25) TO CAMBCOD

	xc1=0
	SELECT 2
	USE PLAN2 ALIAS PL2
	@0,1 SAY LASTREC()
	GO TOP
	SELECT PRD
	DO WHILE !PL2->(EOF())
		SEEK LEFT(PL2->DESCPROD,25)
  	IF FOUND() .AND. PL2->CODPROD # PRD->CODPROD
  		REPLACE PL2->CODPROD WITH PRD->CODPROD
     	xc1=xc1+1
     	@ 1,1 SAY xc1
  	ENDIF
  	SKIP 1 ALIAS PL2
		@0,41 SAY PL2->(RECNO())
	ENDDO

	xc2=0
	SELECT 2
	USE COMPRAS2 ALIAS CO2
	@0,1 SAY LASTREC()
	GO TOP
	SELECT PRD
	DO WHILE !CO2->(EOF())
		SEEK CO2->DESCPROD
  	IF FOUND() .AND. CO2->CODPROD # PRD->CODPROD
  		REPLACE CO2->CODPROD WITH PRD->CODPROD
     	xc2=xc2+1
     	@ 2,1 SAY xc2
  	ENDIF
  	SKIP 1 ALIAS CO2
		@0,41 SAY CO2->(RECNO())
	ENDDO
ENDIF



wait "paso REMITOS Y FACTURAS" TO OP
IF UPPER(OP) == "S"
	CLEAR
	SELECT 1
	USE PROD ALIAS PRD
	INDEX ON LEFT(PRD->DESCPROD,20) TO CAMBCOD

	aa := { "REM2", "FACA2", "FACB2" }
	FOR x=1 TO LEN(aa)
  	@ x,1  SAY aa[x]
		xc3=0
		SELECT 2
		USE (aa[x]) ALIAS X2
		@0,1 SAY LASTREC()
		GO TOP
		SELECT PRD
		DO WHILE !X2->(EOF())
			SEEK X2->DESCPROD
  		IF FOUND() .AND. X2->CODPROD # PRD->CODPROD
  			REPLACE X2->CODPROD WITH PRD->CODPROD
     		xc3=xc3+1
     		@ x,20 SAY xc3
  		ENDIF
  		SKIP 1 ALIAS X2
			@0,41 SAY X2->(RECNO())
		ENDDO
	NEXT
ENDIF
