LOCAL aCpo, oX, oGET, xreg, cMenu

#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
DO CARGAVEC WITH "GASTO", 50

aCpo:={;
	{ "CODGAS",     "C¢d;Gas",                            '', 'M',  '',  0, 0 },;
	{ "FVECTOR(vgasto,FIELD->CODGAS)","Descripci¢n",REPL('X',20),'F', 'F',  0, 0 },;
	{ "DETALLE",    "Detalle; ",                          '', 'M',  '',  0, 0 },;
	{ "IMPORTE",    "IMPORTE; ",                          '', 'M',  '',  0, 0 },;
	{ "FECHA",      "",                                   '',  '',  '',  0, 0 },;
	{ "TURNO",      "",                                   '',  '',  '',  0, 0 },;
	{ "REGISTRO",   "",                                   '',  '',  '',  0, 0 }}

FBASES({ "+FGAS" })
select GA
F_ARCHAUX("CREAR")
dbseek( ftoc(VA->FECHA)+VA->TURNO, .T. )
F_ARCHAUX("CARGAR",aCpo,{||GA->FECHA==VA->FECHA.and.GA->TURNO==VA->TURNO})
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )
select X
sum IMPORTE to M->IMPORTE
RECUPAN()

cMenu:=MENUDOWN({"  <+>  º F2 modif. º F6  Shift F6  º   TAB    º  F10  º  ESC   ",;
			  			"       º F3 busca  º               º          º       º        ",;
			  			" mueve º F4 busca+ º elimina l¡nea º concepto º graba º  sale  "})

SETCOLOR( "W/N,N/W" )
MARCO( 7, 10, 20, 78, "<< GASTOS >>", "D", .T., 0 )
oX := MYBROWSE( 7, 10, 20, 78, aCpo )
oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()
keyboard replic(chr(K_ENTER),3)
lDispTot :=.T.

DO WHILE .T.
	if lDispTot
		OTC := oX:GETCOLUMN( 4 )
		OTC:FOOTING := TRANS(M->IMPORTE,"#######.##")
		OTC:FOOTSEP := "Ä"
		oX:SETCOLUMN( 4, OTC )
		lDispTot := .F.
		TBPOS(oX,.t.)
	endif
	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-7.OR.nk==-6.OR.nK==K_SH_F6.or.nK==K_F10}, {||NK==999} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		if TBNOC(oX) == "IMPORTE"
     	M->IMPORTE -= X->IMPORTE
			X->IMPORTE := oX:CARGO[TB_CONT]
     	M->IMPORTE += X->IMPORTE
			lDispTot :=.T.
		else
			FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
     endif
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
  	skip
     if eof()
			dbgobottom()
 			if FIELD->IMPORTE#0 .or. lastrec()==0
				append blank
				FIELD->FECHA := VA->FECHA
     		FIELD->TURNO := VA->TURNO
				TBPOS(OX,.T.)
        endif
     endif
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
			BLANKREG({"REGISTRO"})
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
		BLANKREG({"REGISTRO"})
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F7
		IF MARCABRW( 7, 30, vgasto, LV(vgasto) ) # 0
			LISTADOR( "GASTOS" )
		ENDIF
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET]==K_ESC .or. oX:Cargo[TB_RET]==K_F10
  	select GA
		if oX:Cargo[TB_RET]==K_F10
     	cAux:="G"
     else
			cAux:=UPPER( PREGUNTA( 12, "[G] graba   [S] sale    [C] contin£a", "GgSsCc") )
     endif
     if cAux=="G"
     	F_ARCHAUX("GRABAR",,{||F_ALTA({||!empty(GA->FECHA)})})
			exit
     elseif cAux=="S"
			exit
     endif
	ENDIF
ENDDO
DBUNLOCKALL()
DBCOMMITALL()
RECUPAN()
MENUDOWN(cMenu)

RETURN



*********************

FUNC F_ARCHAUX( cModo, xAux, bBlock )

*********************
local cBaseAnt:=dbf()
local cBaseAux:=xname('XAUX')

if "CREA"$cModo
	aaux:=dbstruct()
  aadd(aaux,{"REGISTRO","N",6,0})
  select 99;  dbclosearea()
  dbcreate(cBaseAux,aaux)
  select 99
  use (cBaseAux) alias X exclusive
  select (cBaseAnt)

elseif "CARGA"$cModo
	select X
	aa:={}
  for i=1 to fcount()
  	if (cBaseAnt)->(fieldpos(fieldname(i))) # 0
     	aadd(aa,"{||X->"+ fieldname(i) +":="+ cBaseAnt +"->"+ fieldname(i) +"}" )
     endif
  next i
  aeval(aa,{|a,i|aa[i]:=&(a)} )
  do while eval(bBlock) .and. !(cBaseAnt)->(eof())
  	append blank
     aeval(aa,{|a,i|eval(aa[i])})
     FIELD->REGISTRO := (cBaseAnt)->(recno())
     skip 1 alias (cBaseAnt)
  enddo

elseif "GRABA"$cModo
	select X
  go top
	aa:={}
  for i=1 to fcount()
  	if (cBaseAnt)->(fieldpos(fieldname(i))) # 0
     	aadd(aa,"{||"+ cBaseAnt +"->"+ fieldname(i) +":=X->"+ fieldname(i) +"}" )
     endif
  next i
  aeval(aa,{|a,i|aa[i]:=&(a)} )
  select (cBaseAnt)
	do while !X->(eof())
  	if X->REGISTRO==0
     	eval(bBlock)
     else
     	go X->REGISTRO
     endif
     frlock()
*    aeval(aa,{|a,i|aa[i]})
		for i=1 to len(aa)
     	eval(aa[i])
     next
  	skip 1 alias X
  enddo
  dbunlock()
  dbcommitall()

endif

return .T.
