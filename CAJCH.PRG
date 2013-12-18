local cBase:=dbf()
PRIVATE aCpo, OX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

#ifdef DOCSA
	if procname(2)=="FF"
  	FBASES({"+CAJCH4"})
  else
		op = MENUFLASH( ym2, xm2, 1, .T., "",  "CAJA CHICA 1 ",;
															"CAJA CHICA 2 ",;
 															"CAJA CHICA 3 ",;
 															"CAJA CHICA 4 " )
		if lastkey() # K_ENTER
			return
		endif
		FBASES({ "CAJCH"+str(op,1), "COMPRASV", "PROVEEV", "GASTOS" })
  endif
#else
	FBASES({ "CAJCH", "COMPRASV", "PROVEEV", "GASTOS" })
#endif
cPantalla:=savescreen(0,0,24,79)
		
LOGO(.T., " CAJA CHICA " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
DO CARGAVEC WITH "CAJCH", 50

aCpo:={	{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
		   { "CODCONC",    "C¢d;Conc",                           '', 'M',  '',  0, 0 },;
			{ "FVECTOR(vcajch,CAC->CODCONC)",;
								 "Descripci¢n",              REPL('X',10), 'F', 'F',  0, 0 },;
			{ "DETALLE",    "Detalle; ",                      '@S20', 'M', 'C',  0, 0 },;
		  	{ "ENTRADA",    "Entrada",                            '', 'M',  '',  0, 2 },;
		  	{ "SALIDA",     "Salida",                             '', 'M',  '',  0, 0 },;
		  	{ "SALDO",      "Saldo",                              '', 'F',  '',  0, 0 }}

SELECT CAC
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
IF VA->SALDARCAC
	GO TOP
	FSALDAR()
  FRLOCK("VA")
  VA->SALDARCAC := .F.
ENDIF
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º   F7   º  F8  º   F9    º   F12   º    TAB    º ESC  ",;
			  "       º F3 busca  º        ºpasa aºrecalculaº detalle º           º      ",;
			  " mueve º F4 busca+ ºlistadosºgastosº saldos  º factura º conceptos º sale "})

SETCOLOR( "W/N,N/W" )

OX := MYBROWSE( 4, 1, 20, 78, aCpo )

OX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "CAJACH", OX, aedits )
TBCOLOR(OX)


DO WHILE .T.
	
	MOVBROW( OX, {||nK==K_TAB.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_SH_F6.OR.nK==K_F7.OR.nK==K_ALT_E.OR.nK==K_F12.OR.nK==K_F9.OR.nK==K_F8}, {||NK==999} )
	
	IF OX:Cargo[TB_MSGE] == "MODIF"
     if FP()
			IF OX:CARGO[TB_NOMBRE,OX:ColPos] $ "ENTRADA SALIDA"
				IF CAC->NUMCOMPRAV == 0
					FRLOCK()
					FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]) := OX:CARGO[TB_CONT]
					FSALDAR()
        		TBPOS(OX,.T.)
        	ELSE
        		MENSAJE( 0, 0, 10, .T., "MODIFICAR CON F12" )
        	ENDIF
			ELSEIF OX:CARGO[TB_NOMBRE,OX:ColPos] $ "FECHA"
				IF CAC->NUMCOMPRAV == 0
					xreg := RECNO()
					aux := MIN( FIELD->FECHA, OX:CARGO[TB_CONT] )
					FRLOCK()
					FIELD->FECHA := OX:CARGO[TB_CONT]
        		SET SOFTSEEK ON
					SEEK FTOC(aux)
        		SET SOFTSEEK OFF
					FSALDAR()
					DBGOTO( xreg )
					TBPOS(OX,.T.)
        	ELSE
        		MENSAJE( 0, 0, 10, .T., "MODIFICAR CON F12" )
        	ENDIF
			ELSE
				FRLOCK()
				FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]) := OX:CARGO[TB_CONT]
				UNLOCK
     		TBPOS(OX)
			ENDIF
     	IF CAC->NUMGASTO # 0
				SELECT GA
        	GO CAC->NUMGASTO
     		FRLOCK()
     		GA->FECHA    := CAC->FECHA
     		GA->CODGAS   := CAC->CODCONC
     		GA->DETALLE  := CAC->DETALLE
     		GA->IMPORTE  := CAC->SALIDA
     		GA->NUMCAJCH := CAC->(RECNO())
				DBUNLOCK()
     		SELECT CAC
     	ENDIF
     endif
	ELSEIF OX:Cargo[TB_RET] == K_TAB .AND. OX:CARGO[TB_NOMBRE,OX:ColPos] == "CODCONC" .and. FP()
		aux := ABRW( 10, 40, 0, 'vcajch', FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]), 'CONCEPTOS')
		IF LASTKEY() == K_ENTER
			FRLOCK()
			FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]) := vcajch[aux]
			UNLOCK
			OX:RefreshCurrent()
		ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. CAC->NUMCOMPRAV # 0 .AND. FP()
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
			BLANKREG(.T.)
			SKIP -1
			FSALDAR()
     	TBPOS(OX,.T.)
		ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_SH_F6 .AND. CAC->NUMCOMPRAV # 0 .and. FP()
		BLANKREG(.T.)
		SKIP -1
		FSALDAR()
     TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_F9
		xreg := RECNO()
		DBGOTOP()
		FSALDAR()
		DBGOTO( xreg )
     TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_F8
		SELECT GA
     IF CAC->NUMGASTO == 0
     	F_ALTA( FTOC(CTOD(""))+" " )
     ENDIF
     FRLOCK()
     GA->FECHA      := CAC->FECHA
     GA->CODGAS     := CAC->CODCONC
     GA->DETALLE    := CAC->DETALLE
     GA->IMPORTE    := CAC->SALIDA
     GA->NUMCAJCH   := CAC->(RECNO())
     GA->NUMCOMPRAV := CAC->NUMCOMPRAV
		DBUNLOCK()
     SELECT CAC
     FRLOCK()
     CAC->NUMGASTO := GA->(RECNO())
		DBUNLOCK()
     TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == 999
 		IF FIELD->ENTRADA + FIELD->SALIDA # 0
  		SKIP
     	IF EOF()
				DBGOBOTTOM()
				aux  := FIELD->FECHA
				xreg := F_ALTA( FTOC(CTOD('')) )
				FRLOCK()
				FIELD->FECHA := aux
     		DBGOTO(xreg)
        ENDIF
     	TBPOS(OX)
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F12
  	grabar := .F.
		xmenu:=MENUDOWN({"     º   TAB   º   F10   º  ESC   ",;
							  "       º proveed.º graba y º        ",;
							  " mueve º cat.IVA º procede º  sale  "})
  	SELECT CV
		aaux := NEWEDIT( "COMV",,.T. )
		SET ORDER TO 1
     IF CAC->NUMCOMPRAV == 0
     	GO TOP
			FEDITOR( aaux, "SETVARS", K_F5, .F. )
			aaux[ED_REGISTRO] := IF( !EMPTY(CO->FECHA).OR.LASTREC()==0, LASTREC()+1, RECNO() )
			EDPONE(aaux,"CO->FECHA", CAC->FECHA)
     ELSE
     	GO CAC->NUMCOMPRAV
			FEDITOR( aaux, "LEER" )
			aaux[ED_REGISTRO] := RECNO()
     ENDIF
     aaux[ED_I] := 2
		aaux[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( aaux, { K_F10, K_TAB } )
			IF aaux[ED_UPDATE] .OR. aaux[ED_TECLA] == K_TAB
				aaux[ED_MODE] = "MOSTRARTODO"
           IF EDNOM(aaux) == "CO->CATIVA"
					IF aaux[ED_TECLA] == K_TAB
						ele = PP_SELEC( aaux[ED_Y], aaux[ED_X], 0, 0, acativa, EDCONT(aaux), "", "S", .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(aaux,,LEFT(acativa[ele],3))
						ENDIF
						RECUPAN()
              ENDIF
           ELSEIF EDNOM(aaux) == "CO->CODPROV"
					IF aaux[ED_TECLA] == K_TAB
						IF FELEGIR( "PROVEEV", EDCONT(aaux) ) # 0
							EDPONE( aaux, "CO->CODPROV", PRV->(RECNO()) )
              		aaux[ED_I] += 4
                 ENDIF
              ELSEIF !EMPTY(PROVEEV(EDCONT(aaux)))
						EDPONE( aaux, "CO->CODPROV", PRV->(RECNO()) )
              	aaux[ED_I] += 3
              ENDIF
           	EDPONE( aaux, "CO->RAZONSOC", PRV->RAZONSOC )
					EDPONE( aaux, "CO->CATIVA", PRV->CATIVA )
           	EDPONE( aaux, "CO->CUIT", PRV->CUIT )
           ELSEIF EDNOM(aaux) == "CO->NETO"
           	EDPONE(aaux,"CO->CREDITO", EDCONT(aaux,"CO->NETO")*VA->PIVA1/100 )
           ELSEIF EDNOM(aaux) == "CO->TOTAL"
           	aux := EDCONT(aaux,"CO->TOTAL") - EDCONT(aaux,"CO->IMPINT") - EDCONT(aaux,"CO->EXENTO")
           	EDPONE(aaux,"CO->NETO", aux / (1+VA->PIVA1/100) )
           	EDPONE(aaux,"CO->CREDITO", EDCONT(aaux,"CO->NETO")*VA->PIVA1/100 )
           ENDIF
          	EDPONE( aaux, "CO->TOTAL", EDCONT(aaux,"CO->NETO") +EDCONT(aaux,"CO->CREDITO") +EDCONT(aaux,"CO->IMPINT") +EDCONT(aaux,"CO->EXENTO") )
				aaux[ED_MODE] = "MOSTRARTODO"
			ELSEIF ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_ESC
				aux := FEDITOR(aaux,"GRABAR",.T.)
           grabar := ( aux == "G" )
           IF aux # "C"
					EXIT
           ENDIF
			ELSEIF aaux[ED_TECLA] == K_F10
           FRLOCK()
				FEDITOR(aaux,"GRABAR",.F.)
  			grabar := .T.
				EXIT
			ENDIF
		ENDDO
		FEDITOR(aaux,"SACAPAN")
		MENUDOWN(xmenu)
     SELECT CAC
     IF grabar
     	FRLOCK()
     	CAC->FECHA   := CO->FECHA
        CAC->CODCONC := "FAC"
        CAC->DETALLE := CO->RAZONSOC
        CAC->SALIDA  := CO->TOTAL
        CAC->NUMCOMPRAV := CO->(RECNO())
     	SELECT CV
     	FRLOCK()
        CO->NUMCAJCH := CAC->(RECNO())
     	IF CAC->NUMGASTO # 0
				SELECT GA
        	GO CAC->NUMGASTO
     		FRLOCK()
     		GA->FECHA    := CAC->FECHA
     		GA->CODGAS   := CAC->CODCONC
     		GA->DETALLE  := CAC->DETALLE
     		GA->IMPORTE  := CAC->ENTRADA - CAC->SALIDA
     		GA->NUMCAJCH := CAC->(RECNO())
				DBUNLOCK()
     		SELECT CAC
     	ENDIF
     	SELECT CAC
     	FSALDAR()
     ENDIF
     TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F7 .and. procname(2)#"FF"
		IF MARCABRW( 7, 30, vcajch, LV(vcajch) ) # 0
			LISTAR( "CAJCH" )
		ENDIF
  	TBPOS(OX)
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "CAJCH", OX, aedits, "EDITS.EST" )
	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO
restscreen(0,0,24,79,cPantalla)
DBUNLOCKALL()
DBCOMMITALL()
select (cBase)

RETURN


************

STATIC FUNC FSALDAR

************
LOCAL xreg := RECNO(), xsaldo

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
FFLOCK()
SKIP -1
IF RECNO() == xreg
	CAC->SALDO := CAC->ENTRADA - CAC->SALIDA
ENDIF
xsaldo := CAC->SALDO
SKIP
DO WHILE !EOF()
	CAC->SALDO := xsaldo + CAC->ENTRADA - CAC->SALIDA
	xsaldo := CAC->SALDO
	SKIP
ENDDO
DBGOTO( xreg )
UNLOCK
RECUPAN()

RETURN .T.
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
IF listado == "CAJCH"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		xreg := RECNO()
		SELECT 99
		DBCLOSEAREA()
		SELECT CAC
		base := XNAME("XAUX")
		aux := "   -"
		AEVAL( vcajch,{|a| aux+=IF(RIGHT(a,1)=='',LEFT(a,4),'') } )
		SET SOFTSEEK ON
		SEEK FTOC(DESDE)
		COPY TO &base REST FOR CAC->ENTRADA+CAC->SALIDA#0.and.CAC->CODCONC+"-"$aux WHILE CAC->FECHA<=HASTA
		SELECT 99
		USE &base ALIAS X
		INDEX ON X->CODCONC TO &base
		M->ENTRADA := M->SALIDA := 0
		GO TOP
		I_codaux := "@@@"
		DO WHILE !EOF()
			IF SALIR()
				EXIT
			ENDIF
			IF I_codaux # X->CODCONC
				IF !I_INI
					CABEZA( 2 )
					I_CL += 2
					? I_esp + ARMOLIN(I_cab)
					?  I_esp + ARMOLIN(I_cab+2)
				ENDIF
				CABEZA( 2 )
				?
				? I_esp + ""+ FVECTOR( vcajch, X->CODCONC )
				I_CL += 1
				I_codaux = X->CODCONC
				M->ENTRADA := M->SALIDA := 0
			ENDIF
			CABEZA( 1 )
			++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			M->ENTRADA += X->ENTRADA
			M->SALIDA  += X->SALIDA
			SKIP
		ENDDO
		SET SOFTSEEK OFF
		CABEZA( 2 )
		I_CL += 2
		? I_esp + ARMOLIN(I_cab)
		?  I_esp + ARMOLIN(I_cab+2)
     SELECT 99
     DBCLOSEAREA()
		SELECT CAC
		DBGOTO( xreg )
		RECUPAN()
	endif
	LISTADOR( "FIN" )
	RECUPAN()
endif

return


****************

STATIC FUNC FP()

****************
local lAux:=.T.

if procname(3)=="FF"
 	if !empty(FIELD->FECHA).and.FIELD->FECHA<VA->FECHA
  	lAux:=.F.
  endif
endif

return lAux
