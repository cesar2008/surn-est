LOCAL aCpo, oCHE, xreg, lmenu		//, xbase:=DBF()

#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "TB.CH"

aCpo:={{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
		  { "BANCO",      "Banco",                              '', 'M',  '',  0, 0 },;
		  { "NUMCHEQUE",  "N§;Cheque",                          '', 'M',  '',  0, 0 },;
		  { "CHEQUEPARA", "Concepto",                           '', 'M',  '',  0, 0 },;
 		  { "MONTO",      "Monto",                              '', 'M',  '',  0, 0 },;
 		  { "ESTADO",     "Estado; ",                           '', 'F',  '',  0, 0 },;
 		  { "CODPROV",    "C¢d;Prov",                           '', 'F',  '',  0, 0 },;
 		  { "FECHCC",     "Fecha;Cheque",                       '', 'F',  '',  0, 0 }}


FBASES({ "CHEQUEST" })
SELECT CHC
aCpo := FBASEAUX( aCpo, "CH", SELECT(), .F. )
DBGOBOTTOM()

lmenu:=MENUDOWN({" <+>   º F2 modif. º   F5   º   F6    º  ESC   ",;
	               "       º F3 busca  º        º         º        ",;
	               " mueve º F4 busca+ º agrega º elimina º  sale  "})
	
SETCOLOR( "W/N,N/W" )

MARCO( 7, 5, 19, 78, "{ CHEQUES }", "S", .T., 0 )
oCHE := MYBROWSE( 7, 5, 19, 78, aCpo )

oCHE:CARGO[TB_REFRESH] := 0
oCHE:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "CHEQUEST", oCHE, aedits )
TBCOLOR(oCHE)


DO WHILE .T.

	MOVBROW( oCHE, {||nK==9.OR.nK==-4.OR.nK==27.OR.nK==-9.OR.nK==K_ALT_E}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )

  IF oCHE:Cargo[TB_MSGE] == "MODIF"
  	FRLOCK()
    	FIELD->&(oCHE:CARGO[TB_NOMBRE,oCHE:ColPos]) := oCHE:CARGO[TB_CONT]
     UNLOCK
     oCHE:RefreshCurrent()
  ELSEIF oCHE:Cargo[TB_RET] == K_F5
  	SET ORDER TO FORDER({"FTOC(CHC->FECHA)"})
     DBGOBOTTOM()
     aux := CHC->FECHA
		F_ALTA( FTOC(CTOD('')) )
     FRLOCK()
     CHC->FECHA := aux
     CHC->ESTADO := "CHE"
     aux:=RECNO()
		oCHE:PANHOME()
     oCHE:GOBOTTOM()
  	oCHE:RefreshAll()
     GO aux
	ELSEIF oCHE:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "CHEQUEST", oCHE, aedits, "EDITS.EST" )
  ELSEIF oCHE:Cargo[TB_RET] == K_ESC
		EXIT
  ENDIF
ENDDO
DBUNLOCKALL()
DBCOMMITALL()

RECUPAN()
PONEPAN( lmenu )
*DBSELECTAREA( xbase )

RETURN .T.



*********************

FUNC FEDCHEC( ACHE, K, _fc )

*********************
LOCAL r := .F., xmenu

xmenu:=MENUDOWN({"     º PgUp PgDown º presione TAB para obtener una º   ESC    ",;
						"       º             º lista de opciones. (solo fun- º          ",;
						" mueve º    mueve+   º ciona en los campos con  ).  º   sale   "})

ACHE[ED_EDIT] := UPPER( ACHE[ED_EDIT] )
IF K == K_F2 .OR. K == K_ENTER
	IF !EMPTY(_fc)
		ACHE[ED_EDIT] := LOWER( ACHE[ED_EDIT] )
	ENDIF
ELSEIF K==K_F5
	IF EMPTY(_fc)
		EDPONE(ACHE,"CHC->FECHPAGO",VA->FECHA)
  ENDIF
ENDIF
ACHE[ED_MODE] := "MOSTRARTODO"
DO WHILE .T.
	
	FEDITAR( ACHE, { 9 } )
	
	IF ACHE[ED_UPDATE]
		ACHE[ED_MODE] = "MOSTRAR"
	ELSEIF ACHE[ED_TECLA] == K_TAB
		ACHE[ED_MODE] = "MOSTRAR"
		IF EDNOM(ACHE) == "CHC->BANCO"
			e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbancocta', EDCONT(ACHE), 'BANCOS')
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT( vbancocta[e], 3 ))
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->CODCLI"
			IF FELEGIR( "CLIENTE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,CL->(RECNO()))
				EDPONE( ACHE, "CHC->CHEQUDE", CL->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->CODPROV"
			IF FELEGIR( "PROVEE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,PRV->(RECNO()))
				EDPONE( ACHE, "CHC->CHEQUEPARA", PRV->PROVEEDOR )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->TIPO"
			e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, atipo, EDCONT(ACHE), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT(atipo[e],1))
			ENDIF
			RECUPAN()
		ELSEIF EDNOM(ACHE) == "CHC->CODEMP"
			IF FELEGIR( "EMPLEADO", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,EM->CODEMP)
			ENDIF
		ENDIF
		
	ELSEIF ACHE[ED_TECLA] == K_ESC .OR. ( ACHE[ED_TECLA]==K_ENTER .AND. ACHE[ED_I]==LEN(ACHE[ED_FIELDS]) )
  	r := .F.
		IF FEDITOR( ACHE, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
			IF aux =="G"
				FEDITOR( ACHE, "GRABAR", .F. )
           r := .T.
           EXIT
			ELSEIF aux == "S"
				EXIT
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDIF
	
ENDDO
PONEPAN(xmenu)

RETURN r
