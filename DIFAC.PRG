#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "TB.CH"
#include "BL.CH"

LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), XF, XF2, xmenu,xmenu2, lDetallado, lRecalc
local cColor:=setcolor()
DF_DESDE     := date()
DF_HASTA     := date()
DF_CODAJU    := "   "
DF_GRUPOS    := " "

IF FILE("DIFAC.MEM")
	RESTORE FROM DIFAC.MEM ADDITIVE
ENDIF
DO CARGAVEC WITH "AJUSTES", 50

xmenu:=MENUDOWN({"     º presione TAB º   F10    º  ESC   ",;
						"       º para ver las º          º        ",;
						" mueve º opciones.   º comienza º  sale  "})
AX2 := NEWEDIT2( "DIFAC",,.T. )
AX2[ED_MODE] = "MOSTRARTODO"
AX2[ED_I] := 1
DO WHILE .T.
	FEDITAR2( AX2, { K_TAB, K_F10 } )
	IF AX2[ED_UPDATE]
		AX2[ED_MODE] = "MOSTRARTODO"
	ELSEIF AX2[ED_TECLA] == K_TAB
		AX2[ED_MODE] = "MOSTRARTODO"
		IF EDNOM(AX2)=="DF_GRUPOS"
			xmenu:=MENUDOWN({"º  <+>  º Page Up   º  F2   º  F3   º   F4   º  F5   º   F6    º ESC  º",;
								  "º       º Page Down º modi- º       º        º       º         º      º",;
								  "º mueve º   mueve+  º fica  º busca º busca+ º carga º elimina º sale º"})
			PRIVATE bcamp[5], bmasc[5], bcab[5], bedit
			bcamp[ 1] = "GR->CODGRUP"
			bcamp[ 2] = "GR->DESCGRUP"
			bcamp[ 3] = "GR->CODPROD"
			bcamp[ 4] = "FPRODUCTO(GR->CODPROD)"
			bcamp[ 5] = "OBSERV"
			bmasc[ 1] = "99"
			bmasc[ 2] = "@!"
			bmasc[ 3] = ""
			bmasc[ 4] = "XXXXXXXXXXXXX"
			bmasc[ 5] = ""
			bcab[ 1] = "C¢digo"
			bcab[ 2] = "Descripci¢n"
			bcab[ 3] = "C¢d;Prod"
			bcab[ 4] = "Producto;Generico"
			bcab[ 5] = "Observ"
			bedit = "FEEFE"
			SETCOLOR(C_MENU)
			SELECT GR
			BROW( 10, 15, 20, 78, " GRUPOS ", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=-4.OR.tecla=-5.OR.tecla=-1.OR.tecla=9.OR.tecla=13" )
			RECUPAN()
			PONEPAN(xmenu)
     ENDIF
	ELSEIF AX2[ED_TECLA] == K_F10
  	select GR
     nAux:=recno()
  	locate for empty(FPRODUCTO(GR->CODPROD)) .and. !empty(GR->DESCGRUP)
     if found()
			MENSAJE(0,0,10,.T.,"FALTA EL CODIGO GENERICO DE "+alltrim(GR->DESCGRUP)+" !!!" )
     else
     	locate for upper(left(GR->OBSERV,1))=="V"
        if !found()
				MENSAJE(0,0,10,.T.,"poner en Observ. una V para indicar VARIOS !!!" )
        else
        	go nAux
     		nOTROS := GR->CODGRUP
        	exit
        endif
		endif
    	go nAux
	ELSEIF AX2[ED_TECLA]==K_ESC
		EXIT
	ENDIF
ENDDO
FEDITOR(AX2,"SACAPAN")

IF AX2[ED_TECLA] == K_F10
	MENUDOWN({" "," "," "})
	MENSAJE( 99, 99, 0, .F., padc("AGUARDE...",40,' '), " ", " ", " "," " )
	SAVE ALL LIKE DF_* TO DIFAC.MEM
	M->PIVA1      := VA->PIVA1
	M->PIVA2      := 0

	select 99;  dbclosearea()
  cBaseAux := XNAME('XAUX')
	aaux := {{"GRUPO","N",3,0},{"DESCGRUP","C",15,0},;
           {"CODPROD","N",5,0}, {"FECHA","D",8,0},;
  			{"CANTPL","N",15,4}, {"IMPPL","N",15,2},;
  			{"CANTVM","N",15,4}, {"IMPVM","N",15,2},;
  			{"CANTFA","N",15,4}, {"IMPFA","N",15,2},;
  			{"CANTFB","N",15,4}, {"IMPFB","N",15,2},;
 				{"CANTRE","N",15,4}, {"IMPRE","N",15,2},;
 				{"CANTDIF","N",15,4},{"IMPDIF","N",15,2},;
 				{"CANTDIFACU","N",15,4}, {"IMPDIFACU","N",15,2}}
  dbcreate( cBaseAux, aaux )
 	select 99
 	use (cBaseAux) alias X exclusive
  index on str(X->CODPROD)+ftoc(X->FECHA) to (cBaseAux)

 	select GR
 	i:= 0
 	DBEVAL( {|| ++i ,;
 		AXR[i,RG_NEGOCIO ]:=" "     		,;
 		AXR[i,RG_CODPROD ]:=GR->CODGRUP	,;
 		AXR[i,RG_DESCPROD]:=GR->DESCGRUP},;
 		{|| !DELETED().AND.!EMPTY(GR->DESCGRUP) } )

	**************************  PLANILLAS ********************************
	FBASES({"+PLAN2"}, .F.)
  @ 18,38 SAY " PLANILLAS:"
  nCant := 0
  nTot  := 0
  uFechaPla := DF_DESDE
	SELECT PL2
	SET ORDER TO FORDER({"FECHA","TURNO"})
	DBSEEK( FTOC(DF_DESDE), .T. )
  cAux := DTOC(PL2->FECHA)+PL2->TURNO
	DO WHILE PL2->FECHA>=DF_DESDE .AND. PL2->FECHA<=DF_HASTA
		FPRODUCTO(PL2->CODPROD)
		i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO})
		IF i == 0
			i := ASCAN( AXR, {|a| a[RG_CODPROD]==nOTROS} )
     ENDIF
		AXR[ i,RG_CANTIDAD   ] += FIELD->CANTIDAD
		AXR[ i,RG_PRECBASE   ] := FIELD->PRECBASE
		AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
		AXR[ i,RG_IMPINT     ] := FIELD->IMPINT
		AXR[ i,RG_IVA1       ] := FIELD->IVA
		AXR[ i,RG_PRECUNIT   ] := FIELD->PRECUNIT
		AXR[ i,RG_TPRECBASE  ] += ( FIELD->PRECBASE * FIELD->CANTIDAD )
		AXR[ i,RG_TIMPINT    ] += ( FIELD->IMPINT * FIELD->CANTIDAD )
		AXR[ i,RG_TIVA1      ] += FIELD->IVA * FIELD->CANTIDAD
 		AXR[ i,RG_IMPORTE    ] += ( FIELD->PRECBASE+FIELD->IMPINT+AXR[i,RG_IVA1]) * FIELD->CANTIDAD
     nTot += ( FIELD->PRECBASE+FIELD->IMPINT+AXR[i,RG_IVA1]) * FIELD->CANTIDAD

     if !X->(dbseek(str(PL2->CODPROD)+FTOC(PL2->FECHA)))
     	select X
        append blank
        X->CODPROD := PL2->CODPROD
        X->FECHA   := PL2->FECHA
        select PL2
     endif
     X->CANTPL += PL2->CANTIDAD
     X->IMPPL  += ( FIELD->PRECBASE+FIELD->IMPINT+AXR[i,RG_IVA1]) * FIELD->CANTIDAD

     IF cAux # DTOC(PL2->FECHA)+PL2->TURNO
  		@ 18,50 SAY ++nCant PICT "####"
  		@ 18,55 SAY nTot  PICT "#########.##"
        cAux := DTOC(PL2->FECHA)+PL2->TURNO
     	uFechaPla := MAX( uFechaPla, PL2->FECHA )
  		@ 18,68 SAY uFechaPla
     ENDIF
		SKIP
	ENDDO
	FBASES({"-PLAN2"}, .F.)

	**************************  VENTA MAYORISTA  *************************
	FBASES({"+VM"}, .F.)
  @ 19,38 SAY " VTA.MAY.:"
  nCant := 0
  nTot  := 0
  uFechaPla := DF_DESDE
	SELECT VM
	SET ORDER TO FORDER({"FECHA","TURNO"})
	DBSEEK( FTOC(DF_DESDE), .T. )
  cAux := DTOC(VM->FECHA)
	DO WHILE VM->FECHA>=DF_DESDE .AND. VM->FECHA<=DF_HASTA
		FPRODUCTO(VM->CODPROD)
		i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO} )
		IF i == 0
			i := ASCAN( AXR, {|a| a[RG_CODPROD]==nOTROS} )
     ENDIF
		AXR[ i,RG_CANTIDAD   ] += FIELD->CANTIDAD
		AXR[ i,RG_PRECBASE   ] := FIELD->PRECBASE
		AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
		AXR[ i,RG_IMPINT     ] := FIELD->IMPINT
		AXR[ i,RG_IVA1       ] := FIELD->IVA
		AXR[ i,RG_PRECUNIT   ] := (FIELD->PRECBASE+FIELD->IMPINT+FIELD->IVA)
		AXR[ i,RG_TPRECBASE  ] += ( FIELD->PRECBASE * FIELD->CANTIDAD )
		AXR[ i,RG_TIMPINT    ] += ( FIELD->IMPINT * FIELD->CANTIDAD )
		AXR[ i,RG_TIVA1      ] += FIELD->IVA * FIELD->CANTIDAD
 		AXR[ i,RG_IMPORTE    ] += ( FIELD->PRECBASE+FIELD->IMPINT+AXR[i,RG_IVA1]) * FIELD->CANTIDAD
     nTot += ( FIELD->PRECBASE+FIELD->IMPINT+AXR[i,RG_IVA1]) * FIELD->CANTIDAD

     if !X->(dbseek(str(VM->CODPROD)+FTOC(VM->FECHA)))
     	select X
        append blank
        X->CODPROD := VM->CODPROD
        X->FECHA   := VM->FECHA
        select VM
     endif
     X->CANTVM += VM->CANTIDAD
     X->IMPVM  += VM->IMPORTE

     IF cAux # DTOC(VM->FECHA)
  		@ 19,50 SAY ++nCant PICT "####"
  		@ 19,55 SAY nTot  PICT "#########.##"
        cAux := DTOC(VM->FECHA)
     	uFechaPla := MAX( uFechaPla, VM->FECHA )
  		@ 19,68 SAY uFechaPla
     ENDIF
		SKIP
	ENDDO
	FBASES({"-VM"}, .F.)

			
	***************************  FACTURAS  ************************
  aBase:={{"Facturas A","FA","NUMFAC"},;
          {"Facturas B","FB","NUMFAC"}}
*         {"Remitos  X","RE","NUMFAC"}}
  uFechaFa := DF_DESDE
  FOR z=1 TO len(aBase)
  	XF := aBase[z,2]
     nNUM := aBase[z,3]
     if XF=="RE"
     	cBlock := ".T."
     else
  		cBlock := "("+XF+"->TIPOVENTA==2.and.!empty("+XF+"->ID_CCV)).or."+XF+"->TIPOVENTA==1"
  		cBlock := ".T."
     endif
  	bBlock :=  &( "{||"+cBlock+"}" )
  	@ 19+z,38 say aBase[z,1]
  	nCant := 0
     nTot := 0
  	XF2 := XF + "2"
		DBSELECTAREA(XF)
		SET ORDER TO FORDER({"FECHA"})
		DBSEEK(FTOC(DF_DESDE),.T.)
  	SELECT (XF2)
		DO WHILE (XF)->FECHA>=DF_DESDE .AND. (XF)->FECHA<=DF_HASTA .AND. !(XF)->(EOF())
     	if eval(bBlock)
  			SEEK (XF)->&(nNUM)
     		DO WHILE (XF2)->&(nNUM) == (XF)->&(nNUM)
     			IF (XF2)->CODPROD>0 .AND. (XF2)->NEGOCIO#"*"
						FPRODUCTO((XF2)->CODPROD)
						i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO} )
						IF i == 0
							i := ASCAN( AXR, {|a| a[RG_CODPROD]==nOTROS} )
						ENDIF
						AXR[ i,RG_CANTIDAD   ] -= FIELD->CANTIDAD
						AXR[ i,RG_PRECBASE   ] := FIELD->TPRECBASE / FIELD->CANTIDAD
						AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
						AXR[ i,RG_IMPINT     ] := FIELD->TIMPINT / FIELD->CANTIDAD
						AXR[ i,RG_IVA1       ] := FIELD->TIVA1 / FIELD->CANTIDAD
						AXR[ i,RG_PRECUNIT   ] := FIELD->PRECUNIT
						AXR[ i,RG_TPRECBASE  ] -= FIELD->TPRECBASE
						AXR[ i,RG_TIMPINT    ] -= FIELD->TIMPINT
						AXR[ i,RG_TIVA1      ] -= FIELD->TIVA1
						AXR[ i,RG_IMPORTE    ] -= ( FIELD->TPRECBASE + FIELD->TIMPINT + FIELD->TIVA1 )
						nAux := FIELD->TPRECBASE + FIELD->TIMPINT + FIELD->TIVA1 		//+ M->TIVA2
        			nTot += ( FIELD->TPRECBASE + FIELD->TIMPINT + FIELD->TIVA1 )
              ENDIF

     			if !X->(dbseek(str((XF2)->CODPROD)+FTOC((XF)->FECHA)))
     				select X
        			append blank
        			X->CODPROD := (XF2)->CODPROD
        			X->FECHA   := (XF)->FECHA
        			select (XF2)
     			endif
        		if XF == "FA"
     				X->CANTFA += (XF2)->CANTIDAD
     				X->IMPFA  += ( FIELD->TPRECBASE + FIELD->TIMPINT + FIELD->TIVA1 )
        		elseif XF=="FB"
     				X->CANTFB += (XF2)->CANTIDAD
     				X->IMPFB  += ( FIELD->TPRECBASE + FIELD->TIMPINT + FIELD->TIVA1 )
        		elseif XF=="RE"
     				X->CANTRE += (XF2)->CANTIDAD
     				X->IMPRE  += ( FIELD->TPRECBASE + FIELD->TIMPINT + FIELD->TIVA1 )
        		endif

        		SKIP
				ENDDO
     		uFechaFa := MAX( uFechaFa, FIELD->FECHA )
  			@ 19+z,50 SAY ++nCant PICT "####"
  			@ 19+z,55 SAY nTot  PICT "#########.##"
        endif
  		@ 19+z,68 SAY (XF)->FECHA
			SKIP 1 ALIAS (XF)
		ENDDO
		SET ORDER TO FORDER({"NUMFAC"})
     XF := "FB"
     nCant := 0
  NEXT

	MENUDOWN({" presione ENTER "})
	inkey(0)
	RECUPAN()
  ***********************
	MENSAJE( 99, 99, 0, .F., "AGUARDE...")
	aCpo := {;
			{ "CODPROD",     "Gru;po",                        '', 'F',  '',  0, 0 },;
			{ "FPRODUCTO(X->CODPROD)","Descripci¢n",     replic('X',14), 'F', 'F', 14, 0 },;
			{ "FECHA",       "Fecha",                         '', 'F',  '',  0, 0 },;
			{ "IMPPL",       "Importe;Planilla",              '', 'F',  '',  0, 0 },;
			{ "IMPVM",       "Importe;Vta.May",               '', 'F',  '',  0, 0 },;
			{ "IMPFA",       "Importe;Fact.A",                '', 'F',  '',  0, 0 },;
			{ "IMPFB",       "Importe;Fact.B",                '', 'F',  '',  0, 0 },;
			{ "IMPRE",       "Importe;Remito",                '', 'F',  '',  0, 0 },;
			{ "IMPDIF",      "Importe;Diferencia",    '#########.##', 'F', 'F', 12, 2 },;
			{ "IMPDIFACU",   "Importe;Diferencia;Acumulada",    '#########.##', 'F', 'F', 12, 2 },;
			{ "CANTPL",      "Cant;Plan",                     '', 'F',  '',  0, 0 },;
			{ "CANTVM",      "Cant;Vta.May",                  '', 'F',  '',  0, 0 },;
			{ "CANTFA",      "Cant;Fact.A",                   '', 'F',  '',  0, 0 },;
			{ "CANTFB",      "Cant;Fact.B",                   '', 'F',  '',  0, 0 },;
			{ "CANTRE",      "Cant;Remito",                   '', 'F',  '',  0, 0 },;
			{ "CANTDIF",     "Cant.;Diferencia",      '#########.##', 'F', 'F', 12, 2 },;
			{ "CANTDIFACU",  "Cant.;Diferencia;Acumulada",      '#########.##', 'F', 'F', 12, 2 }}
	select X
	aCpo := FARRAYAUX( aCpo )
  go top
  nCODPROD := -1
  nCantDifAcu := nImpDifAcu := 0
  do while ROSCA() .and. !eof()
  	replace CANTDIF with CANTPL+CANTVM-CANTFA-CANTFB-CANTRE, IMPDIF with IMPPL+IMPVM-IMPFA-IMPFB-IMPRE
  	if X->CODPROD # nGrupo
     	nCantDifAcu := nImpDifAcu  := 0
  		nCODPROD := X->CODPROD
     endif
     X->CANTDIFACU := nCantDifAcu + X->CANTDIF
     X->IMPDIFACU  := nImpDifAcu + X->IMPDIF
     nCantDifAcu := X->CANTDIFACU
     nImpDifAcu  := X->IMPDIFACU
  	skip
  enddo
  set relation to X->CODPROD into PRD
  dbeval({||X->GRUPO:=PRD->GRUPO})
  set relation to
  set relation to X->GRUPO into GR
  dbeval({||X->DESCGRUP:=GR->DESCGRUP})
  GO TOP
	RECUPAN()
	xmenu2:=MENUDOWN({"     º        F8        º  ESC   ",;
							"       º cambia detallado º        ",;
							" mueve º por d¡a Si o No  º  sale  "})
	MARCO( 7, 1, 18, 78, "DETALLE FACTURA COMPLEMENTARIA", "D", .T., 0 )
	OX := MYBROWSE( 7, 1, 18, 78, aCpo )
	OX:CARGO[TB_REFRESH] := 0
  OX:FREEZE := 3
  lDetallado := .F.
  lRecalc := .T.
	DO WHILE .T.
     if lRecalc
			MENSAJE( 99, 99, 0, .F., "AGUARDE...")
     	if lDetallado
        	select 99;  dbclosearea()
        	select 99
           use (cBaseAux) alias X exclusive index (cBaseAux)
        else
     		index on X->CODPROD to QQ
        	total on X->CODPROD to QQ for ROSCA() fields CANTPL,IMPPL, CANTVM,IMPVM, CANTFA,IMPFA, CANTFB,IMPFB, CANTRE,IMPRE, CANTDIF,IMPDIF
        	select 99;  dbclosearea()
           select 99
        	use qq alias X exclusive
  			replace CANTDIFACU with CANTDIF, IMPDIFACU with IMPDIF all
        endif
        lDetallado := !lDetallado
        go top
        RECUPAN()
       	OX:refreshall()
     	lRealc := .F.
     endif
		MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F8.OR.nK==K_F9} )
		IF OX:Cargo[TB_MSGE] == "MODIF"
		ELSEIF OX:Cargo[TB_RET] == K_F8
     	lRealc := .T.
		ELSEIF OX:Cargo[TB_RET] == K_F9
			MENSAJE( 99, 99, 0, .F., "AGUARDE...")
     	if !lDetallado
        	aaux:={}
           select X
     		index on str(X->GRUPO)+ftoc(X->FECHA) to QQ for eval({||if(ascan(aaux,GRUPO)#0,,aadd(aaux,GRUPO)),.T.})
           for i=1 to len(aaux)
           	dbseek( str(aaux[i],flen(X->GRUPO)), .T. )
        		total on str(X->GRUPO)+ftoc(X->FECHA) to ("EXT\"+strzero(aaux[i],2)) rest for ROSCA() while GRUPO==aaux[i] fields CANTPL,IMPPL, CANTVM,IMPVM, CANTFA,IMPFA, CANTFB,IMPFB, CANTRE,IMPRE, CANTDIF,IMPDIF
           next i
     	endif
        select X
     	lRealc := .T.
     	lDetallado := .T.
        RECUPAN()
		ELSEIF OX:Cargo[TB_RET] == K_ESC
     	EXIT
		ENDIF
  ENDDO
	RECUPAN()
 	PONEPAN(xmenu2)
  ***********************
ENDIF
MENUDOWN(xmenu)

i := ASCAN( AXR, {|a| a[RG_IMPORTE]==0.AND.!EMPTY(a[RG_DESCPROD])} )
DO WHILE i # 0
	ADEL( AXR, i )
  AXR[LEN(AXR)] := ARRAY( LEN(AXR[1]) )
  AFILL( AXR[LEN(AXR)], 0 )
  AXR[LEN(AXR),RG_DESCPROD] := SPACE(LEN((XF2)->DESCPROD))
  AXR[LEN(AXR),RG_NEGOCIO ] := " "
	i := ASCAN( AXR, {|a| a[RG_IMPORTE]==0.AND.!EMPTY(a[RG_DESCPROD])} )
ENDDO
select GR
FOR i=1 TO LEN(AXR)
*	AXR[i,RG_CANTIDAD] := 0
	if dbseek(AXR[i,RG_CODPROD])
  	AXR[i,RG_CODPROD] := GR->CODPROD
  endif
NEXT
DBSELECTAREA(cBase)
SET ORDER TO nOrder
GO nReg

setcolor(cColor)
SETCOLOR(C_FONDO)
FOR i=1 TO 9;	EVAL( bDetalle1, i );	NEXT
SETCOLOR(C_GET)
FOR i=1 TO 9;  EVAL( bDetalle2, i );	NEXT
FXTOTAL()

RETURN
