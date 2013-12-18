LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " GASTOS " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
DO CARGAVEC WITH "PREST", 20
DO CARGAVEC WITH "GASTO", 50

aCpo:={;
	{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
	{ "TURNO",      "T",                                  '', 'M',  '',  0, 0 },;
	{ "CODGAS",     "C¢d;Gas",                            '', 'M',  '',  0, 0 },;
	{ "FVECTOR(vgasto,GA->CODGAS)","Descripci¢n",REPL('X',20),'F', 'F',  0, 0 },;
	{ "DETALLE",    "Detalle; ",                          '', 'M',  '',  0, 0 },;
	{ "IMPORTE",    "Importe; ",                          '', 'M',  '',  0, 0 }}

FBASES({ "GASTOS", "CAJCH", "GASTOS2" })

SELECT GA
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º    F6    º   F7    º    F8     º    TAB    º  ESC   ",;
			  "       º F3 busca  º Shift F6 º         º   otros   º c¢digo de º        ",;
			  " mueve º F4 busca+ º elimina  º imprime º conceptos º  gastos   º  sale  "})

SETCOLOR( C_MENU )

oX := MYBROWSE( 4, 1, 20, 78, aCpo )

oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()

DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-7.OR.nk==-6.OR.nK==K_SH_F6}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
		UNLOCK
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB
		IF TBNOC(oX) == "CODGAS"
			ele := ABRW( 10, 40, 0, 'vgasto', FIELD->&(TBNOC(oX)), 'GASTOS' )
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->&(TBNOC(oX)) := vgasto[ele]
				DBUNLOCK()
			ENDIF
		ENDIF
		TBPOS(OX)
	ELSEIF OX:Cargo[TB_RET] == 999
  	SKIP
     IF EOF()
			DBGOBOTTOM()
 			IF FIELD->IMPORTE # 0
				aux  := FIELD->FECHA
				xreg := F_ALTA( FTOC(CTOD('')) )
				FRLOCK()
				FIELD->FECHA := aux
     		DBGOTO(xreg)
				TBPOS(OX,.T.)
        ENDIF
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F8
  	GAS2()
     select GA
     TBPOS(OX,.T.)
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
		IF MARCABRW( 7, 30, vgasto, LV(vgasto) ) # 0
			LISTAR( "GASTOS" )
		ENDIF
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN

*********

FUNC GAS2

*********
local xmenu
select GA2
aCpo:={;
	{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
	{ "CODGAS",     "C¢d;Gas",                            '', 'M',  '',  0, 0 },;
	{ "FVECTOR(vgasto,GA2->CODGAS)","Descripci¢n",REPL('X',20),'F', 'F',  0, 0 },;
	{ "DETALLE",    "Detalle; ",                          '', 'M',  '',  0, 0 },;
	{ "IMPORTE",    "Importe; ",                          '', 'M',  '',  0, 0 }}
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
xmenu:=MENUDOWN({"     º    F2    º   F5   º  F10   º ESC  ",;
						"       º          º        º pasa a º      ",;
						" mueve º modifica º agrega º gastos º sale "})
SETCOLOR(C_MENU)
MARCO( 7, 5, 17, 78, "", "D", .T. )
oX2 := MYBROWSE( 7, 5, 17, 78, aCpo )
GO TOP
DO WHILE .T.
	MOVBROW( oX2, {||nK==K_ENTER.OR.nK==K_F5.OR.nK==K_F10.OR.nK==K_ESC.OR.nK==K_TAB} )
	IF oX2:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX2:CARGO[TB_NOMBRE,oX2:ColPos]) := oX2:CARGO[TB_CONT]
		UNLOCK
		TBPOS(OX2)
	ELSEIF oX2:Cargo[TB_RET] == K_TAB
		IF TBNOC(oX2) == "CODGAS"
			ele := ABRW( 10, 40, 0, 'vgasto', FIELD->&(TBNOC(oX2)), 'GASTOS' )
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->&(TBNOC(oX2)) := vgasto[ele]
				DBUNLOCK()
			ENDIF
		ENDIF
		TBPOS(OX2)
	ELSEIF OX2:CARGO[TB_RET] == K_F5
  	aaux := {GA2->FECHA,GA2->CODGAS,GA2->DETALLE}
     go top
     if !empty(GA2->FECHA) .or. lastrec()==0
     	add_rec()
     endif
     frlock()
     recall
 		GA2->FECHA   := aaux[1]
 		GA2->CODGAS  := aaux[2]
 		GA2->DETALLE := aaux[3]
		TBPOS(OX2,.T.)
	ELSEIF OX2:CARGO[TB_RET] == K_F10
		MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
     select GA
     go top
     if !empty(GA->FECHA) .or. lastrec()==0
     	add_rec()
     endif
     frlock()
     recall
 		GA->FECHA   := GA2->FECHA
 		GA->CODGAS  := GA2->CODGAS
 		GA->DETALLE := GA2->DETALLE
     GA->IMPORTE := GA2->IMPORTE
     select GA2
     dAux := GA2->FECHA
     BLANKREG()
     dbseek(dAux,.T.)
     RECUPAN()
		TBPOS(OX2,.T.)
	ELSEIF OX2:CARGO[TB_RET] == K_ESC
		EXIT
	ENDIF
	OX2:CARGO[TB_RET] := 0
ENDDO
RECUPAN()
PONEPAN(xmenu)

return
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
IF listado == "GASTOS"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
     IF ASCAN( __abase,{|a| a[2]=='GA'} ) == 0
			FBASES({"GASTOS"},.F.)
     ENDIF
		xreg := RECNO()
		SELECT 99
		DBCLOSEAREA()
		SELECT GA
		base := XNAME("XAUX")
		aux := "   -"
		AEVAL( vgasto,{|a| aux+=IF(RIGHT(a,1)=='',LEFT(a,4),'') } )
		SET SOFTSEEK ON
		SEEK FTOC(DESDE)
		COPY TO &base REST FOR GA->IMPORTE#0.and.GA->CODGAS+"-"$aux WHILE GA->FECHA<=HASTA
		SELECT 99
		USE &base ALIAS X
		INDEX ON X->CODGAS TO &base
		M->SUBTOTAL := M->TOTAL := 0
		GO TOP
		I_codaux := "@@@"
		DO WHILE !EOF()
			IF SALIR()
				EXIT
			ENDIF
			IF I_codaux # X->CODGAS
				IF !I_INI
					CABEZA( 1 )
					?  I_esp + ARMOLIN(I_cab+2)
					++I_CL
				ENDIF
				CABEZA( 2 )
				?
				? I_esp + ""+ FVECTOR( vgasto, X->CODGAS )
				I_CL = I_CL + 2
				I_codaux = X->CODGAS
				M->SUBTOTAL := 0
			ENDIF
			CABEZA( 1 )
			? I_esp + ARMOLIN(I_cab+1)
			++I_CL
			M->SUBTOTAL += X->IMPORTE
			M->TOTAL    += X->IMPORTE
			SKIP
		ENDDO
		SET SOFTSEEK OFF
		CABEZA( 1 )
		?  I_esp + ARMOLIN(I_cab+2)
		I_CL = I_CL + 1
		CABEZA( 4 )
		?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+3)
		? I_esp + ARMOLIN(I_cab)
		I_CL = I_CL + 4
     SELECT 99
     DBCLOSEAREA()
		SELECT GA
		DBGOTO( xreg )
		RECUPAN()
	endif
	LISTADOR( "FIN" )
	RECUPAN()
endif

return
