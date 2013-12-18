LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO( .T., " COMPRAS VARIAS " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

aCpo:={;
       { "FECHA",      "Fecha; ",                            '', 'F',  '',  0, 0 },;
		  { "CODPROV",    "C¢d;Prov",                           '', 'F',  '',  0, 0 },;
		  { "RAZONSOC",   "Proveedor; ",                        '', 'F',  '',  0, 0 },;
		  { "CUIT",       "C.U.I.T.; ",                         '', 'F',  '',  0, 0 },;
		  { "CATIVA",     "Cat;IVA",                            '', 'F',  '',  0, 0 },;
		  { "NUMFAC",     "N§;Factura",                         '', 'F',  '',  0, 0 },;
		  { "NETO",       "Neto; ",                             '', 'F',  '',  0, 0 },;
		  { "CREDITO",    "Credito; ",                          '', 'F',  '',  0, 0 },;
		  { "EXENTO",     "Exento; ",                           '', 'F',  '',  0, 0 },;
		  { "IMPINT",     "Imp.;Int.",                          '', 'F',  '',  0, 0 },;
		  { "PERCEPCION", "Perc.;RG 3337",                      '', 'F',  '',  0, 0 },;
		  { "PERCIIBB",   "Percepc.;IIBB",                      '', 'F',  '',  0, 0 },;
		  { "TOTAL",      "Total; ",                            '', 'F',  '',  0, 0 },;
		  { "RETIB",      "Ret.IIBB; ",                         '', 'F',  '',  0, 0 },;
		  { "RETGAN",     "Ret.Gan; ",                          '', 'F',  '',  0, 0 },;
		  { "RETIVA",     "Ret.IVA; ",                          '', 'F',  '',  0, 0 },;
		  { "IMPDEP",     "Importe;deposit.",                   '', 'F',  '',  0, 0 },;
		  { "DESTINO",    "Banco",                              '', 'F',  '',  0, 0 },;
		  { "BA->NOMBANCO","Banco",                 REPLIC('X',20), 'F', 'F', 20, 0 },;
		  { "CODPLAN",    "C¢d;Plan Cta",                       '', 'F',  '',  0, 0 },;
		  { "NUMCAJCH",   "CA;CH",                              '', 'F',  '',  0, 0 }}

FBASES({ "CAJCH", "COMPRASV", "PROVEEV", "GASTOS","GASTOS2", "PLANCTA", "BANCO" })
DO CARGAVEC WITH "GASTO", 50

cRAZONSOC  := PRV->RAZONSOC
cDOMCOM    := PRV->DOMCOM
cCUIT      := PRV->CUIT
cCATIVA    := PRV->CATIVA
cNUMIB     := PRV->NUMIB
cCODPLAN   := PRV->CODPLAN

SELECT CV
SET RELATION TO VAL(DESTINO) INTO BA
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
aCpo[6,ATB_MASC] := "@K "+ aCpo[6,ATB_MASC]

SET ORDER TO 1
DBGOBOTTOM()

MENUDOWN({" <+> ºF2 modif.º %  º  F5  ºF6 / SHIFT F6º   F7  º F11  º F12  º  TAB   ºESC ",;
			  "     ºF3 busca ºtasaº      º             º       ºpasa aºpasa aºProveed,º    ",;
			  "mueveºF4 busca+ºIVA ºagregaºelimina l¡neaºimprimeºgastosºcaj.chºcat.IVA ºsale"})

SETCOLOR( "W/N,N/W" )

PRIVATE oX := MYBROWSE( 5, 1, 19, 78, aCpo )
OX:FREEZE:=3
oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()

aedits := TBCOLEDIT( "SETEAR", "COMV", OX, aedits )
TBCOLOR(OX)


DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==K_F7.OR.nk==-9.OR.nK==K_F11.OR.nK==K_F12.OR.nK==K_SH_F6.OR.nK==K_ALT_E.OR.nK==K_F8.OR.nK==37}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF".OR. OX:CARGO[TB_RET]==37
		if OX:CARGO[TB_RET] == 37
			if TBNOC(OX) $ "NETO TOTAL"
     		nAux:=VA->PIVA1
				nAux := INGRVAL( 10, 40, "% IVA", nAux, "99.99", "")
        	if lastkey()==K_ENTER
        		M->PIVA1 := nAux
        	endif
        else
				MENSAJE( 0, 0, 10, .T., "s¢lo en NETO o TOTAL !!!" )
        endif
     else
     	M->PIVA1 := VA->PIVA1
			FRLOCK()
			FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
     	M->PIVA1 := IF( CV->CATIVA$'RNI EX ', 0, M->PIVA1 )
     	if PRV->(DBSEEK(CV->CODPROV))
     		if PRV->IVA1#0
        		M->PIVA1 := PRV->IVA1
        	endif
     	endif
     endif
		FRLOCK()
		IF TBNOC(OX) == "NETO"
			CV->CREDITO := CV->NETO * M->PIVA1 / 100
		ELSEIF TBNOC(OX) == "TOTAL"
			CV->NETO    := ( CV->TOTAL-CV->EXENTO-CV->IMPINT-CV->PERCEPCION-CV->PERCIIBB ) / ( (M->PIVA1)/100+1 )
			CV->CREDITO := CV->NETO * M->PIVA1 / 100
		ELSEIF TBNOC(OX) == "CODPROV"
     	PROVEEV( oX:CARGO[TB_CONT] )
        FRLOCK()
        CV->RAZONSOC  := cRAZONSOC
			CV->CATIVA    := cCATIVA
        CV->CUIT      := cCUIT
        CV->CODPLAN   := cCODPLAN
		ELSEIF TBNOC(OX) == "NUMFAC"
			CV->NUMFAC := FNUMFACT( CV->NUMFAC )
     ENDIF
     CV->TOTAL := CV->NETO + CV->CREDITO + CV->EXENTO + CV->IMPINT + CV->PERCEPCION +PERCIIBB
     DBUNLOCK()
  	IF CV->NUMCAJCH # 0
     	SELECT CAC
  		GO CV->NUMCAJCH
     	FRLOCK()
     	CAC->FECHA   := CV->FECHA
     	CAC->CODCONC := "FAC"
     	CAC->DETALLE := CV->RAZONSOC
     	CAC->SALIDA  := CV->TOTAL
     	FRLOCK("VA")
     	VA->SALDARCAC := .T.
     	DBUNLOCK()
     	SELECT CV
     ENDIF
		TBPOS(OX)
	ELSEIF OX:CARGO[TB_RET]==K_F8
		MENSAJE( 99, 99, 0, .F., " AGUARDE ... " )
  	nReg := recno()
     go top
     fflock()
     seleCT PRV
     do while ROSCA().and.!CV->(eof())
     	if dbseek(CV->CODPROV)
        	CV->CODPLAN := PRV->CODPLAN
        endif
     	skip 1 alias CV
     enddo
     dbunlockall()
     select CV
     go nReg
     RECUPAN()
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_TAB
		IF TBNOC(OX) == "CATIVA"
			ele = PP_SELEC( OX:CARGO[TB_FILA], OX:CARGO[TB_COL], 0, 0, acativa, oX:CARGO[TB_CONT] , "", "S", .T.)
     	FRLOCK()
			IF LASTKEY() == K_ENTER
				CV->CATIVA := acativa[ele]
			ENDIF
			RECUPAN()
     	M->PIVA1 := IF( CV->CATIVA=='RI ', VA->PIVA1, 0 )
			CV->CREDITO := CV->NETO * M->PIVA1 / 100
     	CV->TOTAL   := CV->NETO + CV->CREDITO + CV->EXENTO + CV->IMPINT + CV->PERCEPCION + CV->PERCIIBB
        DBUNLOCK()
     	TBPOS(OX)
		ELSEIF TBNOC(OX) == "CODPROV"
			IF PROVEEV( CV->CODPROV, .T. )
				FRLOCK()
				FIELD->CODPROV   := PRV->CODPROV
           FIELD->RAZONSOC  := PRV->RAZONSOC
				FIELD->CATIVA    := PRV->CATIVA
           FIELD->CUIT      := PRV->CUIT
           FIELD->CODPLAN   := PRV->CODPLAN
     		M->PIVA1 := IF( CV->CATIVA=='RI ', VA->PIVA1, 0 )
				CV->CREDITO := CV->NETO * M->PIVA1 / 100
     		CV->TOTAL   := CV->NETO + CV->CREDITO + CV->EXENTO + CV->IMPINT + CV->PERCEPCION + CV->PERCIIBB
        	DBUNLOCK()
        ENDIF
		ELSEIF TBNOC(OX) == "DESTINO"
     	IF BAN( 10, 30, VAL(CV->DESTINO) ) # 0
        	FRLOCK()
           CV->DESTINO := STRZERO(BA->(RECNO()),3)
           DBUNLOCK()
			ENDIF
		ENDIF
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F5
		aaux := { CV->FECHA }
		xreg := F_ALTA( FTOC(CTOD(""))+" " )
		FRLOCK()
		CV->FECHA := aaux[1]
     DBGOTO(xreg)
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F11
		ele := ABRW( 10, 40, 0, 'vgasto', 1, 'GASTOS' )
		IF LASTKEY() == K_ENTER
			SELECT GA
     	IF CV->NUMGASTO == 0
     		F_ALTA( FTOC(CTOD(""))+" " )
     	ELSE
     		GO CV->NUMGASTO
     	ENDIF
     	FRLOCK()
     	GA->FECHA      := CV->FECHA
     	GA->CODGAS     := vgasto[ele]
     	GA->DETALLE    := CV->RAZONSOC
     	GA->IMPORTE    := CV->TOTAL
     	GA->NUMCOMPRAV := CAC->NUMCOMPRAV
			DBUNLOCK()
     	SELECT CV
     	FRLOCK()
     	CV->NUMGASTO := GA->(RECNO())
			DBUNLOCK()
        GAS2()
        select CV
     	TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F12
  	SELECT CAC
  	IF CV->NUMCAJCH == 0
        F_ALTA(FTOC(CTOD('')))
     ELSE
  		GO CV->NUMCAJCH
     ENDIF
     FRLOCK()
     CAC->FECHA   := CV->FECHA
     CAC->CODCONC := "FAC"
     CAC->DETALLE := CV->RAZONSOC
     CAC->SALIDA  := CV->TOTAL
     FRLOCK("VA")
     VA->SALDARCAC := .T.
     DBUNLOCK()
     SELECT CV
     FRLOCK()
     CV->NUMCAJCH := CAC->(RECNO())
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == 999
  	SKIP
     IF EOF()
			DBGOBOTTOM()
 			IF FIELD->TOTAL # 0
				aaux := { CV->FECHA }
				xreg := F_ALTA( FTOC(CTOD(""))+" " )
				FRLOCK()
				CV->FECHA := aaux[1]
     		DBGOTO(xreg)
				TBPOS(OX,.T.)
        ENDIF
     ENDIF
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
	ELSEIF oX:Cargo[TB_RET] == K_F7
		op = MENUFLASH( 10, 20, 1, .T., "",  "DETALLE","AGRUPADO X PROVEEDOR" )
     IF op == 1
  		LISTADOR("COMPV")
     ELSEIF op == 2
  		LISTADOR("COMPVAGR")
  	ENDIF

	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "COMV", OX, aedits, "EDITS.EST" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN


*************

FUNC FNUMFACT( cualnum )

*************
PRIVATE c1, c2, n1, n2, i, c
cualnum := ALLTRIM(cualnum)

STORE "" TO c1, n1, n2
i := 1
DO WHILE i <= LEN(cualnum)
	c = SUBSTR( cualnum, i, 1 )
	IF .NOT. c $ "QWERTYUIOPASDFGHJKLZXCVBNM-/ "
		EXIT
	ENDIF
	c1 += c
	++i
ENDDO
DO WHILE i <= LEN(cualnum)
	c = SUBSTR( cualnum, i, 1 )
	IF c $ "-"
		++i
		EXIT
	ENDIF
	n1 += c
	++i
ENDDO
n2 = SUBSTR(cualnum,i)
c1 = LEFT( c1+"   ", 3 )
IF VAL(n2) == 0
	n2 := ALLTRIM(n1)
	n1 := '0000'
ELSE
	n1 := RIGHT( '0000'+ALLTRIM(n1), 4 )
	n2 := ALLTRIM(n2)
ENDIF
i := AT("/",n2)
IF i == 0
	n2 := STR(VAL(n2),8,0)
ELSE
	n2 := LEFT(n2,i-1) +"/"+ ALLTRIM(STR(VAL(SUBSTR(n2,i+1)),8,0))
ENDIF
n2 := RIGHT("00000000"+ALLTRIM(n2),8)
IF ISALPHA(c1)
	c1 := LEFT(c1+"   ",3)
ENDIF
cualnum = c1 + n1 +"-"+ n2
cualnum := JUSTIF( cualnum, 16, ">" )

RETURN cualnum


************

FUNC PROVEEV( nCual, lBrowser )

************
LOCAL cBase:=DBF(), cMenu, aCpo, OPC, r:=.f.
DEFAULT lBrowser TO .F.

SELECT PRV
set order to 1
if nCual # NIL
	r := dbseek( nCual )
endif
if !lBrowser
	if r
		cRAZONSOC  := PRV->RAZONSOC
  	cDOMCOM    := PRV->DOMCOM
  	cCUIT      := PRV->CUIT
  	cCATIVA    := PRV->CATIVA
  	cNUMIB     := PRV->NUMIB
	else
		cRAZONSOC  := space(len(PRV->RAZONSOC))
  	cDOMCOM    := space(len(PRV->DOMCOM))
  	cCUIT      := space(len(PRV->CUIT))
  	cCATIVA    := "   "
  	cNUMIB     := 0
     cCODPLAN   := space(len(PRV->CODPLAN))
  endif
  SELECT (cBase)
 	RETURN(r)
endif
if eof()
	go top
endif

aCpo:={;
	{ "CODPROV",    "C¢digo",                 '', 'F',  '',  0, 0 },;
	{ "RAZONSOC",   "Proveedor",              '', 'E',  '',  0, 0 },;
	{ "CUIT",       "CUIT",                   '', 'E',  '',  0, 0 },;
	{ "CODPLAN",    "C¢d;Plan Cta",           '', 'E',  '',  0, 0 }}
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )

cMenu:=MENUDOWN({"  <+>  º    F2    º   F5   º F3 busca  º ESC  ",;
			  			"       º          º        º           º      ",;
			  			" mueve º modifica º agrega º F4 busca+ º sale "})

SETCOLOR( "N/W+,W/N,N/W" )
MARCO( 8, 20, 18, 78, "³ PLAN DE CUENTAS ³", "S", .T., 0 )
OPR := MYBROWSE( 8, 20, 18, 78, aCpo )
OPR:CARGO[TB_REFRESH] := 10
cBuscar := ""
DO WHILE .T.

	MOVBROW( OPR, {||nK==27.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_ENTER.OR.nK==K_F8} )

	IF OPR:Cargo[TB_MSGE] == "MODIF"
		auxtb := FIELD->&(TBNOC(OPR))
		FRLOCK()
		FIELD->&(TBNOC(OPR)) := OPR:CARGO[TB_CONT]
		TBPOS(OPR,.T.)

	ELSEIF OPR:CARGO[TB_RET]==K_F8
		MENSAJE( 99, 99, 0, .F., " AGUARDE ... " )
  	nReg:=recno()
     select CV
     go top
     fflock()
     seleCT PRV
     set order to forder({"CUIT"})
     do while ROSCA().and.!CV->(eof())
     	if !dbseek(CV->CUIT)
        	add_rec()
           PRV->CODPROV   := ULTIMO(dbf(),"CODPROV",1)+1
           PRV->RAZONSOC  := CV->RAZONSOC
           PRV->CUIT      := CV->CUIT
           PRV->CATIVA    := CV->CATIVA
           if CV->CODPROV # PRV->CODPROV
           	CV->CODPROV := PRV->CODPROV
           endif
        else
           if CV->CODPROV # PRV->CODPROV
           	CV->CODPROV := PRV->CODPROV
           endif
        endif
     	skip 1 alias CV
     enddo
     set order to 1
     seleCT PRV
     dbunlockall()
     RECUPAN()
     TBPOS(OPR,.T.)

	ELSEIF OPR:CARGO[TB_RET]==K_F2 .OR. OPR:CARGO[TB_RET]==K_F5
		xmenu2:=MENUDOWN({"     º presione TAB para º  F10  º  ESC   ",;
								"       º obtener una lista º       º        ",;
								" mueve º de Cat.IVA y Loc. º graba º  sale  "})
		seleCT PRV
		EDX := NEWEDIT( "PROVEEV" )
		FEDITOR( EDX, "SETVARS", OPR:CARGO[TB_RET], .F. )
		IF OPR:CARGO[TB_RET] == K_F5
        EDPONE(EDX,"PRV->CODPROV",ULTIMO(dbf(),"CODPROV",1)+1)
		ELSE
			EDX[ED_REGISTRO] := RECNO()
		ENDIF
		EDX[ED_MODE] = "MOSTRARTODO"

		DO WHILE .T.
			FEDITAR( EDX, { K_F10 } )
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
				EDX[ED_MODE] = "MOSTRARTODO"
				IF EDNOM(EDX) == "PRV->CATIVA"
					ele = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, acativa, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE( EDX, , LEFT(acativa[ele],3) )
					ENDIF
					RECUPAN()
				ELSEIF EDNOM(EDX) == "PRV->CODLOC"
					ele = ABRW( 5, 10, 0, 'vlocalid', EDCONT(EDX), 'LOCALIDADES')
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,ele)
					ENDIF
				ELSEIF EDNOM(EDX) $ "PRV->LOCALIDAD PRV->CODPOS"
					IF CP( EDCONT(EDX,"PRV->LOCALIDAD") )
						EDPONE(EDX,"PRV->LOCALIDAD",CP->LOCALIDAD)
						EDPONE(EDX,"PRV->CODPOS",CP->CODPOS)
						EDX[ED_MODE] = "MOSTRARTODO"
					ENDIF
				ELSEIF EDNOM(EDX) == "PRV->CODPLAN"
					IF PC( EDCONT(EDX), .T. )
						EDPONE(EDX,,PC->CODPLAN)
					ENDIF
				ENDIF
			ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==len(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
  			aux := "S"
				IF EDX[ED_TECLA] == K_F10
     			aux := "G"
				ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
					aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
     		ENDIF
				IF aux == "G"
					IF EMPTY(EDCONT(EDX,"PRV->RAZONSOC"))
						MENSAJE( 0, 0, 10, .T., " FALTA EL NOMBRE DEL PROVEEDOR !!!" )
					ELSEIF !EDCONT(EDX,"PRV->CATIVA") $ "CF RI RNI EX "
						MENSAJE( 0, 0, 10, .T., "CATEGORIA DE IVA INCORRECTA !!!" )
					ELSEIF VAL(EDCONT(EDX,"PRV->CUIT")) == 0
						MENSAJE( 0, 0, 10, .T., "C.U.I.T. INCORRECTO !!!" )
					ELSE
     				if "AGREG" $ EDX[ED_MODAPP]
        				F_ALTA({|| FIELD->CODPROV#0})
           			EDX[ED_REGISTRO] := recno()
        			endif
						FEDITOR( EDX, "GRABAR", .F. )
						EXIT
					ENDIF
				ELSEIF aux == "S"
					EXIT
				ENDIF
			ENDIF
		ENDDO
		FEDITOR(EDX,"SACAPAN")
		MENUDOWN(xmenu2)
		OPR:REFRESHALL()

	ELSEIF OPR:Cargo[TB_RET] == K_ESC .OR. OPR:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
RECUPAN()
PONEPAN(cMenu)
SELECT (cBase)

RETURN (OPR:Cargo[TB_RET]==K_ENTER)
