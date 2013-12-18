PARAMETERS AXR, ctitulo
LOCAL aCPO, OX, NROWR:=NROW

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

#define RG_CODPROD        1
#define RG_SURTIDOR       2
#define RG_DESCPROD       3

ctitulo := IF( ctitulo==NIL, " PLANTILLA ", ctitulo )
aCpo:={                                                                        ;
  { "CODPROD",    "C¢d;Prod",                      '99999', 'M', 'N',  5, 0 },;
  { "SURTIDOR",   "Su;rt",                            '99', 'M', 'N',  2, 0 },;
  { "DESCPROD",   "Descripci¢n; ",          REPLIC('X',20), 'F', 'C', 20, 0 }}

SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

NROW := 1
IF LEN(AXR) == 0
	AADD( AXR, AREG0( aCpo ) )
ENDIF

SETCOLOR( "W/N,N/W" )
MARCO( 5, 30, 19, 78, ctitulo, "D", .T., 0 )
OX := MYABROWSE( 5, 30, 19, 78, aCpo, AXR, "AXR" )
OX:CARGO[TB_REFRESH] := 0
OX:GOTOP()


MENUDOWN({"  <+>  º    F2    º    F3    º   F5    º   F6    º    TAB   º ESC  ",;
          "       º          º  busca   º inserta º elimina º  elegir  º      ",;
          " mueve º modifica º producto º  l¡nea  º  l¡nea  º producto º sale "})

guardar = .F.
DO WHILE .T.
	
	MOVABROW( OX, AXR, {||nK==K_TAB.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F5.OR.nK==K_F6},;
	  {||nK==999} )
	
	IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB ) .AND. MODIFICABLE
		IF TBNOC(OX) $ "CODPROD SURTIDOR"
			IF OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			IF TBNOC(OX) == "CODPROD"
				r := 0
				IF OX:Cargo[TB_RET] == K_TAB
					IF FELEGIR( "PRODUCTO", AXR[NROW,RG_CODPROD] ) # 0
						AXR[NROW,RG_CODPROD] := PRD->CODPROD
					ENDIF
				ELSEIF OX:Cargo[TB_RET] == K_F3
					r := SELECTPRD()
					IF r # 0
						AXR[NROW,RG_CODPROD] := r
					ENDIF
				ENDIF
				AXR[NROW,RG_DESCPROD ] := FPRODUCTO(AXR[NROW,RG_CODPROD])
			ENDIF
		ENDIF
		OX:RefreshCurrent()
		
	ELSEIF OX:Cargo[TB_RET] == K_F5 .AND. MODIFICABLE
		AADD( AXR, AREG0(aCpo) )
		AINS( AXR, NROW )
		AXR[NROW] := AREG0(aCpo)
		AXR[NROW,RG_SURTIDOR] := 0
		OX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
		IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
			AADD( AXR, AREG0(aCpo) )
			AXR[LEN(AXR),RG_SURTIDOR] := 0
		ENDIF
		OX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. LEN(AXR) > 1
		ADEL( AXR, NROW )
		ASIZE( AXR, LEN(AXR)-1 )
		OX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == K_ESC
		aux := UPPER(PREGUNTA( 10, " [ G ] graba     [ S ] sale     [ C ] contin£a ","GgSsCc"))
		IF aux == "G"
			OX:Cargo[TB_RET] := K_F10
			EXIT
		ELSEIF aux == "S"
			EXIT
		ENDIF
		
	ELSEIF OX:Cargo[TB_RET] == K_F10
		EXIT
		
	ENDIF
	*    CLEARTYPEAHEAD()
ENDDO

RECUPAN()
NROW := NROWR

IF OX:Cargo[TB_RET] == K_F10
	i := ASCAN( AXR,{|a| EMPTY(a[RG_DESCPROD])} )
	DO WHILE i # 0
		ADEL( AXR, i )
		ASIZE( AXR, LEN(AXR)-1 )
		i := ASCAN( AXR,{|a| EMPTY(a[RG_DESCPROD])} )
	ENDDO
ENDIF

RETURN ( OX:Cargo[TB_RET] == K_F10 )


**************

FUNC CONFIGPLT()

**************
xmenu:=MENUDOWN({"     º presione TAB º  ESC   ",;
            "       º para ver las º        ",;
            " mueve º opciones.    º  sale  "})
aPltCfg := {0,0,"        ",0,0,0,0}
if file("pltcfg.arr")
	aPltCfg := STOA(MEMOREAD("pltcfg.arr"))
endif
aPltCfg[3] := padr(aPltCfg[3],8,' ')
aed := NEWEDIT2( "PLTCFG",,.T. )
aed[ED_MODE] = "MOSTRARTODO"
aed[ED_I] := 1
DO WHILE .T.
	FEDITAR2( aed, { K_TAB, K_F10 } )
	IF aed[ED_UPDATE]
		aed[ED_MODE] = "MOSTRAR"
	ELSEIF aed[ED_TECLA] == K_F10
		MEMOWRIT("pltcfg.arr",ATOS(aPltCfg))
		EXIT
	ELSEIF aed[ED_TECLA] == K_ESC
		aux := UPPER(PREGUNTA( 10, " [ G ] graba     [ S ] sale     [ C ] contin£a ","GgSsCc"))
		IF aux == "G"
			MEMOWRIT("pltcfg.arr",ATOS(aPltCfg))
			EXIT
		ELSEIF aux == "S"
			EXIT
		ENDIF
	ENDIF
ENDDO
FEDITOR(aed,"SACAPAN")
MENUDOWN(xmenu)

RETURN NIL


**************

FUNC IMPRPLT()

**************
LOCAL aaux, nAux1:=nAux2:=nAux3:=0
aComb := {}
aLubr := {}
aVari := {}

aPltCfg := {0,0,"",0,0,0,0}
if file("pltcfg.arr")
	aPltCfg := STOA(MEMOREAD("pltcfg.arr"))
endif
if aPltCfg[1] < 1
	MENSAJE( 0, 0, 10, .T., "LARGO DE HOJA INCORRECTO !" )
	RETURN .F.
endif
aPltCfg[3] := if( empty(aPltCfg[3]), "PLT", alltrim(aPltCfg[3]) )+".PRN"

LISTADOR("INI")
SETIMPRESORA( "INI", "")

#ifdef DOCSA
	?? CHR(27)+"@"
	?? CHR(27)+"A"+CHR(7)
	?? chr(14)+CHR(15)+"PLANILLA DE VENTAS"+CHR(20)
	?? SPACE(10)+"FECHA .../.../...    TURNO ...     CAJA .........."
  ?
  ?
  ? "ABRIO .............................            CERRO ............................."
	
	aaux := {}
	?
	?         CHR(14)+"COMBUSTIBLES"
	aadd(aaux,                   "                                 ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
	aadd(aaux,                   "                                 ³                 M E C A N I C O                º")
	SELECT PLT
	GO TOP
	DO WHILE !EOF()
		IF PLT->MARCA==''
			CARGAPLT()
			if len(aComb) > 0
				aaux2 := array(len(aComb))
				for i=1 to len(aaux2) step 4
					afill(aaux2,if(aaux2[i]==1,2,1),i)
				next
				aadd(aaux,          "ÉÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
				aadd(aaux,          "ºLADOºSurt³Producto              ³Abri¢                  ³Cerr¢                   º")
				FOR i=1 TO LEN(aComb)
					aadd(aaux,       "º    ÇÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶")
					aadd(aaux, USING("º üü º üü ³ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³                       ³                        º",{aaux2[i],aComb[i,2],aComb[i,3]}))
					++nAux1
				NEXT
				aadd(aaux,          "ÈÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼")
			endif
		ENDIF
		SKIP 1 ALIAS PLT
	ENDDO
	aeval(aaux,{|a,i| QOUT(a)})
	nL := LEN(aaux) + 3
	
	
	aaux := {}    // lubricantes
	SELECT PLT
	GO TOP
	DO WHILE !EOF()
		IF PLT->MARCA==''
			CARGAPLT()
			if len(aLubr) > 0
				if nAux2 == 0
					aadd(aaux,      "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»" )
					aadd(aaux,      "ºProducto            ³Inicio    ³Ingreso    ³Total     ³Entrego   ³Venta     º" )
					nAux2+=2
				else
					aadd(aaux,      "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»" )
					nAux2+=1
				endif
				FOR i=1 TO LEN(aLubr)
					aadd(aaux,      "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶" )
					aadd(aaux,USING("ºƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³          ³           ³          ³          ³          º",{aLubr[i,3]}) )
					nAux2+=2
				NEXT
				aadd(aaux,         "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶" )
				aadd(aaux,         "º                               T O T A L                         ³          º" )
				aadd(aaux,         "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼" )
				nAux2+=3
			endif
		ENDIF
		SKIP 1 ALIAS PLT
	ENDDO
	
	SELECT PLT      // varios
	GO TOP
	DO WHILE !EOF()
		IF PLT->MARCA==''
			CARGAPLT()
			if len(aVari) > 0
				IF LEN(aVari)*2+4 > LEN(aaux)
					FOR i=LEN(aaux) TO LEN(aVari)*2+4
						aadd(aaux,SPACE(LEN(aaux[1])))
					NEXT
				ENDIF
				if nAux3 == 0
					aaux[1] +=        "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
					aaux[2] +=        "ºProducto            ³Inicio    ³Ingreso    ³Total     ³Entrego   ³Venta     º"
					nAux3+=2
				else
					aaux[1] +=        "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
					nAux3+=1
				endif
				nn := 3
				FOR i=1 TO LEN(aVari)
					aaux[nn]+=        "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"; ++nn
					aaux[nn]+=  USING("ºƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³          ³           ³          ³          ³          º",{aVari[i,3]} ); ++nn
					nAux3+=2
				NEXT
				aaux[nn+0] +=        "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
				aaux[nn+1] +=        "º                               T O T A L                         ³          º"
				aaux[nn+2] +=        "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼"
				nAux3+=3
			endif
		ENDIF
		SKIP 1 ALIAS PLT
	ENDDO
	
*i := MIN(nAux2,nAux3)+1
*nAux := if(nAux3>nAux2,1,79)
*aa:={"                                     ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»",;
*     "                                     º                 ³                     º",;
*     "                                     º VENTA           ³                     º",;
*     "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶",;
*     "º                                  º º                 ³                     º",;
*     "º BUZON  $                         º º INGRESO         ³                     º",;
*     "º                                  º ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶",;
*     "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ º                 ³                     º",;
*     "                                     º DIFERENCIA      ³                     º",;
*     "                                     ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼" }
*for n=1 to len(aa)
*	if i > len(aaux)
*		aadd(aaux,space(159))
*	endif
*	aaux[i] := stuff(aaux[i],nAux,len(aa[n]),aa[n])
*	++i
*next
	
	?
	?"LUBRICANTES                                             VARIOS"
	? chr(27)+chr(77)+chr(15)
	nL += LEN(aaux) + 2
	nAux := IF(nL>aPltCfg[1],aPltCfg[1],nL)
	aeval(aaux,{|a,i| QOUT(a)},1,nAux)
	for i=nL to aPltCfg[1]
		?
	next
	
#else
	?? CHR(27)+"@"
	?? chr(14)+CHR(15)+"PLANILLA DE VENTAS"
	? SPACE(50)+"FECHA ..........     TURNO ..."
	?? CHR(27)+"A"+CHR(6)
	
	aaux := {}
	?
	?         CHR(14)+"COMBUSTIBLES"
	aadd(aaux,                  "                          ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
	aadd(aaux,                  "                          ³                  M E C A N I C O                 º               E L E C T R O N I C O              º")
	SELECT PLT
	GO TOP
	DO WHILE !EOF()
		IF PLT->MARCA==''
			CARGAPLT()
			if len(aComb) > 0
				aadd(aaux,          "ÉÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍ»")
				aadd(aaux,          "ºSurt³Producto            ³Abri¢            ³Cerr¢           ³Diferencia     ºAbri¢            ³Cerr¢           ³Diferencia     º    º")
				FOR i=1 TO LEN(aComb)
					aadd(aaux,       "ÇÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶    º")
					aadd(aaux, USING("º üü ³ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³                 ³                ³               º                 ³                ³               º    º",{aComb[i,2],aComb[i,3]}))
					++nAux1
				NEXT
				aadd(aaux,          "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍ¼")
			endif
		ENDIF
		SKIP 1 ALIAS PLT
	ENDDO
	aeval(aaux,{|a,i| QOUT(a)})
	nL := LEN(aaux) + 3
	
	
	aaux := {}
	SELECT PLT
	GO TOP
	DO WHILE !EOF()
		IF PLT->MARCA==''
			CARGAPLT()
			if len(aLubr) > 0
				if nAux2 == 0
					aadd(aaux,      "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»" )
					aadd(aaux,      "ºProducto            ³Inicio    ³Ingreso    ³Total     ³Entrego   ³Venta     º" )
					nAux2+=2
				else
					aadd(aaux,      "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»" )
					nAux2+=1
				endif
				FOR i=1 TO LEN(aLubr)
					aadd(aaux,      "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶" )
					aadd(aaux,USING("ºƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³          ³           ³          ³          ³          º",{aLubr[i,3]}) )
					nAux2+=2
				NEXT
				aadd(aaux,         "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶" )
				aadd(aaux,         "º                               T O T A L                         ³          º" )
				aadd(aaux,         "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼" )
				nAux2+=3
			endif
		ENDIF
		SKIP 1 ALIAS PLT
	ENDDO
	
	SELECT PLT
	GO TOP
	DO WHILE !EOF()
		IF PLT->MARCA==''
			CARGAPLT()
			if len(aVari) > 0
				IF LEN(aVari)*2+4 > LEN(aaux)
					FOR i=LEN(aaux) TO LEN(aVari)*2+4
						aadd(aaux,SPACE(LEN(aaux[1])))
					NEXT
				ENDIF
				if nAux3 == 0
					aaux[1] +=        "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
					aaux[2] +=        "ºProducto            ³Inicio    ³Ingreso    ³Total     ³Entrego   ³Venta     º"
					nAux3+=2
				else
					aaux[1] +=        "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
					nAux3+=1
				endif
				nn := 3
				FOR i=1 TO LEN(aVari)
					aaux[nn]+=        "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"; ++nn
					aaux[nn]+=  USING("ºƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³          ³           ³          ³          ³          º",{aVari[i,3]} ); ++nn
					nAux3+=2
				NEXT
				aaux[nn+0] +=        "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
				aaux[nn+1] +=        "º                               T O T A L                         ³          º"
				aaux[nn+2] +=        "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼"
				nAux3+=3
			endif
		ENDIF
		SKIP 1 ALIAS PLT
	ENDDO
	
 	i := MIN(nAux2,nAux3)+1
	nAux := if(nAux3>nAux2,1,79)
	aa:={"                                     ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»",;
		 "                                     º                 ³                     º",;
      "                                     º VENTA           ³                     º",;
      "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶",;
      "º                                  º º                 ³                     º",;
      "º BUZON  $                         º º INGRESO         ³                     º",;
      "º                                  º ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶",;
      "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ º                 ³                     º",;
      "                                     º DIFERENCIA      ³                     º",;
      "                                     ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼" }
	for n=1 to len(aa)
		if i > len(aaux)
			aadd(aaux,space(159))
		endif
		aaux[i] := stuff(aaux[i],nAux,len(aa[n]),aa[n])
		++i
	next
	
	?
	?"LUBRICANTES   APELLIDO......................            VARIOS"
	? chr(27)+chr(77)+chr(15)
	nL += LEN(aaux) + 2
	nAux := IF(nL>aPltCfg[1],aPltCfg[1],nL)
	aeval(aaux,{|a,i| QOUT(a)},1,nAux)
	for i=nL to aPltCfg[1]
		?
	next
#endif

if FILE(aPltCfg[3])
	if aPltCfg[2] # 0
		?? CHR(27)+"A"+CHR(6)
		for n=1 to aPltCfg[2]
			FT_FSELECT( 1 )
			FT_FUSE( aPltCfg[3] )
			DO WHILE !FT_FEOF()
				? FT_FREADLN()
				FT_FSKIP(1)
			ENDDO
			FT_FSELECT( 1 )
			FT_FUSE()
		next
	endif
else
	? "NO SE ENCONTRO ARCHIVO "+aPltCfg[3]
endif
? CHR(27)+"@"

I_IMPRIMIO := .T.
LISTADOR("FIN")
RECUPAN()

RETURN .T.


**********************

STATIC FUNC CARGAPLT()

**********************
LOCAL aaux := STOA( PLT->PLANTILLA )
aComb := {}
aLubr := {}
aVari := {}
FOR i=1 TO LEN(aaux)
	cAux := FPRODUCTO( aaux[i,1] )
	IF "COMBU" $ FARRAY(vrubro,NRUBRO)
		aadd( aComb, { aaux[i,1], aaux[i,2], cAux, NGRUPO, NRUBRO })
	ELSEIF "LUBRI" $ FARRAY(vrubro,NRUBRO)
		aadd( aLubr, { aaux[i,1], aaux[i,2], cAux, NGRUPO, NRUBRO })
	ELSEIF "VARIO" $ FARRAY(vrubro,NRUBRO)
		aadd( aVari, { aaux[i,1], aaux[i,2], cAux, NGRUPO, NRUBRO })
	ENDIF
NEXT

RETURN NIL
