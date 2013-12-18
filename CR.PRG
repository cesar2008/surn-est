LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " COMPROBANTES DE RETENCION " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
DO CARGAVEC WITH "PREST", 20
DO CARGAVEC WITH "GASTO", 50

aCpo:={;
	{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
	{ "CODCLI",     "C¢d.;Cli",                           '', 'M',  '',  0, 0 },;
	{ "RAZONSOC",   "Raz¢n Social",                       '', 'E',  '',  0, 0 },;
	{ "CUIT",       "CUIT",                               '', 'E',  '',  0, 0 },;
	{ "CATIVA",     "Cat;IVA",                            '', 'E',  '',  0, 0 },;
	{ "NUMFAC",     "Comprobante",                        '', 'M',  '',  0, 0 },;
	{ "NETO",       "Neto",                               '', 'M',  '',  0, 0 },;
	{ "IVA1",       "IVA",                                '', 'M',  '',  0, 0 },;
	{ "TOTAL",      "Total",                              '', 'M',  '',  0, 0 },;
	{ "RETIVA",     "Retenc;IVA",                         '', 'M',  '',  0, 0 },;
	{ "RETIB",      "Retenc;IIBB",                        '', 'M',  '',  0, 0 },;
	{ "RETGAN",     "Retenc;GAN",                         '', 'M',  '',  0, 0 }}

FBASES({ "COMPRET" })
select CR
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º    F6    º   F7    º    TAB   º  ESC   ",;
			  "       º F3 busca  º Shift F6 º         º          º        ",;
			  " mueve º F4 busca+ º elimina  º imprime º clientes º  sale  "})

SETCOLOR( C_MENU )
oX := MYBROWSE( 4, 1, 20, 78, aCpo )
oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "CR", OX, aedits )
TBCOLOR(OX)


DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-7.OR.nk==-6.OR.nK==K_SH_F6.OR.nK==K_ALT_E}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		IF TBNOC(OX) == "NUMFAC"
			CR->NUMFAC := FNUMFACT( oX:CARGO[TB_CONT] )
		ELSE
			FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
     ENDIF
		UNLOCK
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB
		IF TBNOC(oX) == "CODCLI"
			if FELEGIR("CLI")#0
        	frlock()
           CR->CODCLI:=CL->CODCLI
           CR->RAZONSOC := CL->RAZONSOC
           CR->CATIVA := CL->CATIVA
           CR->CUIT := CL->CUIT
           dbunlock()
        endif
		ENDIF
		TBPOS(OX)
	ELSEIF OX:Cargo[TB_RET] == 999
  	SKIP
     IF EOF()
			DBGOBOTTOM()
 			IF FIELD->RETIVA+FIELD->RETIB+FIELD->RETGAN # 0
				aux  := FIELD->FECHA
				xreg := F_ALTA( FTOC(CTOD('')) )
				FRLOCK()
				FIELD->FECHA := aux
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
		LISTAR( "CR" )
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "CR", OX, aedits, "EDITS.EST" )
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nReg:=recno()

IF listado == "CR"
  select CR
  IF QUEFECHA2(10,30)
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		nNETO     := 0
		nCREDITO  := 0
		nIMPINT   := 0
		nTOTAL    := 0
		nRETIB    := 0
		nRETGAN   := 0
		nRETIVA   := 0
     DBSEEK(FTOC(DESDE),.T.)
     DO WHILE CR->FECHA>=DESDE .AND. CR->FECHA<=HASTA .AND. !EOF()
        IF !EOF()
				CABEZA( 1 ); ++I_CL
				? I_esp + ARMOLIN(I_cab+1)
				nRETIB  += CR->RETIB
				nRETGAN += CR->RETGAN
				nRETIVA += CR->RETIVA
        ENDIF
        SKIP
  	ENDDO
		CABEZA( 2 ); I_CL += 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		RECUPAN()
		LISTADOR( "FIN" )
	ENDIF
  go nReg
endif

return
