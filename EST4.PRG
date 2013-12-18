#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

*********

FUNC LOGO( r, titulo )

*********
LOCAL lastcolor := SETCOLOR(C_FONDO)
titulo = IF(PCOUNT()<2, "", titulo )

cR = REPLICATE("°",80)
IF r
	FOR x = 0 TO 5
		FOR xx = 0 TO 24 STEP 5
			@ xx + x, 0 SAY cR
		NEXT xx
	NEXT x
ELSE
	@ 0,0 SAY cR
	@ 1,0 SAY cR
	@ 2,0 SAY cR
ENDIF
SOMBRA( 1, 4, 2, 77 )
SETCOLOR(C_MENUDN)
@ 0, 2 CLEAR TO 1, 75
@ 0, 4 SAY DEQUIEN
@ 0,40 SAY ALLTRIM(nomsemana[DOW(DATE())]) + STR(DAY(DATE()),3) + " de " + ALLTRIM(nomes[MONTH(DATE())]) + " de " + STR(YEAR(DATE()),4,0)
@ 1,70 SAY left(cDirAno,4) color "*"+C_MENUDN
SETCOLOR(C_ELEGIDO)
aux = CENTRO(80,LEN(titulo))
@ 1, aux SAY titulo

SETCOLOR( lastcolor )

RETURN .T.


**************

FUNC SUPERBROW

**************
PARAMETERS bby1, bbx1, bby2, bbx2, barrax, func_replace, eslatecla, tratar_tecla, condappend
PRIVATE campo

READEXIT(.T.)
CLEAR TYPEAHEAD
KEYBOARD CHR(0)
SET CONFIRM ON

barray = IF( EMPTY(INDEXKEY(1)), .T., .F. )
xlargobarra = bbx2 - bbx1 + 1
xcoefbarra = xlargobarra / LEN( bbedit )
ylargobarra = bby2 - bby1 + 1
*i = AT( "M", bbedit )
i = 1
lastcolor = SETCOLOR( "W/N" )
@ bby2, bbx1 SAY REPLICATE( "Û", xlargobarra )
SETCOLOR( lastcolor )
KEYBOARD REPLICATE( CHR(19), 10 )

DBEDIT( bby1, bbx1, bby2-1, bbx2-1, bbcamp, "XSUPERBROW", bbmasc, bbcab, "ÑÍ", "³" )

RETURN(RECNO())


***************

FUNC XSUPERBROW

***************
PARAMETERS modo, i
PUBLIC cur_field

fila = ROW()
columna = COL()

cur_field = bbcamp[i]
IF LASTKEY() = 1
	KEYBOARD CHR(0)
	KEYBOARD CHR(31)
ELSEIF LASTKEY() = 6
	KEYBOARD CHR(0)
	KEYBOARD CHR(30)
ENDIF

tecla  =LASTKEY()
DO CASE
	
	***
	* TRATAMIENTO DE TECLA PRECIONADA
	***
CASE &eslatecla
	r = &tratar_tecla
	
	***
	* Seleccion
	***
CASE tecla == 13
	IF .NOT. "M"$bbedit
		r = 1
	ELSE
		r = 1
		aux = SUBSTR( bbedit, i+1, 20 )
		i = AT( "M", aux )
		IF i > 0
			KEYBOARD REPLICATE( CHR(4), i )
		ELSE
			i = AT( "M", bbedit )
			TONE (100,.5)
			K = CHR(24) + CHR(29)
			IF RECNO() = LASTREC() .AND. &condappend
				APPEND BLANK
				K = K + CHR(30)
			ENDIF
			K = K + IF( i>1, REPLICATE(CHR(13), i ), "" )
			KEYBOARD K
		ENDIF
	ENDIF
	
	
	***
	* Alta
	***
CASE tecla = -4
	r = 2
	IF "M"$bbedit
		KEYBOARD CHR(6) + CHR(29)
		APPEND BLANK
	ENDIF
	
	***
	* Modificaci¢n
	***
CASE tecla>31 .AND. tecla<132 .AND. SUBS(bbedit,i,1)="M"
	contenido = GET( fila, columna, cur_field, "M" )
	aux = &func_replace
	r = IF(cur_field $ INDEXKEY(1), 2, 1 )
	*	CLEARTYPEAHEAD()
	
	
	***
	* Edici¢n
	***
CASE tecla = -1  .AND. SUBSTR(bbedit,i,1) $ "ME"
	contenido = GET( fila, columna, cur_field, "E" )
	aux = &func_replace
	r = IF(cur_field $ INDEXKEY(1), 2, 1 )
	
OTHERWISE
	r = 1
	
ENDCASE

IF LASTKEY() = 24 .AND. RECNO() = LASTREC() .AND. &condappend
	APPEND BLANK
	KEYBOARD CHR(30)
ENDIF

lastcolor = SETCOLOR( "N/W" )
@ bby1-1, bbx1 CLEAR TO bby1-1, 79
@ bby1-1, bbx1 SAY LASTREC() PICT "####"
?? "/", RECNO()		&&, "³", XCL->EMPLEADOR, "³", XCL->EMPLEADO +"("+XCL->TIPOSUELDO+")"
IF barray
	@ bby1, bbx2 CLEAR TO bby2,bbx2
	ycoefbarra = ylargobarra/LASTREC()
	@ bby1+ycoefbarra*(RECNO()-1), bbx2 SAY ""
ENDIF
IF barrax
	@ bby2, bbx1 SAY REPLICATE( " ", xlargobarra )
	@ bby2, bbx1+xcoefbarra*(i-1) SAY REPLICATE( "", xcoefbarra )
ENDIF
SETCOLOR( lastcolor )

IF SUBS(bbedit,i,1) = "M"
	SETCURSOR( 1 )
ELSE
	SETCURSOR( 0 )
ENDIF
@ fila, columna SAY ""

RETURN(r)


************

FUNC MASCARA

************
PARAMETERS camp
PRIVATE r

IF camp = "CODPROD"
	r = "99999"
ELSEIF TYPE(camp) = "C"
	r = "@!"
ELSE
	r = ""
ENDIF

RETURN r


*********

FUNC FPROD

*********
PARAMETERS cualcod
PRIVATE lastbase, lastorder, r

lastbase = DBF()
SELECT PRD
lastorder = INDEXORD()
SET ORDER TO 1
SEEK cualcod
IF FOUND()
	r = PRD->DESCPROD
ELSE
	r = SPACE(LEN(PRD->DESCPROD))
ENDIF
SET ORDER TO lastorder
SELECT &lastbase

RETURN r


************

FUNC FPROVEE

************
PARAMETERS cualcod, conree
local nOrder
PRIVATE lastbase, r, campo, i

conree = IF(PCOUNT()>1, conree, .F. )
lastbase = DBF()
seleCT PRV
nOrder:=indexord()
set order to 1
IF !dbseek(cualcod)
	IF conree
		FOR i=1 TO FCOUNT()
			campo = FIELD(i)
			M->&campo := CAMPOVACIO( FIELD(i) )
		NEXT i
	ENDIF
	r = SPACE(LEN(PRV->RAZONSOC))
ELSE
	IF conree
		FOR i=1 TO FCOUNT()
			campo = FIELD(i)
			M->&campo = PRV->&campo
		NEXT i
	ENDIF
	r = PRV->RAZONSOC
ENDIF
set order to nOrder
SELECT &lastbase

RETURN r


*************

FUNC FCLIENTE

*************
PARAMETERS cualcod, conree
PRIVATE lastbase, r, campo, i

IF cualcod == -1
	RETURN "MIO                 "
ENDIF
conree = IF(PCOUNT()>1, conree, .F. )
lastbase = DBF()
SELECT CL
SET ORDER TO 1
IF !dbseek(cualcod)
	r = SPACE(LEN(CL->RAZONSOC))
	IF conree
		FOR i=1 TO FCOUNT()
			campo = FIELD(i)
			M->&campo = CAMPOVACIO( FIELD(i) )
		NEXT i
	ENDIF
ELSE
	r = CL->RAZONSOC
	IF conree
		FOR i=1 TO FCOUNT()
			campo = FIELD(i)
			M->&campo = CL->&campo
		NEXT i
	ENDIF
ENDIF
M->NUMCUENTA = cualcod
SELECT &lastbase

RETURN r


************

FUNC FELEGIR

************
PARAMETERS base, cual, lRecu
LOCAL cBase:=DBF(), nreg:=RECNO()
LOCAL ccolor:=SETCOLOR(C_MENU), norder, r, lastconv, aux1, aux2
LOCAL lIntensity := SET(_SET_INTENSITY)
LOCAL cmenu:=MENUDOWN({"º  <+>  º PgUp   º  F3   º   F4   º ENTER  º ESC  º",;
								"º       º PgDown º       º        º elige  º      º",;
								"º mueve º mueve+ º busca º busca+ º y sale º sale º"})
DEFAULT lRecu TO .T.

IF base = "PRODUCTO"
	PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
	bcamp[ 1] = "PRD->CODPROD"
	bcamp[ 2] = "PRD->DESCPROD"
	bcamp[ 3] = "PRD->PRECVENTA"
	bmasc[ 1] = ""
	bmasc[ 2] = "@!"
	bmasc[ 3] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Descripci¢n"
	bcab[ 3] = "Precio"
	bedit = "FFF"
	SELECT PRD
	nreg = RECNO()
	r = BROW(10, 1, 18, 50, "PRODUCTOS", bcamp, bmasc, bcab, bedit )
	IF lRecu
		RECUPAN()
	ENDIF

ELSEIF base = "ART"
	PRIVATE bcamp[4], bmasc[4], bcab[4], bedit
	bcamp[ 1] = "ART->RUBRO"
	bcamp[ 2] = "ART->CODPROD"
	bcamp[ 3] = "ART->DESCPROD"
	bcamp[ 4] = "ART->PRECIO"
	bmasc[ 1] = ""
	bmasc[ 2] = ""
	bmasc[ 3] = "@!"
	bmasc[ 4] = ""
	bcab[ 1] = "Rubro"
	bcab[ 2] = "C¢digo"
	bcab[ 3] = "Descripci¢n"
	bcab[ 4] = "Precio"
	bedit = "FFFF"
	SELECT ART
	nreg = RECNO()
	r = BROW(10, 1, 18, 55, "ARTICULOS", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)" )
	IF lRecu
		RECUPAN()
	ENDIF
	

ELSEIF base == "PROVEE" .OR. base == "PROV"
	PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
	bcamp[ 1] = "PRV->CODPROV"
	bcamp[ 2] = "PRV->RAZONSOC"
	bcamp[ 3] = "PRV->CUIT"
	bmasc[ 1] = ""
	bmasc[ 2] = "@!"
	bmasc[ 3] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Proveedor"
	bcab[ 3] = "C.U.I.T."
	bedit = "FFF"
	SELECT PRV
	nreg = RECNO()
	r = BROW(10, 5, 19, 50, "PROVEEDORES", bcamp, bmasc, bcab, bedit )
	RECUPAN()
	
	
ELSEIF base == "GRUPO"
	PRIVATE bcamp[4], bmasc[4], bcab[4], bedit
	bcamp[ 1] = "GR->(RECNO())"
	bcamp[ 2] = "GR->DESCGRUP"
	bcamp[ 3] = "STR(GR->IMPINT)+GR->TIPOIMPINT"
	bcamp[ 4] = "GR->ESCOMBUST"
	bmasc[ 1] = "999"
	bmasc[ 2] = "@!"
	bmasc[ 3] = "@!"
	bmasc[ 4] = "!"
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Grupo"
	bcab[ 3] = "Imp.Int"
	bcab[ 4] = "Combust"
	bedit = "FFFE"
	SELECT GR
	nreg = RECNO()
	r = BROW(10, 5, 19, 50, "GRUPOS", bcamp, bmasc, bcab, bedit )
	RECUPAN()
	
	
ELSEIF base == "CLIENTE" .OR. base == "CLI"
	PRIVATE bcamp[5], bmasc[5], bcab[5], bedit
	bcamp[ 1] = "CL->CODCLI"
	bcamp[ 2] = "CL->RAZONSOC"
	bcamp[ 3] = "CL->CUIT"
	bcamp[ 4] = "CL->CATIVA"
	bcamp[ 5] = "CL->FECHBAJA"
	bmasc[ 1] = "999"
	bmasc[ 2] = "@!"
	bmasc[ 3] = ""
	bmasc[ 4] = ""
	bmasc[ 5] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Cliente"
	bcab[ 3] = "C.U.I.T."
	bcab[ 4] = "IVA"
	bcab[ 5] = "Baja"
	bedit = "FFFFF"
	SELECT CL
  SET ORDER TO 1
	nreg = RECNO()
	r = BROW(10, 5, 19, 65, "CLIENTES CTA.CTE.", bcamp, bmasc, bcab, bedit )
	RECUPAN()
	
ELSEIF base == "CLICCV"
	PRIVATE bcamp[4], bmasc[4], bcab[4], bedit
	bcamp[ 1] = "CL->CODCLI"
	bcamp[ 2] = "CL->RAZONSOC"
	bcamp[ 3] = "CL->SALDOINI+CL->SALDOACUM+CL->REMAPAGAR"
	bcamp[ 4] = "CL->FECHBAJA"
	bmasc[ 1] = ""
	bmasc[ 2] = "@!"
	bmasc[ 3] = ""
	bmasc[ 4] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Cliente"
	bcab[ 3] = "Saldo"
	bcab[ 4] = "Baja"
	bedit = "FFFF"
	SELECT CL
  SET ORDER TO 1
	nreg = RECNO()
	r = BROW(10, 5, 19, 65, "CLIENTES CTA.CTE.", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)","tecla=-7" )
	RECUPAN()
	
ELSEIF base == "PROCCC"
	PRIVATE bcamp[4], bmasc[4], bcab[4], bedit
	bcamp[ 1] = "PRV->CODPROV"
	bcamp[ 2] = "PRV->RAZONSOC"
	bcamp[ 3] = "PRV->SALDOINI+PRV->SALDOACUM+PRV->COMAPAGAR"
	bcamp[ 4] = "PRV->FECHBAJA"
	bmasc[ 1] = ""
	bmasc[ 2] = "@!"
	bmasc[ 3] = ""
	bmasc[ 4] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Proveedor"
	bcab[ 3] = "Saldo"
	bcab[ 4] = "Baja"
	bedit = "FFFF"
	SELECT PRV
  SET ORDER TO 1
	nreg = RECNO()
	r = BROW(10, 5, 19, 65, "PROVEEDORES", bcamp, bmasc, bcab, bedit )
	RECUPAN()
	

ELSEIF base == "CLA"
  MENUDOWN({"  <+>  º PgUp   º  F2  º F3  º  F4  º  F5  º"+IF(lPermiso,"  F6   º","")+IF(lPUBLICO,"","  F7   º")+" ENTER ºESC ",;
				 "       º PgDown º      º     º      º      º"+IF(lPermiso,"       º","")+IF(lPUBLICO,"","       º")+" elige º    ",;
				 " mueve º mueve+ ºmodif.ºbuscaºbusca+ºagregaº"+IF(lPermiso,"eliminaº","")+IF(lPUBLICO,"","imprimeº")+" y saleºsale"})
	PRIVATE bcamp[4], bmasc[4], bcab[4], bedit
	bcamp[ 1] = "CLA->CODCLI"
	bcamp[ 2] = "CLA->RAZONSOC"
	bcamp[ 3] = "CLA->CUIT"
	bcamp[ 4] = "CLA->CATIVA"
	bmasc[ 1] = ""
	bmasc[ 2] = "@!"
	bmasc[ 3] = ""
	bmasc[ 4] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Cliente"
	bcab[ 3] = "C.U.I.T."
	bcab[ 4] = "IVA"
	bedit = "FFFF"
	SELECT CLA
	nreg = RECNO()
	r = BROW(10, 5, 19, 55, "CLIENTES (CUIT)", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=-1.OR.tecla=-5.OR.tecla=-4.OR.tecla=-6.OR.tecla=-8" )
	RECUPAN()

ELSEIF base = "EMPLEADO"
	MENUDOWN({"º  <+>  º   F2   º  F3   º   F4   º   F5   º    F6   º   F9   º ENTER  º ESC  º",;
				 "º       º        º       º        º        º         º elige  º elige  º      º",;
				 "º mueve º modif. º busca º busca+ º agrega º elimina º categ. º empl.  º sale º"})
	PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
	bcamp[ 1] = "EM->CODEMP"
	bcamp[ 2] = "EM->EMPLEADO"
	bcamp[ 3] = "EM->CODCAT"
	bmasc[ 1] = "!!!"
	bmasc[ 2] = "@!"
	bmasc[ 3] = "!!!"
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Empleado"
	bcab[ 3] = "Categ"
	bedit = "FEE"
	SELECT EM
	SEEK cual
	IF !FOUND()
		GO TOP
	ENDIF
	nreg = RECNO()
	r = BROW(10, 5, 19, 50, " EMPLEADO ", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=-4.OR.tecla=-5.OR.tecla=-1.OR.tecla=9" )
	RECUPAN()
	
elseif base = "RETIB"
	PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
	bcamp[ 1] = "RI->CODRET"
	bcamp[ 2] = "RI->DESCRET"
	bcamp[ 3] = "RI->ALICUOTA"
	bmasc[ 1] = ""
	bmasc[ 2] = ""
	bmasc[ 1] = ""
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Descripci¢n"
	bcab[ 3] = "% Ret"
	bedit = "EEE"
	SELECT RI
	nreg = RECNO()
	r = BROW(10, 1, 18, 55, "Reten.I.B.", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)" )
	IF lRecu
		RECUPAN()
	ENDIF
	
ENDIF
PONEPAN(cmenu)
IF LASTKEY() == K_ENTER
	nreg = RECNO()
ELSE
	GO nreg
	nreg = 0
ENDIF
SET(_SET_INTENSITY,lIntensity)
SETCOLOR(ccolor)
DBSELECTAREA(cbase)

RETURN nReg


****************

FUNC ESLACLAVE()

****************
LOCAL aux
aux := ""
MARCO( 10, 20, 10, 60, "", "D", .T., 0 )
@ 10, 20 SAY "Ingrese clave:"
DO WHILE .T.
	aux += CHR(INKEY(0))
  IF ALLTRIM(aux) == ALLTRIM(VA->CLAVE) .OR. LASTKEY()==K_ESC .OR. LASTKEY()==K_ENTER .OR. LEN(ALLTRIM(aux))>LEN(VA->CLAVE)
  	EXIT
  ENDIF
  @ 10,35 SAY REPLIC("*",LEN(aux))
ENDDO
RECUPAN()

RETURN( ALLTRIM(aux) == ALLTRIM(VA->CLAVE) )


*****************************************

FUNC FLOCA( buscar, campoclave, acampos, lSinSeek )

*****************************************
local array:={}, i:=0
DEFAULT lSinSeek TO .F.

buscar := alltrim(buscar)
if len(buscar) < 2
	MENSAJE( 0, 0, 10, .T., "puede ser mas ESPECIFICO ?" )
  return 0
endif
MENSAJE( 0, 0, 0, .F., "BUSCANDO..." )
if empty(indexkey()) .or. lSinSeek
	locate for buscar $ &(campoclave)
	do while !eof()
		if buscar $ &campoclave .and. !deleted()
			aadd( array, &(acampos) )
		endif
		skip
	enddo
else
	dbseek( buscar, .T. )
	do while left(buscar,1) == left(&campoclave,1) .and. !eof()
		if left(&campoclave,len(buscar))=Buscar .and. !deleted()
			aadd( array, &acampos )
		endif
		skip
	enddo
endif
RECUPAN()
if len(array) == 0
	MENSAJE( 0, 0, 10, .T., "NO ENCONTRADO !!!" )
else
	i = PP_SELEC(10, 20, i, 0, array, 1, "ELEGIR", "S", .T.)
	RECUPAN()
endif

RETURN i


**************

FUNC REEVARIOS

**************
PARAMETERS tecla
LOCAL nReg:=RECNO()
PRIVATE r, lastreg, tecla, contenido, base, lastbase, campo, aux
PROCESO = PROCNAME()

r = 1
IF DBF() == "GR"
	IF tecla = K_TAB
		IF FELEGIR("PRODUCTO",GR->CODPROD) # 0
			FRLOCK()
			GR->CODPROD := PRD->CODPROD
			DBUNLOCK()
		ENDIF
		r := 1
	ELSEIF tecla = K_F5
		cur_field = bcamp[2]
		contenido = GET( by2, bx1, cur_field, "A" )
		IF LASTKEY() = 13
			SET DELETED OFF
			LOCATE FOR DELETED()
			IF FOUND()
				FRLOCK()
				RECALL
			ELSE
				ADD_REC()
			ENDIF
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
			SET DELETED ON
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = K_F2
		contenido = GET( fila, columna, cur_field, "E" )
		IF UPDATED()
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG(.T.)
		ENDIF
		CLEARTYPEAHEAD()
	ENDIF
	
ELSEIF DBF() = "PRD" .AND. tecla == K_F7
	LISTADOR( "REPOS" )
	CLEARTYPEAHEAD()
	
ELSEIF DBF() = "CL" .AND. tecla == K_F8
	nReg:=recno()
	op2 = MENUFLASH( 10, 40, 1, .F., "UTIL",  "Sumar Saldos" )
  if op2==1
		sum CL->SALDOINI+CL->SALDOACUM+CL->REMAPAGAR to nAux
		MENSAJE( 0, 0, 999, .T., "Sumatoria Saldos="+str(nAux,10,2) )
  endif
  go nReg
  RECUPAN()
	
ELSEIF DBF() = "ART" .AND.1==2
	IF tecla == K_F2
		SELECT ART
		aX := NEWEDIT( "ART", .T., .T. )
		y1 = ASC( SUBSTR(aX[ED_FCOUNT],1) )
		x1 = ASC( SUBSTR(aX[ED_FCOUNT],2) )
		y2 = ASC( SUBSTR(aX[ED_FCOUNT],3) )
		x2 = ASC( SUBSTR(aX[ED_FCOUNT],4) )
		xcolor:=SETCOLOR("+W/N")
		SETCOLOR(xcolor)
		FEDPROD( aX, K_F2 )
		FEDITOR( aX, "SACAPAN" )
	ELSEIF tecla == K_F5
		SELECT ART
		aX := NEWEDIT( "ART", .T., .T. )
		y1 = ASC( SUBSTR(aX[ED_FCOUNT],1) )
		x1 = ASC( SUBSTR(aX[ED_FCOUNT],2) )
		y2 = ASC( SUBSTR(aX[ED_FCOUNT],3) )
		x2 = ASC( SUBSTR(aX[ED_FCOUNT],4) )
		xcolor:=SETCOLOR("+W/N")
		SETCOLOR(xcolor)
		FEDPROD( aX, K_F5 )
		FEDITOR( aX, "SACAPAN" )
  ENDIF
	CLEARTYPEAHEAD()
  r := 2
	
ELSEIF DBF() = "FAC"
	IF tecla == K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG(.T.)
        GO TOP
		ENDIF
     r := 2
  ENDIF
	CLEARTYPEAHEAD()
	

ELSEIF DBF() = "CLA"
	IF tecla == K_F2
  	CLA( K_F2 )
	ELSEIF tecla == K_F5
  	cCLIENTE := SPACE(LEN(FIELD->RAZONSOC))
  	CLA( K_F5 )
	ELSEIF tecla == K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG()
        r := 2
		ENDIF
 	ELSEIF tecla == K_F7 .AND. !lPUBLICO
 		lastreg:=RECNO()
  	LISTADOR("CLA")
     GO lastreg
  ENDIF
	CLEARTYPEAHEAD()
	

ELSEIF DBF() = "CLA"
	IF tecla == K_F2
  	CLA( K_F2 )
	ELSEIF tecla == K_F5
  	cCLIENTE := SPACE(LEN(FIELD->RAZONSOC))
  	CLA( K_F5 )
	ELSEIF tecla == K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG()
        r := 2
		ENDIF
*	ELSEIF tecla == K_F7
*		lastreg:=RECNO()
* 	LISTADOR("CLA")
*    GO lastreg
  ENDIF
	CLEARTYPEAHEAD()

	
ELSEIF DBF() = "EM"
	IF tecla = -4
		cur_field = bcamp[1]
		contenido = GET( by2, bx1, cur_field, "A" )
		IF LASTKEY() = K_ENTER
			SET DELETED OFF
			GO TOP
			IF EMPTY(EM->CODEMP) .OR. LASTREC()==0
				FRLOCK()
				RECALL
			ELSE
				ADD_REC()
			ENDIF
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
			SET DELETED ON
        r := 2
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = K_F2
		contenido = GET( fila, columna, cur_field, "E" )
		IF UPDATED()
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = 9 .AND. cur_field=="EM->CODCAT"
		e = ABRW( 5, 10, 0, 'vcateg', &cur_field, 'CATEGORIAS')
		IF LASTKEY() == K_ENTER
			FRLOCK()
			REPLACE &cur_field WITH LEFT(vcateg[e],3)
			UNLOCK
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG(.T.)
		ENDIF
		CLEARTYPEAHEAD()
	ENDIF
	
ELSEIF DBF() = "PLT"
	IF tecla = -4
		cur_field = bcamp[2]
		contenido = GET( by2, bx1, cur_field, "A" )
		IF LASTKEY() = K_ENTER
			SET DELETED OFF
			LOCATE FOR EMPTY(PLT->DESCPLANT)
			IF FOUND()
				FRLOCK()
				RECALL
			ELSE
				ADD_REC()
			ENDIF
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
			SET DELETED ON
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = -1
		cur_field = bcamp[2]
		contenido = GET( fila, columna, cur_field, "E" )
		IF UPDATED()
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla == K_TAB
  	r := 0
	ELSEIF tecla == 32
  	FRLOCK();  PLT->MARCA:=IF(PLT->MARCA==' ','',' ');  DBUNLOCK()
     CLEARTYPEAHEAD()
     r := 2
	ELSEIF tecla = -5
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG(.T.)
		ENDIF
		CLEARTYPEAHEAD()
	ENDIF

ELSEIF DBF() $ "CL PRV PRD"
	IF tecla = 43			// +
		MENSAJE( 0, 0, 0, .F., "MARCANDO . . ." )
		FFLOCK()
		lastreg = RECNO()
		REPLACE MARCA WITH "" FOR MARCA # "" REST
		GO lastreg
		UNLOCK ALL
		RECUPAN()
		r = 2
		CLEARTYPEAHEAD()
	ELSEIF tecla = 45		//-
		MENSAJE( 0, 0, 0, .F., "DESMARCANDO . . ." )
		FFLOCK()
		lastreg = RECNO()
		REPLACE MARCA WITH " " FOR MARCA # " " REST
		GO lastreg
		UNLOCK ALL
		RECUPAN()
		r = 2
		CLEARTYPEAHEAD()
	ELSEIF tecla == 32
		FRLOCK()
		REPLACE MARCA WITH IF( MARCA=='', '', '' )
		UNLOCK
		CLEARTYPEAHEAD()
     KEYBOARD CHR(K_DOWN)
	ELSEIF CHR(tecla) $ 'Pp'
  	IF PLTPRD()
			INIVER( "MARCANDO...",22,20,40,PRD->(LASTREC()) )
        FFLOCK()
     	GO TOP
        DO WHILE !PRD->(EOF())
        	cMarca := IF(PLP2->(DBSEEK(STR(PLP->CODPLT)+STR(PRD->CODPROD))),'',' ')
        	IF cMarca # PRD->MARCA
           	PRD->MARCA := cMarca
           ENDIF
           VER(0)
        	SKIP 1 ALIAS PRD
        ENDDO
        DBUNLOCK()
        RECUPAN()
     ENDIF
     GO nReg
     CLEARTYPEAHEAD()
     r := 2
	ELSEIF tecla==27 .OR. tecla==13
		r = 0
	ENDIF
	
ELSEIF DBF() == "RU"
	IF tecla = K_F5
		cur_field = bcamp[1]
		contenido = GET( by2, bx1, cur_field, "A" )
		IF LASTKEY() = 13
			SET DELETED OFF
			SEEK SPACE(LEN(RU->CODRUB))
			IF FOUND()
				FRLOCK()
				RECALL
			ELSE
				ADD_REC()
			ENDIF
			xreg := RECNO()
			SKIP -1
			aux2 := RU->DESDECOD
			GO xreg
			FRLOCK()
			RU->CODRUB   := aux
			RU->DESDECOD := aux2 + 201
			RU->HASTACOD := RU->DESDECOD + 200
			DBUNLOCK()
			SET DELETED ON
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = K_F2
		contenido = GET( fila, columna, cur_field, "E" )
		IF UPDATED()
			FRLOCK()
			REPLACE &cur_field WITH contenido
			UNLOCK
		ENDIF
		CLEARTYPEAHEAD()
	ELSEIF tecla = K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			BLANKREG(.T.)
		ENDIF
		CLEARTYPEAHEAD()
	ENDIF
	
ELSEIF DBF() == "FAC"
	IF CHR(tecla) $ 'Dd'
		IF QUEFECHA2( 10, 30 )
			MENSAJE( 0, 0, 0, .F., " BUSCANDO . . . " )
        GO TOP
        DO WHILE !EOF()
        	IF FAC->FACTURA # 0 .AND. FAC->FECHA>=DESDE .AND. FAC->FECHA<=HASTA
        		SELECT FAC2
           	DO WHILE DBSEEK(FAC->NUMFAC)
						BLANKREG(.T.)
           	ENDDO
           	SELECT FAC
					BLANKREG(.T.)
           ENDIF
           SKIP
        ENDDO
        GO TOP
        r := 2
     	RECUPAN()
		ENDIF
	ELSEIF tecla == K_F6
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
     	aux := &(INDEXKEY())
        SELECT FAC2
        DO WHILE DBSEEK(FAC->NUMFAC)
				BLANKREG(.T.)
        ENDDO
        SELECT FAC
			BLANKREG(.T.)
        DBSEEK( aux, .T.)
        r := 2
		ENDIF
  ENDIF
	CLEARTYPEAHEAD()
	
	
ENDIF
COMMIT

RETURN r


*************

FUNC HAYSTOCK

*************
PARAMETERS cual, cant
PRIVATE r, lastbase

r = .F.
IF EST->CTRLSTOCK == "S"
	lastbase = DBF()
	SELECT PRD
	SEEK cual
	IF FOUND()
		IF PRD->STOCKACT - cant < 0
			K = INKEY(0)
			MENSAJE( 0, 0, 10, .T., " NO HAY STOCK !!! " )
		ELSEIF PRD->STOCKACT - cant < PRD->STOCKMIN
			K = INKEY(0)
			MENSAJE( 0, 0, 10, .T., " STOCK MINIMO ALCANZADO !!! ("+ STR(PRD->STOCKMIN) +")" )
		ENDIF
		r = .T.
	ENDIF
	SELECT &lastbase
ENDIF

RETURN r


***********

FUNC VALIDO

***********
PARAMETERS cualcampo, cualvalido
PRIVATE lastbase, lastreg, lastorder, r, aux1, aux2

r = .T.
lastbase = DBF()
IF cualcampo = "CODPROD"
	IF EMPTY(FPROD(cualvalido))
		r = .F.
	ENDIF
ENDIF
SELECT &lastbase

RETURN r



************

FUNC FTECLAS

************
PARAMETERS que
PRIVATE na, archivo, i, e, buffer, block

block = 20
que = IF( PCOUNT()=0, "", que )
IF que == "INI"
	PUBLIC atecla[10]
	AFILL( atecla, SPACE(block) )
	archivo = XNAME("tecla","") + ".CFG"
	IF FILE( archivo )
		na = FOPEN(archivo)
		buffer = SPACE(block)
		FOR i=1 TO 10
			FSEEK( na, (i-1)*block )
			bytes = FREAD( na, @buffer, block )
			atecla[i] = buffer
		NEXT
		FCLOSE( na )
	ENDIF
	FOR i=1 TO 10
		SET FUNCTION (i+20) TO RTRIM(atecla[i])
	NEXT
	
ELSE
	PRIVATE aaux[10]
	FOR i=1 TO 9
		aaux[i] = "Ctrl F"+STR(i,1) +" :"+ atecla[i]
	NEXT
	aaux[i] = "Ctrl F"+STR(i,2) +":"+ atecla[i]
	e = 1
	vez = .T.
	DO WHILE .T.
		e = PP_SELEC(ym2-5, xm2-10, 10, 0, aaux, e, "", "S", vez)
		vez = .F.
		IF LASTKEY() == 13
			aux = LEFT( atecla[e]+SPACE(20), 20 )
			MARCO( ym2-5+e, xm2-20, ym2-5+e, xm2+23, "", "S", .T., 0 )
			SETCURSOR( 1 )
			@ ym2-5+e, xm2-20 SAY LEFT(aaux[e],9) GET aux PICT "XXXXXXXXXXXXXXXXXXXX"
			READ
			IF LASTKEY() == 13
				atecla[e] = aux
				aaux[e] = STUFF( aaux[e], 10, 20, aux )
				SET FUNCTION (e+20) TO RTRIM(aux)
			ENDIF
			RECUPAN()
		ELSEIF LASTKEY()==27
			EXIT
		ENDIF
	ENDDO
	archivo = XNAME("tecla","") + ".CFG"
	na = FCREATE(archivo,0)
	IF FERROR() == 0
		FOR i=1 TO 10
			FSEEK( na, (i-1)*block )
			buffer = LEFT(atecla[i]+SPACE(20),block)
			bytes = FWRITE( na, buffer, block )
		NEXT
	ENDIF
	FCLOSE( na )
	RECUPAN()
ENDIF

RETURN .T.


***************

FUNC SETVARSIVA( cualcat )

***************
LOCAL aaux:=ARRAY( EST_IVA2 )

aaux[EST_IVA1] := VA->PIVA1
aaux[EST_IVA2] := 0
IF cualcat == "RNI"
	aaux[EST_TIPO] := "A"
	aaux[EST_IVA2] := VA->PIVA2
ELSEIF cualcat == "RI "
	aaux[EST_TIPO] := "A"
	aaux[EST_IVA2] := 0
ELSE
	aaux[EST_TIPO] := "B"
ENDIF

RETURN( aaux )


*************

FUNC SELECTPRD( cual )

*************
LOCAL r:=0, aux:=SPACE(LEN(PRD->DESCPROD)), lastcolor:=SETCOLOR(C_MENU)
LOCAL lastreg:=PRD->(RECNO()), xmenu, aux2, x
LOCAL aaux:={}, lastbase:=DBF(), nCursor:=SET(_SET_CURSOR,SC_OFF)
LOCAL x1 := 15
LOCAL x2 := x1 + LEN( STR(PRD->CODPROD)+"³"+PRD->DESCPROD+"³"+STR(PRD->PRECCOMPRA,10,4)+"³"+STR(PRD->PRECVENTA) )

SELECT PRD
SET ORDER TO
IF cual == NIL
	aux = ALLTRIM(INGRVAL( 10, 0, "Qu‚ busco:", aux, "@!", "") )
ELSE
	aux := ALLTRIM( cual )
ENDIF
IF LASTKEY() == 13 .AND. !EMPTY(aux)
	MENSAJE( 1, 0, 0, .F., "Buscando "+aux+" . . ." )
	SALVAPAN( 1, x1, 24, x2 )
*	SOMBRA( 22, x1+2, 22, x2 )
	GO TOP
	r := 20
	DO WHILE !EOF() .AND. INKEY() # K_ESC
		IF aux $ PRD->DESCPROD
			AADD( aaux, STR(PRD->CODPROD) +"³"+ PRD->DESCPROD +"³"+ STR(PRD->PRECCOMPRA,10,4) +"³"+ STR(PRD->PRECVENTA) )
			IF r > 5
*				SOMBRA( r+1, x2, 21, x2+1 )
				@ r-1, x1 TO 21,x2
			ENDIF
			SCROLL( IF(r<6,6,r), x1+1, 20, x2, 1 )
			@ 20, 16 SAY aaux[LEN(aaux)]
			--r
		ENDIF
		SKIP
	ENDDO
	r := IF(r<5,5,r)
	CLEARTYPEAHEAD()
	RECUPAN()
	RECUPAN()
	IF LEN(aaux) == 0
		MENSAJE( 0, 0, 10, .T., "NO encontr‚ nada con "+ aux +" !!!" )
		r = 0
	ELSE
 		xmenu:=MENUDOWN({"     º  ENTER   º ESC  ",;
 							  "       º toma el  º      ",;
 							  " mueve º producto º sale "})
		aux := {"C¢d. ³Descripci¢n                   ³Pr.Compra ³Pr.Venta  ",;
				  "ÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ" }
		r = PP_SELEC( r, x1+1, 0, 0, aaux, 1, {aux}, "S", .T. )
		RECUPAN()
		SET ORDER TO 1
		IF LASTKEY() == K_ENTER
			SEEK VAL(aaux[r])
			r := PRD->CODPROD
		ELSE
			r := 0
		ENDIF
     PONEPAN(xmenu)
	ENDIF
ENDIF
SET ORDER TO 1
GO lastreg
SETCOLOR(lastcolor)
DBSELECTAREA(lastbase)
CLEARTYPEAHEAD()
SET(_SET_CURSOR,nCursor)

RETURN( r )


*************

FUNC SELECTAR( cual )

*************
LOCAL r:=0, aux:=SPACE(LEN(ART->DESCPROD)), lastcolor:=SETCOLOR(C_MENU)
LOCAL lastreg:=ART->(RECNO()), xmenu, bBuscado
PRIVATE aaux:={}, lastbase:=DBF()

IF cual == NIL
	aux := ALLTRIM(INGRVAL( 10, 0, "Qu‚ busco:", aux, "@!", "") )
ELSE
	aux := ALLTRIM( cual )
ENDIF
aux := STRTRAN( aux, "*", "" )
SELECT ART
SET ORDER TO
IF LASTKEY() == K_ENTER .AND. !EMPTY(aux)
	MENSAJE( 1, 0, 0, .F., "Buscando "+aux+" . . ." )
	aux1 := aux2 := ""
	x := AT( ",", aux )
 	IF x == 0
  	IF VAL(aux) == 0
     	bBuscado := &( "{|| '"+ aux +"'$ART->DESCPROD }" )
		ELSE
     	bBuscado := &( "{|| ART->PRECIO=="+ aux +"}" )
     ENDIF
  ELSE
  	aux1 := LEFT(aux,x-1)
  	aux2 := SUBSTR(aux,x+1)
     bBuscado := &( "{||"+ IF( EMPTY(aux1),"", "'"+aux1+"'$ART->DESCPROD.AND.") + IF(EMPTY(aux2),"","ART->PRECIO=="+ aux2) +"}" )
  ENDIF
	SALVAPAN( 1, 19, 24, 70 )
	* @ 19, 20 CLEAR TO 21,66
	SOMBRA( 22, 21, 22, 68 )
	GO TOP
	r := 20
	DO WHILE !EOF() .AND. INKEY() # K_ESC
		IF EVAL( bBuscado )
			AADD( aaux, STR(ART->CODPROD) +"³"+ ART->DESCPROD +"³"+ STR(ART->PRECIO) )
			IF r > 5
				SOMBRA( r+1, 67, 21, 68 )
				@ r-1, 19 TO 21,66
			ENDIF
			SCROLL( IF(r<6,6,r), 20, 20, 65, 1 )
			@ 20, 20 SAY aaux[LEN(aaux)]
			--r
		ENDIF
		SKIP
	ENDDO
	CLEARTYPEAHEAD()
	RECUPAN()
	RECUPAN()
	r := IF( r<6, 6, r )
	IF LEN(aaux) == 0
		MENSAJE( 0, 0, 10, .T., "NO ENCONTRE NINGUNO !!!" )
		r = 0
	ELSE
 		xmenu:=MENUDOWN({"     º  ENTER   º ESC  ",;
 							  "       º toma el  º      ",;
 							  " mueve º producto º sale "})
		r := PP_SELEC( r, 20, 0, 0, aaux, 1, "ELEGIR", "S", .T.)
		RECUPAN()
		SET ORDER TO 1
		IF LASTKEY() == K_ENTER
			r := VAL( aaux[r] )
		ELSE
			r := 0
		ENDIF
     PONEPAN(xmenu)
	ENDIF
ENDIF
SET ORDER TO 1
GO lastreg
SETCOLOR(lastcolor)
SELECT &lastbase
CLEARTYPEAHEAD()

RETURN r


**********************

FUNC FFECHVENC( cualfecha, tipoventa )

**********************
LOCAL r := IF( cualfecha==NIL, CTOD(""), cualfecha )

IF tipoventa == 2
	IF DAY(r) > 15
		r := CTOD( STR(DIASXMES(YEAR(r),MONTH(r)),2) +"/"+ STR(MONTH(r),2) +"/"+ STR(YEAR(r),4) )
	ELSE
		r := CTOD( STUFF(DTOC(r),1,2,"15") )
	ENDIF
ENDIF

RETURN r


********************

FUNC FCIERRE( cualfecha )

********************
RETURN CTOD( STR( IF( DAY(cualfecha)>15, DIASXMES(YEAR(cualfecha),MONTH(cualfecha)), 15 ), 2)+SUBSTR(DTOC(cualfecha),3) )


****************

FUNC MARCARCLI()

****************
local xmenu
xmenu:=MENUDOWN({"  <+>  º PgUp   º  F3   º   F4   º   +   º    -     º ESPACIO  º  ENTER  º ESC  ",;
						"       º PgDown º       º        º marca º desmarca º marca /  º         º      ",;
						" mueve º mueve+ º busca º busca+ º todo  º   todo   º desmarca º procede º sale "})
private bcamp[4], bmasc[4], bcab[4], bedit
bcamp[ 1] = "CL->CODCLI"
bcamp[ 2] = "CL->RAZONSOC"
bcamp[ 3] = "CL->CATIVA"
bcamp[ 4] = "CL->MARCA"
bmasc[ 1] = "999"
bmasc[ 2] = "@!"
bmasc[ 3] = "!!!"
bmasc[ 4] = "!"
bcab[ 1] = "C¢digo"
bcab[ 2] = "Cliente"
bcab[ 3] = "Cat;IVA"
bcab[ 4] = "Marca"
bedit = "FFFF"
select CL
set order to 1
lastreg = RECNO()
r = BROW(10, 5, 19, 78, "MARCAR CLIENTES", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "chr(tecla)$' +-'" )
RECUPAN()
MENUDOWN(xmenu)

return( lastkey() == K_ENTER )


*****************

FUNC MARCARPROV()

*****************
local xmenu
xmenu:=MENUDOWN({"  <+>  º PgUp   º  F3   º   F4   º   +   º    -     º ESPACIO  º  ENTER  º ESC  ",;
						"       º PgDown º       º        º marca º desmarca º marca /  º         º      ",;
						" mueve º mueve+ º busca º busca+ º todo  º   todo   º desmarca º procede º sale "})
private bcamp[3], bmasc[3], bcab[3], bedit
bcamp[ 1] = "PRV->CODPROV"
bcamp[ 2] = "PRV->RAZONSOC"
bcamp[ 3] = "PRV->MARCA"
bmasc[ 1] = "999"
bmasc[ 2] = "@!"
bmasc[ 3] = "!"
bcab[ 1] = "C¢digo"
bcab[ 2] = "Proveedor"
bcab[ 3] = "Marca"
bedit = "FFF"
select PRV
lastreg = RECNO()
r = BROW(10, 5, 19, 50, "MARCAR PROVEEDORES", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "chr(tecla)$' +-'" )
RECUPAN()
MENUDOWN(xmenu)

return( LASTKEY() == K_ENTER )


*****************

FUNC MARCARPROD()

*****************
LOCAL xmenu, xord
xmenu:=MENUDOWN({"  <+>  º  F3   º   F4   º   +   º     -    º ESPACIO  º   P    º  ENTER  º ESC  ",;
						"       º       º        º marca º desmarca º marca /  º plan-  º         º      ",;
						" mueve º busca º busca+ º todo  º   todo   º desmarca º tillas º procede º sale "})
PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
bcamp[ 1] = "PRD->CODPROD"
bcamp[ 2] = "PRD->DESCPROD"
bcamp[ 3] = "PRD->MARCA"
bmasc[ 1] = ""
bmasc[ 2] = "@!"
bmasc[ 3] = "!"
bcab[ 1] = "C¢digo"
bcab[ 2] = "Descripci¢n"
bcab[ 3] = "Marca"
bedit = "FFF"
SELECT PRD
xord := INDEXORD()
lastreg = RECNO()
SET ORDER TO FORDER({"PRD->CODPROD"})
r = BROW(10, 5, 19, 50, "MARCAR PRODUCTOS", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=43.OR.tecla=45.OR.tecla=32.or.chr(tecla)$'Pp'" )
SET ORDER TO xord
RECUPAN()

RETURN( LASTKEY() == K_ENTER )


*****************

FUNCTION funcacho

*****************
PARAMETERS amod, sel, rel
LOCAL srow:=ROW(), scol:=COL(), csel, crel, lastcolor
PRIVATE k, r

csel = sel
crel = rel
IF aach[ACH_LARGO] > aach[ACH_Y2]-aach[ACH_Y1]+1
	IF aach[ACH_LADO] == ""
		aach[ACH_LADO] := SAVESCREEN( aach[ACH_Y1], aach[ACH_X2]+1, aach[ACH_Y1], aach[ACH_X2]+1 )
	ENDIF
*	lastcolor = SETCOLOR("*W+/N,N/W")
	IF csel > crel + 1
		@ aach[ACH_Y1], aach[ACH_X2]+1 SAY ""
	ELSE
		RESTSCREEN( aach[ACH_Y1], aach[ACH_X2]+1, aach[ACH_Y1], aach[ACH_X2]+1, aach[ACH_LADO] )
	ENDIF
	IF aach[ACH_LARGO] - csel > (aach[ACH_Y2]-aach[ACH_Y1])-crel
		@ aach[ACH_Y2], aach[ACH_X2]+1 SAY ""
	ELSE
		RESTSCREEN( aach[ACH_Y2], aach[ACH_X2]+1, aach[ACH_Y1], aach[ACH_X2]+1, aach[ACH_LADO] )
	ENDIF
*	SETCOLOR(lastcolor)
ENDIF
r := 2
aach[ACH_TECLA] := 0

IF amod == 3
	k := aach[ACH_TECLA] := LASTKEY()
	DO CASE
		
	CASE EVAL( aach[ACH_CONDEXIT] )
		aach[ACH_TECLA] := K
		r = 1
		
	CASE k == K_ESC
		aach[ACH_TECLA] := k
		r = 0
		
	CASE k == K_ENTER
		aach[ACH_TECLA] := k
		r = 1
		
	CASE k == K_HOME
		aach[ACH_TECLA] := k
		KEYBOARD CHR(31)
		
	CASE k == K_END
		aach[ACH_TECLA] := k
		KEYBOARD CHR(30)
		
	OTHERWISE
		r = 3
		
	ENDCASE
ELSEIF LASTKEY() == K_ESC
	k := aach[ACH_TECLA] := LASTKEY()
ENDIF

aach[ACH_REL] := rel
aach[ACH_ELE] := sel

RETURN r


**********************************

FUNC NEWACHO( aa, _largo, apos )

**********************************
LOCAL aach:= ARRAY( ACH_LARGO )
_largo := IF( _largo==NIL, LEN(aa), _largo )
apos[3] := apos[1] + IF( apos[3]==0, LEN(aa)-1, apos[3] )
apos[4] := apos[2] + IF( apos[4]==0, LEN(aa[1])-1, apos[4] )

aach[ ACH_Y1       ] := apos[1]
aach[ ACH_Y2       ] := IF(apos[3]>22,22,apos[3])
aach[ ACH_X1       ] := apos[2]
aach[ ACH_X2       ] := apos[4]
aach[ ACH_ELE      ] := 1
aach[ ACH_REL      ] := 0
aach[ ACH_LADO     ] := ""
aach[ ACH_TECLA    ] := 0
aach[ ACH_CONDEXIT ] := {|| k==K_ENTER.OR.K==K_ESC }
aach[ ACH_LARGO    ] := _largo

KEYBOARD CHR(K_LEFT)

RETURN aach


***********

FUNC ARMARNTX( aa )

***********
LOCAL r:="", i

FOR i=1 TO LEN(aa)
	IF TYPE( aa[i] ) == "N"
		x := "STR("+aa[i]+")"
	ELSEIF TYPE( aa[i] ) == "D"
		x := "FTOC("+aa[i]+")"
	ELSE
		x := aa[i]
	ENDIF
	r += "+" + x
NEXT

RETURN SUBSTR(r,2)


*****************

FUNC MARCARACH( y1, x1, aa, _permiso, _titulo )

*****************
LOCAL xmenu, i, e, xcant:=0
_permiso := IF( _permiso==NIL, ".T.", _permiso )

IF LEN(aa) == 0
	RETURN 0
ENDIF
xmenu:=MENUDOWN({"     º ESPACIO  º     +      º     -      º  ENTER  º ESC  ",;
						"       º marca /  º   marca    º  desmarca  º         º      ",;
						" mueve º desmarca ºhacia abajo ºhacia abajo º procede º sale "})
AEVAL( aa, {|a| IF(RIGHT(a,1)#'',,++xcant) })
aach := NEWACHO(aa,,{y1,x1,0,0} )
aach[ACH_CONDEXIT] := {||k==32.OR.k==K_ENTER.OR.k==43.OR.K==45}
IF VALTYPE(_titulo) == NIL
	MARCO( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], "", "S", .T. )
ELSEIF VALTYPE(_titulo) == "C"
	MARCO( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], IF(_titulo==NIL,"",_titulo), "S", .T. )
ELSEIF VALTYPE(_titulo) == "A"
	MARCO( aach[ACH_Y1]-LEN(_titulo), aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], "", "S", .T. )
  FOR i=1 TO LEN(_titulo)
		@ aach[ACH_Y1]-LEN(_titulo)+i-1, aach[ACH_X1] SAY _titulo[i]
  NEXT
ENDIF
DO WHILE .T.
	@ aach[ACH_Y2]+1, aach[ACH_X1]+1 SAY "("+STR(xcant,3)+")"
	e := ACHOICE( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], aa, &_permiso, "funcacho", aach[ACH_ELE], aach[ACH_REL] )
	IF aach[ACH_TECLA] == K_SPACE
		IF RIGHT(aa[e],1) = ""
			aa[e] := LEFT(aa[e],LEN(aa[e])-1) + " "
        --xcant
		ELSE
			aa[e] := LEFT(aa[e],LEN(aa[e])-1) + ""
        ++xcant
		ENDIF
     KEYBOARD CHR(K_DOWN)
	ELSEIF aach[ACH_TECLA] == 43
     FOR i=e TO LEN(aa)
			IF RIGHT(aa[i],1) # ""
				aa[i] := LEFT(aa[i],LEN(aa[i])-1) + ""
        	++xcant
        ENDIF
		NEXT
	ELSEIF aach[ACH_TECLA] == 45
     FOR i=e TO LEN(aa)
			IF RIGHT(aa[i],1) # " "
				aa[i] := LEFT(aa[i],LEN(aa[i])-1) + " "
        	--xcant
        ENDIF
		NEXT
	ELSEIF aach[ACH_TECLA] == K_ESC .OR. aach[ACH_TECLA]==K_ENTER
		EXIT
	ENDIF
ENDDO
RECUPAN()
MENUDOWN(xmenu)

RETURN aach[ACH_TECLA]


***************

FUNC FTOTALIZAR

***************

M->DESCUENTO := M->TPRECBASE * M->PORCDESC / 100
M->SUBTOTAL  := M->TPRECBASE - M->DESCUENTO
M->TIVA1     := M->SUBTOTAL * M->PIVA1 / 100
M->TIVA2     := M->SUBTOTAL * M->PIVA2 / 100
M->TOTAL     := M->SUBTOTAL + M->TIMPINT + M->TIVA1 + M->TIVA2
M->SUBTOTAL  := M->TOTAL - M->TIMPINT - M->TIVA1 - M->TIVA2

RETURN M->TOTAL


**************

FUNC BUSCADOR( nK, OTB )

**************
LOCAL aux, nReg
LOCAL nOrder:=INDEXORD(), i:=0, r:=0

IF nK == K_F3
	cNomCampo := oTB:CARGO[TB_NOMBRE,oTB:COLPOS]
 	IF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) $ 'N C D'
		oTC := oTB:GETCOLUMN(oTB:COLPOS)
		bBuscar := EVAL( OTC:BLOCK )
     aux := EVAL( OTC:BLOCK )
     IF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == "N"
     	aux := VAL(aux)
     ELSEIF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == "D"
        aux := CTOD(aux)
     ENDIF
		KEYBOARD CHR(25)
		bBuscar := INGRVAL(OTB:CARGO[TB_FILA], OTB:CARGO[TB_COL], "BUSCAR", aux, OTB:CARGO[TB_MASC,OTB:COLPOS], "")
		IF LASTKEY() == K_ENTER
     	oTB:CARGO[TB_BUSCAR] := NIL
			nReg := RECNO()
			MENSAJE(0, 0, 0, .F., " BUSCANDO... ")
			DO WHILE !EMPTY( INDEXKEY(++i) )
        	cAux := STRTRAN(INDEXKEY(i),DBF()+"->","" )
        	nAux := AT( "+", cAux )
        	nAux := IF(nAux==0,LEN(cAux),nAux-1)
        	IF cNomCampo == LEFT(cAux,nAux)
					r := i
					EXIT
				ENDIF
			ENDDO
			IF r == 0
        	i := 0
				DO WHILE !EMPTY( INDEXKEY(++i) )
        		IF "("+ cNomCampo $ STRTRAN(INDEXKEY(i),DBF()+"->","" )
        			IF AT("(",INDEXKEY(i)) > AT("+",INDEXKEY(i))
              		bBuscar := &( STRTRAN( INDEXKEY(i), DBF()+"->"+cNomCampo, 'bBuscar' ) )
							r := i
							EXIT
                 ENDIF
					ENDIF
				ENDDO
        ENDIF
			IF r # 0
        	SET ORDER TO r
				DBSEEK( bBuscar, .T. )
        ELSE
				IF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == 'C'
					bBuscar := STRTRAN( bBuscar, CHR(34), "" )
					bBuscar := "'"+ UPPER(ALLTRIM(STRTRAN(bBuscar,".",""))) + "' $ STRTRAN(UPPER(FIELD->" + oTB:CARGO[TB_NOMBRE,oTB:COLPOS] +"),'.','') "
				ELSEIF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == 'N'
					bBuscar := "FIELD->"+ oTB:CARGO[TB_NOMBRE,oTB:COLPOS] +"==" + STR(bBuscar)
*					bBuscar := {|| FIELD->&(cNomCampo)==oTB:CARGO[TB_BUSCAR }
				ELSEIF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == 'D'
					bBuscar := "DTOC(FIELD->" + oTB:CARGO[TB_NOMBRE,oTB:COLPOS] +")=='" + DTOC(bBuscar) +"'"
				ENDIF
				bBuscar := bBuscar + ".AND. CORTAR()"
           bBuscar := &( "{||"+ bBuscar +"}" )
 				LOCATE FOR EVAL(bBuscar)
				IF FOUND()
     			oTB:CARGO[TB_BUSCAR] := bBuscar
           ELSE
					MENSAJE(0, 0, 10, .T., "Lo siento NO lo ENCUENTRO !")
					GO nReg
				ENDIF
			ENDIF
			RECUPAN()
		ELSE
			bBuscar = NIL
		ENDIF
	ENDIF
	CLEARTYPEAHEAD()
	TBPOS(OTB,.T.)

ELSEIF nK == K_F4
  IF oTB:CARGO[TB_BUSCAR] != NIL
		nReg := RECNO()
		SKIP
		MENSAJE(0, 0, 0, .F., " CONTINUO BUSCANDO... ")
     bBuscar := oTB:CARGO[TB_BUSCAR]
		LOCATE REST FOR EVAL(bBuscar)
		IF !FOUND()
			MENSAJE( 0, 0, 10, .T., "Lo siento NO lo ENCUENTRO !")
  		oTB:CARGO[TB_BUSCAR] := NIL
			GO nReg
		ENDIF
		RECUPAN()
	ENDIF
	CLEARTYPEAHEAD()
  oTB:RefreshAll()
ENDIF
SET ORDER TO nOrder

RETURN



************

FUNC FRUBRO( cual )

************
LOCAL xbase:=DBF(), r

IF cual>0 .AND. cual<=RU->(LASTREC())
	SELECT RU
	GO cual
	r := RU->DESCRUB
	DBSELECTAREA( xbase )
ELSE
	r := SPACE(LEN(RU->DESCRUB))
ENDIF

RETURN r


************

FUNC CAMPOVACIO( cual )

************

RETURN IF( TYPE(cual)=="N", 0, IF( TYPE(cual)=="D", CTOD(''), IF( TYPE(cual)=="L", .F., SPACE(LEN(&(cual))) ) ) )


*************

FUNC FCLAVE(cCampoClave)

*************
LOCAL r := .F.

MARCO( 10, 20, 10, 40, "", "S", .T., 0 )
aux := ""
DO WHILE .T.
  @ 10,20 SAY "CLAVE:           "
  @ 10,20 SAY "CLAVE:"+REPLICATE("*",LEN(aux))
  INKEY(0)
  @ 10,20 SAY "CLAVE:"+REPLICATE("*",LEN(aux))
  IF LASTKEY()==K_ENTER
  	IF ALLTRIM(cCampoClave) == ALLTRIM(aux)
     	r := .T.
     ENDIF
    	EXIT
 	ELSEIF LASTKEY()==K_BS .AND. LEN(aux)>1
     aux := LEFT(aux,LEN(aux)-1)
 	ELSEIF LASTKEY()==K_ESC
     EXIT
  ELSE
     aux += CHR(LASTKEY())
  ENDIF
 	aux := LEFT(aux,LEN(cCampoClave))
ENDDO
RECUPAN()

RETURN r


*****************

FUNC ASUMAR( aa )

*****************
LOCAL r:=0

AEVAL( aa, {|a| r+=a} )

RETURN r


**************************

FUNC FCALCPRECIO(AXR,nLin)

**************************
local nIVA1:=M->PIVA1
local nIVA2:=M->PIVA2

AXR[ nLin, RG_DESCUENTO  ] := AXR[nLin,RG_PRECUNIT] * AXR[nLin,RG_PORCDESC] / 100
AXR[ nLin, RG_PRECUNIT   ] := AXR[nLin,RG_PRECUNIT] - AXR[nLin,RG_DESCUENTO]

if AXR[nLin,RG_TIPOIMPINT] == "%"
	FGRUPO(NGRUPO)
	AXR[ nLin, RG_PRECBASE   ] := AXR[nLin,RG_PRECUNIT] / (1+(FIMPINT+M->PIVA1)/100)
	AXR[ nLin, RG_IMPINT     ] := AXR[nLin,RG_PRECBASE] * FIMPINT / 100
else
	AXR[ nLin, RG_PRECUNIT   ] -= AXR[nLin,RG_IMPINT]
	AXR[ nLin, RG_PRECBASE   ] := AXR[nLin,RG_PRECUNIT] / (1+(M->PIVA1)/100)
endif

if AXR[ nLin, RG_NEGOCIO ] == "*"
  if ART->(dbseek(AXR[nLin,RG_CODPROD])) .and. ART->EXENTO==0
  	nIVA1 := nIVA2 := 0
		AXR[ nLin, RG_PRECBASE   ] := AXR[nLin,RG_PRECUNIT]
  endif
endif
AXR[ nLin, RG_IVA1       ] := AXR[nLin,RG_PRECBASE] * nIVA1 / 100
AXR[ nLin, RG_IVA2       ] := AXR[nLin,RG_PRECBASE] * nIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[nLin,RG_RUBRO]==1.AND.AXR[nLin,RG_NEGOCIO]==" ",0,1)
AXR[ nLin, RG_PRECUNIT   ] := AXR[nLin,RG_PRECBASE] + AXR[nLin,RG_IMPINT] + AXR[nLin,RG_IVA1] + AXR[nLin,RG_IVA2]

AXR[ nLin, RG_TPRECBASE  ] := AXR[nLin,RG_PRECBASE] * AXR[nLin,RG_CANTIDAD]
AXR[ nLin, RG_TIMPINT    ] := AXR[nLin,RG_IMPINT] * AXR[nLin,RG_CANTIDAD]
AXR[ nLin, RG_TIVA1      ] := AXR[nLin,RG_IVA1] * AXR[nLin,RG_CANTIDAD]
AXR[ nLin, RG_TIVA2      ] := AXR[nLin,RG_IVA2] * AXR[nLin,RG_CANTIDAD]
AXR[ nLin, RG_TDESCUENTO ] := AXR[nLin,RG_DESCUENTO] * AXR[nLin,RG_CANTIDAD]
AXR[ nLin, RG_IMPORTE    ] := AXR[nLin,RG_PRECUNIT] * AXR[nLin,RG_CANTIDAD]
AXR[ nLin, RG_PRECUNIT   ] := FPRECVENTA
*    IF K # K_F2 .AND. K # K_F12
*			AXR[ nLin, RG_DESCPROD   ] := LEFT(FPRODUCTO(AXR[nLin,RG_CODPROD],AXR[nLin,RG_NEGOCIO]),20)
*			AXR[ nLin, RG_RUBRO      ] := NRUBRO
*			AXR[ nLin, RG_PRECBASE   ] := FPRECBASE
*			AXR[ nLin, RG_TIPOIMPINT ] := FTIPOIMPINT
*			AXR[ nLin, RG_IMPINT     ] := FIMPINT
*			AXR[ nLin, RG_PRECUNIT   ] := FPRECVENTA
*		ENDIF

return


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
	set alternate to ERR.TXT
	set alternate on
	r := ERRORSYS(eObj)
	set alternate to
	return .T.
endif

if --I_errores > 0
	return .T.
else
  break(nil)
	return .F.
endif


******************************

FUNC FCUIT( cCualCuit, cModo )

******************************
local r, cCuit:=strtran(cCualCuit,"-","")
DEFAULT cModo TO "BIEN"

	WX1 = val(substr(cCuit,1,1))  * 5
	WX2 = val(substr(cCuit,2,1))  * 4
	WX3 = val(substr(cCuit,3,1))  * 3
	WX4 = val(substr(cCuit,4,1))  * 2
	WX5 = val(substr(cCuit,5,1))  * 7
	WX6 = val(substr(cCuit,6,1))  * 6
	WX7 = val(substr(cCuit,7,1))  * 5
	WX8 = val(substr(cCuit,8,1))  * 4
	WX9 = val(substr(cCuit,9,1))  * 3
	WX10= val(substr(cCuit,10,1)) * 2
	WX11=val(substr(cCuit,11,1))

	WA = WX1 + WX2 + WX3 + WX4 + WX5 + WX6 + WX7 + WX8 + WX9 + WX10
	WB = int(WA / 11)
	WC = WB * 11
	WD = WA - WC
	WE = 11 - WD

	if WD > 1
		WV = WE
	else
		WV = 0
	endif

	if cModo == "BIEN"
		if WX11 <> WV
			r := .F.
  	else
			r := .T.
		endif
  elseif cModo == "DIGITO"
  	 r := WV
  endif

return r


*****************

FUNC FPPERC(cCUIT)

*****************
local cAux, nAux

cAux := strtran(cCUIT,"-","")
if PIB->(dbseek(cAux)) .and. PIB->ESTADO<>"B"
	nAux := PIB->PPERC
else
	nAux := VA->PIB_VEN1
endif

return nAux


*****************

FUNC FRETIB( cCUIT )

*****************
local cAux, nAux
cAux := strtran(cCUIT,"-","")
if PIB->(dbseek(cAux)) .and. PIB->ESTADO<>"B"
	nAux := PIB->PRET
else
	nAux := VA->PIB_COM1
endif

return nAux
