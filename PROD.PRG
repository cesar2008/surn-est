#include "EST.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "EDI.CH"
#include "TB.CH"

LOCAL k, xmenu, xmenu2, ele

FBASES({ "PROVEE" })
op = menuflash( ym2, xm2, 1, .t., "", "Actualizar Productos ",;
													"Inventario / Stock   ",;
 													"Imp.Interno          ",;
 													"Varillada            ",;
 													"Precios              ",;
 													"Precios Mayorista    ",;
 													"Aumento Precios x %  ",;
 													"Cambiar c¢d.Productos" )

IF op == 1
	LOGO(.T., " ACTUALIZACION DE PRODUCTOS " )
	MENUDOWN({"     º  ENTER   º   F5   º   F6    º   F7    º  F8   º   TAB   º ESC ",;
				 "       º  o  F2   º        º         º         º utili-º  elige  º     ",;
				 " mueve º modifica º agrega º elimina º imprime º dades º product º sale"})
	SELECT PRD
	M->IMPINT := PRD->IMPINT
	aX := NEWEDIT( "PROD" )
	DO WHILE .T.
		k := FVERREG( aX, {|K|K==K_TAB.OR.K==K_F5.OR.K==K_F6.OR.K==K_F7.OR.K==K_F8} )
		
		IF k == K_TAB
			FELEGIR( "PRODUCTO" )
		ELSEIF k == K_ENTER .OR. K==K_F2 .OR. k == K_F5
			xmenu:=MENUDOWN({ "     º    F2    º ALT M  º presione TAB para obtener una º ESC  º  F10   ",;
									"       º          º calcu- º lista de opciones. (solo fun- º      º graba  ",;
									" mueve º modifica º ladora º ciona en los campos con  ).  º sale º y sale "})
			FEDITOR( aX, "SETVARS", K )
			M->TIPOIMPINT := PRD->TIPOIMPINT
			IF K == K_F5
				aX[ED_I]    := 1
				aX[ED_MODE] := "MOSTRARTODO"
			ENDIF
        i:=EDNUM(AX,"PRD->CODPROD");  if i#0;  AX[ED_EDIT]:=stuff(AX[ED_EDIT],i,1,if(K==K_F5,"M","F"));  endif
			DO WHILE .T.
				FEDITAR( aX, { 9, K_ALT_M, K_F10 } )
				IF aX[ED_UPDATE] .OR. aX[ED_TECLA] == K_TAB
					aX[ED_MODE] := "MOSTRARTODO"
					aux := .F.
					IF aX[ED_TECLA] == K_TAB
						IF EDNOM(aX) == "PRD->RUBRO"
							ele = ABRW( AX[ED_Y], AX[ED_X], 0, 'vrubro', EDCONT(AX), 'RUBROS' )
							IF LASTKEY() == K_ENTER
								EDPONE( aX,, ele)
							ENDIF
                    aux := .f.
						ELSEIF EDNOM(aX) == "PRD->GRUPO"
							IF FELEGIR( "GRUPO") # 0
								EDPONE( aX,, GR->CODGRUP )
								aux := .T.
							ENDIF
						ELSEIF EDNOM(aX) == "PRD->CODPROV"
							IF FELEGIR( "PROVEE" ) # 0
								EDPONE( aX,, PRV->CODPROV )
							ENDIF
						ENDIF
					ELSEIF EDNOM(aX) $ "PRD->PRECVENTA PRD->GRUPO PRD->CONIMPINT"
						aux := .T.
					ELSEIF EDNOM(aX) == "PRD->PRECBASE"
						M->PIVA1 := EDCONT(AX) * VA->PIVA1 / 100
						EDPONE(AX,"PRD->PRECVENTA",EDCONT(AX) + EDCONT(AX,"PRD->IMPINT") + M->PIVA1 )
					ELSEIF EDNOM(aX) == "PRD->CODPROD"
						IF FREPEAT( EDCONT(aX,"PRD->CODPROD"), aX[ED_MODAPP] )
        				MENSAJE( 0, 0, 10, .T., "CODIGO PRODUCTO REPETIDO !!!" )
							EDPONE( aX, "PRD->CODPROD", aX[ED_LAST] )
						ENDIF
					ENDIF
					IF aux
						EDPONE( AX, "PRD->PRECBASE", FNETOVENTA( EDCONT(AX,"PRD->GRUPO"),EDCONT(AX,"PRD->PRECVENTA"),EDCONT(AX,"PRD->CONIMPINT")) )
						M->TIPOIMPINT := FTIPOIMPINT
						EDPONE(AX,"PRD->IMPINT", IF( M->TIPOIMPINT="%", EDCONT(AX,"PRD->PRECBASE")*FIMPINT/100*EDCONT(AX,"PRD->CONIMPINT"),FIMPINT)*EDCONT(AX,"PRD->CONIMPINT") )
					ENDIF
				ELSEIF aX[ED_TECLA] == K_ESC .OR. ( aX[ED_TECLA]==K_ENTER .AND. aX[ED_I]==LEN(aX[ED_FIELDS]) ) .OR. aX[ED_TECLA] == K_F10
					aux := "S"
					IF aX[ED_TECLA] == K_F10
						aux := "G"
					ELSEIF FEDITOR( aX, "HUBOCAMBIOS" )
						aux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
					ENDIF
					IF aux == "G"
						if EDCONT(AX,"PRD->CODPROD")==0 .OR. EMPTY( EDCONT(AX,"PRD->DESCPROD") )
							MENSAJE(0,0,10,.T., "FALTA EL CODIGO O LA DESCRIPCION !" )
							aux := "C"
						elseif EDCONT(AX,"PRD->RUBRO")==0 .OR. EDCONT(AX,"PRD->GRUPO")==0
							MENSAJE(0,0,10,.T., "FALTA EL RUBRO OGRUPO !" )
							aux := "C"
						endif
					ENDIF
              xcod := PRD->CODPROD
					IF aux == "G"
						FEDITOR( aX, "GRABAR", .F. )
						frlock()
						PRD->TIPOIMPINT := M->TIPOIMPINT
						PRD->UTIL       := EDCONT(AX,"PRD->PRECBASE") - EDCONT(AX,"PRD->PRECCOMPRA")
                 PRD->FECHMODIF  := date()
						dbunlock()
                 ********************************
     				IF PRD->CODPROD # xcod .AND. "MOD" $ aX[ED_MODAPP]
							MENSAJE (99, 99, 0, .F., "REEMPLAZANDO CODIGOS EN COMPRAS, PLANILLAS, FACTURAS, REMITOS, ETC ...")
							aaux := {{"COMPRAS2","CO2"},{"PLAN2","PL2"},{"AJUSTES","AJ"},{"VARI","VR"},;
										{"FACA2","FA2"},{"FACB2","FB2"},{"REM2","RE2"}}
                    FOR b=1 TO LEN(aaux)
                    	@ 24,60 SAY PADC(aaux[b,1],10,' ')
								FBASES({"+"+aaux[b,1]}, .F. )
           				SELECT (aaux[b,2])
           				SET ORDER TO
                       IF aaux[b,2] $ "FA2 FB2 RE2"
 									DBEVAL( {|| FRLOCK(),;
 										FIELD->CODPROD:=PRD->CODPROD,;
 										DBUNLOCK(),;
                          	DEVPOS(24,70),QQOUT(FIELD->FECHA)},;
 										{|| FIELD->CODPROD==xcod.AND.FIELD->NEGOCIO==' '} )
                       ELSE
 									DBEVAL( {|| FRLOCK(),;
 										FIELD->CODPROD:=PRD->CODPROD,;
 										DBUNLOCK(),;
                          	DEVPOS(24,70),QQOUT(FIELD->FECHA)},;
 										{|| FIELD->CODPROD==xcod } )
                       ENDIF
								FBASES({"-"+aaux[b,1]}, .F. )
							NEXT b
           			RECUPAN()
        			ENDIF
        			SELECT PRD
						EXIT
                 ********************************
						EXIT
					ELSEIF aux == "S"
						EXIT
					ENDIF
				ENDIF
			ENDDO
			PONEPAN(xmenu)
		ELSEIF K == K_F6
			FEDITOR( aX, "ELIMINAR" )
		ELSEIF K == K_F7
			IF QUECOD2( 10, 30, 2 )
				LISTADOR( "PROD", PRIHOJA )
			ENDIF
		ELSEIF K == K_F8
     	xcolor:=SETCOLOR("+W/N,N/W,,,W/M")
			op = MENUFLASH( 10, 30, 1, .T., "UTILIDADES", "CAMBIAR CODIGOS", "ELIMINAR PRODUCTOS" )
        IF op == 1
				DO CAMBIARCOD
        ELSEIF op == 2
*				DO ELIMINARCOD
        ENDIF
     	SETCOLOR(xcolor)
		ELSEIF K == K_ESC
			EXIT
		ENDIF
	ENDDO
	FEDITOR( aX, "SACAPAN" )
	
ELSEIF op == 2
	DO STI
	
ELSEIF op == 3								&& Imp.Int.
	xmenu:=MENUDOWN({"º  <+>  º Page Up   º  F2   º  F3   º   F4   º  F5   º   F6    º ESC  º",;
						  "º       º Page Down º modi- º       º        º       º         º      º",;
						  "º mueve º   mueve+  º fica  º busca º busca+ º carga º elimina º sale º"})
	PRIVATE bcamp[7], bmasc[7], bcab[7], bedit
	bcamp[ 1] = "GR->CODGRUP"
	bcamp[ 2] = "GR->DESCGRUP"
	bcamp[ 3] = "GR->TIPOIMPINT"
	bcamp[ 4] = "GR->IMPINT"
	bcamp[ 5] = "GR->IMPINT2"
	bcamp[ 6] = "GR->CODPROD"
	bcamp[ 7] = "FPRODUCTO(GR->CODPROD)"
	bmasc[ 1] = "99"
	bmasc[ 2] = "@!"
	bmasc[ 3] = "!"
	bmasc[ 4] = ""
	bmasc[ 5] = ""
	bmasc[ 6] = ""
	bmasc[ 7] = "XXXXXXXXXXXXX"
	bcab[ 1] = "C¢digo"
	bcab[ 2] = "Descripci¢n"
	bcab[ 3] = "Tipo;Imp."
	bcab[ 4] = "Imp.Int.;Venta"
	bcab[ 5] = "Imp.Int.;Compra"
	bcab[ 6] = "C¢d;Prod"
	bcab[ 7] = "Producto;Generico"
	bedit = "FEEMMMF"
	SET COLOR TO W/N,N/W
	SELECT GR
	BROW( 10, 15, 20, 78, " GRUPOS ", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=-4.OR.tecla=-5.OR.tecla=-1.OR.tecla=9.OR.tecla=13" )
	IF PREGUNTA( 0, "¨ Recalculo el Impuesto Interno   [ S / N ] ?", "SsNn" ) $ "Ss"
		MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
		SELECT PRD
		lastorder = INDEXORD()
		SET ORDER TO
		INIVER("",22,20,40,LASTREC())
		FFLOCK()
		GO TOP
		DO WHILE !PRD->(EOF()) .AND. INKEY() # K_ESC
			REPLACE PRD->PRECBASE WITH FNETOVENTA(PRD->GRUPO,PRD->PRECVENTA,PRD->CONIMPINT),;
				PRD->TIPOIMPINT WITH FTIPOIMPINT, PRD->IMPINT WITH IF(PRD->TIPOIMPINT="%",PRD->PRECBASE*FIMPINT/100,FIMPINT)*PRD->CONIMPINT,;
           PRD->FECHMODIF WITH date()
        por_donde := RECNO()
			VER(0)
			SKIP
		ENDDO
		verindex = .F.
		DBUNLOCK()
		SET ORDER TO lastorder
		RECUPAN()
	ENDIF
	RECUPAN()
	PONEPAN(xmenu)

ELSEIF op == 4								&& AJUSTES
	DO VARI

ELSEIF OP == 5								&& PRECIOS
	DO PRE

ELSEIF OP == 6								&& PRECIOS MAYORISTA
	DO PREM

ELSEIF OP == 7								&& PRECIOS X %
	DO PREXP

ELSEIF OP == 8								&& CAMBIAR CODPROD
	DO UC
	
ENDIF

RETURN NIL



***************

FUNC FNETOVENTA

***************
PARAMETERS cualgrupo, cualprecv, conii
PRIVATE r
conii := IF(conii==NIL,1,conii)

r = 0
IF !EMPTY(FGRUPO(cualgrupo))
	IF GR->TIPOIMPINT == "%"
		r = cualprecv / ( 1 + (((FIMPINT*conii)+VA->PIVA1)/100) )
	ELSE
		r = ( cualprecv - (FIMPINT*conii) ) / (1+((VA->PIVA1)/100))
	ENDIF
ENDIF

RETURN r



************

FUNC FIMPINT( cualgrupo, cualprec )

************
LOCAL r:=0

IF !EMPTY(FGRUPO(cualgrupo))
	IF GR->TIPOIMPINT == "%"
  	r := cualprec * FIMPINT / 100
	ELSE
		r = ( cualprecv - FIMPINT ) / (1+((VA->PIVA1+ivarni)/100))
	ENDIF
ENDIF

RETURN r


**************

FUNC FPRODUCTO

**************
PARAMETERS cualcod, _como
PRIVATE lastbase, r
cualcod := IF(cualcod==NIL,PRD->CODPROD,cualcod)

lastbase = DBF()
IF _como == NIL .OR. _como == " "
	SELECT PRD
	SEEK cualcod
	IF FOUND()
		r = PRD->DESCPROD
		FNETOCOMPRA := PRD->NETOCOMPRA
		FPRECCOMPRA := PRD->PRECCOMPRA
		FPRECBASE   := PRD->PRECBASE
		FTIPOIMPINT := PRD->TIPOIMPINT
     NCONIMPINT  := PRD->CONIMPINT
		FIMPINT     := PRD->IMPINT * NCONIMPINT
  	NUNXCAJA    := PRD->UNXCAJA
		NGRUPO      := PRD->GRUPO
		NRUBRO      := PRD->RUBRO
  	FPRECVENTA  := PRD->PRECVENTA
     FRECARGO    := PRD->RECARGO
		FREGART     := RECNO()
	ELSE
		r = SPACE(25)
		STORE 0 TO FNETOCOMPRA, FPRECBASE, FIMPINT, FREGART, FPRECCOMPRA, NGRUPO, NUNXCAJA, FPRECVENTA, NRUBRO, NCONIMPINT, FRECARGO
  ENDIF
ELSE
	SELECT ART
	SEEK cualcod
	IF FOUND()
		r = ART->DESCPROD
		FPRECCOMPRA := 0
		FTIPOIMPINT := " "
		FIMPINT     := ART->IMPINT
  	NUNXCAJA    := ART->UNXCAJA
		NGRUPO      := ART->RUBRO
		NRUBRO      := ART->RUBRO
  	FPRECVENTA  := ART->PRECIO
		FPRECBASE   := ( FPRECVENTA - FIMPINT ) / ( 1+VA->PIVA1/100*ART->EXENTO )
		FREGART     := RECNO()
	ELSE
		r = SPACE(25)
		STORE 0 TO FPRECBASE, FIMPINT, FREGART, FPRECCOMPRA, NGRUPO, NUNXCAJA, FPRECVENTA, NRUBRO
  ENDIF
ENDIF
SELECT &lastbase

RETURN r


***********

FUNC FGRUPO

***********
PARAMETERS cual
PRIVATE r, lastbase

lastbase := DBF()
if GR->(dbseek(cual))
	select GR
	r = GR->DESCGRUP
	FIMPINT     := GR->IMPINT
	FIMPINT2    := GR->IMPINT2
	FTIPOIMPINT := GR->TIPOIMPINT
	FCODPROD    := GR->CODPROD
	FESCOMBUST  := GR->ESCOMBUST
	SELECT &lastbase
ELSE
	r = SPACE(LEN(GR->DESCGRUP))
	FIMPINT     := 0
	FIMPINT2    := 0
	FTIPOIMPINT := ""
	FCODPROD    := 0
	FESCOMBUST  := " "
ENDIF
SELECT &lastbase

RETURN r


************

FUNC CAMBIARCOD

************
LOCAL aCPO, OX, xmenu, xreg := RECNO(), nCant

#define RG_CODPROD        1
#define RG_DESCPROD       2
#define RG_CODPROD2       3
#define RG_DESCPROD2      4

aCpo:={	                                                                      ;
	{ "CODPROD",    "C¢d;Prod",                      '99999', 'M', 'N',  5, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",          REPLIC('X',20), 'F', 'C', 20, 0 },;
	{ "CODPROD2",   "Nuevo;C¢d",                     '99999', 'M', 'N',  5, 0 } }

SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

NROW := 1
AXR := {}
AADD( AXR, AREG0( aCpo ) )
	
SETCOLOR( "W/N,N/W" )
MARCO( 5, 20, 19, 78, "CAMBIO DE CODIGOS", "D", .T., 0 )
OX := MYABROWSE( 5, 20, 19, 78, aCpo, AXR, "AXR" )
OX:CARGO[TB_REFRESH] := 0
	
	
xmenu:=MENUDOWN({"  <+>  º    F2    º    F3    º   F6    º   TAB    º   F10   º ESC  ",;
			  			"       º          º  busca   º elimina º  elegir  º cambia  º      ",;
			  			" mueve º modifica º producto º  l¡nea  º producto º c¢digos º sale "})
	
guardar = .F.
DO WHILE .T.
		
	MOVABROW( OX, AXR, {||nK==K_TAB.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F6},;
		{||nK==999} )
		
	IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB )
		IF TBNOC(OX) $ "CODPROD"
			IF OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			IF TBNOC(OX) == "CODPROD"
				r := 0
				IF OX:Cargo[TB_RET] == K_TAB
					IF FELEGIR( "PRODUCTO", AXR[NROW,OX:COLPOS] ) # 0
						AXR[NROW,OX:COLPOS] := PRD->CODPROD
					ENDIF
				ELSEIF OX:Cargo[TB_RET] == K_F3
					r := SELECTPRD()
					IF r # 0
						AXR[NROW,RG_CODPROD] := r
					ENDIF
				ENDIF
           n:=ascan(AXR,{|a|a[RG_CODPROD2]==AXR[NROW,RG_CODPROD]})
           if n#0
        		MENSAJE( 0, 0, 10, .T., "ESTE CODIGO ESTA EN LA 2§ COLUMNA !!!" )
           endif
           if n == 0
           	aeval(AXR,{|a,i|n+=if(i#NROW.and.a[RG_CODPROD]==AXR[NROW,RG_CODPROD],1,0)})
           	if n#0
        			MENSAJE( 0, 0, 10, .T., "EL CODIGO YA ESTA CARGADO !!!" )
              endif
           endif
           if n # 0
           	AXR[NROW,RG_CODPROD] := 0
           else
					AXR[NROW,RG_DESCPROD ] := FPRODUCTO(AXR[NROW,RG_CODPROD])
           endif
        ENDIF
		ELSEIF TBNOC(OX) $ "CODPROD2"
			IF OX:CARGO[TB_MSGE] == "MODIF"
        	IF AXR[NROW,RG_CODPROD] # OX:CARGO[TB_CONT]
           	if dbseek(OX:CARGO[TB_CONT])
        			MENSAJE( 0, 0, 10, .T., "EL PRODUCTO YA EXISTE !!!" )
              else
						AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
              endif
           ENDIF
			ENDIF
		ENDIF
		TBPOS(OX)

	ELSEIF OX:Cargo[TB_RET] == 999
		IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
			AADD( AXR, AREG0(aCpo) )
		ENDIF
		OX:RefreshAll()

	ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. LEN(AXR) > 1
		ADEL( AXR, NROW )
     ASIZE( AXR, LEN(AXR)-1 )
		OX:RefreshAll()

	ELSEIF OX:Cargo[TB_RET] == K_ESC .OR. OX:Cargo[TB_RET] == K_F10
		EXIT

	ENDIF

ENDDO
IF OX:Cargo[TB_RET] == K_F10
	MENSAJE( 99, 99, 0, .F., " CAMBIANDO CODIGOS ..." )
  nCant:=0

  FBASES({"COMPRAS2", "PLAN2"},.F.)
  DBSETORDER( FORDER({"STR(PL2->CODPROD)+FTOC(PL2->FECHA)"}) )
  FFLOCK()
  SET SOFTSEEK ON
  FOR i=1 TO LEN(AXR)
		IF AXR[i,RG_CODPROD]#0 .AND. AXR[i,RG_CODPROD2]#0
  		SEEK STR(AXR[i,RG_CODPROD],5)
	     	DO WHILE PL2->CODPROD == AXR[i,RG_CODPROD]
     		PL2->CODPROD := AXR[i,RG_CODPROD2]
           @ 24,70 say ++nCant pict "#####"
  			SEEK STR(AXR[i,RG_CODPROD],5)
     	ENDDO
     ENDIF
  NEXT i
  SET SOFTSEEK OFF
  DBUNLOCK()

  SELECT CO2
  DBSETORDER( FORDER({"STR(CO2->CODPROD)+FTOC(CO2->FECHA)"}) )
  FFLOCK()
  SET SOFTSEEK ON
  FOR i=1 TO LEN(AXR)
		IF AXR[i,RG_CODPROD]#0 .AND. AXR[i,RG_CODPROD2]#0
  		SEEK STR(AXR[i,RG_CODPROD],5)
     	DO WHILE CO2->CODPROD == AXR[i,RG_CODPROD]
           @ 24,70 say ++nCant pict "#####"
     		CO2->CODPROD := AXR[i,RG_CODPROD2]
  			SEEK STR(AXR[i,RG_CODPROD],5)
     	ENDDO
     ENDIF
  NEXT i
  SET SOFTSEEK OFF
  DBUNLOCK()

	aAlias:={"FA2","FB2","RE2"}
	aBase :={"FACA2","FACB2","REM2"}
	for b=1 to len(aBase)
  	@ 23,65 say justif(aBase[b],6,"=")
  	FBASES({aBase[b]},.F.)
  	select (aAlias[b])
     set order to
     nAux := lastrec()
  	go top
  	do while .not.eof()
  		i:=ascan(AXR,{|a| a[RG_CODPROD]==FIELD->CODPROD})
  		if i # 0
				if AXR[i,RG_CODPROD]#0 .AND. AXR[i,RG_CODPROD2]#0
           	FRLOCK()
     			FIELD->CODPROD := AXR[i,RG_CODPROD2]
           	@ 24,70 say ++nCant pict "#####"
              DBUNLOCK()
				endif
     	endif
  		@ 23,71 say --nAux pict "#######"
        SKIP
     enddo
  next b

	aBase :={"PLAN2","COMPRAS2","FACA2","FACB2","REM2"}
  aDir := directory("*.","D")
  for d=1 to len(aDir)
  	if aDir[d,5]=="D"
			for b=1 to len(aBase)
  			cArch := aDir[d,1]+"\"+aBase[b]
           if file(cArch+".dbf")
  				@ 23,60 say cArch
              do while .t.
  					select 99
  					use (cArch) alias X
                 if dbf()=="X"
                 	exit
                 endif
              enddo
     			nAux := lastrec()
  				go top
              lAux :=.F.
  				do while .not.eof()
  					i:=ascan(AXR,{|a| a[RG_CODPROD]==FIELD->CODPROD})
  					if i # 0
							if AXR[i,RG_CODPROD]#0 .AND. AXR[i,RG_CODPROD2]#0
           				FRLOCK()
     						FIELD->CODPROD := AXR[i,RG_CODPROD2]
           				@ 24,70 say ++nCant pict "#####"
              			lAux :=.T.
              			DBUNLOCK()
							endif
     				endif
  					@ 23,71 say --nAux pict "#######"
        			SKIP
     			enddo
              if lAux .and. abase[b] == "PLAN2"
              	ERASEFILE(aDir[d,1]+"\PL2*.NTX")
              endif
              if lAux .and. abase[b] == "COMPRAS2"
              	ERASEFILE(aDir[d,1]+"\CO2*.NTX")
              endif
           endif
  		next b
     endif
  next
  select 99;  dbclosearea()

	FBASES({ "PROVEE" },.F.)
	SELECT PRD
	fflock()
	for i=1 to len(AXR)
		IF AXR[i,RG_CODPROD]#0 .AND. AXR[i,RG_CODPROD2]#0
			SEEK AXR[i,RG_CODPROD]
  		DO WHILE PRD->CODPROD == AXR[i,RG_CODPROD]
  			PRD->CODPROD := AXR[i,RG_CODPROD2]
				SEEK AXR[i,RG_CODPROD]
  		ENDDO
		ENDIF
	next
	dbunlockall()
	RECUPAN()
ENDIF
select PRD
GO xreg
RECUPAN()
PONEPAN(xmenu)

RETURN OX:Cargo[TB_RET]


*************

FUNC PLTPRD()

*************
LOCAL aCpo, oX, oGET, nReg,cMenu,cMenu2,oX2, cBase:=DBF()

MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
aCpo:={;
	{ "CODPLT",     "C¢d",                                '', 'F',  '',  0, 0 },;
	{ "DESCPLT",    "Descripci¢n",                        '', 'E',  '',  0, 0 } }

FBASES({ "PLTPRD", "PLTPRD2" })

SELECT PLP
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
DBGOTOP()

cMenu:=MENUDOWN({"  <+>  º F2 modif. º   F2  º   F5   º   F6    º    F12    º  ESC   ",;
			  			"       º F3 busca  º modif.º        º         º   arma    º        ",;
			  			" mueve º F4 busca+ º descr.º agrega º elimina º plantilla º  sale  "})
SETCOLOR( "W/N,N/W" )
MARCO( 8, 25, 20, 78, "PLANTILLAS", "D", .T., 0 )
oX := MYBROWSE( 8, 25, 20, 78, aCpo )
oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()

DO WHILE .T.
	
	MOVBROW( oX, {||nK==K_F12.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_ENTER} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
		UNLOCK
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F5
  	SET DELETED OFF
  	nReg := 0
  	IF LASTREC() # 0
  		LOCATE FOR EMPTY(PLP->DESCPLT)
        if found(); nReg:=recno();  endif
     ENDIF
     DBGOBOTTOM()
     nAux := PLP->CODPLT + 1
     IF nReg == 0
     	ADD_REC()
     ELSE
     	go nReg
     	FRLOCK(); RECALL
     ENDIF
     set deleted on
     FRLOCK()
     PLP->CODPLT := nAux
     DBUNLOCK()
     TBPOS(OX)

	ELSEIF oX:Cargo[TB_RET] == K_F12
     MENSAJE( 0, 0, 0, .F., "CARGANDO ..." )
     AXR := {}
     SELECT PLP2
     DBSEEK( STR(PLP->CODPLT),.T.)
     DO WHILE PLP2->CODPLT==PLP->CODPLT .AND. !EOF()
			aadd(AXR,{PLP2->CODPROD,FPRODUCTO(PLP2->CODPROD)})
        SKIP 1 ALIAS PLP2
     ENDDO
		aCpo:={	                                                                      ;
			{ "CODPROD",    "C¢d;Prod",                      '99999', 'M', 'N',  5, 0 },;
			{ "DESCPROD",   "Descripci¢n; ",          REPLIC('X',20), 'F', 'C', 20, 0 }}
		SET(_SET_INTENSITY,.T.)
		NROW := 1
		IF LEN(AXR) == 0
			AADD( AXR, AREG0( aCpo ) )
		ENDIF
     recupan()
		SETCOLOR( "W/N,N/W" )
		MARCO( 5, 30, 19, 78, ALLTRIM(PLP->DESCPLT), "D", .T., 0 )
		OX2 := MYABROWSE( 5, 30, 19, 78, aCpo, AXR, "AXR" )
		OX2:CARGO[TB_REFRESH] := 0
		OX2:GOTOP()
		cMenu2:=MENUDOWN({"  <+>  º    F2    º    F3    º   F5    º   F6    º    TAB   º ESC  ",;
				 	 			"       º          º  busca   º inserta º elimina º  elegir  º      ",;
				 	 			" mueve º modifica º producto º  l¡nea  º  l¡nea  º producto º sale "})
		DO WHILE .T.
			MOVABROW( OX2, AXR, {||nK==K_TAB.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F5.OR.nK==K_F6},;
				{||nK==999} )
			IF ( OX2:Cargo[TB_MSGE] == "MODIF" .OR. OX2:Cargo[TB_RET] == K_TAB )
				IF TBNOC(OX2) == "CODPROD"
					IF OX2:CARGO[TB_MSGE] == "MODIF"
						AXR[NROW,OX2:ColPos] := OX2:CARGO[TB_CONT]
					ENDIF
					IF TBNOC(OX2) == "CODPROD"
						r := 0
						IF OX2:Cargo[TB_RET] == K_TAB
							IF FELEGIR( "PRODUCTO", AXR[NROW,RG_CODPROD] ) # 0
								AXR[NROW,RG_CODPROD] := PRD->CODPROD
							ENDIF
						ELSEIF OX2:Cargo[TB_RET] == K_F3
							r := SELECTPRD()
							IF r # 0
								AXR[NROW,RG_CODPROD] := r
							ENDIF
						ENDIF
						AXR[NROW,RG_DESCPROD ] := FPRODUCTO(AXR[NROW,RG_CODPROD])
           	ENDIF
				ENDIF
				OX2:RefreshCurrent()
			ELSEIF OX2:Cargo[TB_RET] == K_F5
				AADD( AXR, AREG0(aCpo) )
				AINS( AXR, NROW )
				AXR[NROW] := AREG0(aCpo)
				OX2:RefreshAll()
			ELSEIF OX2:Cargo[TB_RET] == 999
				IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
					AADD( AXR, AREG0(aCpo) )
				ENDIF
				OX2:RefreshAll()
			ELSEIF OX2:Cargo[TB_RET] == K_F6 .AND. LEN(AXR) > 1
				ADEL( AXR, NROW )
        	ASIZE( AXR, LEN(AXR)-1 )
				OX2:RefreshAll()
			ELSEIF OX2:Cargo[TB_RET] == K_ESC
				aux := UPPER(PREGUNTA( 10, " [ G ] graba     [ S ] sale     [ C ] contin£a ","GgSsCc"))
        	IF aux == "G"
					OX2:Cargo[TB_RET] := K_F10
					EXIT
        	ELSEIF aux == "S"
					EXIT
        	ENDIF
			ELSEIF OX2:Cargo[TB_RET] == K_F10
				EXIT
			ENDIF
		ENDDO
     ponepan(cMenu2)
 		RECUPAN()
		IF OX2:Cargo[TB_RET] == K_F10
     	MENSAJE( 0, 0, 0, .F., "GRABANDO..." )
        SELECT PLP2
        DBSEEK( STR(PLP->CODPLT),.T. )
        DO WHILE PLP2->CODPLT==PLP->CODPLT .AND. !EOF()
        	BLANKREG()
        	DBSEEK( STR(PLP->CODPLT),.T. )
        ENDDO
        FOR i=1 TO LEN(AXR)
				IF !EMPTY(AXR[i,RG_DESCPROD])
           	GO TOP
              IF PLP2->CODPLT#0 .OR. LASTREC()==0
              	ADD_REC()
              ENDIF
           	FRLOCK()
           	PLP2->CODPLT  := PLP->CODPLT
           	PLP2->CODPROD := AXR[i,RG_CODPROD]
           ENDIF
        NEXT
        DBUNLOCK()
        RECUPAN()
		ENDIF
     SELECT PLP
		TBPOS(OX)

	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	nAux := PLP->CODPLT
     	SELECT PLP2
        DBSEEK( STR(PLP->CODPLT),.T. )
        DO WHILE PLP2->CODPLT==PLP->CODPLT
        	BLANKREG()
        	DBSEEK( STR(PLP->CODPLT),.T. )
        ENDDO
        SELECT PLP
        BLANKREG(.T.)
        DBSEEK(nAux,.t.)
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ELSEIF oX:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
RECUPAN()
ponepan(cMenu)
DBUNLOCKALL()
DBCOMMITALL()
SELECT (cBase)
CLEARTYPEAHEAD()

RETURN( oX:Cargo[TB_RET]==K_ENTER )


*****************

FUNC FCOMPUESTO( cual, nCant, dFecha )

*****************
LOCAL cBase := DBF(), nReg:=RECNO()
RETURN .T.

SELECT ART2
SEEK cual
SELECT ART
FFLOCK()
DO WHILE ART2->CODPROD == cual
	SEEK ART2->CODPROD2
  IF FOUND()
     IF dFECHA >= ART->FECHA
     	ART->STOCKACT += nCant
        IF ART->CONDEP == 'S'
     		ART->STOCKACT -= nCant
        ENDIF
     ENDIF
  ENDIF
  SKIP 1 ALIAS ART2
ENDDO
DBSELECTAREA(cBase)
GO nReg

RETURN .T.
