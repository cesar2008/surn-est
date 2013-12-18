local aCpo, oGET, xreg, aOrden, areg, xaux, aux, aaux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

#define AX_CATIVA		EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->CATIVA") ]
#define AX_NUMFAC		EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->NUMFAC") ]
#define AX_CODPROV		EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->CODPROV") ]
#define AX_FECHA 		EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->FECHA") ]
#define AX_FECHVENC		EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->FECHVENC") ]
#define AX_TIPOCOMPRA	EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->TIPOCOMPRA") ]
#define AX_PIVA1  		EDC[ ED_CONT, ASCAN(EDC[ED_FIELDS],"CO->PIVA1") ]

LOGO( .T., " COMPRAS VARIAS " )
MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
F_ABASE({"CO","PRV"},"CERRAR")
FBASES({ "PROD" })
FBASES({ "COMPRASV", "PROVEEV","PLANCTA", "BANCO" })
aOrden:={"Ordenado x C¢d.Prov.y N§Comprob.","Ordenado x Fecha Comprobante"}

aCpo:={{ "FECHA",      "Fecha; ",                            '', 'F',  '',  0, 0 },;
		  { "CODPROV",    "C¢d;Prov",                           '', 'F',  '',  0, 0 },;
		  { "RAZONSOC",   "Proveedor; ",                        '', 'F',  '',  0, 0 },;
		  { "CUIT",       "C.U.I.T.; ",                         '', 'F',  '',  0, 0 },;
		  { "CATIVA",     "Cat;IVA",                            '', 'F',  '',  0, 0 },;
		  { "NUMFAC",     "Comprobante",                        '', 'F',  '',  0, 0 },;
		  { "NETO",       "Neto; ",                             '', 'F',  '',  0, 0 },;
		  { "CREDITO",    "Credito; ",                          '', 'F',  '',  0, 0 },;
		  { "EXENTO",     "Exento; ",                           '', 'F',  '',  0, 0 },;
		  { "IMPINT",     "Imp.;Int.",                          '', 'F',  '',  0, 0 },;
		  { "PERCEPCION", "Perc.;RG 3337",                      '', 'F',  '',  0, 0 },;
		  { "PERCIIBB",   "Percepc.;IIBB",                      '', 'F',  '',  0, 0 },;
		  { "TOTAL",      "Total; ",                            '', 'F',  '',  0, 0 },;
		  { "RETIVA",     "Ret.IVA; ",                          '', 'F',  '',  0, 0 },;
		  { "RETIB",      "Ret.IIBB; ",                         '', 'F',  '',  0, 0 },;
		  { "RETGAN",     "Ret.Gan; ",                          '', 'F',  '',  0, 0 }}
*		  { "IMPDEP",     "Importe;deposit.",                   '', 'F',  '',  0, 0 },;
*		  { "DESTINO",    "Banco",                              '', 'F',  '',  0, 0 },;
*		  { "BA->NOMBANCO","Banco",                 REPLIC('X',20), 'F', 'F', 20, 0 },;
*		  { "CODPLAN",    "C¢d;Plan Cta",                       '', 'F',  '',  0, 0 }}

select CO
set order to CO_FECHA_CODPROV
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )

EDC := NEWEDIT( "COMV", .F. )
x:=EDNUM(EDC,"CO->NUMFAC");  if x#0;  EDC[ED_PICTS,x]:="@K "+EDC[ED_PICTS,x];  endif

MENUDOWN({" <+> º         º   F2   º  F5  º     F6      º  F7   º   O  ºESC ",;
			  "     ºF3 busca º        º      º   elimina   º       ºcambiaº    ",;
			  "mueveºF4 busca+ºmodificaºagregaº comprobante ºimprimeºorden ºsale"})

setcolor( C_MENU )
PRIVATE oX := MYBROWSE( 6, 1, 17, 78, aCpo )
OX:FREEZE:=3
oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()

@18,1 say padr(aOrden[indexord()],40,' ')
do while .T.
	MOVBROW( oX, {||nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_F7.OR.nk==K_ALT_F9.OR.nK==K_SH_F6.or.chr(nK)$'Oo'} )
	
	if oX:Cargo[TB_MSGE] == "MODIF".OR. OX:CARGO[TB_RET]==37
  	if CO->NUMCAJCH # 0
     	select CAC
  		GO CO->NUMCAJCH
     	FRLOCK()
     	CAC->FECHA   := CO->FECHA
     	CAC->CODCONC := "FAC"
     	CAC->DETALLE := CO->RAZONSOC
     	CAC->SALIDA  := CO->TOTAL
     	FRLOCK("VA")
     	VA->SALDARCAC := .T.
     	dbunlock()
     	select CO
     endif
		TBPOS(OX)
	ELSEIF OX:CARGO[TB_RET]==K_F2 .OR. OX:CARGO[TB_RET]==K_F5
  	if EDCOMV( OX:CARGO[TB_RET] )
			TBPOS(OX,.T.)
     endif
	ELSEIF OX:CARGO[TB_RET]==K_ALT_F9
  	copy to qq for round(NETO+EXENTO+IMPINT,2) # round(DESTINO1+DESTINO2+DESTINO3+DESTINO4+DESTINO5,2)
	ELSEIF chr(OX:CARGO[TB_RET]) $ 'Oo'
		op2 = PP_SELEC( 10, 30, 0, 0, aOrden, indexord(), "", "S", .T.)
		if lastkey() == K_ENTER
			set order to op2
		endif
		RECUPAN()
		TBPOS(OX,.T.)
		@18,1 say padr(aOrden[indexord()],40,' ')
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
		op = MENUFLASH( 10, 20, 1, .T., " IMPRIMIR ",  "Comprobantes","Agrupados x Proveedor",;
			"Agrupados x Plan de Cuenta","Comprob. x Plan de Cuenta","Totales IVA Compras" )
     IF op == 1
  		LISTAR("COMPV")
     ELSEIF op == 2
  		LISTAR("COMPVAGR")
     ELSEIF op == 3
  		LISTAR("COMVXPC")
     ELSEIF op == 4
  		LISTAR("COMVXPCD")
     ELSEIF op == 5
  		LISTAR("TIVACOM")
  	ENDIF
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO
DBUNLOCKALL()
DBCOMMITALL()

RETURN


************************

FUNC FNUMFACT( cualnum, cCatIva )

************************
PRIVATE c1, c2, n1, n2, i, c
cualnum := ALLTRIM(cualnum)

STORE "" TO c1, n1, n2
i := 1
DO WHILE i <= LEN(cualnum)
	c = SUBSTR( cualnum, i, 1 )
	IF .NOT. c $ "QWERTYUIOPASDFGHJKLZXCOBNM-/ "
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
if empty(c1)
  c1 := if(cCatIva$"EX RNI","FC ","FA ")
endif
cualnum = c1 + n1 +"-"+ n2
cualnum := JUSTIF( cualnum, 16, ">" )

RETURN cualnum


************

FUNC PROVEEV( nCual, lBrowser )

************
local cBase:=DBF(), cMenu, aCpo, OPC, r:=.f.
DEFAULT lBrowser TO .F.

seleCT PRV
set order to 1
if nCual # NIL
	r := dbseek( nCual )
endif
if !lBrowser
	if r
		r := PRV->RAZONSOC
	else
		r := space(len(PRV->RAZONSOC))
  endif
  select (cBase)
 	return(r)
endif
if eof();  dbgotop();  endif

aCpo:={;
	{ "CODPROV",    "C¢digo",                 '', 'F',  '',  0, 0 },;
	{ "RAZONSOC",   "Proveedor",              '', 'E',  '',  0, 0 },;
	{ "CATIVA",     "Cat;IVA",                '', 'E',  '',  0, 0 },;
	{ "CUIT",       "CUIT",                   '', 'E',  '',  0, 0 },;
	{ "CODPLAN",    "C¢d;Plan Cta",           '', 'E',  '',  0, 0 }}
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )

cMenu:=MENUDOWN({"  <+>  º    F2    º   F5   º F3 busca  º ESC  ",;
			  			"       º          º        º           º      ",;
			  			" mueve º modifica º agrega º F4 busca+ º sale "})

SETCOLOR(C_MENU)
MARCO( 8, 20, 18, 78, "³ PROVEEDORES "+if(M->TIPOPROV=="V","VARIOS ","")+"³", "S", .T., 0 )
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
     select CO
     go top
     fflock()
     seleCT PRV
     set order to forder({"CUIT"})
     do while ROSCA().and.!CO->(eof())
     	if !dbseek(CO->CUIT)
        	add_rec()
           PRV->CODPROV   := ULTIMO(dbf(),"CODPROV",1)+1
           PRV->RAZONSOC  := CO->RAZONSOC
           PRV->CUIT      := CO->CUIT
           PRV->CATIVA    := CO->CATIVA
           if CO->CODPROV # PRV->CODPROV
           	CO->CODPROV := PRV->CODPROV
           endif
        else
           if CO->CODPROV # PRV->CODPROV
           	CO->CODPROV := PRV->CODPROV
           endif
        endif
     	skip 1 alias CO
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
				ELSEIF "CODPLAN" $ EDNOM(EDX)
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
						MENSAJE( 0, 0, 10, .T., "FALTA RAZON SOCIAL !!!" )
					ELSEIF ascan(acativa,{|a|left(a,3)==EDCONT(EDX,"PRV->CATIVA")})==0
						MENSAJE( 0, 0, 10, .T., "CATEGORIA DE IVA INCORRECTA !!!" )
*					ELSEIF val(EDCONT(EDX,"PRV->CUIT")) == 0
*						MENSAJE( 0, 0, 10, .T., "C.U.I.T. INCORRECTO !!!" )
					ELSE
     				if "AGREG" $ EDX[ED_MODAPP]
        				F_ALTA({|| FIELD->CODPROV#0})
        			endif
           		EDX[ED_REGISTRO] := recno()
						FEDITOR( EDX, "GRABAR", .F. )
                 if procname(2)=="COMV"
                 	if PRV->(dbseek(CO->CODPROV))
                 		frlock("PRV")
                    	PRV->CODPLAN1 := CO->CODPLAN1
                    	PRV->CODPLAN2 := CO->CODPLAN2
                    	PRV->CODPLAN3 := CO->CODPLAN3
                    	PRV->CODPLAN4 := CO->CODPLAN4
                    	PRV->CODPLAN5 := CO->CODPLAN5
                    	PRV->(dbunlock())
                 	endif
                 endif
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


****************

FUNC EDCOMV( K )

****************
LOCAL aux, xmenu, nOrder, nReg

xmenu:=MENUDOWN({"     º presione TAB para º  F2 º  F10  º  ESC   ",;
						"       º obtener una lista ºeditaº       º        ",;
						" mueve º de opciones ()   ºcampoº graba º  sale  "})

FEDITOR(EDC,"PONEPAN")
FEDITOR( EDC, "SETVARS", K, .F. )
IF K == K_F5
	AX_FECHA    := VA->FECHA
	AX_FECHVENC := VA->FECHA
  EDPONE(EDC,"CO->TIPOCOMPRA",1)
ENDIF
EDC[ED_MODE] = "MOSTRARTODO"

DO WHILE .T.
	FEDITAR( EDC, { K_TAB, K_F10 } )
  lRecalc := .F.
	IF EDC[ED_UPDATE] .OR. EDC[ED_TECLA]==K_TAB
		EDC[ED_MODE] = "MOSTRARTODO"
     M->PIVA1 := VA->PIVA1
     IF AX_CATIVA == "RNI"
			M->PIVA1 += VA->PIVA2
     ELSEIF AX_CATIVA == "EX "
			M->PIVA1 := 0
     ENDIF
		IF EDNOM(EDC) $ "CO->NUMFAC CO->CODPROV"
			IF EDNOM(EDC) == "CO->CODPROV"
				IF EDC[ED_TECLA] == K_TAB
					if PROVEEV( AX_CODPROV, .T. )
						EDPONE(EDC,"CO->CODPROV", PRV->CODPROV )
              endif
           ENDIF
           IF empty(PROVEEV(AX_CODPROV))
					EDPONE(EDC,"CO->CODPROV", 0 )
           	EDPONE(EDC,"CO->RAZONSOC", space(len(CO->RAZONSOC)) )
					EDPONE(EDC,"CO->CATIVA", space(len(PRV->CATIVA)) )
           	EDPONE(EDC,"CO->CUIT", space(len(PRV->CUIT)) )
           	EDPONE(EDC,"CO->PIVA1", 0 )
           ELSE
					EDPONE(EDC,"CO->CODPROV", PRV->CODPROV )
           	EDPONE(EDC,"CO->RAZONSOC", PRV->RAZONSOC )
					EDPONE(EDC,"CO->CATIVA", PRV->CATIVA )
           	EDPONE(EDC,"CO->CUIT", PRV->CUIT )
           	EDPONE(EDC,"CO->PIVA1", if(PRV->PIVA1==0,VA->PIVA1,PRV->PIVA1) )
              if val(EDCONT(EDC,"CO->CODPLAN1"))+val(EDCONT(EDC,"CO->CODPLAN2"))+;
						val(EDCONT(EDC,"CO->CODPLAN3"))+val(EDCONT(EDC,"CO->CODPLAN4"))+val(EDCONT(EDC,"CO->CODPLAN5"))==0
              	EDPONE(EDC,"CO->CODPLAN1",PRV->CODPLAN1)
              	EDPONE(EDC,"CO->CODPLAN2",PRV->CODPLAN2)
              	EDPONE(EDC,"CO->CODPLAN3",PRV->CODPLAN3)
              	EDPONE(EDC,"CO->CODPLAN4",PRV->CODPLAN4)
              	EDPONE(EDC,"CO->CODPLAN5",PRV->CODPLAN5)
              endif
				ENDIF
  			lRecalc := .F.
			ELSEIF EDNOM(EDC) == "CO->NUMFAC"
 				AX_NUMFAC := FNUMFACT(EDCONT(EDC),EDCONT(EDC,"CO->CATIVA"))
			ENDIF
			if EDC[ED_MODAPP] == "AGREGAR"
				nReg = RECNO()
           set order to CO_CODPROV_NUMFAC
				SEEK STR(AX_CODPROV,FLEN(CO->CODPROV)) + AX_NUMFAC
				if found()
					MENSAJE( 0, 0, 10, .T., "N§ DE FACTURA REPETIDA !!!" )
*					EDPONE(EDC,,EDC[ED_LAST])
				endif
				GO nReg
			else
				nReg = RECNO()
				SEEK STR(AX_CODPROV,FLEN(CO->CODPROV)) + AX_NUMFAC
				DO WHILE CO->CODPROV==AX_CODPROV .AND. CO->NUMFAC==AX_NUMFAC
					IF RECNO() != nReg
						MENSAJE( 0, 0, 10, .T., "N§ DE FACTURA REPETIDA !!!" )
*						EDPONE(EDC,,EDC[ED_LAST] )
						exit
					endif
					skip
				enddo
				go nReg
           set order to CO_FECHA_CODPROV
			endif
		ELSEIF EDNOM(EDC) == "CO->TIPOFAC"
			ele = ABRW( EDC[ED_Y], EDC[ED_X], 0, 'vtipofac', ascan(vtipofac,{|a|left(a,3)==EDCONT(EDC)}), 'TIPO FACT.')
			IF LASTKEY() == K_ENTER
				EDPONE(EDC,,left(vtipofac[ele],3))
			ENDIF
		ELSEIF EDNOM(EDC) == "CO->CATIVA"
			IF EDC[ED_TECLA] == K_TAB
				ele = PP_SELEC( EDC[ED_Y], EDC[ED_X], 0, 0, acativa, ascan(acativa,{|a|left(a,3)==EDCONT(EDC)}), "", "S", .T.)
				IF LASTKEY() == K_ENTER
					EDPONE( EDC, , LEFT(acativa[ele],3) )
     			lRecalc := .T.
				ENDIF
				RECUPAN()
			ENDIF
		ELSEIF EDC[ED_TECLA]==K_TAB .AND. EDNOM(EDC) == "CO->TIPOCOMPRA"
			ele = PP_SELEC( EDC[ED_Y], EDC[ED_X], 0, 0, atipoventa, EDCONT(EDC), "", "S", .T.,.T.)
			IF LASTKEY() == K_ENTER
				EDPONE(EDC,,VAL(atipoventa[ele]) )
			ENDIF
			RECUPAN()
        IF EDCONT(EDC,"CO->TIPOCOMPRA") == 1
        	AX_FECHVENC := EDCONT(EDC,"CO->FECHA")
        ELSE
				AX_FECHVENC := FFECHVENC( AX_FECHA, 2 )
        ENDIF
			EDC[ED_MODE] = "MOSTRARTODO"
		ELSEIF "CODPLAN" $ EDNOM(EDC) .and. EDC[ED_TECLA]==K_TAB
			IF PC( EDCONT(EDC), .T. )
				EDPONE(EDC,,PC->CODPLAN)
			ENDIF
		ELSEIF EDNOM(EDC) $ "CO->NETO CO->PIVA1"
			lRecalc := .T.
		ELSEIF EDNOM(EDC) == "CO->TOTAL"
			EDPONE(EDC,"CO->NETO", ( EDCONT(EDC,"CO->TOTAL")-EDCONT(EDC,"CO->EXENTO")-EDCONT(EDC,"CO->EXENTO")-EDCONT(EDC,"CO->PERCEPCION")-EDCONT(EDC,"CO->PERCIIBB") ) / ( (AX_PIVA1)/100+1 ) )
			EDPONE(EDC,"CO->CREDITO", EDCONT(EDC,"CO->NETO") * AX_PIVA1 / 100 )
     ENDIF
     if lRecalc
     	M->PIVA1 := VA->PIVA1
     	IF AX_CATIVA == "RNI"
				M->PIVA1 += VA->PIVA2
     	ELSEIF AX_CATIVA == "EX "
				M->PIVA1 := 0
     	ENDIF
			EDPONE(EDC,"CO->CREDITO", EDCONT(EDC,"CO->NETO") * AX_PIVA1 / 100 )
     endif
     EDPONE(EDC,"CO->TOTAL", EDCONT(EDC,"CO->NETO")+ EDCONT(EDC,"CO->CREDITO")+ EDCONT(EDC,"CO->EXENTO")+ EDCONT(EDC,"CO->IMPINT")+EDCONT(EDC,"CO->PERCEPCION")+EDCONT(EDC,"CO->PERCIIBB") )
     if val(EDCONT(EDC,"CO->CODPLAN2"))==0 .and. !"DESTINO"$EDNOM(EDC)
     	EDPONE(EDC,"CO->DESTINO1",EDCONT(EDC,"CO->NETO")+EDCONT(EDC,"CO->IMPINT")+EDCONT(EDC,"CO->EXENTO"))
     endif
     EDPONE(EDC,"CO->TOTAL", EDCONT(EDC,"CO->NETO")+EDCONT(EDC,"CO->CREDITO")+ EDCONT(EDC,"CO->EXENTO")+ EDCONT(EDC,"CO->IMPINT")+EDCONT(EDC,"CO->PERCEPCION")+EDCONT(EDC,"CO->PERCIIBB") )
	ELSEIF EDC[ED_TECLA] == K_ESC .OR. EDC[ED_TECLA] == K_F10
  	aux := "S"
		IF EDC[ED_TECLA] == K_F10
     	aux := "G"
		ELSEIF FEDITOR( EDC, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
     ENDIF
		IF aux == "G"
			IF EMPTY(EDCONT(EDC,"CO->RAZONSOC"))
				MENSAJE( 0, 0, 10, .T., "FALTA RAZON SOCIAL !!!" )
			ELSEIF ascan(acativa,{|a|left(a,3)==EDCONT(EDC,"CO->CATIVA")})==0
				MENSAJE( 0, 0, 10, .T., "CATEGORIA DE IVA INCORRECTA !!!" )
 			ELSEIF EDCONT(EDC,"CO->FECHA") <= VA->FECHSEG
 				MENSAJE( 0, 0, 10, .T., "LA FECHA DEL COMPROBANTE ES MENOR O IGUAL"," A LA FECHA DE CIERRE DEL SISTEMA !" )
			ELSEIF round(EDCONT(EDC,"CO->NETO")+EDCONT(EDC,"CO->IMPINT")+EDCONT(EDC,"CO->EXENTO"),2) # round(EDCONT(EDC,"CO->DESTINO1")+EDCONT(EDC,"CO->DESTINO2")+EDCONT(EDC,"CO->DESTINO3")+EDCONT(EDC,"CO->DESTINO4")+EDCONT(EDC,"CO->DESTINO5"),2)
				MENSAJE( 0, 0, 10, .T., "LOS RUBROS NO SUMAN NETO+IMP.INT.+EXENTO/NO GRAV !" )
			ELSEIF ( empty(EDCONT(EDC,"CO->CODPLAN1")) .and. EDCONT(EDC,"CO->DESTINO1")#0 ) .or.;
					 ( empty(EDCONT(EDC,"CO->CODPLAN2")) .and. EDCONT(EDC,"CO->DESTINO2")#0 ) .or.;
					 ( empty(EDCONT(EDC,"CO->CODPLAN3")) .and. EDCONT(EDC,"CO->DESTINO3")#0 ) .or.;
					 ( empty(EDCONT(EDC,"CO->CODPLAN4")) .and. EDCONT(EDC,"CO->DESTINO4")#0 ) .or.;
					 ( empty(EDCONT(EDC,"CO->CODPLAN5")) .and. EDCONT(EDC,"CO->DESTINO5")#0 )
				MENSAJE( 0, 0, 10, .T., "FALTA CODIGO DE PLAN DE CUENTA !" )
			ELSE
				IF EDC[ED_MODAPP] == "AGREGAR"
					go top
					if !empty(CO->FECHA) .or. lastrec()==0
           		add_rec()
           	else
           		frlock()
              	recall
           	endif
           endif
           EDC[ED_REGISTRO] := recno()
				FEDITOR( EDC, "GRABAR", .F. )
           if PRV->(dbseek(CO->CODPROV))
           	frlock("PRV")
              PRV->CODPLAN1 := CO->CODPLAN1
              PRV->CODPLAN2 := CO->CODPLAN2
              PRV->CODPLAN3 := CO->CODPLAN3
              PRV->CODPLAN4 := CO->CODPLAN4
              PRV->CODPLAN5 := CO->CODPLAN5
              PRV->(dbunlock())
           endif
				EXIT
			ENDIF
		ELSEIF aux == "S"
			EXIT
		ENDIF
	ENDIF
ENDDO
FEDITOR(EDC,"SACAPAN")
MENUDOWN(xmenu)

RETURN ( aux=="G" )
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local cBaseAux:=xname('XAUX')

if listado == "COMPV"
  if QUEFECHA2(10,30)
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
     select CO
		nNETO        := 0
		nCREDITO     := 0
		nEXENTO      := 0
		nIMPINT      := 0
		nTOTAL       := 0
		nPERCEPCION  := 0
		nPERCIIBB    := 0
		nRETIB       := 0
		nRETGAN      := 0
		nRETIVA      := 0
     nCANT := 0
     dbseek(FTOC(DESDE),.T.)
     do while CO->FECHA>=DESDE .and. CO->FECHA<=HASTA .and. !eof()
        if !eof()
				CABEZA( 1 ); ++I_CL
				? I_esp + ARMOLIN(I_cab+1)
				nNETO        += CO->NETO
				nCREDITO     += CO->CREDITO
				nEXENTO      += CO->EXENTO
				nIMPINT      += CO->IMPINT
				nTOTAL       += CO->TOTAL
				nPERCEPCION  += CO->PERCEPCION
				nPERCIIBB    += CO->PERCIIBB
				nRETIB       += CO->RETIB
				nRETGAN      += CO->RETGAN
				nRETIVA      += CO->RETIVA
     		++nCANT
			endif
        skip
  	enddo
		CABEZA( 2 ); I_CL += 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
  	RECUPAN()
		LISTADOR( "FIN" )
  endif

ELSEIF listado == "COMPVAGR"
  IF QUEFECHA2(10,30)
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
  	SELECT 99;	DBCLOSEAREA()
     SELECT CO
		nNETO        := 0
		nCREDITO     := 0
		nEXENTO      := 0
		nIMPINT      := 0
		nTOTAL       := 0
		nPERCEPCION  := 0
		nRETIB       := 0
		nRETGAN      := 0
		nRETIVA      := 0
     DBSEEK(FTOC(DESDE),.T.)
     INDEX ON CO->CODPROV TO (XNAME('XAUX')) REST FOR CO->FECHA>=DESDE .AND. CO->FECHA<=HASTA 		//WHILE CO->FECHA<=HASTA
     TOTAL ON CO->CODPROV FIELDS NETO,CREDITO,EXENTO,IMPINT,TOTAL,PERCEPCION,RETIB,RETGAN,RETIVA TO (XNAME('XAUX'))
     SELECT 99
     USE (XNAME('XAUX')) ALIAS X
     INDEX ON X->RAZONSOC TO (XNAME('XAUX'))
     GO TOP
  	DO WHILE !EOF()
        IF X->TOTAL # 0
				CABEZA( 1 ); ++I_CL
				? I_esp + ARMOLIN(I_cab+1)
				nNETO        += X->NETO
				nCREDITO     += X->CREDITO
				nEXENTO      += X->EXENTO
				nIMPINT      += X->IMPINT
				nTOTAL       += X->TOTAL
				nPERCEPCION  += X->PERCEPCION
				nRETIB       += X->RETIB
				nRETGAN      += X->RETGAN
				nRETIVA      += X->RETIVA
        ENDIF
        SKIP
  	ENDDO
		CABEZA( 2 ); I_CL += 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
	FREABRIR({"COMPRASV"})
	SELECT CO

ELSEIF listado == "COMVXPC"
  IF QUEFECHA2(10,30)
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
  	select 99;	dbclosearea()
     dbcreate(cBaseAux,{{"CODPLAN","C",10,0},{"IMPORTE","N",10,2}})
     select 99
     use (cBaseAux) alias X exclusive
     index on X->CODPLAN to (cBaseAux)
     select CO
		set order to CO_FECHA_CODPROV
     dbseek(ftoc(DESDE),.t.)
     select 99
     do while BETWEEN(CO->FECHA,DESDE,HASTA) .and. !CO->(eof())
			for i=1 to 5
        	cAux1:="CO->CODPLAN"+str(i,1)
        	cAux2:="CO->DESTINO"+str(i,1)
*          if !empty(&(cAux1)) .and. &(cAux2)#0
           if &(cAux2)#0
     			if !dbseek(&(cAux1))
           		append blank
           		X->CODPLAN := &(cAux1)
           	endif
           	X->IMPORTE += &(cAux2)
           endif
        next
        skip 1 alias CO
     enddo
     M->IMPORTE := 0
		select X
     dbgotop()
     do while !eof()
     	if X->IMPORTE # 0
				CABEZA( 1 ); I_CL += 1
				? I_esp + ARMOLIN(I_cab+1)
     		M->IMPORTE += X->IMPORTE
        endif
     	skip
     enddo
		CABEZA( 2 ); I_CL += 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
	select CO

ELSEIF listado == "COMVXPCD"
	if PC( ,.T.,.T. )
  	if QUEFECHA2(10,30)
			nNETO2       := 0
			nEXENTO2     := 0
			nIMPINT2     := 0
        nDESTINO2    := 0
			LISTADOR( "INI" )
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			select PC
        dbgotop()
        select CO
			set order to CO_FECHA_CODPROV
        do while !PC->(eof())
        	if PC->MARCA==""
					nNETO        := 0
					nEXENTO      := 0
					nIMPINT      := 0
        		nDESTINO1    := 0
					CABEZA( 2 ); I_CL += 2
              ?
					? I_esp + PC->CODPLAN +' '+PC->DESCPLAN
     			dbseek(ftoc(DESDE),.T.)
     			do while BETWEEN(CO->FECHA,DESDE,HASTA) .and. !CO->(eof())
						for i=1 to 5
        				cAux1:="CO->CODPLAN"+str(i,1)
        				cAux2:="CO->DESTINO"+str(i,1)
     					if &(cAux1) == PC->CODPLAN .and. &(cAux2)#0
                    	nDESTINO := &(cAux2)
								CABEZA( 1 ); I_CL += 1
								? I_esp + ARMOLIN(I_cab+1)
								nNETO        += CO->NETO
								nEXENTO      += CO->EXENTO
								nIMPINT      += CO->IMPINT
                       nDESTINO1    += nDESTINO
								nNETO2       += CO->NETO
								nEXENTO2     += CO->EXENTO
								nIMPINT2     += CO->IMPINT
                       nDESTINO2    += nDESTINO
           			endif
        			next
        			skip 1 alias CO
     			enddo
					CABEZA( 2 ); I_CL += 2
					? I_esp + strtran(ARMOLIN(I_cab),"=","-")
					? I_esp + ARMOLIN(I_cab+2)
           endif
           skip 1 alias PC
        enddo
			CABEZA( 3 ); I_CL += 3
        ?
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+3)
			LISTADOR( "FIN" )
			RECUPAN()
		endif
	endif
	select CO

ELSEIF listado == "TIVACOM"
  if QUEFECHA2(10,30)
 		LISTADOR( "INI" )
 		if !SETIMPRESORA("INI");  break(nil);  endif
 		DO ICARGA WITH listado
  	select 99;  dbclosearea()
     aaux:={{"DESCRIPC","C",20,0},{"PIVA1","N",7,2},{"NETO","N",12,2},{"IMPINT","N",12,2},;
				{"CREDITO","N",10,2},{"EXENTO","N",12,2},{"PERCEPCION","N",12,2},{"PERCIIBB","N",12,2},{"TOTAL","N",12,2}}
     dbcreate(cBaseAux,aaux)
     select 99
     use (cBaseAux) alias X exclusive
     index on X->DESCRIPC to (cBaseAux)
		nNETO        := 0
		nEXENTO      := 0
		nIMPINT      := 0
     nCREDITO     := 0
     nPERCEPCION  := 0
     nPERCIIBB    := 0
     nTOTAL       := 0
     CO->(dbseek(ftoc(DESDE),.T.))
     do while BETWEEN(CO->FECHA,DESDE,HASTA) .and. !CO->(eof())
     	if "LP"$left(CO->NUMFAC,3)
     		cAux:="TOTAL NLP"
        else
        	cAux:="TOTAL "+str(CO->PIVA1)+" %"
        endif
        cAux:=padr(cAux,20," ")
        if !dbseek(cAux)
        	append blank
           X->DESCRIPC := cAux
        endif
			X->NETO        += CO->NETO
			X->EXENTO      += CO->EXENTO
			X->IMPINT      += CO->IMPINT
			X->CREDITO     += CO->CREDITO
     	X->PERCEPCION  += CO->PERCEPCION
     	X->PERCIIBB    += CO->PERCIIBB
			X->TOTAL       += CO->TOTAL
			X->PIVA1       := CO->PIVA1
     	skip 1 alias CO
     enddo
     select 99;  dbgotop()
     do while !eof()
			CABEZA( 1 ); I_CL += 1
			? I_esp + ARMOLIN(I_cab+1)
			nNETO        += X->NETO
			nEXENTO      += X->EXENTO
			nIMPINT      += X->IMPINT
        nCREDITO     += X->CREDITO
     	nPERCEPCION  += X->PERCEPCION
     	nPERCIIBB    += X->PERCIIBB
        nTOTAL       += X->TOTAL
        skip
     enddo
		CABEZA( 3 ); I_CL += 3
     ?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		LISTADOR( "FIN" )
		RECUPAN()
	endif
	select CO
endif

return
