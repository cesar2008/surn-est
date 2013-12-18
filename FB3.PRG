LOCAL aCpo, oBAN, oGET, xreg, xpant:=GUARDOPAN( 0, 0, 24, 79 )

#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " FACTURAS ( b ) " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
aCpo:={{ "FECHA",      "Fecha; ",                            '', 'F',  '',  0, 0 },;
	{ "NUMFAC",     "N§ Fac; ",                           '', 'F',  '',  0, 0 },;
	{ "CODPROD",    "C¢d;art",                            '', 'F',  '',  0, 0 },;
	{ "CANTIDAD",   "Cant.; ",                            '', 'F',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                      '', 'F',  '',  0, 2 },;
	{ "UNXCAJA",    "Un;xC",                              '', 'F',  '',  0, 0 },;
	{ "COSTO",      "Costo; ",                            '', 'F',  '',  0, 0 },;
	{ "UTIL",       "Utilidad; ",                         '', 'F',  '',  0, 0 },;
	{ "IMPINT",     "Imp.;Int",                           '', 'F',  '',  0, 0 },;
	{ "IVA",        "I.V.A.; ",                           '', 'F',  '',  0, 2 },;
	{ "PRECUNIT",   "Precio;Unitario",                    '', 'F',  '',  0, 0 } }

FBASES( {"+FACB3"}, .F. )
SELECT FB3
aCpo := FBASEAUX( aCpo, "FB3", SELECT(), .F. )
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º    F6   º  ESC   ",;
	"       º F3 busca  º         º        ",;
	" mueve º F4 busca+ º elimina º  sale  "})

SETCOLOR( "W/N,N/W" )

oBAN := MYBROWSE( 4, 0, 19, 79, aCpo )

oBAN:CARGO[TB_BARRAY] := .F.
oBAN:CARGO[TB_BARRAX] := .T.
oBAN:CARGO[TB_REFRESH] := 10
oBAN:GOBOTTOM()

DO WHILE .T.
	
	MOVBROW( oBAN, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-7} )
	
	IF oBAN:Cargo[TB_MSGE] == "MODIF"
		IF oBAN:CARGO[TB_NOMBRE,oBAN:ColPos] == "FECHA"
			xreg := RECNO()
			FRLOCK()
			FIELD->&(oBAN:CARGO[TB_NOMBRE,oBAN:ColPos]) := oBAN:CARGO[TB_CONT]
			oBAN:RefreshAll()
			DBGOTO( xreg )
		ELSE
			FRLOCK()
			FIELD->&(oBAN:CARGO[TB_NOMBRE,oBAN:ColPos]) := oBAN:CARGO[TB_CONT]
			DBUNLOCK()
			oBAN:RefreshCurrent()
		ENDIF
	ELSEIF oBAN:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
			SELECT S
			SEEK FB3->CODPROD
			IF FOUND()
				FRLOCK("S")
				S->STOCKACT += FCANT( FB3->CANTIDAD, FB3->UNXCAJA )
			ENDIF
			SELECT FB3
			BLANKREG(.T.)
			DBUNLOCKALL()
			SKIP -1
			oBAN:RefreshAll()
		ENDIF
	ELSEIF oBAN:Cargo[TB_RET] == K_F8
	ELSEIF oBAN:Cargo[TB_RET] == K_F9
		oBAN:RefreshAll()
	ELSEIF oBAN:Cargo[TB_RET] == K_F10
		MARCO( 10, 30, 11, 60, "", "S", .T., 0 )
		@ 10, 30 SAY "Desde:" GET DESDE
		@ 11, 30 SAY "Hasta:" GET HASTA
		READ
		RECUPAN()
		IF LASTKEY() == K_ENTER
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			aaux := {}
			xreg := RECNO()
			SELECT CH
			SET SOFTSEEK ON
			SEEK FTOC(DESDE)
			SET SOFTSEEK OFF
			SELECT BA
			DO WHILE CH->FECHA >= DESDE .AND. CH->FECHA <= HASTA
				F_ALTA('þþþ')
				BA->FECHA := CH->FECHA
				BA->CONCEPTO := CH->CONCEPTO
				BA->CHEQUE := CH->MONTO
				AADD( aaux, CH->(RECNO()) )
				SKIP 1 ALIAS CH
			ENDDO
			SELECT CH
			AEVAL( aaux, {|a| DBGOTO(a), BLANKREG(.T.)} )
			SELECT BA
			DBGOTOP()
			oBAN:RefreshAll()
			DBGOTO( xreg )
			RECUPAN()
		ENDIF
	ELSEIF oBAN:Cargo[TB_RET] == K_ESC
		IF UPPER( PREGUNTA( 12, "[ S ] sale.       [ C ] contin£a.", "SsCc") ) == "S"
			EXIT
		ENDIF
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

PONEPAN(xpant)

RETURN
