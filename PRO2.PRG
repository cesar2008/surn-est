LOCAL xmenu, xmenu2, K, lastcolor:=SETCOLOR("W/N,N/W"), lastbase,;
	lastreg, aaux
PRIVATE EDX

#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

LOGO(.T., " PROVEEDORES ")
MENSAJE( 0, 0, 0, .F., "AGUARDE . . " )
PROCESO := PROCNAME()
FBASES({ "PROVEE" }, .F.)
MENUDOWN({	"     º  ENTER   º   F5   º   F6    º   F7    º   TAB   º ESC ",;
				"       º  o  F2   º        º         º         º  elige  º     ",;
				" mueve º modifica º agrega º elimina º imprime º cliente º sale"})
RECUPAN()

SELECT PR
SET ORDER TO 1
EDX := NEWEDIT( "PRO" )

DO WHILE .T.
	
	k := FVERREG( EDX, {|K|K==9.OR.K==-4.OR.K==-5.OR.K==K_F7} )
	
	IF k == K_TAB
		SETCOLOR("W/N,N/W")
		FELEGIR( "PROVEE" )
		
		
	ELSEIF k == K_ENTER .OR. K==K_F2 .OR. k == K_F5
		xmenu:=MENUDOWN({	"     º PgUp PgDown º presione TAB para obtener una º   ESC    ",;
							  	"       º             º lista de opciones. (solo fun- º          ",;
								" mueve º    mueve+   º ciona en los campos con  ).  º   sale   "})
		FEDITOR( EDX, "SETVARS", K )
		EDX[ED_MODE] := "MOSTRARTODO"
     IF EDCONT(EDX,"PRV->CODPROV") == 0
     	EDPONE(EDX,"PRV->CODPROV",ULTIMO(dbf(),"CODPROV",1)+1)
     ENDIF
		DO WHILE .T.
			
			FEDITAR( EDX, { 9 } )
			
			IF EDX[ED_UPDATE]
				EDX[ED_MODE] = "MOSTRAR"
			ELSEIF EDX[ED_TECLA] == K_TAB
				EDX[ED_MODE] = "MOSTRAR"
				IF EDNOM(EDX) == "PRV->CATIVA"
					ele = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, acativa, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(acativa[ele],3))
					ENDIF
					RECUPAN()
				ELSEIF EDNOM(EDX) == "PRV->BANCO"
					ele = ABRW( EDX[ED_Y], EDX[ED_X], 0, 'vbanco', EDCONT(EDX), 'BANCOS')
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(vbanco[ele],3))
					ENDIF
				ELSEIF EDNOM(EDX) == "PRV->NUMCORR"
					ele = ABRW( EDX[ED_Y], EDX[ED_X], 0, 'vcorredor', EDCONT(EDX), 'CORREDOR')
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,ele)
					ENDIF
				ENDIF
				
			ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) )
				IF FEDITOR( EDX, "HUBOCAMBIOS" )
					aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					IF aux == "G"
						IF EMPTY(EDCONT(EDX,"PRV->PROVEEDOR"))
							MENSAJE( 0, 0, 10, .T., " DATOS INCOMPLETOS !!!" )
						ELSE
							FEDITOR( EDX, "GRABAR", .F. )
							EXIT
						ENDIF
					ELSEIF aux == "S"
						EXIT
					ENDIF
				ELSE
					EXIT
				ENDIF
			ENDIF
		ENDDO
		PONEPAN(xmenu)
		
	ELSEIF K == K_F7
  	LISTADOR("PROVEE")
		
	ELSEIF K == K_F6
		IF PREGUNTA( 12, "¨ ESTAS SEGURO DE ELIMINARLO  [ S / N ]", "SsNn") $ "Ss"
			BLANKREG(.T.)
			DBGOTOP()
			RECUPAN()
		ENDIF
		
		
	ELSEIF K == K_ESC
		EXIT
		
	ENDIF
	
ENDDO
FEDITOR( EDX, "SACAPAN" )

SETCOLOR(lastcolor)

RETURN NIL


************

FUNC FPROVEE

************
PARAMETERS nCualCod, lConRee
local cBase:=dbf(), r, i
PRIVATE campo

DEFAULT lConRee TO .F.
lastbase = DBF()
SELECT PR
set order to 1
IF !dbseek( nCualCod )
	IF lConRee
		FOR i=1 TO FCOUNT()
			campo = FIELD(i)
			M->&campo := CAMPOVACIO( FIELD(i) )
		NEXT i
	ENDIF
	r = SPACE(LEN(PRV->PROVEEDOR))
ELSE
	IF lConRee
		FOR i=1 TO FCOUNT()
			campo = FIELD(i)
			M->&campo = PRV->&campo
		NEXT i
	ENDIF
	r = PRV->PROVEEDOR
ENDIF
select(cBase)

RETURN r
