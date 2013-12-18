LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO(.T., ' INVENTARIO / STOCK ' )
MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
M->FECHA    := RFECHA := VA->FECHA
M->STOCKACT := 0
M->DEPOSITO := 0
M->COMPRAS  := 0
M->VENTAS   := 0

aCpo:={{ "CODPROD",           "C¢digo; ",                           '', 'F',  '',  0, 0 },;
		  { "DESCPROD",          "Descripci¢n",            REPLIC('X',20), 'F',  '',  0, 0 },;
		  { "CONSTOCK",          "Con;Stk",                            '', 'M',  '',  0, 0 },;
		  { "FECHA",             "Fecha;St ini",                       '', 'M',  '',  0, 0 },;
		  { "STOCKINI",          "Stock;Inicial",                      '', 'M',  '',  0, 0 },;
		  { "STOCKACT",          "Stock;Actual",                       '', 'F',  '',  0, 0 },;
		  { "COMPRAS",           "Compras; ",                          '', 'F',  '',  0, 0 },;
		  { "VENTAS",            "Ventas; ",                           '', 'F',  '',  0, 0 },;
		  { "AJUSTES",           "Ajustes; ",                          '', 'F',  '',  0, 0 },;
		  { "STOCKMIN",          "Stock;M¡nimo",                       '', 'E',  '',  0, 0 },;
		  { "STOCKMAX",          "Stock;M ximo",                       '', 'E',  '',  0, 0 } }

SELECT PRD
aCpo := FBASEAUX( aCpo, "PRD", SELECT(), .F. )
DBGOTOP()
RECUPAN()

SETCOLOR( "W/N,N/W" )
OX := MYBROWSE( 5, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 10
OX:FREEZE(2)
	
MENUDOWN({"  <+>  º       F8        º        F10         º ESC  ",;
			  "       º recalcula stock º recalcula el stock º      ",;
			  " mueve º del prod.actual º de todos los prod. º sale "})
	
DO WHILE .T.

	MOVBROW( OX, {||nK==9.OR.nK==-9.OR.nK==27.OR.nK==-6.OR.nK==K_F8.OR.nK==43.OR.nK==45.OR.nK==K_F10 }, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )

	IF OX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		PRD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		DBUNLOCK()
		TBPOS(OX)


	ELSEIF OX:Cargo[TB_RET] == K_F8
		MENSAJE( 0, 0, 0, .F., " RECALCULANDO STOCK DE "+ALLTRIM(PRD->DESCPROD) )
 		FBASES({"PLAN2", "COMPRAS2", "AJUSTES","LUB","LUB2"})
     SELECT PL2
    	DBSETORDER( FORDER({"CODPROD","FECHA"}) )
     SET ORDER TO 3
     SELECT CO2
     DBSETORDER( FORDER({"CODPROD","FECHA"}) )
     SELECT AJ
     DBSETORDER( FORDER({"CODPROD","FECHA"}) )
     SELECT LU
     DBSETORDER( FORDER({"FECHA"}) )
		SELECT PRD
     SET SOFTSEEK OFF
     IF PRD->CONSTOCK == "S"
     	aaux:=RECALCSTOCK()
        FRLOCK()
        PRD->COMPRAS := aaux[1]
        PRD->VENTAS  := aaux[2]
        PRD->AJUSTES := aaux[3]
        PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS -PRD->VENTAS + PRD->AJUSTES
     	DBUNLOCK()
     ENDIF
 		RECUPAN()
		OX:REFRESHCURRENT()


			
	ELSEIF OX:Cargo[TB_RET] == K_F10
		IF PREGUNTA( 12, " ¨ RECALCULO STOCK ?   [ S / N ]", "SsNn") $ "Ss"
			MENSAJE( 0, 0, 0, .F., " RECALCULANDO STOCK ... " )
 			FBASES({"PLAN2", "COMPRAS2", "AJUSTES","LUB","LUB2"})
        SELECT PL2
     	DBSETORDER( FORDER({"CODPROD","FECHA"}) )
        SET ORDER TO 3
        SELECT CO2
     	DBSETORDER( FORDER({"CODPROD","FECHA"}) )
        SELECT AJ
     	DBSETORDER( FORDER({"CODPROD","FECHA"}) )
     	SELECT LU
     	DBSETORDER( FORDER({"FECHA"}) )
     	SELECT PRD
        xorder := INDEXORD()
        SET ORDER TO
			GO TOP
			INIVER( "",22,20,40,PRD->(LASTREC()) )
        DO WHILE !PRD->(EOF())
           IF PRD->CONSTOCK == "S"
     			aaux:=RECALCSTOCK()
        		FRLOCK()
        		PRD->COMPRAS  := aaux[1]
        		PRD->VENTAS   := aaux[2]
        		PRD->AJUSTES  := aaux[3]
        		PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
     			DBUNLOCK()
				ENDIF
       		VER(0); por_donde:=PRD->(RECNO())
           SKIP 1 ALIAS PRD
     	ENDDO
     	verindex := .F.
     	RECUPAN()
        SELECT PRD
     	DBSETORDER( xorder )
     	DBGOTOP()
			TBPOS(OX,.T.)
		ENDIF

			
	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF

ENDDO
	

RETURN



****************

FUNC RECALCSTOCK									//BIEN

****************
LOCAL aa
#define RG_COMPRAS      1
#define RG_VENTAS       2
#define RG_AJUSTES      3
aa := ARRAY( RG_AJUSTES )
afill(aa,0)

* * * Compras
SELECT CO2
SET SOFTSEEK ON
SEEK STR(PRD->CODPROD)+FTOC(PRD->FECHA)
SET SOFTSEEK OFF
SELECT PRD
DO WHILE CO2->CODPROD==PRD->CODPROD  .AND. CO2->FECHA>=PRD->FECHA
  aa[RG_COMPRAS]  += CO2->CANTIDAD
  SKIP 1 ALIAS CO2
ENDDO

* * * Ventas
SELECT PL2
SET SOFTSEEK ON
SEEK STR(PRD->CODPROD)+FTOC(PRD->FECHA)
SET SOFTSEEK OFF
SELECT PRD
DO WHILE PL2->CODPROD==PRD->CODPROD .AND. PL2->FECHA>=PRD->FECHA
  aa[RG_VENTAS] += PL2->CANTIDAD
  SKIP 1 ALIAS PL2
ENDDO

* * * Ajustes
SELECT AJ
SET SOFTSEEK ON
SEEK STR(PRD->CODPROD)+FTOC(PRD->FECHA)
SET SOFTSEEK OFF
SELECT PRD
DO WHILE AJ->CODPROD==PRD->CODPROD  .AND. AJ->FECHA>=PRD->FECHA
  aa[RG_AJUSTES]  += AJ->CANTIDAD
  SKIP 1 ALIAS AJ
ENDDO

* * * Lubricentro
select LU
dbseek( FTOC(PRD->FECHA), .T. )
select LU2
dbseek( LU->NUMPARTE, .T. )
select PRD
do while LU2->FECHA>=PRD->FECHA .and. !LU2->(eof())
	if LU2->CODPROD==PRD->CODPROD
  	aa[RG_VENTAS]  += LU2->CANTOTAL
  endif
  skip 1 alias LU2
enddo


* * * Actualiza Stock
*PRD->STOCKACT  := PRD->STOCKINI + M->COMPRAS - M->VENTAS + M->AJUSTES

RETURN( aa )



***********************************

FUNC INVENTARIAR( bCond, lDetalle )

***********************************
LOCAL aux:=SAVESCREEN( 0, 0, 24, 79 ), aaux
DEFAULT lDetalle TO .T.
MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

SELECT PRD
aaux := DBSTRUCT()
aaux := ADEJAR( aaux, {"CODPROD","FECHA","COMPRAS","VENTAS","AJUSTES","FECHA","STOCKACT","PRECVENTA"} )
cBaseAux := XNAME('XAUX')
SELECT 99;	DBCLOSEAREA()
DBCREATE( cBaseAux, aaux )
SELECT 99
USE (cBaseAux) ALIAS X EXCLUSIVE
if lDetalle
	INDEX ON STR(X->CODPROD)+FTOC(X->FECHA) TO (cBaseAux)
else
	INDEX ON X->CODPROD TO (cBaseAux)
endif

FBASES({"PLAN2", "COMPRAS2", "AJUSTES"})
SELECT PL2
DBSETORDER( FORDER({"STR(PL2->CODPROD)+FTOC(PL2->FECHA)"}) )
SET ORDER TO 3
SELECT CO2
DBSETORDER( FORDER({"CODPROD","FECHA"}) )
SELECT AJ
DBSETORDER( FORDER({"CODPROD","FECHA"}) )

@15,0 SAY " PRODUCTO                               COMPRAS   VENTAS    AJUSTES   STOCK   "
@16,0 SAY "===============================         ========= ========= ========= ========"
SCROLL( 17, 0, 24, 79, -20 )
SELECT PRD
GO TOP
if lDetalle
DO WHILE !PRD->(EOF())
	IF EVAL(bCond) .AND. PRD->CONSTOCK=='S' .AND. PRD->CODPROD#0
  	@ 24, 0 SAY STR(PRD->CODPROD) +" "+ PRD->DESCPROD

     	*** Compras
  	SELECT CO2
  	DBSEEK( STR(PRD->CODPROD)+FTOC(PRD->FECHA), .T. )
     SELECT X
     DO WHILE CO2->CODPROD==PRD->CODPROD .AND. CO2->FECHA>=PRD->FECHA .AND. CO2->FECHA<=HASTA
  		DBSEEK( STR(CO2->CODPROD)+FTOC(CO2->FECHA) )
        IF !FOUND()
        	APPEND BLANK
           X->CODPROD := CO2->CODPROD
           X->FECHA   := CO2->FECHA
  			@ 24,40 SAY CO2->FECHA
        ENDIF
        X->COMPRAS += CO2->CANTIDAD
        SKIP 1 ALIAS CO2
     ENDDO

     	*** Ventas
  	SELECT PL2
  	DBSEEK( STR(PRD->CODPROD)+FTOC(PRD->FECHA), .T. )
     SELECT X
     DO WHILE PL2->CODPROD==PRD->CODPROD
			IF PL2->FECHA>=PRD->FECHA .AND. PL2->FECHA<=HASTA
  			DBSEEK( STR(PL2->CODPROD)+FTOC(PL2->FECHA) )
        	IF !FOUND()
        		APPEND BLANK
           	X->CODPROD := PL2->CODPROD
           	X->FECHA   := PL2->FECHA
  				@ 24,50 SAY PL2->FECHA
        	ENDIF
        	X->VENTAS += PL2->CANTIDAD
        ENDIF
        SKIP 1 ALIAS PL2
     ENDDO

     	*** Ajustes
  	SELECT AJ
  	DBSEEK( STR(PRD->CODPROD)+FTOC(PRD->FECHA), .T. )
     SELECT X
     DO WHILE AJ->CODPROD==PRD->CODPROD .AND. AJ->FECHA>=PRD->FECHA .AND. AJ->FECHA<=HASTA
  		DBSEEK( STR(AJ->CODPROD)+FTOC(AJ->FECHA) )
        IF !FOUND()
        	APPEND BLANK
           X->CODPROD := AJ->CODPROD
           X->FECHA   := AJ->FECHA
  			@ 24,60 SAY AJ->FECHA
        ENDIF
        X->AJUSTES += AJ->CANTIDAD
        SKIP 1 ALIAS AJ
     ENDDO

		SELECT X
     DBSEEK(STR(PRD->CODPROD),.T.)
     M->STOCKANT := PRD->STOCKINI
     DO WHILE X->CODPROD == PRD->CODPROD .AND. !EOF()
     	X->STOCKACT := M->STOCKANT + X->COMPRAS - X->VENTAS + X->AJUSTES
     	M->STOCKANT := X->STOCKACT
  		@ 24,70 SAY X->FECHA
        SKIP
     ENDDO

  	SCROLL( 17, 0, 24, 79, 1 )

  ENDIF
  SKIP 1 ALIAS PRD

ENDDO
else
DO WHILE !PRD->(EOF())
	IF EVAL(bCond) .AND. PRD->CONSTOCK=='S' .AND. PRD->CODPROD#0
  	@ 24, 0 SAY STR(PRD->CODPROD) +" "+ PRD->DESCPROD

     	*** Compras
  	SELECT CO2
  	DBSEEK( STR(PRD->CODPROD)+FTOC(PRD->FECHA), .T. )
     SELECT X
     DO WHILE CO2->CODPROD==PRD->CODPROD .AND. CO2->FECHA>=PRD->FECHA .AND. CO2->FECHA<=HASTA
  		DBSEEK( CO2->CODPROD )
        IF !FOUND()
        	APPEND BLANK
           X->CODPROD := CO2->CODPROD
        ENDIF
        X->FECHA   := CO2->FECHA
        X->COMPRAS += CO2->CANTIDAD
  		@ 24,40 SAY CO2->FECHA
        SKIP 1 ALIAS CO2
     ENDDO

     	*** Ventas
  	SELECT PL2
  	DBSEEK( STR(PRD->CODPROD)+FTOC(PRD->FECHA), .T. )
     SELECT X
     DO WHILE PL2->CODPROD==PRD->CODPROD
			IF PL2->FECHA>=PRD->FECHA .AND. PL2->FECHA<=HASTA
  			DBSEEK( PL2->CODPROD )
        	IF !FOUND()
        		APPEND BLANK
           	X->CODPROD := PL2->CODPROD
        	ENDIF
          	X->FECHA  := PL2->FECHA
        	X->VENTAS += PL2->CANTIDAD
  			@ 24,50 SAY PL2->FECHA
        ENDIF
        SKIP 1 ALIAS PL2
     ENDDO

     	*** Ajustes
  	SELECT AJ
  	DBSEEK( STR(PRD->CODPROD)+FTOC(PRD->FECHA), .T. )
     SELECT X
     DO WHILE AJ->CODPROD==PRD->CODPROD .AND. AJ->FECHA>=PRD->FECHA .AND. AJ->FECHA<=HASTA
  		DBSEEK( AJ->CODPROD )
        IF !FOUND()
        	APPEND BLANK
           X->CODPROD := AJ->CODPROD
        ENDIF
        X->FECHA   := AJ->FECHA
        X->AJUSTES += AJ->CANTIDAD
  		@ 24,60 SAY AJ->FECHA
        SKIP 1 ALIAS AJ
     ENDDO

		SELECT X
     if DBSEEK( PRD->CODPROD )
     	X->STOCKACT  := PRD->STOCKINI + X->COMPRAS - X->VENTAS + X->AJUSTES
        X->PRECVENTA := PRD->PRECVENTA
     endif

  	SCROLL( 17, 0, 24, 79, 1 )

  ENDIF
  SKIP 1 ALIAS PRD

ENDDO
endif
RECUPAN()
RESTSCREEN( 0, 0, 24, 79, aux )

RETURN
