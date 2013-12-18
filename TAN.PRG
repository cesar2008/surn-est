LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO( .T., " TANQUES " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
aSurt := {}
IF FILE("SURTIDOR.ARR")
  aSurt := STOA(MEMOREAD("SURTIDOR.ARR"))
ENDIF

aCpo:={;
	{ "NUMTANQ",    "Tanque",                             '', 'E',  '',  0, 0 },;
	{ "CODPROD",    "C¢d;Prod.",                          '', 'E',  '',  0, 0 },;
	{ "FPRODUCTO(CODPROD)",;
   					 "Producto",               replic('X',20), 'F', 'F', 20, 0 },;
	{ "STOCKINI",   "Stock;Inicial",                      '', 'E',  '',  0, 0 },;
	{ "STOCKACT",   "Stock;Actual",                       '', 'E',  '',  0, 0 },;
	{ "FECHA",      "Fecha;Stk.Ini",                      '', 'E',  '',  0, 0 },;
	{ "CAPACIDAD",  "Capacidad",                          '', 'E',  '',  0, 0 },;
	{ "SURTIDORES", "Surtidores",                         '', 'E',  '',  0, 0 }}

FBASES({ "TANQUES" })
SELECT TAN
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º    F6    º   F5   º    F7   º    F9     º  ESC   ",;
			  "       º F3 busca  º Shift F6 º        º         º recalcula º        ",;
			  " mueve º F4 busca+ º elimina  º agrega º listado º   stock   º  sale  "})

SETCOLOR( C_MENU )
oX := MYBROWSE( 4, 1, 20, 78, aCpo )
oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()
OX:FREEZE:=3

DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==-8.OR.nK==K_F9.OR.nk==K_F7.OR.nK==K_SH_F6.OR.nK==K_F12} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
     IF TBNOC(OX) == "STOCKINI" .AND. TAN->STOCKACT==0
     	TAN->STOCKACT := TAN->STOCKINI
     ENDIF
		UNLOCK
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB
		IF FELEGIR( "PRODUCTO", TAN->CODPROD ) # 0
			FRLOCK();  TAN->CODPROD := PRD->CODPROD;  DBUNLOCK()
			TBPOS(OX)
		ENDIF
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F5
  	DBGOBOTTOM()
     if TAN->NUMTANQ#0 .or. lastrec()==0
     	nAux := TAN->NUMTANQ
     	add_rec()
        frlock()
        TAN->NUMTANQ := nAux+1
        dbunlock()
     endif
		TBPOS(OX,.t.)
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
			BLANKREG(.T.)
			GO xreg2
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
     xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
		BLANKREG(.T.)
		GO xreg2
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F9
		IF PREGUNTA( 12, " ¨ RECALCULO STOCK TANQUES ?   [ S / N ]", "SsNn") $ "Ss"
			MENSAJE( 0, 0, 0, .F., " RECALCULANDO ... " )
 			FBASES({"+PLAN2", "+COMPRAS2", "+AJUSTES"})
			select PL2;  set order to forder({"CODPROD","FTOC(PL2->FECHA)"})
			select CO2;  set order to forder({"CODPROD","FECHA"})
			select AJ;  set order to forder({"CODPROD","FECHA"})

     	SELECT TAN
			GO TOP
        DO WHILE !TAN->(EOF())
           IF TAN->CODPROD # 0
					nAux := 0
						* * * Compras
					SELECT CO2
					DBSEEK( STR(TAN->CODPROD)+FTOC(TAN->FECHA), .T. )
					SELECT TAN
					DO WHILE CO2->CODPROD==TAN->CODPROD .AND. CO2->FECHA>=TAN->FECHA
              	if CO2->NUMTANQ==TAN->NUMTANQ
  						nAux  += CO2->CANTIDAD
                 endif
  					SKIP 1 ALIAS CO2
					ENDDO
						* * * Ventas
              aaux := {}
              for i=1 to len(aSurt)
              	if aSurt[i,TAN_NUMTANQ] == TAN->NUMTANQ
                 	aadd( aaux, {aSurt[i,TAN_CODPROD],aSurt[i,TAN_SURTIDOR]} )
                 endif
              next
					SELECT PL2
					DBSEEK( STR(TAN->CODPROD)+FTOC(TAN->FECHA), .T. )
					SELECT TAN
					DO WHILE PL2->CODPROD==TAN->CODPROD .AND. PL2->FECHA>=TAN->FECHA
              	if ascan( aaux, {|a| a[1]==PL2->CODPROD.and.a[2]==PL2->SURTIDOR} ) # 0
  						nAux -= PL2->CANTIDAD
                 endif
  					SKIP 1 ALIAS PL2
					ENDDO
						* * * Ajustes
					SELECT AJ
					DBSEEK( STR(TAN->CODPROD)+FTOC(TAN->FECHA), .T. )
					SELECT TAN
					DO WHILE AJ->CODPROD==TAN->CODPROD  .AND. AJ->FECHA>=TAN->FECHA
              	if AJ->NUMTANQ==TAN->NUMTANQ
  						nAux += AJ->CANTIDAD
                 endif
  					SKIP 1 ALIAS AJ
					ENDDO

					FRLOCK()
        		TAN->STOCKACT := TAN->STOCKINI + nAux
     			DBUNLOCK()
				ENDIF
           SKIP 1 ALIAS TAN
     	ENDDO
     	RECUPAN()
        SELECT TAN
     	DBGOTOP()
			TBPOS(OX,.T.)
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F12
		MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
  	nReg := recno()
     cBaseAux := XNAME('XAUX')
     index on CODPROD to (cBaseAux)
     select 99;  dbclosearea()
     select TAN
     total on CODPROD to (cBaseAux) FIELDS STOCKINI, STOCKACT
     select 99
     use (cBaseAux) alias X exclusive
     go top
     select PRD
     do while !X->(eof())
     	if dbseek(X->CODPROD)
        	FRLOCK()
        	PRD->STOCKINI := X->STOCKINI
           PRD->STOCKACT := X->STOCKACT
           PRD->FECHA    := X->FECHA
           DBUNLOCK()
        endif
        skip 1 alias X
     enddo
     FREABRIR({"TANQUES"})
     select TAN
     go nReg
     RECUPAN()

	ELSEIF oX:Cargo[TB_RET] == K_F12
  	FBASES({"+PLAN2"})
     select PL2
     go top
     set console off
     set alternate to qq.
     set alternate on
     do while !eof()
     	if VXS(PL2->CODPROD)
				n := ascan(aSurt, {|a| a[TAN_CODPROD]=PL2->CODPROD.and.a[TAN_SURTIDOR]==PL2->SURTIDOR} )
        	if n == 0
        		? PL2->FECHA, PL2->TURNO, PL2->CODPROD
        	endif
        endif
     	skip
     enddo
     set alternate to
     set console on
     select TAN


	ELSEIF oX:Cargo[TB_RET] == K_F7
  	nReg := recno()
		if QUEFECHA2( 10, 25 )
  		if INVTANQ( {||.T.} )
  			LST_TAN("STKTANQ")
        endif
     endif
     select TAN
     go nReg

	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO
DBUNLOCKALL()
DBCOMMITALL()

RETURN


***************************************

FUNC ACT_TANQ( nPrdTanq, nSurt, nCant )

***************************************
local n

if nSurt==nil			// compras
  if TAN->(dbseek(nPrdTanq))
     frlock("TAN")
     TAN->STOCKACT += nCant
     TAN->(dbunlock())
	endif
else						// planillas
	n := ascan(aSurt,{|a| a[TAN_CODPROD]==nPrdTanq.and.a[TAN_SURTIDOR]==nSurt})
	if n # 0
  	if TAN->(dbseek(aSurt[n,TAN_NUMTANQ]))
     	frlock("TAN")
     	TAN->STOCKACT += nCant
     	TAN->(dbunlock())
		endif
	endif
endif

return .t.


*******************

FUNC FSURT( nCod, nSurt, nK )

*******************
local aaux := {}, r:=0, i

aeval(aSurt,{|a,i| if(a[TAN_CODPROD]==nCod.and.ascan(aaux,a[TAN_SURTIDOR])==0,aadd(aaux,a[TAN_SURTIDOR]),.f.)} )
if nK == K_TAB
	if len(aaux) # 0
  	r := ele := ascan(aaux,nSurt)
		aeval(aaux,{|a,i| aaux[i]:='Surtidor '+str(a,2)} )
		ele = PP_SELEC( 10, 30, 0, 0, aaux, ele, "", "S", .T.,.T.)
		if LASTKEY() == K_ENTER
			r := val(right(aaux[ele],2))
     else
     	r := -1
		ENDIF
		RECUPAN()
	endif
else
	if nCod#0 .and. nSurt#0 .and. ascan(aaux,nSurt)==0
		MENSAJE( 0, 0, 10, .T., "SURTIDOR INCORRECTO !!!" )
	else
		r := nSurt
  endif
endif

return r


*******************

FUNC FTANQ( nCod, nTanq, nK )

*******************
local aaux := {}, r:=0, i

aeval(aSurt,{|a,i| if(a[TAN_CODPROD]==nCod.and.ascan(aaux,a[TAN_NUMTANQ])==0,aadd(aaux,a[TAN_NUMTANQ]),.f.)} )
if nK == K_TAB
	if len(aaux) # 0
  	r := ele := ascan(aaux,nTanq)
		aeval(aaux,{|a,i| aaux[i]:='Tanque '+str(a,2)} )
		ele = PP_SELEC( 10, 30, 0, 0, aaux, ele, "", "S", .T.,.T.)
		IF LASTKEY() == K_ENTER
			r := val(right(aaux[ele],2))
     else
     	r := -1
		ENDIF
		RECUPAN()
	endif
else
	if nCod#0 .and. nTanq#0 .and. ascan(aaux,nTanq)==0
		MENSAJE( 0, 0, 10, .T., "TANQUE INCORRECTO !!!" )
	else
		r := nTanq
  endif
endif

return r


***********************

FUNC LST_TAN( listado )

***********************
LOCAL nOrder, nReg
#define    lxp		60

bLastErr := ErrorBlock()
bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
begin sequence

	IF listado $ "STKTANQ"
		LISTADOR( "INI" )
		DO ICARGA WITH listado
 		if !SETIMPRESORA("INI");  break(nil);  endif
     select TAN
     GO TOP
     select X
     do while !TAN->(eof())
     	I_COMPRAS := I_VENTAS := I_AJUSTES := nAux := M->STOCKACT := 0
     	dbseek(STR(TAN->NUMTANQ)+STR(TAN->CODPROD)+FTOC(DESDE),.T.)
     	DO WHILE X->NUMTANQ==TAN->NUMTANQ .AND. X->CODPROD==TAN->CODPROD .AND. X->FECHA>=DESDE.AND.X->FECHA<=HASTA.AND.!EOF()
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
           I_COMPRAS += X->COMPRAS
           I_VENTAS  += X->VENTAS
           I_AJUSTES += X->AJUSTES
           M->STOCKACT := X->STOCKACT
           ++nAux
				SKIP
			ENDDO
        if nAux > 0
 				CABEZA( 3 )
 				I_CL += 3
 				? I_esp + ARMOLIN(I_cab)
 				? I_esp + ARMOLIN(I_cab+2)
 				? I_esp + ARMOLIN(I_cab)
				for x=1 to UT_largo-I_CL;  ?;  next
        	I_CL := UT_largo+1
        endif
        SKIP 1 ALIAS TAN
     ENDDO
		LISTADOR( "FIN" )
  ENDIF

end sequence
ErrorBlock(bLastErr)
RECUPAN()
		
RETURN nil


*********************

FUNC INVTANQ( bCond )

*********************
LOCAL cAux:=SAVESCREEN( 0, 0, 24, 79 ), aaux
MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

SELECT TAN
aaux := DBSTRUCT()
aadd( aaux, {"COMPRAS","N",12,4} )
aadd( aaux, {"VENTAS", "N",12,4} )
aadd( aaux, {"AJUSTES","N",12,4} )
aadd( aaux, {"VECES","N",3,0} )

cBaseAux := XNAME('XAUX')
SELECT 99;	DBCLOSEAREA()
DBCREATE( cBaseAux, aaux )
SELECT 99
USE (cBaseAux) ALIAS X EXCLUSIVE
INDEX ON STR(X->NUMTANQ)+STR(X->CODPROD)+FTOC(X->FECHA) TO (cBaseAux)

FBASES({"+PLAN2", "+COMPRAS2", "+AJUSTES"})
select PL2;  set order to forder({"CODPROD","FTOC(PL2->FECHA)"})
select CO2;  set order to forder({"CODPROD","FECHA"})
select AJ;  set order to forder({"CODPROD","FECHA"})

@15,0 SAY " PRODUCTO                               COMPRAS   VENTAS    AJUSTES   STOCK   "
@16,0 SAY "===============================         ========= ========= ========= ========"
SCROLL( 17, 0, 24, 79, -20 )
SELECT TAN
GO TOP
DO WHILE !TAN->(EOF())
	IF EVAL(bCond) .AND. TAN->CODPROD#0
 		@ 24, 0 SAY STR(TAN->NUMTANQ)+STR(TAN->CODPROD)+" "+TAN->DESCPROD

     	*** Compras
     select CO2
  	dbseek( STR(TAN->CODPROD)+FTOC(TAN->FECHA), .T. )
     select X
     DO WHILE CO2->CODPROD==TAN->CODPROD .AND. CO2->FECHA>=TAN->FECHA .AND. CO2->FECHA<=HASTA .and. !CO2->(eof())
     	if CO2->NUMTANQ == TAN->NUMTANQ
  			if !dbseek( STR(CO2->NUMTANQ)+STR(CO2->CODPROD)+FTOC(CO2->FECHA) )
        		append blank
					X->CODPROD := CO2->CODPROD
           	X->NUMTANQ := CO2->NUMTANQ
           	X->FECHA   := CO2->FECHA
  				@ 24,40 SAY CO2->FECHA
        	ENDIF
        	X->COMPRAS += CO2->CANTIDAD
        endif
        SKIP 1 ALIAS CO2
     ENDDO

     	*** Ventas
  	select PL2
  	dbseek( STR(TAN->CODPROD)+FTOC(TAN->FECHA), .T. )
     SELECT X
     DO WHILE PL2->CODPROD==TAN->CODPROD .and. PL2->FECHA>=TAN->FECHA .AND. PL2->FECHA<=HASTA .and. !PL2->(eof())
 			n := ascan(aSurt, {|a| a[TAN_CODPROD]=PL2->CODPROD.and.a[TAN_SURTIDOR]==PL2->SURTIDOR} )
        nTanq := if(n==0,0,aSurt[n,TAN_NUMTANQ])
        if nTanq == TAN->NUMTANQ
  			if !dbseek( STR(nTanq,2)+STR(PL2->CODPROD)+FTOC(PL2->FECHA) )
        		append blank
           	X->CODPROD := PL2->CODPROD
           	X->NUMTANQ := nTanq
           	X->FECHA   := PL2->FECHA
  				@ 24,50 SAY PL2->FECHA
        	endif
        	X->VENTAS += PL2->CANTIDAD
        	X->VECES  += 1
        endif
        SKIP 1 ALIAS PL2
     ENDDO

     	*** Ajustes
  	select AJ
  	dbseek( STR(TAN->CODPROD)+FTOC(TAN->FECHA), .T. )
     SELECT X
     DO WHILE AJ->CODPROD==TAN->CODPROD .AND. AJ->FECHA>=TAN->FECHA .AND. AJ->FECHA<=HASTA .and. !AJ->(eof())
     	if AJ->NUMTANQ == TAN->NUMTANQ
  			if !dbseek( STR(AJ->NUMTANQ)+STR(AJ->CODPROD)+FTOC(AJ->FECHA) )
        		append blank
           	X->CODPROD := AJ->CODPROD
           	X->NUMTANQ := AJ->NUMTANQ
           	X->FECHA   := AJ->FECHA
  				@ 24,60 SAY AJ->FECHA
        	endif
        	X->AJUSTES += AJ->CANTIDAD
        endif
        SKIP 1 ALIAS AJ
     ENDDO

		SELECT X
     dbseek(STR(TAN->NUMTANQ)+STR(TAN->CODPROD),.T.)
     M->STOCKANT := TAN->STOCKINI
     DO WHILE X->NUMTANQ==TAN->NUMTANQ .AND. X->CODPROD==TAN->CODPROD .AND. !EOF()
     	X->STOCKACT := M->STOCKANT + X->COMPRAS - X->VENTAS + X->AJUSTES
     	M->STOCKANT := X->STOCKACT
  		@ 24,70 SAY X->FECHA
        SKIP
     ENDDO

  	SCROLL( 17, 0, 24, 79, 1 )

  ENDIF
  SKIP 1 ALIAS TAN

ENDDO
RECUPAN()
RESTSCREEN( 0, 0, 24, 79, cAux )

RETURN( X->(lastrec())#0 )
