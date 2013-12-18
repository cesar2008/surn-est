#include "INKEY.CH"
#include "SETCURS.CH"
#include "ERROR.CH"

*************

PROC LISTADOR( listado, param2 )

*************
local cAux, nReg
local bErr

IF listado # "FIN"
	SEMAFORO("OFF")
	PUBLIC block, UT_largo, I_ancho, I_cab, I_seteo, I_esp, I_largo, lVertxt, I_pie
	PUBLIC I_NH      := 0
	PUBLIC I_INI     := .T.
	PUBLIC I_prihoja := .T.
	PUBLIC I_CL      := UT_largo + 1
	PUBLIC I_LMAS    := 0
	PUBLIC I_IMPRIMIO := .F.
	PUBLIC I_CIERRE := .T.
	I_errores := 3
	IF listado == "INI"
		RETURN
	ENDIF
ENDIF

IF listado # "FIN"
bLastErr := ErrorBlock()
bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
begin sequence
	DO CASE

	CASE listado = "PLA"
  	nReg := recno()
		nLargo := 41
		DO ICARGA WITH listado
 		if !SETIMPRESORA("INI");  break(nil);  endif
		SET DEVICE TO SCREEN
		SET PRINT OFF
		SET PRINTER TO
		SET CONSOLE ON
  	SET ALTERNATE TO LISTADO.TXT
 		SET ALTERNATE ON
		SET CONSOLE OFF
		GO TOP
     I_NH := PL->NUMPLA-1
     I_esp := space(10)
     I_seteo := ""
		for n=1 to I_cab;  ? I_esp+ARMOLIN(n);  next
     I_CL := 0
     nAPAGAR := nEFECTIVO := nCHEQUE := 0
		DO WHILE !EOF()
     	IF PA->NUMPLA # 0
           IF I_CL > nLargo
           	?
     			++I_NH
					for n=I_pie to len(LI);  ? I_esp+ARMOLIN(n);  next
     			nAPAGAR := nEFECTIVO := nCHEQUE := 0
           ENDIF
           select CH
           aaux := {}
           dbseek( str(PA->CODSEG)+str(PA->CODCLI)+str(PA->NUMCUOTA) )
           do while CH->CODSEG==PA->CODSEG.and.CH->CODCLI==PA->CODCLI.and.CH->NUMCUOTA==PA->NUMCUOTA.and.!eof()
           	aadd( aaux, {trans(CH->IMPORTE,"@Z #####.##"),CH->CODBAN, if(empty(CH->FECHA),"",dtoc(CH->FECHA))} )
              skip
           enddo
           if len(aaux)==0;  aaux := {{"","",""}};  endif
           select PA
				? I_esp + ARMOLIN(I_cab+1)
				++I_CL
           for n=2 to len(aaux)
					? I_esp + ARMOLIN(I_cab+3)
					++I_CL
           next
     		nAPAGAR   += PA->APAGAR
				nEFECTIVO += PA->EFECTIVO
				nCHEQUE   += PA->CHEQUE
        ENDIF
			SKIP
		ENDDO
     ++I_NH
     for n=I_CL TO nLargo;  ? I_esp+ARMOLIN(I_cab+2);  next
		for n=I_pie to len(LI);  ? I_esp+ARMOLIN(n);  next
		I_CL := UT_largo+1
     I_imprimio := .T.
     go nReg
 		SET ALTERNATE OFF
  	SET ALTERNATE TO
		SET CONSOLE OFF
     RECUPAN()


	CASE listado == "VENCIDAS"
 		DO ICARGA WITH listado
		if !SETIMPRESORA("INI");  break(nil);  endif
     select PA
     SET ORDER TO FORDER({"FECHVENC"})
     go top
     locate for empty(PA->FECHA) while PA->FECHVENC<=DATE()
     if found()
			nCANTIDAD := 0
        set relation to PA->CODCLI into CLI
    		DO WHILE PA->FECHVENC<=date() .AND. !EOF()
     		IF empty(PA->FECHA)
					CABEZA( 1 )
					I_CL += 1
					? I_esp + ARMOLIN(I_cab+1)
					++nCANTIDAD
        	ENDIF
				SKIP
     	ENDDO
 			CABEZA( 2 )
 			I_CL += 2
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+2)
     	RECUPAN()
     endif
     SET ORDER TO 1


	CASE listado == "VENCASUC"
     if QUEFECHA2()
 			DO ICARGA WITH listado
			if !SETIMPRESORA("INI");  break(nil);  endif
     	select PA
        SET ORDER TO FORDER({"FECHVENC"})
			nCANTIDAD := 0
        dbseek(dtos(DESDE),.T.)
        set relation to PA->CODCLI into CLI
    		locate for PA->FECHVENC>=DESDE .AND. PA->FECHVENC<=HASTA rest
        if found()
    			DO WHILE PA->FECHVENC>=DESDE .AND. PA->FECHVENC<=HASTA .AND. !EOF()
     			IF empty(PA->FECHA)
						CABEZA( 1 )
						I_CL += 1
						? I_esp + ARMOLIN(I_cab+1)
						++nCANTIDAD
        		ENDIF
					SKIP
     		ENDDO
 				CABEZA( 2 )
 				I_CL += 2
				? I_esp + ARMOLIN(I_cab)
				? I_esp + ARMOLIN(I_cab+2)
    			SET ORDER TO 1
     		RECUPAN()
        endif
     endif


	CASE listado == "CLI"
		op2 = MENUFLASH( 10, 35, 1, .T., "", "ORDEN NUMERICO ","ORDEN ALFABETICO " )
     if lastkey() == K_ENTER
     	if op2==1
        	set order to forder({"CODCLI"})
        else
        	set order to forder({"APENOM"})
        endif
        GO TOP
 			DO ICARGA WITH listado
			if !SETIMPRESORA("INI");  break(nil);  endif
			nCANTIDAD := 0
     	SELECT CLI
			GO TOP
    		DO WHILE !EOF()
     		IF !empty(CLI->APENOM)
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
					++nCANTIDAD
        	ENDIF
				SKIP
     	ENDDO
 			CABEZA( 2 )
 			I_CL += 2
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+2)
     	RECUPAN()
     endif

	ENDCASE
	break(nil)

end sequence
ErrorBlock(bLastErr)
IF I_errores < 1
	RECUPAN()
ENDIF
ENDIF
if I_IMPRIMIO
	FOR i=I_CL TO UT_largo
		?
	NEXT i
	?? CHR(27)+"@"
	SETIMPRESORA("FIN")
	RELEASE ALL LIKE I_*
	TONE(1000, 1)
	CLEARTYPEAHEAD()
	DBCOMMITALL()
	IF EST->SALIDA # "IMP"
		cAux:=SAVESCREEN(0,0,24,79)
*		RUN ..\VERTXT LISTADO.TXT
 		TXT("LISTADO.TXT")
		RESTSCREEN(0,0,24,79,cAux)
	ENDIF
	if listado == "PLA" .and. EST->SALIDA=="IMP"
		MENSAJE(99, 99, 0, .F., "presione P para detener la Impresi¢n.")
*		RUN SIDEWAYS LISTADO.TXT >NUL
		SAVE ALL LIKE UT_* TO SIDEWAYS.BAK
     QUIT
	endif
endif
SEMAFORO( "ON" )

RETURN



***********

FUNC CABEZA

***********
PARAMETERS mas

IF I_CL + mas < UT_largo - IF( I_prihoja, 2, 3 )
	RETURN .T.
ENDIF
IF !I_INI
	?? CHR(10)
	FOR x = 1 TO UT_largo-I_CL
		?
	NEXT x
ENDIF
I_NH = I_NH + 1
I_prihoja = IF( I_INI, .T., .F. )
? I_seteo
?? I_esp + LEFT(ARMOLIN(1), I_ancho)
FOR n = 2 TO I_cab
	? I_esp + LEFT(ARMOLIN(n), I_ancho)
NEXT n
I_IMPRIMIO := .T.
I_CL = I_cab + IF( I_INI, 1, 0 )
I_INI = .F.

RETURN .T.



**********

FUNC SALIR

**********

K = INKEY()
IF K = 27
	RETURN .T.
ENDIF

RETURN .F.


***********

PROC ICARGA

***********
PARAMETERS archivo
PRIVATE na, buffer, x, bytes

arch = ALLTRIM(LEFT(archivo, 8) ) + ".PRN"
na = FOPEN( arch )

block = 20
buffer = SPACE(block)
FSEEK(na, 0)
bytes = FREAD( na, @buffer, block )
PUBLIC MACRO[ VAL(buffer) ], NMACRO[ VAL(buffer) ]
AFILL(MACRO, "")
AFILL(NMACRO, 0)

bytes = FREAD( na, @buffer, block )
PUBLIC LI[ VAL(buffer) ]
AFILL(LI, "")

bytes = FREAD( na, @buffer, block )
I_largo = VAL(buffer)

bytes = FREAD( na, @buffer, block )
block = VAL(buffer)

buffer = SPACE(block)
FOR x = 1 TO LEN(MACRO)
	bytes = FREAD( na, @buffer, block )
	MACRO[x] = RTRIM(SUBSTR(buffer, 3, RAT("³", buffer)-4))
	NMACRO[x] = VAL(buffer)
NEXT x
I_cab := I_pie := 0
FOR x = 1 TO LEN(LI)
	bytes = FREAD( na, @buffer, block )
	LI[x] = LEFT(buffer, RAT("³", buffer)-1)
	IF "" $ buffer
		I_cab = x
		i := AT('',LI[x])
		LI[x] = STUFF(LI[x], i, 1, substr(LI[x],i+1,1))
	ENDIF
	IF "" $ buffer
		I_pie = x
		i := AT('',LI[x])
		LI[x] = STUFF(LI[x], i, 1, substr(LI[x],i+1,1))
	ENDIF
NEXT x
FCLOSE(na)

block = LEN(LI[1])
IF block > 137
	I_ancho = 160
	I_seteo = CHR(27) + CHR(77) + CHR(15)
ELSEIF block > 80
	I_ancho = 137
	I_seteo = CHR(15)
ELSE
	I_ancho = 80
	I_seteo = CHR(18)
ENDIF
I_esp = SPACE((I_ancho - block) / 2)

RETURN


************

FUNC ARMOLIN

************
PARAMETERS cual
PRIVATE xx, I, r1, r2

xx = ASCAN(NMACRO, cual)
IF xx < 1
	RETURN RTRIM( LI[cual] )
ENDIF
I = LI[cual]
DO WHILE NMACRO[xx] = cual
	r1  = AT("þ", I)
	r2 = AT("º", I) - r1 + 1
	otro = MACRO[xx]
	otro = LEFT(&otro+SPACE(100), r2)
	I = STUFF(I, r1, r2, otro)
	xx = xx + 1
	IF xx > LEN(MACRO)
		EXIT
	ENDIF
ENDDO

RETURN RTRIM( I )


****************

FUNC PRINT_ERROR( eObj )

****************
local cPantalla

if eObj:GenCode == EG_PRINT
	SETIMPRESORA("FIN")
	SAVE SCREEN TO cPantalla
	CLEAR
	MENSAJE(0, 0, 10, .T., " LA IMPRESORA NO RECIBE DATOS...")
	CLEARTYPEAHEAD()
	RESTORE SCREEN FROM cPantalla
ELSE
	r := ERRORSYS(eObj)
	return .T.
endif

if --I_errores > 0
	return .T.
else
  break(nil)
	return .F.
endif


***********************************

FUNC SETIMPRESORA( cModo, listado )

***********************************
local archivo, xSal, cAux

IF cModo == "INI"
	op2 = IF(EST->SALIDA="IMP",1,2)
	op2 = MENUFLASH( 10, 30, op2, .T., "", "IMPRESORA", "PANTALLA" )
	IF LASTKEY() == K_ENTER
		cAux := IF( op2==1, "IMP", "PAN" )
		IF EST->SALIDA # cAux
  		FRLOCK("EST")
			EST->SALIDA	:= cAux
     	DBUNLOCKALL()
  	ENDIF
  ELSE
  	RETURN .F.
  ENDIF
ENDIF

IF EST->SALIDA == "IMP"
	xSal := IF( "LPT"$EST->IMPRESORA.OR."COM"$EST->IMPRESORA, EST->IMPRESORA, "LPT1" )
ELSE
* xSal := XNAME("XLIS")+".TXT"
  xSal := "LISTADO.TXT"
ENDIF
IF cModo == "INI"
	MENSAJE(30, 80, 0, .F., " IMPRIMIENDO . . . ")
  SET PRINTER TO (xSal)
	SET DEVICE TO PRINTER
	SET PRINT ON
	SET CONSOLE OFF
ELSEIF cModo == "ON"
	SET DEVICE TO PRINTER
	SET PRINT ON
	SET CONSOLE OFF
ELSEIF cModo == "OFF"
	SET DEVICE TO SCREEN
	SET PRINT OFF
	SET PRINTER TO
	SET CONSOLE ON
ELSEIF cModo == "FIN"
	SET DEVICE TO SCREEN
	SET PRINT OFF
	SET PRINTER TO
	SET CONSOLE ON
ENDIF

RETURN .T.
