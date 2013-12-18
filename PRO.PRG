local xmenu, xmenu2, K, lastcolor:=SETCOLOR("W/N,N/W"), lastbase,;
	lastreg, aaux
private EDX

#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

LOGO(.T., " PROVEEDORES ")
MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
FBASES({ "PROVEE" }, .F.)
MENUDOWN({	"     º  ENTER   º   F5   º   F6    º   F7    º   TAB   º ESC ",;
				"       º  o  F2   º        º         º         º  elige  º     ",;
				" mueve º modifica º agrega º elimina º imprime º cliente º sale"})
RECUPAN()

select PRV
set order to 1
EDX := NEWEDIT( "PRO" )

do while .t.
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
     if K==K_F5
        EDPONE(EDX,"PRV->CODPROV",ULTIMO(dbf(),"CODPROV",1)+1)
     endif
		DO WHILE .T.
			FEDITAR( EDX, { 9 } )

			IF EDX[ED_UPDATE]
				EDX[ED_MODE] = "MOSTRAR"
				IF EDNOM(EDX) == "PRV->CUIT"
     			xorder := INDEXORD()
					DBSETORDER( FORDER({"CUIT"}) )
        		IF FREPEAT( EDCONT(EDX), EDX[ED_MODAPP] )
        			MENSAJE( 0, 0, 10, .T., "ESTE C.U.I.T. YA FUE REGISTRADO !!!" )
*       			EDPONE( EDX,, EDX[ED_LAST] )
        		ENDIF
     			DBSETORDER( xorder )
     		ENDIF
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
				ELSEIF EDNOM(EDX) $ "PRV->LOCALIDAD PRV->CODPOS"
					IF CP( EDCONT(EDX,"PRV->LOCALIDAD") )
						EDPONE(EDX,"PRV->LOCALIDAD",CP->LOCALIDAD)
						EDPONE(EDX,"PRV->CODPOS",CP->CODPOS)
						EDX[ED_MODE] = "MOSTRARTODO"
					ENDIF
				ELSEIF "CODPLAN" $ EDNOM(EDX) .and. EDX[ED_TECLA]==K_TAB
					IF PC( EDCONT(EDX), .T. )
						EDPONE(EDX,,PC->CODPLAN)
					ENDIF
				ENDIF
				
			ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) )
				IF FEDITOR( EDX, "HUBOCAMBIOS" )
					aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					IF aux == "G"
						IF EMPTY(EDCONT(EDX,"PRV->RAZONSOC"))
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
		ENDIF
		
		
	ELSEIF K == K_ESC
		EXIT
		
	ENDIF
	
enddo
FEDITOR( EDX, "SACAPAN" )
setcolor(lastcolor)

return NIL


*******************

FUNC FPROV( nCual )

*******************
local r:=space(len(PRV->RAZONSOC))
if PRV->(dbseek( nCual ))
	r := PRV->RAZONSOC
endif

return r
