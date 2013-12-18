LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO( .T., " Z " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
aCpo:={;
	{ "SUCURSAL",	 "Suc",   					 '', 'E',  '',  0, 0 },;
	{ "NUMZ",		 "N§ Z", 					 '', 'E',  '',  0, 0 },;
	{ "FECHA",		 "Fecha",					 '', 'E',  '',  0, 0 },;
	{ "HORA",       "Hora",          		 '', 'E',  '',  0, 0 },;
	{ "TOTAL",      "Total",					 '', 'E',  '',  0, 0 },;
	{ "TIVA1",      "IVA",				       '', 'E',  '',  0, 0 },;
	{ "TIMPINT",    "Total;Imp.Int",			 '', 'E',  '',  0, 0 },;
	{ "TNETO",      "Neto",  					 '', 'E',  '',  0, 0 },;
	{ "CANTTI",     "Cant;Tick",				 '', 'E',  '',  0, 0 },;
	{ "ULTTI",      "Ultimo;Tkt/FB",			 '', 'E',  '',  0, 0 },;
	{ "ULTFA",      "Ultima;Fact.A",    	 '', 'E',  '',  0, 0 },;
	{ "CANTDFCANC", "Cant;DF;canc", 			 '', 'E',  '',  0, 0 },;
	{ "CANTDNFH" ,  "Cant;DNFH",				 '', 'E',  '',  0, 0 },;
	{ "CANTDNF",    "Cant;DNF",       		 '', 'E',  '',  0, 0 }}

FBASES({ "Z" })
select Z
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )
dbgobottom()

MENUDOWN({"  <+>  º F2 modif. º   F5   º   F6    º    F7   º  ESC   ",;
			  "       º F3 busca  º        º         º         º        ",;
			  " mueve º F4 busca+ º agrega º elimina º imprime º  sale  "})

SETCOLOR(C_MENU)
oX := MYBROWSE( 4, 1, 20, 78, aCpo )
oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()

DO WHILE .T.
	MOVBROW( oX, {||nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_F7.or.nK==K_F8} )

	IF oX:Cargo[TB_MSGE] == "MODIF" .and. VA->FECHSEG<date()
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
* 	if TBNOC(OX)=="TNETO"
*    	Z->TIVA1 := Z->TNETO * VA->IVA1 / 100
*    endif
  	if TBNOC(OX)$"TNETO TIVA1 TIVA2 TIMPINT TEXENTO"
     	Z->TOTAL := Z->TNETO + Z->TIVA1 + Z->TIVA2 + Z->TIMPINT + Z->TEXENTO
  	elseif TBNOC(OX)$"TOTAL"
     	Z->TNETO := Z->TOTAL - Z->TIVA1 - Z->TIVA2 - Z->TIMPINT - Z->TEXENTO
     endif
		UNLOCK
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET]==K_F5
		dbgobottom()
		dAux:=Z->FECHA
		nAux:=Z->NUMZ
		F_ALTA({||Z->NUMZ#0})
		frlock()
		Z->NUMZ := nAux+1
		Z->FECHA := dAux+1
		dbunlock()
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
			xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
			BLANKREG(.T.)
			GO xreg2
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET]==K_F8
		if QUEFECHA2( 10, 30 )
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
        nReg:=Z->(recno())
        select 99;  dbclosearea()
        cBaseAux:="QQ"			//XNAME("XAUX")
			dbcreate(cBaseAux,{{"FECHA","D",8,0},{"TURNO1","N",10,2},{"TURNO2","N",10,2},{"TURNO3","N",10,2},;
        	{"TOTCAJA","N",10,2},{"TOTZ","N",10,2}})
			select 99
			use (cBaseAux) alias X exclusive
			index on ftoc(X->FECHA) to (cBaseAux)
IF .T.
	VTAXTUR(DESDE,HASTA,"1","2")
ELSE
        FBASES({"+CAJA"})
        select 99
        use (cBAseAux) alias X exclusive
        index on ftoc(X->FECHA) to (cBaseAux)
        CA->(dbseek(ftoc(DESDE),.T.))
        do while BETWEEN(CA->FECHA,DESDE,HASTA).and.!CA->(eof())
           if CA->CODCONC == "TT "
					if !dbseek(ftoc(CA->FECHA))
              	append blank
              	X->FECHA := CA->FECHA
              endif
              cAux:="TURNO"+CA->TURNO
              X->&(cAux) += CA->INGRESO+CA->EGRESO
              X->TOTCAJA += X->TURNO1 + X->TURNO2 + X->TURNO3
           endif
           skip 1 alias CA
			enddo
ENDIF
        Z->(dbseek(ftoc(DESDE),.T.))
        do while BETWEEN(Z->FECHA,DESDE,HASTA).and.!Z->(eof())
				if !dbseek(ftoc(Z->FECHA))
              append blank
              X->FECHA := Z->FECHA
           endif
           X->TOTZ += Z->TOTAL
           skip 1 alias Z
			enddo
        select Z
        go nReg
        RECUPAN()
		endif
	ELSEIF oX:Cargo[TB_RET] == K_F7
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN
