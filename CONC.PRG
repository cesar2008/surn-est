#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

#define LV(a)				( a[LEN(a)-1] )

PARAMETERS nCual, lBrowser, lMarcar
LOCAL nReg := RECNO(), OX2, cAux, cBase:=DBF(), r:=.F., aaux
DEFAULT lBrowser TO .F.
DEFAULT lMarcar TO .F.

FBASES({"+CONC"},.F.)
select CON
set order to 1
if nCual # NIL
	r := dbseek( nCual )
endif
if !lBrowser
	if r
  	r := CON->DESCONC
  else
  	r := space(len(CON->DESCONC))
  endif
  SELECT (cBase)
 	RETURN(r)
endif
if eof();  dbgotop();  endif

if lMarcar
	aCp:={;
     { "CODCONC",    "C¢d",              '', 'F',  '',  0, 0 },;
     { "DESCONC",    "Descripci¢n",      '', 'F',  '',  0, 0 },;
     { "MARCA",      "Mca",             '!', 'F',  '',  0, 0 } }
	aaux:={"  <+>  º F3 busca  º   +   º     -    º ESPACIO  º  ESC  ",;
         "       º           º marca º desmarca º marca /  º       ",;
         " mueve º F4 busca+ º      º         º desmarca º  sale "}
else
	aCp:={;
     { "CODCONC",    "C¢d",              '', 'F',  '',  0, 0 },;
     { "DESCONC",    "Descripci¢n",      '', 'F',  '',  0, 0 },;
     { "MODIF",      "M",                '', 'F',  '',  0, 0 },;
     { "CODPLAN",    "C¢d;Plan Cta",     '', 'F',  '',  0, 0 } }
	aaux:={"  <+>  º F3 busca  º    F2    º   F5   º   F6    º  ESC  ",;
         "       º           º          º        º         º       ",;
         " mueve º F4 busca+ º modifica º agrega º elimina º  sale "}
endif

select CON
aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
setcolor(C_MENU)
MARCO( 7, 30, 17, 77, "³ CONCEPTOS ³", "S", .T., 0 )
OX2 := MYBROWSE( 7, 30, 17, 77, aCp )
OX2:CARGO[TB_REFRESH] := 10
cAux:=MENUDOWN(aaux)

DO WHILE .T.
	MOVBROW( OX2, {||nK==K_F2.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F5.OR.CHR(nK)$" +-".or.nK==K_F8.or.nK==K_F12} )
	IF OX2:Cargo[TB_MSGE] == "MODIF"
	ELSEIF OX2:CARGO[TB_RET] == K_F2 .OR. OX2:CARGO[TB_RET] == K_F5
		EDCONC( OX2:CARGO[TB_RET] )
		OX2:REFRESHALL()
	ELSEIF OX2:CARGO[TB_RET] == K_ENTER
		r := .T.
		EXIT
	ELSEIF OX2:CARGO[TB_RET] == K_F8
		op = MENUFLASH( 10, 30, 1, .T., "",  "Cargar Vector","Poner Cod.Conc.en Caja","Borrar Conc.MODIF=' '","Cambiar "+CON->CODCONC+" por.." )
     if op==1
			DO CARGAVEC WITH "CONC", 50
  		for i=1 to LV(vconc)
     		if !dbseek(left(vconc[i],3))
        		F_ALTA({||!empty(FIELD->CODCONC)})
           	CON->CODCONC := left(vconc[i],3)
           	CON->DESCONC := subst(vconc[i],5)
        	endif
     	next
     elseif op==2
     	select CA
        nOrder:=indexord()
        set order to
        dbgotop()
        do while !CA->(eof())
        	if empty(CA->CODCONC)
           	select CON
              locate for alltrim(CA->CONCEPTO) $ CON->DESCONC
              if found()
              	select CA
              	frlock()
                 CA->CODCONC := CON->CODCONC
              else
              	? CA->FECHA, CA->TURNO, CA->CODCONC, CA->CONCEPTO
                 wait
              endif
           else
              select CON
           	if !dbseek(CA->CODCONC)
                 add_rec()
                 CON->CODCONC := CA->CODCONC
                 CON->DESCONC := CA->CONCEPTO
              endif
              select CA
           endif
        	skip 1 alias CA
        enddo
     	set order to nOrder
     elseif op==3
     	select CON
        set order to
     	do while .T.
        	locate for !empty(CON->DESCONC) .and. empty(CON->MODIF)
           if !found();  exit;  endif
           BLANKREG()
        enddo
        set order to 1
     elseif op==4
     	cAux:=SPACE(LEN(CON->CODCONC))
			cAux := INGRVAL( 10, 20, "Cambiar "+CON->CODCONC+" x:", cAux, "!!!", "")
        if lastkey()==K_ENTER
        	select CA
           nOrder:=indexord()
           set order to
           fflock()
           replace CA->CODCONC with cAux for CA->CODCONC==CON->CODCONC
           dbunlockall()
           set order to nOrder
        endif
     endif
     select CON
		OX2:REFRESHALL()
	ELSEIF OX2:CARGO[TB_RET] == K_F6 .and. empty(CON->MODIF)
		IF PREGUNTA( 11, "¨ ESTA SEGURO  [ S / N ] ?", "SsNn")$ "Ss"
     	xAux := &(INDEXKEY())
			BLANKREG()
        dbseek(xAux,.t.)
			OX2:REFRESHALL()
     ENDIF
	ELSEIF OX2:CARGO[TB_RET] == K_F12
  	frlock()
     CON->MODIF := if(empty(CON->MODIF),"*","")
     dbunlock()
     OX2:REFRESHCURRENT()
  ELSEIF chr(OX2:Cargo[TB_RET])$" +-" .or. OX2:Cargo[TB_RET]==K_F9
  	FMARCA( OX2:Cargo[TB_RET] )
     TBPOS(OX2,.T.)
	ELSEIF OX2:CARGO[TB_RET] == 43			// +
		MENSAJE( 99, 99, 0, .F., "MARCANDO . . ." )
		FFLOCK()
		lastreg = RECNO()
		REPLACE MARCA WITH "" FOR ROSCA().AND.MARCA # "" REST
		GO lastreg
		UNLOCK ALL
		RECUPAN()
		CLEARTYPEAHEAD()
		OX2:REFRESHCURRENT()
	ELSEIF OX2:CARGO[TB_RET] == 45			// -
		MENSAJE( 99, 99, 0, .F., "DESMARCANDO . . ." )
		FFLOCK()
		lastreg = RECNO()
		REPLACE MARCA WITH " " FOR ROSCA().AND.MARCA # " " REST
		GO lastreg
		UNLOCK ALL
		RECUPAN()
		CLEARTYPEAHEAD()
		OX2:REFRESHCURRENT()
	ELSEIF OX2:CARGO[TB_RET] == 32
		FRLOCK()
		REPLACE MARCA WITH IF( MARCA=='', '', '' )
		UNLOCK
		CLEARTYPEAHEAD()
		OX2:REFRESHCURRENT()
     KEYBOARD CHR(K_DOWN)
	ELSEIF OX2:CARGO[TB_RET] == K_ESC
		r := .F.
		EXIT
	ENDIF
ENDDO
RECUPAN()
PONEPAN(cAux)
if F_ABASE(cBase,"?")
	select (cBase)
endif

RETURN r


***********************

STATIC FUNC EDCONC( K )

***********************
LOCAL aux, EDX, xmenu, nOrder

xmenu:=MENUDOWN({"     º presione TAB en los cam- º  F10  º  ESC   ",;
                 "       º pos con  p/obtener una  º       º        ",;
                 " mueve º lista de de opciones.    º graba º  sale  "})

select CON
EDX := NEWEDIT( "CONC" )
if K == K_F5
	FEDITOR( EDX, "SETVARS", K, .F. )
	SET ORDER TO 1
	nAux := RECNO()
	GO nAux
else
	FEDITOR( EDX, "SETVARS", K, .F. )
  if !empty(CON->MODIF)
  	i:=EDNUM(EDX,"CON->CODCONC");  EDX[ED_EDIT]:=stuff(EDX[ED_EDIT],i,1,"F")
  	i:=EDNUM(EDX,"CON->DESCONC");  EDX[ED_EDIT]:=stuff(EDX[ED_EDIT],i,1,"F")
  endif
endif
EDX[ED_MODE] = "MOSTRARTODO"

DO WHILE .T.
	FEDITAR( EDX, { K_F10 } )
	IF EDX[ED_UPDATE]
		EDX[ED_MODE] = "MOSTRAR"
		IF EDNOM(EDX) == "CON->CODCONC"
			nOrden := INDEXORD()
			DBSETORDER( FORDER({"CODCONC"}) )
			IF FREPEAT( EDCONT(EDX), EDX[ED_MODAPP] )
				MENSAJE( 0, 0, 10, .T., "CODIGO CONCEPTO REPETIDO !!!" )
				EDPONE( EDX,, EDX[ED_LAST] )
			ENDIF
			DBSETORDER( nOrden )
		ENDIF
	ELSEIF EDX[ED_TECLA] == K_TAB
		EDX[ED_MODE] = "MOSTRARTODO"
		IF "CODPLAN" $ EDNOM(EDX) .and. EDX[ED_TECLA]==K_TAB
			IF PC( EDCONT(EDX), .T. )
				EDPONE(EDX,,PC->CODPLAN)
			ENDIF
		ENDIF
	ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
		aux := "S"
		IF EDX[ED_TECLA] == K_F10
			aux := "G"
		ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
		ENDIF
		IF aux == "G"
			IF EMPTY(EDCONT(EDX,"CON->DESCONC"))
				MENSAJE( 0, 0, 10, .T., "FALTA DESCRIPCION !!!" )
			ELSE
     		if "AGREG" $ EDX[ED_MODAPP]
        		F_ALTA({|| !empty(FIELD->CODCONC)})
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
MENUDOWN(xmenu)

RETURN ( aux=="G" )
