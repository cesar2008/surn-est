LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " CHEQUES EN CARTERA " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
aCpo:={{ "FECHEMI",    "Fecha;Emisi¢n",           '', 'F',  '',  0, 0 },;
		  { "TURNO",      "T",                       '', 'F',  '',  0, 0 },;
		  { "CODBAN",     "Banco; ",                 '', 'F',  '',  0, 0 },;
		  { "NUMCHEQ",    "N§de;Cheque",             '', 'F',  '',  0, 0 },;
		  { "MONTO",      "Monto; ",                 '', 'F',  '',  0, 0 },;
		  { "FECHCOB",    "Fecha;Cobro",             '', 'F',  '',  0, 0 },;
		  { "CODCLI",     "C¢d.;Cli",                '', 'F',  '',  0, 0 },;
		  { "ESTADO",     "Est",                     '', 'F',  '',  0, 0 },;
		  { "NUMREC",     "N§;Recibo",               '', 'F',  '',  0, 0 },;
		  { "FECHSALIDA",  "Fecha;Salida",            '','F',  '',  0, 0 },;
		  { "CODPROV",    "C¢d;Prov",                '', 'F',  '',  0, 0 },;
		  { "CONCEPTO",   "Concepto; ",              '', 'F',  '',  0, 0 },;
		  { "FECHCIERRE", "Fecha;Cierre",            '', 'F',  '',  0, 0 } }

FBASES({ "CHEQCAR","CLA","PROVEE"})
select CHC
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
set order to 1
set order to FORDER({"FECHEMI"})
dbgobottom()
DO CARGAVEC WITH "BANCO", 99
ACHE := NEWEDIT( "CHEQCAR", .F., .F. )
RECUPAN()

MENUDOWN({"  <+>  º F2 modif. º   F5   º    F6   º  ESC   ",;
			  "       º F3 busca  º        º         º        ",;
			  " mueve º F4 busca+ º agrega º elimina º  sale  "})

SETCOLOR(C_MENU)

PRIVATE oX := MYBROWSE( 5, 1, 19, 78, aCpo )

oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "CHEQCAR", OX, aedits )
TBCOLOR(OX)


DO WHILE .T.
	
	MOVBROW( oX, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_F7.OR.nK==K_ESC.OR.nK==K_SH_F6.OR.nK==K_ALT_E} )
	
  xreg := RECNO()
	IF oX:Cargo[TB_MSGE] == "MODIF" .AND. EMPTY(CHC->FECHCIERRE)
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB .AND. EMPTY(CHC->FECHCIERRE)
		IF TBNOC(OX) == "BANCO"
			e = ABRW( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 'vbanco', CHC->BANCO, 'BANCOS')
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->BANCO := LEFT( vbanco[e], 3 )
			ENDIF
		ELSEIF TBNOC(OX) == "CODCLI"
			IF FELEGIR( "CLI", CHC->CODCLI ) # 0
				FRLOCK()
				CHC->CODCLI   := CL->CODCLI
				CHC->CONCEPTO := CL->RAZONSOC
           DBUNLOCK()
			ENDIF
		ELSEIF TBNOC(OX) == "CODCLI"
			IF FELEGIR( "CLIENTE", CHC->CODCLI ) # 0
				FRLOCK()
				CHC->CODCLI   := CLA->CODCLI
				CHC->CONCEPTO := CLA->RAZONSOC
           DBUNLOCK()
			ENDIF
		ELSEIF TBNOC(OX) == "TURNO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aturno, CHC->TURNO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->TURNO := LEFT(aturno[e],1)
			ENDIF
			RECUPAN()
		ELSEIF TBNOC(OX) == "ESTADO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aestado, FIELD->ESTADO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->ESTADO := LEFT(aestado[e],3)
			ENDIF
			RECUPAN()
		ELSEIF TBNOC(OX) == "CODEMP"
			IF FELEGIR( "EMPLEADO", CHC->CODEMP ) # 0
				FRLOCK()
				FIELD->&(TBNOC(OX)) := EM->CODEMP
			ENDIF
		ENDIF
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F2 .OR. oX:Cargo[TB_RET] == K_F5
		FEDITOR( ACHE,"PONEPAN")
  	IF FEDCHC( ACHE, oX:Cargo[TB_RET] )
     	TBPOS(OX,.T.)
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F6
		if FIELD->CODCLI#0
			IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     		xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
				BLANKREG(.T.)
				TBPOS(OX,.T.)
			ENDIF
     else
			MENSAJE( 0, 0, 10, .T., "EL CHEQUE DEBE ESTAR EN CARTERA !" )
     endif
	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
		if FIELD->CODCLI#0
     	xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
			BLANKREG(.T.)
			TBPOS(OX,.T.)
     else
			MENSAJE( 0, 0, 10, .T., "EL CHEQUE DEBE ESTAR EN CARTERA !" )
     endif
	ELSEIF oX:Cargo[TB_RET] == K_F7
		op = MENUFLASH( 10, 30, 1, .T., "", "CHEQUES EN CARTERA" )
		IF op == 1
			LISTAR( "CHEQCAR" )
		ENDIF
		
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "CHEQCAR", OX, aedits, "EDITS.EST" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN


*********************

FUNC FEDCHC( ACHE, K )

*********************
LOCAL r:=.F., xmenu

xmenu:=MENUDOWN({"     º PgUp PgDown º presione TAB para obtener una º  F10   º ESC  ",;
                 "       º             º lista de opciones. (solo fun- º graba  º      ",;
                 " mueve º    mueve+   º ciona en los campos con  ).  º y sale º sale "})

FEDITOR( ACHE, "SETVARS", K, .F. )
if K==K_F5
	if ascan(aestado,{|a,i| left(a,3)==EDCONT(ACHE,"CHC->ESTADO")})==0
		EDPONE(ACHE,"CHC->ESTADO","CAR")
	endif
	if empty(EDCONT(ACHE,"CHC->FECHEMI"))
		EDPONE(ACHE,"CHC->FECHEMI",VA->FECHA)
		if empty(EDCONT(ACHE,"CHC->FECHEMI"))
			EDPONE(ACHE,"CHC->FECHEMI",VA->FECHA)
  	endif
	endif
	ACHE[ED_EDIT] := upper( ACHE[ED_EDIT] )
else
	ACHE[ED_EDIT] := lower( ACHE[ED_EDIT] )
endif
if EDCONT(ACHE,"CHC->ESTADO")#"CAR"
	ACHE[ED_EDIT] := lower( ACHE[ED_EDIT] )
endif
ACHE[ED_MODE] := "MOSTRARTODO"
DO WHILE .T.
	
	FEDITAR( ACHE, { K_TAB, K_F10 } )
	
	IF ACHE[ED_UPDATE]
		ACHE[ED_MODE] = "MOSTRAR"
		IF EDNOM(ACHE) $ "CHC->FECHEMI CHC->FECHEMI"
     	IF !empty(EDCONT(ACHE,"CHC->FECHEMI")) .and. (EDCONT(ACHE,"CHC->FECHEMI")>EDCONT(ACHE,"CHC->FECHEMI") .or. EDCONT(ACHE,"CHC->FECHEMI")<EDCONT(ACHE,"CHC->FECHEMI"))
				MENSAJE( 0, 0, 10, .T., "LA FECHA DE COBRO DEBE SER","MAYOR A LA DE EMISION !!!" )
        	EDPONE(ACHE,,ACHE[ED_LAST])
           ACHE[ED_TECLA]:=0
        endif
     ENDIF
	ELSEIF ACHE[ED_TECLA] == K_TAB
		ACHE[ED_MODE] = "MOSTRAR"
		IF EDNOM(ACHE) == "CHC->CODBAN"
			e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbanco', EDCONT(ACHE), 'BANCOS')
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT( vbanco[e], 3 ))
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->CODCLI"
			IF FELEGIR( "CLIENTE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,CL->(RECNO()))
				EDPONE( ACHE, "CHC->CHEQUDE", CL->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->CODPROV"
			IF FELEGIR( "PROV", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,PRV->(RECNO()))
				EDPONE( ACHE, "CHC->CHEQUEPARA", PRV->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->TURNO"
			e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, aturno, EDCONT(ACHE), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT(aturno[e],1))
			ENDIF
			RECUPAN()
		ELSEIF EDNOM(ACHE) == "CHC->CODEMP"
			IF FELEGIR( "EMPLEADO", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,EM->CODEMP)
			ENDIF
		ENDIF
	ELSEIF ACHE[ED_TECLA]==K_ESC .OR. ACHE[ED_TECLA]==K_F10
		r := .F.
     cAux := "S"
		IF ACHE[ED_TECLA]==K_F10
     	cAux := "G"
		ELSEIF FEDITOR( ACHE, "HUBOCAMBIOS" )
			cAux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
     ENDIF
		IF cAux =="G"
     	if "AGRE"$ACHE[ED_MODAPP]
				F_ALTA( {||!empty(CHC->FECHEMI)} )
        endif
        ACHE[ED_REGISTRO]:=recno()
			FEDITOR( ACHE, "GRABAR", .F. )
     	if empty(CHC->ID_CHE);  FRLOCK();CHC->ID_CHE:="CHC"+F_ID();DBUNLOCK();  endif
			r := .T.
			EXIT
		ELSEIF cAux == "S"
			EXIT
		ENDIF
	ENDIF
	DBUNLOCK()
ENDDO
PONEPAN(xmenu)
FEDITOR( ACHE,"SACAPAN")

RETURN r
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nReg, nOrder, cBaseAux

if listado == "CHEQCAR"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	DO ICARGA WITH listado
  select 99; dbclosearea()
	select CHC
  nReg := RECNO()
  nOrder := INDEXORD()
  dbsetorder( FORDER({"CHC->ESTADO"}) )
  if dbseek("CAR",.T.)
		cBaseAux := XNAME("XAUX")
     copy to (cBaseAux) while ESTADO=="CAR"
		select 99
		use (cBaseAux) alias X
		index on FTOC(X->FECHCOB) to (cBaseAux)
		I_TOTAL := 0
		do while !eof() .and. !salir()
			CABEZA( 1 )
			++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			I_TOTAL += X->MONTO
			skip
		enddo
		CABEZA( 1 )
		++I_CL
		?  I_esp + ARMOLIN(I_cab+2)
	endif
  select CHC
  dbsetorder( nOrder )
  dbgoto( nReg )
	RECUPAN()
	I_IMPRIMIO := .T.
	LISTADOR( "FIN" )
endif

return
