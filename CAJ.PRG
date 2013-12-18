parameters TURNOXITO, cualcli
private AX, ATOT, aCPO

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

X_CODCONC    =  1
X_CONCEPTO   =  2
X_DESCRIPC   =  3
X_CODEMP     =  4
X_INGRESO    =  5
X_EGRESO     =  6
X_CODCONCINT =  7
X_NUMERO     =  8
X_TURNO      =  9
X_REGISTRO   =  10

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
FBASES({"CAJA","EMPLEADO","CONC"},.F.)

aCpo:={;
  { "CODCONC",    "C¢d"                             ,'!!!', 'M', 'C',  3, 0 },;
  { "CONCEPTO",   "Concepto"                           ,'', 'E', 'C', 20, 0 },;
  { "DESCRIPC",   "Detalle"                            ,'', 'E', 'C', 30, 0 },;
  { "CODEMP",     "Emp"                             ,'!!!', 'M', 'C',  3, 0 },;
  { "INGRESO",    "Rendici¢n"                          ,'', 'M', 'N', 10, 3 },;
  { "EGRESO",     "Ventas"                             ,'', 'M', 'N', 10, 3 },;
  { "CODCONCINT", ""                                   ,'',  '',  '',  0, 0 },;
  { "NUMERO",     ""                                   ,'',  '',  '',  0, 0 },;
  { "TURNO",      "",                                  ,'',  '',  '',  0, 0 },;
  { "REGISTRO",   "",                                  ,'',  '', 'N',  6, 0 } }

select CA
aCpo := FARRAYAUX( aCpo )
DBGOBOTTOM()

RECUPAN()


****************************************************************************
declare aing[LEN(aturno)], aegr[LEN(aturno)], adif[LEN(aturno)]

M->FECHA := VA->FECHA
M->TURNO  := CA->TURNO
ym2 = 3
xm2 = 5
DO WHILE .T.
  LOGO(.T., " CAJA DIARIA ")
  ***
  * Ingreso de CAJA
  ***
  SELECT CA
  SETCOLOR("W/N,N/W")
  SET INTENSITY ON
  MENUDOWN({"  +   º  -   º    F7    º   F10   º  TAB  º  ENTER   º ESC  ",;
            "      º      º          º resumen º  ver  º          º      ",;
            " sig. º ant. º listados º del d¡a º cajas º confirma º sale "})
  @ ym2,xm2 CLEAR TO ym2,xm2+68
  SOMBRA( ym2+1, xm2+1, ym2+1, xm2+69 )
  
  NUEVO = .F.
  F10 = .F.
  DO WHILE .T.
     READEXIT(.T.)
     SET CONFIRM ON
     SETCURSOR(SC_ON)
     SET KEY 45 TO CLEAR_GETS
     SET KEY 43 TO CLEAR_GETS
     SET KEY -9 TO CLEAR_GETS
     SET KEY -1 TO CLEAR_GETS
     SET KEY 9 TO CLEAR_GETS
     SET KEY -6 TO CLEAR_GETS
     SET KEY -7 TO CLEAR_GETS
     SET KEY K_F8 TO CLEAR_GETS
     @ ym2,xm2+8 GET M->FECHA
     READ
     SET KEY 45 TO
     SET KEY 43 TO
     SET KEY -9 TO
     SET KEY -1 TO
     SET KEY -6 TO
     SET KEY 9 TO
     SET KEY -7 TO
     SET KEY K_F8 TO
     IF LASTKEY()==K_ESC .OR. LASTKEY()==K_ENTER .OR. LASTKEY()==K_F2
        EXIT
     ELSEIF LASTKEY() == K_F10
        F10 = .T.
        M->TURNO = " "
        EXIT
     ELSEIF LASTKEY() == K_F7         && listados
        op := MENUFLASH( 10, 30, 1, .T., "", "Resumen de caja p/turnos", "Resumen de caja p/d¡a", "Faltantes/Sobrantes", "Vales", "Resumen X conceptos","Detallado x conceptos" )
        IF op == 1
           LISTAR( "RESUCAJA" )
        ELSEIF op == 2
           LISTAR( "RESCAJDI" )
        ELSEIF op == 3
           LISTAR( "FALTANTE" )
        ELSEIF op == 4
           LISTAR( "VALES" )
        ELSEIF op == 5
           IF CONC(,.T.,.T.)
              LISTAR( "CAJXCONC" )
           ENDIF
        ELSEIF op == 6
           IF CONC(,.T.,.T.)
              LISTAR( "CAJXCOND" )
           ENDIF
        ENDIF
     ELSEIF LASTKEY() == 43         && +
        M->FECHA = M->FECHA + 1
     ELSEIF LASTKEY() == 45        && -
        M->FECHA = M->FECHA - 1
     ELSEIF LASTKEY() == K_TAB             && Tab
        SELECT CA
        SET ORDER TO CA_UFECHA_TURNO
        PRIVATE bcamp[2], bmasc[2], bcab[2], bedit
        bcamp[ 1] = "CA->FECHA"
        bcamp[ 2] = "CA->TURNO"
        bmasc[ 1] = ""
        bmasc[ 2] = "!"
        bcab[ 1] = "Fecha"
        bcab[ 2] = "Turno"
        bedit = "FF"
        mbuz:=MENUDOWN({"  <+>  º  F3   º   F4   º  ENTER  º  ESC   ",;
                        "       º       º        º elige y º        ",;
                        " mueve º busca º busca+ º  sale   º  sale  "})
        SET DELETED OFF
        xreg = RECNO()
        BROW( 8, 15, 18, 65, "CAJAS", bcamp, bmasc, bcab, bedit )
        SET DELETED ON
        IF LASTKEY() == K_ENTER
           M->FECHA := CA->FECHA
           M->TURNO := CA->TURNO
     		XTURNO   := ascan(aTurno,{|a|left(a,2)==M->TURNO+"-"})
           keyboard chr(K_ENTER)+chr(K_ENTER)
        ELSE
           GO xreg
        ENDIF
        SET ORDER TO CA_FECHA_TURNO
        RECUPAN()
        PONEPAN(mbuz)
     ENDIF
  ENDDO
  MODIFICABLE = .T.
  IF LASTKEY() == K_ESC
     EXIT
  ELSEIF LASTKEY() == K_ENTER
     mbuz:=MENUDOWN({"     º  ENTER   º ESC  ",;
                     "       º          º      ",;
                     " mueve º confirma º sale "})
     XTURNO := PP_SELEC( 4, 30, 0, 0, aturno, ascan(aTurno,{|a|left(a,2)==M->TURNO+"-"}), "", "S", .T.)
     M->TURNO := IF( LASTKEY()==K_ENTER, LEFT(aturno[XTURNO],1), M->TURNO )
     RECUPAN()
     IF LASTKEY() = K_ESC
        LOOP
     ENDIF
     PONEPAN(mbuz)
  ENDIF
  @ ym2,xm2+40 SAY IF( F10, "TOTAL DEL DIA", FARRAY(aturno,M->TURNO+'-') )
  
  **************************************************************************
  
  ************************
  * Carga la Caja/s
  ************************
  MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
  AX := {}
  AFILL( aing, 0 )
  AFILL( aegr, 0 )
  AFILL( adif, 0 )
  IF F10
     XTURNO = 1
     XTURNO = LEN(aturno)
     NUEVO = .F.
     MODIFICABLE = .F.
     SELECT CA
     SET SOFTSEEK ON
     SEEK FTOC(M->FECHA)
     DO WHILE CA->FECHA == M->FECHA
        i := ASCAN(AX, {|a| a[X_CODCONC]==CA->CODCONC} )
        IF i==0
           AADD( AX, AREG0( aCpo ) )
           i := LEN(AX)
        ENDIF
        AX[i,X_TURNO]      := CA->TURNO
        AX[i,X_CODCONC]    := CA->CODCONC
        AX[i,X_CONCEPTO]   := CA->CONCEPTO
        AX[i,X_NUMERO]     := SPACE(LEN(CA->NUMERO))
        AX[i,X_DESCRIPC]   := CA->DESCRIPC
        AX[i,X_CODEMP]     := SPACE(LEN(CA->CODEMP))
        AX[i,X_INGRESO]    += CA->INGRESO
        AX[i,X_EGRESO]     += CA->EGRESO
        AX[i,X_CODCONCINT] := CA->CODCONCINT
        AX[i,X_REGISTRO]   := 0
        SKIP
     ENDDO
     SET SOFTSEEK OFF
  ELSE
     SELECT CA
     SET ORDER TO 1
     SEEK FTOC(M->FECHA)+M->TURNO
     IF FOUND()
        NUEVO = .F.
        DO WHILE CA->FECHA==M->FECHA .AND. CA->TURNO==M->TURNO
           AADD( aX, ARRAY( X_REGISTRO ) )
           i := LEN(AX)
           AX[i,X_TURNO]      := CA->TURNO
           AX[i,X_CODCONC]    := CA->CODCONC
           AX[i,X_CONCEPTO]   := CA->CONCEPTO
           AX[i,X_NUMERO]     := CA->NUMERO
           AX[i,X_DESCRIPC]   := CA->DESCRIPC
           AX[i,X_CODEMP]     := CA->CODEMP
           AX[i,X_INGRESO]    := CA->INGRESO
           AX[i,X_EGRESO]     := CA->EGRESO
           AX[i,X_CODCONCINT] := CA->CODCONCINT
           AX[i,X_REGISTRO]   := RECNO()
           SKIP
        ENDDO
     ELSE
        NUEVO = .T.
     ENDIF
  ENDIF
  ASORT( AX,,,{|x,y| x[X_CODCONC] < y[X_CODCONC] } )
  SELECT CA
  SET SOFTSEEK ON
  SEEK FTOC(M->FECHA)+" "
  DO WHILE CA->FECHA == M->FECHA
     i = AT(CA->TURNO,STURNOS)
     IF i # 0
        aing[i] += CA->INGRESO
        aegr[i] += CA->EGRESO
        adif[i] := aing[i] - aegr[i]
     ENDIF
     SKIP 1
  ENDDO
  SET SOFTSEEK OFF
  IF MODIFICABLE .OR. LEN(AX) == 0
     AADD( AX, AREG0( aCpo ) )
     AX[LEN(AX),X_TURNO] := M->TURNO
  ENDIF
  RECUPAN()
  
  
  SETCOLOR( "W/N,N/W" )
  OX := MYABROWSE( 5, 1, 12, 78, aCpo, AX, "AX" )
  OX:CARGO[TB_REFRESH] := 0
  OX:GOTOP()
  aedits := TBCOLEDIT( "SETEAR", "CAJA", OX, aedits )
  TBCOLOR(OX)
  
  
  aTot := NEWEDIT( "TOTCAJA",,.F. )
  aux := "["+ STR( ASCAN(aturno,{|a| LEFT(a,1)==M->TURNO}), 1 ) +"]"
  aauxt := {}
  i := ASCAN( aTOT[ED_VFIELDS], {|a| aux $ a })
  DO WHILE i > 0
     AADD( aauxt, i )
     i := ASCAN( aTOT[ED_VFIELDS], {|a| aux $ a }, i+1)
  ENDDO
  
  FVERREG( aTot,, .T. )
  FTOT2()
  
  
  IF F10
     MENUDOWN({"  <+>  º   F7    º ESC  ",;
               "       º         º      ",;
               " mueve º imprime º sale "})
  ELSE
     MENUDOWN({" <+> º   F2   º   F6  º   F7  º F9  º  - F8  -    suma:º   TAB   ºESC ",;
               "     º        ºeliminaº       ºdeta-ºPlanillas, Remitosºconceptosº    ",;
               "mueveºmodificaº l¡nea ºimprimeºlles ºCheques, Tarjetas.ºempleadosºsale"})
  ENDIF
  
  guardar = .F.
  DO WHILE .T.
     MOVABROW( OX, AX, {||nK==9.OR.nK==37.OR.nK==27.OR.nK==K_F9.OR.nK==K_F8.OR.nK==-5.OR.nK==K_ALT_E.OR.nK==K_F10.OR.nK==K_F7},;
        {||nK==999} )
     
     IF OX:Cargo[TB_RET] == K_TAB .AND. MODIFICABLE
        IF TBNOC(OX) == "CODCONC" //.AND. AX[NROW,X_CODCONCINT] == 0
           IF CONC( AX[NROW,X_CODCONC], .T. )
              AX[NROW,X_CODCONC] := CON->CODCONC
           ENDIF
           AX[NROW,X_CONCEPTO] := CONC( AX[NROW,X_CODCONC] )
           
        ELSEIF TBNOC(OX) == "CODEMP"
        	if EMP(AX[NROW,X_CODEMP],.T.)
              AX[NROW,X_CODEMP] := EM->CODEMP
           ENDIF
           
        ELSEIF TBNOC(OX) == "TURNO"      && .AND. AX[NROW,X_CODCONCINT]==0
           ele = PP_SELEC( 10, 30, 0, 0, aturno, AX[NROW,X_TURNO], "", "S", .T.)
           IF LASTKEY() == K_ENTER
              AX[NROW,X_TURNO] := LEFT(aturno[ele],1)
           ENDIF
           RECUPAN()
        ENDIF
        OX:RefreshCurrent()
        
        
     ELSEIF OX:Cargo[TB_MSGE] == "MODIF" .AND. MODIFICABLE
        IF TBNOC(OX) == "CODCONC" //.AND. AX[NROW,X_CODCONCINT] == 0
           AX[NROW,X_CODCONC] := OX:CARGO[TB_CONT]
           AX[NROW,X_CONCEPTO] := CONC( AX[NROW,X_CODCONC] )
           
        ELSEIF TBNOC(OX) == "INGRESO"    && .AND. AX[NROW,X_CODCONCINT]==0
*          aing[XTURNO] := ( aing[XTURNO]-AX[NROW,X_INGRESO]) + OX:CARGO[TB_CONT]
*          adif[XTURNO] := aing[XTURNO] - aegr[XTURNO]
           AX[NROW,X_INGRESO] := OX:CARGO[TB_CONT]
           OX:RefreshAll()
*          FVERREG( aTot,, .T. )
           FTOT2()
           
        ELSEIF TBNOC(OX) == "EGRESO"     &&.AND. AX[NROW,X_CODCONCINT]==0
*          aegr[XTURNO] := (aegr[XTURNO]-AX[NROW,X_EGRESO]) + OX:CARGO[TB_CONT]
*          adif[XTURNO] := aing[XTURNO] - aegr[XTURNO]
           AX[NROW,X_EGRESO] := OX:CARGO[TB_CONT]
           OX:RefreshAll()
*          FVERREG( aTot,, .T. )
           FTOT2()
           
        ELSEIF TBNOC(OX) == "NUMERO"
           AX[NROW,X_NUMERO] := JUSTIF(OX:CARGO[TB_CONT],,">")
           
        ELSEIF TBNOC(OX) == "CODEMP"
        	IF !EMPTY(OX:CARGO[TB_CONT])
        		IF EMPTY(EMP(OX:CARGO[TB_CONT]))
						MENSAJE( 0, 0, 10, .T., " CODIGO EMPLEADO NO ENCONTRADO !!! " )
              ELSE
           		AX[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
              ENDIF
           ELSE
           	AX[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
           ENDIF

        ELSEIF OX:CARGO[TB_MSGE] == "MODIF"    && .AND. AX[NROW,X_CODCONCINT]==0
           AX[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
           
        ENDIF
        OX:RefreshCurrent()
        
     ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
        IF AX[NROW,X_INGRESO]+AX[NROW,X_EGRESO] # 0 .AND. NROW==LEN(AX)
           AADD( AX, AREG0(aCpo) )
           ++NROW
           AX[NROW,X_TURNO] := M->TURNO
           OX:RefreshAll()
        ENDIF
        
     ELSEIF OX:Cargo[TB_RET] == K_F6     &&.AND. MODIFICABLE .AND. AX[NROW,X_CODCONCINT] == 0
        IF PREGUNTA( 12, "¨ Est s Seguro  [ S / N ] ?", "SsNn") $ "Ss"
           aing[XTURNO] -= AX[NROW,X_INGRESO]
           aing[XTURNO] -= AX[NROW,X_EGRESO]
           adif[XTURNO] := aing[XTURNO] - aegr[XTURNO]
           xreg     := AX[NROW,X_REGISTRO]
           AX[NROW] := AREG0(aCpo,{X_REGISTRO})
           AX[NROW,X_TURNO]    := M->TURNO
           AX[NROW,X_REGISTRO] := xreg
           OX:RefreshAll()
           FVERREG( aTot,, .T. )
           FTOT2()
        ENDIF
        
     ELSEIF OX:Cargo[TB_RET]==K_F9 .AND. MODIFICABLE .and. procname(1)=="EST"
        IF F10
           DET( M->FECHA, sTURNOS )
        ELSE
           DET( M->FECHA, M->TURNO )
        ENDIF
        
     ELSEIF OX:Cargo[TB_RET]==K_F9 .AND. MODIFICABLE .and. procname(1)=="MIN"
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
        ARTXTUR(M->FECHA,M->FECHA,M->TURNO,M->TURNO)
        cBaseAux:=xname('XAUX')
        cBaseAux2:=xname('XX')
        select 99
        index on X->RUBRO to (cBaseAux)
        total on X->RUBRO to (cBaseAux2) fields IMPORTE
        select 99
        use (cBaseAux2) alias X
        go top
        nAux:=0
			SETIMPRESORA("INI","")
			? "Feacha:", M->FECHA, "     Turno:",M->TURNO
  			* * *  suma las planillas
			ENCABEZADO( "VENTA SERVICOMPRAS", 80 )
			?             "ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
			?             "ºC¢digo³Rubro                      ³   Importeº"
			?             "ÇÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
        do while !eof()
  			if X->IMPORTE # 0
     			? USING("ºüüüüüü³ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³üüüüüü.üüüº",{X->RUBRO,FRUBRO(X->RUBRO),X->IMPORTE})
     			nAux += X->IMPORTE
  			endif
           skip
			enddo
			?             "ÇÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
			?       USING("º Total                            ³üüüüüü.üüüº",{nAux} )
			?             "ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ½"

			SETIMPRESORA("FIN","")
			RECUPAN()
			RECUPAN()
			IF EST->SALIDA $ "PAN TXT"      //.AND. FILE("..\VERTXT.COM")
  			mbuz:=MENUDOWN({"  <+>  º  ESC   ",;
                  			"       º        ",;
                  			" mueve º  sale  "})
  			MARCO( 1, 1, 20, 78, "", "D", .T., 0 )
  			MEMOEDIT( MEMOREAD(XNAME("XLIS")+".TXT"), 1, 1, 20, 78, .F., "FOUND()", 99 )
  			RECUPAN()
  			PONEPAN(mbuz)
			ENDIF
			CLEARTYPEAHEAD()
        

     ELSEIF OX:Cargo[TB_RET]==K_F8 .AND. MODIFICABLE .and. procname(1)=="MIN"
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
			nAux := 0
			FBASES({"+TICKETS","+TICKETS2"})
			select TI
			SET ORDER TO FORDER({"FECHA","TURNO"})
			for i=1 to 3
				dbseek( ftoc(M->FECHA)+M->TURNO )
        next
			do while TI->FECHA==M->FECHA .and. TI->TURNO==M->TURNO .and. !TI->(eof())
				nAux += TI->TOTAL
				skip 1 alias TI
			enddo
			if nAux # 0
				i := ASCAN(AX,{|a| a[X_CODCONC]=="TT "} )
				IF i == 0
					i := ASCAN( AX, {|a| EMPTY(a[X_CONCEPTO])} )
					IF i == 0
						AADD( AX, AREG0( aCpo ) )
						i := LEN(AX)
						AX[i,X_TURNO] := M->TURNO
					ENDIF
				ENDIF
				AX[i,X_CODCONC]  := "TT "
           AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
				AX[i,X_EGRESO]   := nAux
			endif

			aBase:={{"FACA","FA"},{"FACB","FB"}}
			nAux1:=2
	   	nAux2:=4
        nAux:=0
	   	for z=nAux1 to nAux2
        	cSUCURSAL := str(z,1)
           for b=1 to len(aBase)
					FBASES({"-"+aBase[b,1],"-"+aBase[b,1]+"2"})
					FBASES({"+"+aBase[b,1],"+"+aBase[b,1]+"2"})
           	XF:=aBase[b,2];  XF2:=XF+"2"
					select (XF)
					set order to forder({"FECHA","TURNO"})
					for i=1 to 3
						dbseek( ftoc(M->FECHA)+M->TURNO )
        		next
					select (XF2)
					do while (XF)->FECHA==M->FECHA .and. (XF)->TURNO==M->TURNO .and. !(XF)->(eof())
						dbseek((XF)->NUMFAC)
						do while (XF2)->NUMFAC == (XF)->NUMFAC
							if (XF2)->NEGOCIO == '*'
								nAux += (XF2)->IMPORTE
							endif
							skip
						enddo
						skip 1 alias (XF)
					enddo
        	next b
        next z
			if nAux # 0
				i := ASCAN(AX,{|a| a[X_CODCONC]=="FAM"} )
				IF i == 0
					i := ASCAN( AX, {|a| EMPTY(a[X_CONCEPTO])} )
					IF i == 0
						AADD( AX, AREG0( aCpo ) )
						i := LEN(AX)
						AX[i,X_TURNO] := M->TURNO
					ENDIF
				ENDIF
				AX[i,X_CODCONC]  := "FAM"
           AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
				AX[i,X_EGRESO]   := nAux
			endif
				
				* * *  Recalcula los totales  * * *
			aing[XTURNO] := aegr[XTURNO] := 0
			FOR x=1 TO LEN(AX)
				i := ASCAN( AX,{|a| a[X_TURNO]==M->TURNO }, x )
				IF i # 0
					aing[XTURNO] += AX[i,X_INGRESO]
					aegr[XTURNO] += AX[i,X_EGRESO]
					adif[XTURNO] := aing[XTURNO] - aegr[XTURNO]
				ENDIF
			NEXT
			RECUPAN()
			FVERREG( aTot,, .T. )
			FTOT2()
			OX:RefreshAll()
			CLEARTYPEAHEAD()
			
     ELSEIF OX:Cargo[TB_RET] == K_F8 .AND. MODIFICABLE .and. procname(1)=="EST"
			CA_REMITOS  := 'S'
			CA_PLANILLAS:= 'S'
			CA_CHEQUES  := 'S'
			CA_TARJETAS := 'S'
			CA_POSNET   := 'S'
			CA_COPRES   := 'S'
			CA_GASTOS   := 'S'
			CA_TGASTOS  := ''
			CA_CCV      := 'S'
			CA_COCHERA  := 'S'
			CA_DESCFAC  := 'S'
        CA_LUBRICEN := 'S'
        CA_LAVADERO := 'S'
        CA_EFECTIVO := 'S'
        CA_PAGOEF   := 'S'
        CA_CPAGOEF  := '   '
			if CAJEAR("SETEAR")
           MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
           FBASES({ "+REM", "+FACA","+FACB","+PLAN", "+CHEQUES", "+TARJETAS", "+CCV2", "+COPRES", "+GASTOS","+POSNET" }, .F.)
              * * *  suma los descuentos
           if CA_DESCFAC == 'S'
              aux := 0
           	aEmp := {}
              select PL
              set order to 1
              SEEK FTOC(M->FECHA) + M->TURNO
              do while PL->FECHA==M->FECHA .and. PL->TURNO==M->TURNO
              	for i=1 to 6
                 	if !empty(PL->&("CODEMP"+str(i,1)));  aadd( aEmp, PL->&("CODEMP"+str(i,1)) );  endif
                 next
                 skip
              enddo
              if len(aEmp) > 0
              	XF := "FA"
						for z=1 to 2
              		select (XF)
              		set order to FORDER({"FECHA"})
              		M->FECHA2 := M->FECHA+1
              		dbseek( FTOC(M->FECHA), .T. )
              		do while ROSCA().and.(XF)->FECHA>=M->FECHA .AND. (XF)->FECHA<=(M->FECHA2) .AND. !(XF)->(eof())
              			if (XF)->FECHA==M->FECHA2
                       	lAux := ( (XF)->TURNO=="4" )
                 		else
                    		lAux := .T.
                 		endif
                 		if lAux .and. ascan(aEmp,(XF)->CODEMP)#0
                 			aux += (XF)->TDESCUENTO
                 		endif
                 		skip
              		enddo
              		XF := "FB"
              	next z
              endif
              if aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="DES"} )
                 if i == 0
                    i := ASCAN( AX, {|a| EMPTY(a[X_CONCEPTO])} )
                    if i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    endif
                 endif
                 AX[i,X_CODCONC]  := "DES"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO]  := aux
              endif
           endif

              * * *  suma los remitos
           IF CA_REMITOS == 'S'
              aux := 0
              SELECT RE
              SET ORDER TO FORDER({"FECHA","TURNO"})
#ifdef SUR
              xaux := DTOS(M->FECHA) + M->TURNO +" "
              M->FECHA2 := M->FECHA
              IF M->TURNO == "3"
              	M->FECHA2 += 1
                 xaux += DTOS(M->FECHA2) + "4 "
              ENDIF
              DBSEEK( FTOC(M->FECHA) + M->TURNO, .T. )
              DO WHILE RE->FECHA>=M->FECHA .AND. RE->FECHA<=(M->FECHA2) .AND. !RE->(EOF())
             		IF DTOS(RE->FECHA)+RE->TURNO+" " $ xaux
                 	aux += FIELD->TOTAL + FIELD->TDESCUENTO
                 ENDIF
                 SKIP
              ENDDO
#else
#ifdef POWEROIL
              dbseek( ftoc(M->FECHA), .T. )
              do while FIELD->FECHA==M->FECHA
              	if left(RE->OBSERV,1)==M->TURNO
              		aux += FIELD->TOTAL + FIELD->TDESCUENTO
                 endif
                 skip
              enddo
#else
              SEEK FTOC(M->FECHA) + M->TURNO
              DO WHILE FIELD->FECHA == M->FECHA .AND. FIELD->TURNO == M->TURNO
              	aux += FIELD->TOTAL + FIELD->TDESCUENTO
                 SKIP
              ENDDO
#endif
#endif
              IF aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="REM"} )
                 IF i == 0
                    i := ASCAN( AX, {|a| EMPTY(a[X_CONCEPTO])} )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "REM"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO]  := aux
              ENDIF
           ENDIF
           
              * * *  suma las planillas
           IF CA_PLANILLAS == 'S'
              aux1 := aux2 := 0
              SELECT PL
              SET ORDER TO 1
              SEEK FTOC(M->FECHA) + M->TURNO
              DO WHILE PL->FECHA == M->FECHA .AND. PL->TURNO == M->TURNO
                 aux1 += PL->TOTAL
                 aux2 += PL->DESCUENTO
                 SKIP
              ENDDO
              IF aux1 # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="PLA"} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "PLA"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_EGRESO  ] := aux1
              ENDIF
              IF aux2 # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="DES"} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "DES"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_EGRESO  ] := -aux2
              ENDIF
           ENDIF
           
              * * *  suma los cheques
           IF CA_CHEQUES == 'S'
              aux = 0
              SELECT CH
              SET ORDER TO CH_FECHPAGO_TURNO
              SEEK FTOC(M->FECHA) + M->TURNO
              DO WHILE CH->FECHPAGO == M->FECHA .AND. CH->TURNO == M->TURNO
*                if empty(CH->FECHCIERRE)
                 if empty(substr(CH->ID_CCV,4))
                    aux += CH->MONTO
                 endif
                 skip
              ENDDO
              IF aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="CH "} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "CH "
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO ] := aux
              ENDIF
           ENDIF
           
              * * *  suma las tarjetas
           IF CA_TARJETAS == 'S'
              aux = 0
              SELECT TA
              SET ORDER TO TA_FECHPAGO_TURNO
              SEEK FTOC(M->FECHA) + M->TURNO
              do while TA->FECHPAGO == M->FECHA .and. TA->TURNO == M->TURNO
*                if empty(TA->FECHCIERRE)
                 if empty(substr(TA->ID_CCV,4))
                    aux += TA->MONTO
                 endif
                 skip
              enddo
              IF aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="TAR"} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC] := "TAR"
                 AX[i,X_CONCEPTO  ] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO   ] := aux
              ENDIF
           ENDIF
           
              * * *  suma los posnet
           IF CA_POSNET == 'S'
              aux = 0
              SELECT PN
              SET ORDER TO TA_FECHPAGO_TURNO
              SEEK FTOC(M->FECHA) + M->TURNO
              DO WHILE PN->FECHPAGO == M->FECHA .AND. PN->TURNO == M->TURNO
                 IF EMPTY(PN->FECHCIERRE)
                    aux += PN->MONTO
                 ENDIF
                 SKIP
              ENDDO
              IF aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="POS"} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "POS"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO]  := aux
              ENDIF
           ENDIF
           
              * * *  suma los copres
           IF CA_COPRES == 'S'
              aux = 0
              SELECT COP
              SET ORDER TO COP_FECHA_TURNO
              SEEK FTOC(M->FECHA) + M->TURNO
              DO WHILE COP->FECHA == M->FECHA .AND. COP->TURNO == M->TURNO
                 aux += COP->MONTO
                 SKIP
              ENDDO
              IF aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="COP"} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "COP"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO ] := aux
              ENDIF
           ENDIF
           
              * * *  suma los gastos
           IF CA_GASTOS == 'S'
              aux = 0
              SELECT GA
              SET ORDER TO FORDER( {"GA->FECHA","GA->TURNO" } )
              SEEK FTOC(M->FECHA) + M->TURNO
              DO WHILE GA->FECHA == M->FECHA .AND. GA->TURNO == M->TURNO
*                IF GA->CODGAS $ UT_GASTOS
                    aux += GA->IMPORTE
*                ENDIF
                 SKIP
              ENDDO
              IF aux # 0
                 i := ASCAN(AX,{|a| a[X_CODCONC]=="GAS"} )
                 IF i == 0
                    i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                       AADD( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC]  := "GAS"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO ] := aux
              ENDIF
           ENDIF
           
           if CA_CCV == 'S'
           	FBASES({ "+CCV2" }, .F. )
              aux:={0,0,0}
              cAux := ""
              select CCV2
              set order to CCV2_FECHPAGO
              dbseek( ftoc(M->FECHA) )
              do while CCV2->FECHPAGO == M->FECHA
                 if CCV2->TURNO == M->TURNO
*                   aux += ( CCV2->EFECTIVO + CCV2->CHEQUE + CCV2->TARJETA )
                    aux[1] += CCV2->EFECTIVO
							aux[2] += CCV2->CHEQUE
							aux[3] += CCV2->TARJETA
                    if ( CCV2->EFECTIVO + CCV2->CHEQUE + CCV2->TARJETA ) # 0
                       cAux += ","+alltrim(FCLIENTE(CCV2->CODCLI))
                    endif
                 endif
                 skip
              enddo
              if aux[1]+aux[2]+aux[3] # 0
              	i := ASCAN(AX,{|a| a[X_CODCONC]=="CCC"} )
                 if i == 0
                 	i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                    	aadd( AX, AREG0( aCpo ) )
                       i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    endif
                 endif
                 AX[i,X_CODCONC ] := "CCC"
                 AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
           		AX[i,X_DESCRIPC] := padr(substr(cAux,2),len(CA->DESCRIPC)," ")
                 AX[i,X_EGRESO  ] := aux[1]+aux[2]+aux[3]
                 aux2:={"EFC","CHC","TAC"}
                 for n=1 to len(aux)
                 	if aux[n] # 0
              			i := ASCAN(AX,{|a| a[X_CODCONC]==aux2[n]} )
                 		if i == 0
                 			i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    		IF i == 0
                    			aadd( AX, AREG0( aCpo ) )
                       		i := LEN(AX)
                       		AX[i,X_TURNO] := M->TURNO
                    		endif
                 		endif
                 		AX[i,X_CODCONC ] := aux2[n]
                 		AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
                 		AX[i,X_INGRESO ] := aux[n]
                    endif
              	next n
              endif
              FBASES({ "-CCV2" }, .F. )
           endif

           if CA_PAGOEF == 'S'
              do while .T.
*             	i := ascan(AX,{|a| a[X_CODCONC]==CA_CPAGOEF.and.a[X_CODCONCINT]#0} )
              	i := ascan(AX,{|a| a[X_CODCONC]==CA_CPAGOEF} )
              	if i == 0
                 	exit
                 endif
             		nAux := AX[i,X_REGISTRO]
              	AX[i] := AREG0( aCpo )
             		AX[i,X_CODCONCINT] := 1		//no cero
             		AX[i,X_REGISTRO] := nAux
              enddo
           	FBASES({ "+OPAGO","+PROVEEV" }, .F. )
              aaux := {}
              select OPG
              set order to OPG_FECHA_TURNO
              dbseek( ftoc(M->FECHA)+M->TURNO )
              do while OPG->FECHA==M->FECHA .and. OPG->TURNO==M->TURNO .and. !OPG->(eof())
                 if OPG->EFECTIVO # 0
                 	i := ascan(aaux,{|a|a[1]==OPG->CODPROV})
                    if i==0
                    	aadd(aaux,{0,0,""})
                       i:=len(aaux)
                    endif
                		aaux[i,1] := OPG->CODPROV
                    aaux[i,2] += OPG->EFECTIVO
                    aaux[i,3] += OPG->NUMOPAG+","
                 endif
                 skip
              enddo
              for n=1 to len(aaux)
              	if aaux[n,2] # 0
                 	i := ascan(AX,{|a| empty(a[X_CONCEPTO]) } )
                    if i == 0
                    	aadd( AX, AREG0( aCpo ) )
                       i := len(AX)
                       AX[i,X_TURNO] := M->TURNO
                    endif
                 	AX[i,X_CODCONC ] := CA_CPAGOEF
                 	AX[i,X_CONCEPTO] := CONC(AX[i,X_CODCONC])
           			AX[i,X_DESCRIPC] := padr("OP:"+aaux[n,3]+alltrim(FPROV(aaux[n,1])),len(CA->DESCRIPC)," ")
                 	AX[i,X_INGRESO ] := aaux[n,2]
             			AX[i,X_CODCONCINT] := 1		//no cero
                 endif
              next
              FBASES({ "-OPG" }, .F. )
           endif
           
              * * *  suma lubricentro
           IF CA_LUBRICEN == 'S'
              FBASES({ "+LUB" }, .F. )
              aux = 0
              SELECT LU
              SET ORDER TO FORDER({"FECHA","TURNO"})
              SEEK FTOC(M->FECHA)+M->TURNO
              DO WHILE LU->FECHA==M->FECHA .AND. LU->TURNO==M->TURNO
              	aux += ( LU->TMODULO+LU->TOTAL )
                 SKIP
              ENDDO
              IF aux # 0
              	i := ASCAN(AX,{|a| a[X_CODCONC]=="LUB"} )
                 IF i == 0
                 	i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                    	AADD( AX, AREG0( aCpo ) )
                    	i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC] := "LUB"
                 AX[i,X_CONCEPTO  ] := CONC(AX[i,X_CODCONC])
                 AX[i,X_EGRESO    ] := aux
              ENDIF
              FBASES({ "-LUB" }, .F. )
           ENDIF
           
              * * *  suma lavadero
           IF CA_LAVADERO == 'S'
              FBASES({ "+LAV" }, .F. )
              aux = 0
              SELECT LV
              SET ORDER TO FORDER({"FECHA","TURNO"})
              SEEK FTOC(M->FECHA)+M->TURNO
              DO WHILE LV->FECHA==M->FECHA .AND. LV->TURNO==M->TURNO
              	aux += LV->TOTAL
                 SKIP
              ENDDO
              IF aux # 0
              	i := ASCAN(AX,{|a| a[X_CODCONC]=="LAV"} )
                 IF i == 0
                 	i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                    	AADD( AX, AREG0( aCpo ) )
                    	i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC] := "LAV"
                 AX[i,X_CONCEPTO  ] := CONC(AX[i,X_CODCONC])
                 AX[i,X_EGRESO    ] := aux
              ENDIF
              FBASES({ "-LAV" }, .F. )
           ENDIF
           
              * * *  suma efectivo
           IF CA_EFECTIVO == 'S'
              aux = 0
           	for b=1 to 3
						cAux:= "CAJCH"+str(b,1)
						if file(cAux+".DBF")
        				F_ABASE({"CAC"},"CERRAR")
							FBASES({"+"+cAux },.F. )
              		select CAC
              		SET ORDER TO FORDER({"FECHA"})
              		DBSEEK(FTOC(M->FECHA))
              		do while CAC->FECHA==M->FECHA .AND. !EOF()
                 		if "T"+M->TURNO $ CAC->CODCONC
              				aux += CAC->ENTRADA
                    	endif
                 		skip
                 	enddo
              	endif
              next b
              IF aux # 0
              	i := ASCAN(AX,{|a| a[X_CODCONC]=="EF "} )
                 IF i == 0
                 	i := ASCAN(AX,{|a| EMPTY(a[X_CONCEPTO]) } )
                    IF i == 0
                    	AADD( AX, AREG0( aCpo ) )
                    	i := LEN(AX)
                       AX[i,X_TURNO] := M->TURNO
                    ENDIF
                 ENDIF
                 AX[i,X_CODCONC] := "EF "
                 AX[i,X_CONCEPTO  ] := CONC(AX[i,X_CODCONC])
                 AX[i,X_INGRESO   ] := aux
              ENDIF
           ENDIF
           RECUPAN()
           
           FTOT2()
           OX:RefreshAll()
           CLEARTYPEAHEAD()
        ENDIF
        select CA
        
     ELSEIF OX:Cargo[TB_RET] == K_ALT_E
        TBCOLEDIT( "CAMBIAR", "CAJA", OX, aedits, "EDITS.EST" )

     ELSEIF OX:Cargo[TB_RET] == K_F10
        IF MODIFICABLE
           guardar := .T.
        ENDIF
        EXIT

     ELSEIF OX:Cargo[TB_RET] == K_F7	// .AND. F10
        LISTAR( "CAJADIA" )

     ELSEIF OX:Cargo[TB_RET] == K_ESC
        IF MODIFICABLE
           aux := UPPER( PREGUNTA( 12, "[ G ] graba.       [ S ] sale.       [ C ] contin£a.", "GgSsCc") )
           IF aux $ "GS"
              guardar := ( aux == "G" )
              EXIT
           ENDIF
        ELSE
           EXIT
        ENDIF
     ENDIF

  ENDDO
  
  IF guardar
  	if M->FECHA <= VA->FECHSEG
  		MENSAJE( 0, 0, 10, .T., "LA FECHA ES MENOR O IGUAL","A LA DE CIERRE DEL SISTEMA !" )
     else
  		MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
     	select CA
#ifdef NADA
     	fflock()
        do while dbseek(ftoc(M->FECHA)+M->TURNO)
        	if CA->FECHA==M->FECHA .and. CA->TURNO==M->TURNO
        		blankreg()
           else
           	exit
           endif
        enddo
#endif
     	for i=1 to len(AX)
        	if AX[i,X_INGRESO]+AX[i,X_EGRESO] == 0
           	if AX[i,X_REGISTRO] # 0
              	go AX[i,X_REGISTRO]
              	blankreg()
           	endif
        	else
           	if AX[i,X_REGISTRO] # 0
              	GO AX[i,X_REGISTRO]
           	else
              	F_ALTA({||!empty(FIELD->FECHA)})
           	endif
           	frlock()
           	CA->FECHA      := M->FECHA
           	CA->TURNO      := M->TURNO
           	CA->CODCONC    := AX[i,X_CODCONC]
           	CA->CONCEPTO   := AX[i,X_CONCEPTO]
           	CA->NUMERO     := AX[i,X_NUMERO]
           	CA->DESCRIPC   := AX[i,X_DESCRIPC]
           	CA->CODEMP     := AX[i,X_CODEMP]
           	CA->INGRESO    := AX[i,X_INGRESO]
           	CA->CODCONCINT := AX[i,X_CODCONCINT]
           	CA->EGRESO     := AX[i,X_EGRESO]
        	endif
        	skip 0
     	next
  		RECUPAN()
     endif
  ENDIF
  DBUNLOCKALL()
  DBCOMMITALL()
  
ENDDO

RETURN


***********

FUNC CAJEAR(que)

***********
LOCAL _fecha, _turno, xmenu, aaux, r
que := IF( que==NIL, "", que )


IF FILE("CAJA.MEM")
	RESTORE FROM CAJA.MEM ADDITIVE
ENDIF
xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
                 "       º graba y º        ",;
                 " mueve º procede º  sale  "})
aaux := NEWEDIT2( "INPCAJA",,.T. )
aaux[ED_I] := 1
aaux[ED_REGISTRO] := RECNO()
aaux[ED_MODE] = "MOSTRARTODO"
do while .T.
	FEDITAR2( aaux, { K_F10 } )
	if aaux[ED_UPDATE]
		aaux[ED_MODE] = "MOSTRAR"
	elseif aaux[ED_TECLA] == K_TAB .AND. EDNOM(aaux)== "CA_GASTOS"
		AEVAL( vgasto, {|a,i|vgasto[i]:=LEFT(a,LEN(a)-1)+IF(LEFT(a,4)$CA_TGASTOS,""," ")},1,LV(vgasto) )
		if MARCABRW( aaux[ED_Y],aaux[ED_X], vgasto, LV(vgasto) ) # 0
			CA_TGASTOS := ""
			AEVAL( vgasto, {|a,i| CA_TGASTOS+=IF(RIGHT(a,1)=="",LEFT(a,4),"")}, 1, LV(vgasto) )
		endif
	elseif aaux[ED_TECLA] == K_TAB .AND. EDNOM(aaux)== "CA_PAGOEF"
     if CONC( CA_CPAGOEF, .T. )
			CA_CPAGOEF := CON->CODCONC
		endif
	elseif ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_F10
		SAVE ALL LIKE CA_* TO CAJA.MEM
		exit
	elseif aaux[ED_TECLA] == K_ESC
		exit
	endif
enddo
FEDITOR(aaux,"SACAPAN")
MENUDOWN(xmenu)
r := ( aaux[ED_TECLA] # K_ESC )
IF que == "SETEAR"
	RETURN r
ENDIF

return NIL


********

FUNC DET

********
PARAMETERS _fecha, _turno
LOCAL mbuz

MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
FBASES({ "+REM", "+PLAN2", "+CHEQUES", "+TARJETAS", "+CCV2", "+COPRES", "+GASTOS","+POSNET" }, .F.)

SETIMPRESORA("INI","")
? _fecha, "     ", FARRAY(aturno,_turno)
           
  * * *  suma las planillas
ENCABEZADO( "RESUMEN PLANILLAS", 80 )
aaux := {}
SELECT PL2
DBSETORDER( FORDER({"FECHA","TURNO"}) )
DBSEEK( FTOC(_fecha) + LEFT(_turno,1), .T. )
DO WHILE PL2->FECHA == _fecha .AND. PL2->TURNO $ _turno
  FPRODUCTO(FIELD->CODPROD)
  i := ASCAN( aaux, {|a| a[1]==NGRUPO } )
  IF i == 0
     AADD( aaux, { NGRUPO, FGRUPO(NGRUPO), 0, 0, NRUBRO } )
     i := LEN(aaux)
  ENDIF
  aaux[i,3] += FIELD->CANTIDAD
  aaux[i,4] += FIELD->IMPORTE
  SKIP
ENDDO
ASORT( aaux,,,{|x,y| x[1] < y[1]} )
x1 := xtot1 := 0
x2 := xtot2 := 0
?            "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
?            "ºDescripci¢n         ³Cantidad  ³Importe   º"
?            "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
FOR i=1 TO LEN(aaux)
  IF aaux[i,5] ==  1
     ? USING("ºƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³üüüüüü.üüü³üüüüüü.üüüº",{aaux[i,2],aaux[i,3],aaux[i,4]})
     x1 += aaux[i,3];  xtot1 += aaux[i,4]
  ENDIF
NEXT
?            "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
?      USING("ºTotal Combustibles  ³üüüüüü.üüü³üüüüüü.üüüº",{x1,xtot1} )
?            "ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ½"
?            "ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ·"
FOR i=1 TO LEN(aaux)
  IF aaux[i,5] # 1
     ? USING("ºƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³üüüüüü.üüü³üüüüüü.üüüº",{aaux[i,2],aaux[i,3],aaux[i,4]})
     x2 += aaux[i,3];  xtot2 += aaux[i,4]
  ENDIF
NEXT
?            "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
?      USING("ºTotal Lubr.y Varios ³üüüüüü.üüü³üüüüüü.üüüº",{x2,xtot2} )
?            "ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ½"
?            "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
?      USING("ºTotal               ³üüüüüü.üüü³üüüüüü.üüüº",{x1+x2,xtot1+xtot2} )
?            "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼"

x1 := x2 := 0
aaux := {}
SELECT PL2
DBSETORDER( FORDER({"FECHA","TURNO"}) )
DBSEEK( FTOC(_fecha) + LEFT(_turno,1), .T. )
DO WHILE PL2->FECHA == _fecha .AND. PL2->TURNO $ _turno
  IF FIELD->CANTIDAD # 0
     i := ASCAN( aaux, {|a| a[1]==FIELD->CODPROD.AND.a[2]==FIELD->SURTIDOR } )
     IF i == 0
        AADD( aaux, { FIELD->CODPROD, FIELD->SURTIDOR, FIELD->DESCPROD, FIELD->ABRIO, 0, 0, 0 } )
        i := LEN(aaux)
     ENDIF
     aaux[i,5] := FIELD->CERRO
     aaux[i,6] += FIELD->CANTIDAD
     aaux[i,7] += FIELD->IMPORTE
     x2 += FIELD->IMPORTE
  ENDIF
  SKIP
ENDDO
ASORT( aaux,,,{|x,y| IF(x[2]==0,99,x[2]) < IF(y[2]==0,99,y[2])} )
?         "ÉÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»"
?         "ºSurt³Descripci¢n         ³Abri¢       ³Cerr¢       ³Cantidad  ³Importe   º"
?         "ÇÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
FOR i=1 TO LEN(aaux)
  ? USING("º üü ³ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³üüüüüüüü.üüü³üüüüüüüü.üüü³üüüüüü.üüü³üüüüüü.üüüº",{aaux[i,2],aaux[i,3],aaux[i,4],aaux[i,5],aaux[i,6],aaux[i,7]})
NEXT
?         "ÇÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶"
? USING(  "º                                                              ³üüüüüü.üüüº",{x2})
?         "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼"



     ***   suma los Remitos   ***
ENCABEZADO( "REMITOS", 80 )
aaux := {}
SELECT RE
DBSETORDER( FORDER({"FECHA","TURNO"}) )
#ifdef SUR
	n1 := 0
	n2 := IF( "SUR"$CURDIR() .AND. _turno=="3", n1+1, n1 )
	FOR i=n1 TO n2
  	dff := _fecha + i
  	ctt := STR(VAL(_turno)+i,1)
  	SEEK FTOC(dff) + ctt
  	DO WHILE FIELD->FECHA == dff .AND. FIELD->TURNO==ctt
     	AADD( aaux, { FIELD->CODCLI, FIELD->FECHA, FIELD->TURNO, FIELD->NUMFAC, FIELD->TOTAL } )
     	SKIP
  	ENDDO
	NEXT
#else
#ifdef POWEROIL
	dbseek( ftoc(M->FECHA), .T. )
	do while FIELD->FECHA==M->FECHA
		if left(RE->OBSERV,1)==M->TURNO
     	AADD( aaux, { FIELD->CODCLI, FIELD->FECHA, FIELD->TURNO, FIELD->NUMFAC, FIELD->TOTAL } )
		endif
		skip
	enddo
#else
	SEEK FTOC(M->FECHA) + M->TURNO
	DO WHILE FIELD->FECHA == M->FECHA .AND. FIELD->TURNO == M->TURNO
     AADD( aaux, { FIELD->CODCLI, FIELD->FECHA, FIELD->TURNO, FIELD->NUMFAC, FIELD->TOTAL } )
		SKIP
	ENDDO
#endif
#endif
*******************************
IF LEN(aaux) == 0
  ? "* * *    NO HAY REMITOS   * * *"
ELSE
  ASORT( aaux,,,{|x,y| x[1] <y[1] } )
  xant:=xtot:=xcant:=xtcant:=xttot:=0
  aa := {{},{},{}}; x := 1
  FOR i=1 TO LEN(aaux)
     IF aaux[i,1] # xant
        IF xant # 0
           AADD(aa[x],       "ÇÄÁÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
           AADD(aa[x], USING("ºcant:üüü   ³üüüüüüü.üüº",{xcant,xtot}) )
           AADD(aa[x],       "ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
           AADD(aa[x],       "                        ")
           x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 ); x := IF( LEN(aa[3]) < LEN(aa[x]), 3, x )
        ENDIF
        AADD(aa[x],          "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
        AADD(aa[x],          "º                      º")
        AADD(aa[x], STRINSTR("º                      º", ALLTRIM(FCLIENTE(aaux[i,1])) ))
        AADD(aa[x],          "º                      º")
        AADD(aa[x],          "ÇÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¶")
        AADD(aa[x],          "ºT³Remito   ³Importe   º")
        AADD(aa[x],          "ÇÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
        xant:=aaux[i,1]; xtot := 0; xcant := 0
     ENDIF
     AADD(aa[x],USING(       "ºƒ³üüüüüüüüü³üüüüüüü.üüº",{aaux[i,3],aaux[i,4],aaux[i,5]}) )
     xtot += aaux[i,5]; ++xcant
     xttot += aaux[i,5]; ++xtcant
  NEXT
  AADD(aa[x],       "ÇÄÁÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
  AADD(aa[x], USING("ºcant:üüü   ³üüüüüüü.üüº",{xcant,xtot}) )
  AADD(aa[x],       "ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
  x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 ); x := IF( LEN(aa[3]) < LEN(aa[x]), 3, x )
  AADD(aa[x],       "                        ")
  AADD(aa[x],       "ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»")
  AADD(aa[x], USING("ºTotal üüü  ºüüüüüüü.üüº",{xtcant,xttot}))
  AADD(aa[x],       "ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¼")
  FOR i=1 TO MAX( LEN(aa[1]), MAX( LEN(aa[2]),LEN(aa[3]) ) )
     ?  IF(i<=LEN(aa[1]), aa[1,i], SPACE(LEN(aa[1,1])) ) +SPACE(4)
     ?? IF(i<=LEN(aa[2]), aa[2,i], SPACE(LEN(aa[1,1])) ) +SPACE(4)
     ?? IF(i<=LEN(aa[3]), aa[3,i], SPACE(LEN(aa[1,1])) )
  NEXT
ENDIF
           


  * * *  suma los cheques
ENCABEZADO( "CHEQUES", 80 )
aaux := {}
SELECT CH
DBSETORDER( FORDER({"FECHPAGO","TURNO"}) )
DBSEEK( FTOC(_fecha) + _turno, .T. )
DO WHILE FIELD->FECHPAGO == _fecha .AND. FIELD->TURNO $ _turno
  AADD( aaux, { FIELD->TURNO, FIELD->CODBAN, FIELD->NUMCHEQUE, FIELD->MONTO } )
  SKIP
ENDDO
IF LEN(aaux) == 0
  ? "* * *    NO HAY CHEQUES   * * *"
ELSE
  ASORT( aaux,,,{|x,y| x[2]+x[1] <y[2]+y[1] } )
  xant:= ""
  xtot:=xcant:=xtcant:=xttot:=0
  aa := {{},{}}; x:=1
  FOR i=1 TO LEN(aaux)
     IF aaux[i,2] # xant
        IF xant # ''
           AADD(aa[x],       "ÇÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
           AADD(aa[x], USING("ºcant:üüü        ³üüüüüüü.üüº",{xcant,xtot}) )
           AADD(aa[x],       "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
           AADD(aa[x],       "                             ")
           x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 )
        ENDIF
        AADD(aa[x],          "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
        AADD(aa[x],          "º                           º")
        AADD(aa[x], STRINSTR("º                           º",ALLTRIM(FVECTOR(vbanco,aaux[i,2])) ))
        AADD(aa[x],          "º                           º")
        AADD(aa[x],          "ÇÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¶")
        AADD(aa[x],          "ºT³n§ Cheque     ³Monto     º")
        AADD(aa[x],          "ÇÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
        xant:=aaux[i,2]; xtot := 0; xcant := 0
     ENDIF
     AADD(aa[x], USING(      "ºƒ³ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³üüüüüüü.üüº", {aaux[i,1],JUSTIF(aaux[i,3],14,"<"),aaux[i,4]}) )
     xtot += aaux[i,4]; ++xcant
     xttot += aaux[i,4]; ++xtcant
  NEXT
  AADD(aa[x],                "ÇÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
  AADD(aa[x], USING(         "ºcant:üüü        ³üüüüüüü.üüº",{xcant,xtot}) )
  AADD(aa[x],                "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
  x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 )
  AADD(aa[x],                "                             ")
  AADD(aa[x],                "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»")
  AADD(aa[x], USING(         "ºTotal: üüü      ºüüüüüüü.üüº",{xtcant,xttot}) )
  AADD(aa[x],                "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¼")
  FOR i=1 TO MAX( LEN(aa[1]), LEN(aa[2]) )
     ?  IF(i<=LEN(aa[1]), aa[1,i], SPACE(LEN(aa[1,1])) ) +SPACE(9)
     ?? IF(i<=LEN(aa[2]), aa[2,i], SPACE(LEN(aa[1,1])) )
  NEXT
ENDIF



  * * *  suma las tarjetas
ENCABEZADO( "TARJETAS", 80 )
aaux := {}
SELECT TA
DBSETORDER( FORDER({"FECHPAGO","TURNO"}) )
DBSEEK( FTOC(_fecha) + _turno, .T. )
DO WHILE FIELD->FECHPAGO == _fecha .AND. FIELD->TURNO $ _turno
  AADD( aaux, { FIELD->TURNO, FIELD->CODTARJ, FIELD->NUMTARJ, FIELD->MONTO } )
  SKIP
ENDDO
IF LEN(aaux) == 0
  ? "* * *    NO HAY TARJETAS   * * *"
ELSE
  ASORT( aaux,,,{|x,y| x[2]+x[1] < y[2]+y[1] } )
  xant:=""
  xtot:=xcant:=xtcant:=xttot:=0
  aa := {{},{}}; x:=1
  FOR i=1 TO LEN(aaux)
     IF aaux[i,2] # xant
        IF xant # ""
           AADD(aa[x],       "ÇÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
           AADD(aa[x], USING("ºcant:üüü        ³üüüüüüü.üüº",{xcant,xtot}) )
           AADD(aa[x],       "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
           AADD(aa[x],       "                             ")
           x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 )
        ENDIF
        AADD(aa[x],          "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
        AADD(aa[x],          "º                           º")
        AADD(aa[x], STRINSTR("º                           º",ALLTRIM(FVECTOR(vtarjeta,aaux[i,2])) ))
        AADD(aa[x],          "º                           º")
        AADD(aa[x],          "ÇÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¶")
        AADD(aa[x],          "ºT³n§ Tarjeta    ³Monto     º")
        AADD(aa[x],          "ÇÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
        xant:=aaux[i,2]; xtot := 0; xcant := 0
     ENDIF
     AADD(aa[x], USING(      "ºƒ³ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ³üüüüüüü.üüº", {aaux[i,1],aaux[i,3],aaux[i,4]}) )
     xtot += aaux[i,4]; ++xcant
     xttot += aaux[i,4]; ++xtcant
  NEXT
  AADD(aa[x],                "ÇÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
  AADD(aa[x], USING(         "ºcant:üüü        ³üüüüüüü.üüº",{xcant,xtot}) )
  AADD(aa[x],                "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
  x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 )
  AADD(aa[x],                "                             ")
  AADD(aa[x],                "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»")
  AADD(aa[x], USING(         "ºTotal: üüü      ºüüüüüüü.üüº",{xtcant,xttot}) )
  AADD(aa[x],                "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¼")
  FOR i=1 TO MAX( LEN(aa[1]), LEN(aa[2]) )
     ?  IF(i<=LEN(aa[1]), aa[1,i], SPACE(LEN(aa[1,1])) ) +SPACE(9)
     ?? IF(i<=LEN(aa[2]), aa[2,i], SPACE(LEN(aa[1,1])) )
  NEXT
ENDIF



  * * *  suma las posnet
ENCABEZADO( "POSNET", 80 )
aaux := {}
SELECT PN
DBSETORDER( FORDER({"FECHPAGO","TURNO"}) )
DBSEEK( FTOC(_fecha) + _turno, .T. )
DO WHILE FIELD->FECHPAGO == _fecha .AND. FIELD->TURNO $ _turno
  AADD( aaux, { FIELD->TURNO, FIELD->CODTARJ, FIELD->MONTO } )
  SKIP
ENDDO
IF LEN(aaux) == 0
  ? "* * *    NO HAY POSNET  * * *"
ELSE
  ASORT( aaux,,,{|x,y| x[2]+x[1] < y[2]+y[1] } )
  xant:=""
  xtot:=xcant:=xtcant:=xttot:=0
  aa := {{},{}}; x:=1
  FOR i=1 TO LEN(aaux)
     IF aaux[i,2] # xant
        IF xant # ""
           AADD(aa[x],       "ÇÄÁÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
           AADD(aa[x], USING("ºcant:üüü³üüüüüüü.üüº",{xcant,xtot}) )
           AADD(aa[x],       "ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
           AADD(aa[x],       "                     ")
           x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 )
        ENDIF
        AADD(aa[x],          "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»")
        AADD(aa[x],          "º                   º")
        AADD(aa[x], STRINSTR("º                   º",ALLTRIM(FVECTOR(vtarjeta,aaux[i,2])) ))
        AADD(aa[x],          "º                   º")
        AADD(aa[x],          "ÇÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¶")
        AADD(aa[x],          "ºT³      ³Monto     º")
        AADD(aa[x],          "ÇÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
        xant:=aaux[i,2]; xtot := 0; xcant := 0
     ENDIF
     AADD(aa[x], USING(      "ºƒ³      ³üüüüüüü.üüº", {aaux[i,1],aaux[i,3]}) )
     xtot += aaux[i,3]; ++xcant
     xttot += aaux[i,3]; ++xtcant
  NEXT
  AADD(aa[x],                "ÇÄÁÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
  AADD(aa[x], USING(         "ºcant:üüü³üüüüüüü.üüº",{xcant,xtot}) )
  AADD(aa[x],                "ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
  x := IF( LEN(aa[1]) < LEN(aa[2]), 1, 2 )
  AADD(aa[x],                "                     ")
  AADD(aa[x],                "ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»")
  AADD(aa[x], USING(         "ºTot.:üüüºüüüüüüü.üüº",{xtcant,xttot}) )
  AADD(aa[x],                "ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¼")
  FOR i=1 TO MAX( LEN(aa[1]), LEN(aa[2]) )
     ?  IF(i<=LEN(aa[1]), aa[1,i], SPACE(LEN(aa[1,1])) ) +SPACE(9)
     ?? IF(i<=LEN(aa[2]), aa[2,i], SPACE(LEN(aa[1,1])) )
  NEXT
ENDIF

           


* * *  suma los copres
ENCABEZADO( "COPRES", 80 )
aaux := {}
SELECT COP
DBSETORDER( FORDER({"COP->FECHA","COP->TURNO"}) )
DBSEEK( FTOC(_fecha) + _turno, .T. )
DO WHILE COP->FECHA == _fecha .AND. COP->TURNO $ _turno
  AADD( aaux, { FIELD->TURNO, FIELD->NUMERO, FIELD->MONTO } )
  SKIP
ENDDO
IF LEN(aaux) == 0
  ? "* * *    NO HAY COPRES   * * *"
ELSE
  ASORT( aaux,,,{|x,y| x[1] < y[1] } )
  xant:=""
  xtot:=xcant:=xtcant:=0
  aa := {{},{}}; x:=1
  AADD(aa[x],           "ÉÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»")
  AADD(aa[x],           "ºT³n§ Copres³Monto     º")
  AADD(aa[x],           "ÇÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
  FOR i=1 TO LEN(aaux)
     AADD(aa[x], USING( "ºƒ³üüüüüüüüü³üüüüüüü.üüº", {aaux[i,1],aaux[i,2],aaux[i,3]}) )
     xtot += aaux[i,3]; ++xcant
  NEXT
  AADD(aa[x],           "ÇÄÁÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ¶")
  AADD(aa[x], USING(    "ºcant:üüü   ³üüüüüüü.üüº", {xcant,xtot}) )
  AADD(aa[x],           "ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼")
  FOR i=1 TO MAX( LEN(aa[1]), LEN(aa[2]) )
     ?  IF(i<=LEN(aa[1]), aa[1,i], SPACE(LEN(aa[1,1])) ) +SPACE(9)
     ?? IF(i<=LEN(aa[2]), aa[2,i], SPACE(LEN(aa[1,1])) )
  NEXT
ENDIF

SETIMPRESORA("FIN","")

RECUPAN()
RECUPAN()
IF EST->SALIDA $ "PAN TXT"      //.AND. FILE("..\VERTXT.COM")
  mbuz:=MENUDOWN({"  <+>  º  ESC   ",;
                  "       º        ",;
                  " mueve º  sale  "})
  MARCO( 1, 1, 20, 78, "", "D", .T., 0 )
  MEMOEDIT( MEMOREAD(XNAME("XLIS")+".TXT"), 1, 1, 20, 78, .F., "FOUND()", 99 )
  RECUPAN()
  PONEPAN(mbuz)
ENDIF
CLEARTYPEAHEAD()

RETURN NIL

*****************************

STATIC FUNC ENCABEZADO( que, ancho )

*****************************
LOCAL aux := SPACE((ancho-LEN(que))/2)

?
?
? aux + REPLIC( "#", LEN(que) )
? aux + que
? aux + REPLIC( "#", LEN(que) )
?

RETURN NIL


*************

FUNC STRINSTR( str1, str2 )

*************
LOCAL r, x
str2 := IF( LEN(str2)>LEN(str1), LEFT(str2,LEN(str1)), str2 )
x := ( LEN(str1) - LEN(str2) ) / 2
r := STUFF( str1, x, LEN(str2), str2 )

RETURN r


***********************

FUNC USING( _masc, aa )

***********************
LOCAL x, sm, i, ia:=0

FOR i=1 TO LEN(aa)
  x:=AT( 'ü', _masc )
  y:=AT( 'ƒ', _masc )

  IF (x<y .AND. y#0 .AND. x#0) .OR. (y==0.AND. x#0)         // es numerico
     xi := x
     c:=SUBSTR(_masc,x,1); sm:=''
     DO WHILE c $ 'ü.'
        sm += IF(c=='ü',"#",c)
        c := SUBSTR(_masc,++x,1)
     ENDDO
     _masc:=STUFF( _masc, xi, LEN(sm), TRANS(aa[i],sm) )

  ELSEIF y # 0
     xi := y
     c:=SUBSTR(_masc,y,1); sm:=''
     DO WHILE c $ 'ƒ'
        sm += IF(c=='ƒ',"X",c)
        c := SUBSTR(_masc,++y,1)
     ENDDO
     _masc:=STUFF( _masc, xi, LEN(sm), TRANS(aa[i]+space(40),sm) )

  ENDIF
NEXT

RETURN _masc


****************

STATIC FUNC FTOT2

****************
SETCOLOR("W+/N")
              * * *  Recalcula los totales  * * *
           aing[XTURNO] := aegr[XTURNO] := 0
           FOR x=1 TO LEN(AX)
*             i := ASCAN( AX,{|a| a[X_TURNO]==M->TURNO }, x )
					i:=x
*             IF i # 0
                 aing[XTURNO] += AX[i,X_INGRESO]
                 aegr[XTURNO] += AX[i,X_EGRESO]
                 adif[XTURNO] := aing[XTURNO] - aegr[XTURNO]
*             ENDIF
           NEXT
           FVERREG( aTot,, .T. )

FOR i=1 TO LEN(aauxt)
  @ ED_CTON(aTOT[ED_VPOSY],aauxt[i]), ED_CTON(aTOT[ED_VPOSX],aauxt[i]) SAY EVAL(aTOT[ED_VFUNCS,aauxt[i]],aTOT[ED_CONT]) PICT aTOT[ED_VPICTS,aauxt[i]]
NEXT i
SETCOLOR(aTOT[ED_CFUNC])

RETURN NIL
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local cBaseAux:=XNAME("XAUX")

IF listado $ "CAJADIA"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	DO ICARGA WITH listado
	FOR z=1 TO LEN(AX)
		CABEZA( 1 )
		I_CL = I_CL + 1
		? I_esp + ARMOLIN(I_cab+1)
	NEXT
	CABEZA( 2 )
	I_CL += 3
	?
	? I_esp + ARMOLIN(I_cab+2)
	? I_esp + ARMOLIN(I_cab+3)
	LISTADOR( "FIN" )
	RECUPAN()
		
ELSEIF listado = "RESUCAJA"
	IF QUEFECHA2( 10, 30 )
*		FBASES({ "CAJA" })
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		SELECT CA
		I_codaux=CTOD('')
		M->TURNO = ""
		STORE 0 TO M->INGRESO, M->EGRESO, TINGRESO, TEGRESO
		SET SOFTSEEK ON
		SEEK FTOC(DESDE)
		I_codaux = CA->FECHA
		M->TURNO = CA->TURNO
		DO WHILE !EOF() .AND. !SALIR()
			IF CA->FECHA >= DESDE .AND. CA->FECHA <= HASTA	 .AND. !EMPTY(CA->TURNO)
				IF I_codaux # CA->FECHA .OR. CA->TURNO # M->TURNO
					CABEZA( 1 )
					I_CL = I_CL + 1
					?  I_esp + ARMOLIN(I_cab+1)
					I_codaux = CA->FECHA
					M->TURNO = CA->TURNO
					STORE 0 TO M->INGRESO, M->EGRESO
				ENDIF
				M->INGRESO = M->INGRESO + CA->INGRESO
				M->EGRESO = M->EGRESO + CA->EGRESO
				TINGRESO = TINGRESO + CA->INGRESO
				TEGRESO = TEGRESO + CA->EGRESO
			ENDIF
			SKIP
		ENDDO
		SET SOFTSEEK OFF
		CABEZA( 3 )
		I_CL = I_CL + 3
		?  I_esp + ARMOLIN(I_cab+1)
		?
		? I_esp + ARMOLIN(I_cab+2)
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
		
ELSEIF listado = "RESCAJDI"
	IF QUEFECHA2( 10, 30 )
*		FBASES({ "CAJA" })
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		SELECT CA
		I_codaux=CTOD('')
		M->TURNO = ""
		STORE 0 TO M->INGRESO, M->EGRESO, TINGRESO, TEGRESO
		SET SOFTSEEK ON
		SEEK FTOC(DESDE)
		I_codaux = CA->FECHA
		DO WHILE !EOF() .AND. !SALIR()
			IF CA->FECHA >= DESDE .AND. CA->FECHA <= HASTA .AND. !EMPTY(CA->TURNO)
				IF I_codaux # CA->FECHA
					CABEZA( 1 )
					I_CL = I_CL + 1
					?  I_esp + ARMOLIN(I_cab+1)
					I_codaux = CA->FECHA
					STORE 0 TO M->INGRESO, M->EGRESO
				ENDIF
				M->INGRESO = M->INGRESO + CA->INGRESO
				M->EGRESO = M->EGRESO + CA->EGRESO
				TINGRESO = TINGRESO + CA->INGRESO
				TEGRESO = TEGRESO + CA->EGRESO
			ENDIF
			SKIP
		ENDDO
		SET SOFTSEEK OFF
		CABEZA( 3 )
		I_CL = I_CL + 3
		?  I_esp + ARMOLIN(I_cab+1)
		?
		? I_esp + ARMOLIN(I_cab+2)
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
		
ELSEIF listado = "FALTANTE"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		SELECT 99
		DBCLOSEAREA()
		SELECT CA
		SET SOFTSEEK ON
		SEEK FTOC(DESDE)
		COPY TO (cBaseAux) REST FOR CA->CODCONC$"FAL SOB" .AND. !EMPTY(TURNO) WHILE CA->FECHA<=HASTA
		SELECT 99
		USE (cBaseAux) ALIAS X
		INDEX ON X->CODEMP TO (cBaseAux)
		aux = .F.
		STORE 0 TO M->FALTANTE, M->TFALTANTE
		I_codaux="123"
		GO TOP
		DO WHILE !EOF()
			IF SALIR()
				EXIT
			ENDIF
			IF I_codaux # X->CODEMP
				IF !I_INI
					CABEZA( 1 )
					?  I_esp + ARMOLIN(I_cab+2)
					I_CL = I_CL + 1
				ENDIF
				CABEZA( 2 )
				?
				? I_esp + ""+ EMP( X->CODEMP )
				I_CL = I_CL + 2
				I_codaux = X->CODEMP
				STORE 0 TO M->FALTANTE
			ENDIF
			CABEZA( 1 )
			M->FALTANTE += X->EGRESO - X->INGRESO
			?  I_esp + ARMOLIN(I_cab+1)
			M->TFALTANTE += X->EGRESO - X->INGRESO
			I_CL = I_CL + 1
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
		SELECT CA
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
		
ELSEIF listado = "VALES"
	IF QUEFECHA2( 10, 30 )
*		FBASES({"+CAJA"})
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		SELECT 99
		DBCLOSEAREA()
		SELECT CA
		SET SOFTSEEK ON
		SEEK FTOC(DESDE)
		COPY TO (cBaseAux) REST FOR CA->CODCONC=="VAL" .AND. !EMPTY(TURNO) WHILE CA->FECHA<=HASTA
		SELECT 99
		use (cBaseAux) alias X exclusive
		INDEX ON X->CODEMP TO (cBaseAux)
		aux = .F.
		STORE 0 TO M->VALES, M->TVALES
		I_codaux="123"
		GO TOP
		DO WHILE !EOF()
			IF SALIR()
				EXIT
			ENDIF
			IF I_codaux # X->CODEMP
				IF !I_INI
					CABEZA( 1 )
					?  I_esp + ARMOLIN(I_cab+2)
					I_CL = I_CL + 1
				ENDIF
				CABEZA( 2 )
				?
				? I_esp + ""+ EMP( X->CODEMP )
				I_CL = I_CL + 2
				I_codaux = X->CODEMP
				STORE 0 TO M->VALES
			ENDIF
			CABEZA( 1 )
			M->VALES += X->INGRESO + X->EGRESO
			?  I_esp + ARMOLIN(I_cab+1)
			M->TVALES += X->INGRESO + X->EGRESO
			I_CL = I_CL + 1
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
		SELECT CA
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
		
ELSEIF listado = "CAJXCONC"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		select 99;  dbclosearea()
     select CON
		aux:="";  dbeval( {|a|aux+=CON->CODCONC+"-"}, {||CON->MARCA==""} )
		select CA
     set order to CA_FECHA_TURNO
		dbseek(ftoc(DESDE),.T.)
		index on CA->CODCONC to (cBaseAux) rest for CA->CODCONC+"-"$aux .and. !empty(TURNO) while CA->FECHA<=HASTA
		total on CA->CODCONC to (cBaseAux) fields INGRESO, EGRESO
		use (cBaseAux) alias X exclusive
		dbgotop()
		M->TINGRESO := 0
		M->TEGRESO  := 0
		do while !salir().and. !EOF()
			CABEZA( 1 )
			++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			M->TINGRESO += X->INGRESO
			M->TEGRESO  += X->EGRESO
			skip
		enddo
		CABEZA( 4 )
		I_CL += 4
		?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		? I_esp + ARMOLIN(I_cab)
     FREABRIR({"CAJA"})
		select CA
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
		
ELSEIF listado = "CAJXCOND"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
     select CON
		aux:="";  dbeval( {|a|aux+=CON->CODCONC+"-"}, {||CON->MARCA==""} )
		select CA
     set order to CA_FECHA_TURNO
		dbseek(ftoc(DESDE),.T.)
		index on CA->CODCONC+FTOC(CA->FECHA)+CA->TURNO to (cBaseAux) rest for CA->CODCONC+"-"$aux .and. !empty(TURNO) while CA->FECHA<=HASTA
		dbgotop()
		M->INGRESO:=M->TINGRESO:= 0
		M->EGRESO :=M->TEGRESO := 0
     I_aux:="@"
		do while !salir().and. !EOF()
     	if I_aux#CA->CODCONC
        	if !I_INI
					CABEZA( 2 )
					I_CL += 2
					? I_esp + ARMOLIN(I_cab+2)
           	?
           endif
				CABEZA( 2 )
				I_CL += 2
           ?
				? I_esp + CA->CODCONC +" "+ CA->CONCEPTO
				M->INGRESO := M->EGRESO  := 0
     		I_aux:=CA->CODCONC
        endif
			CABEZA( 1 )
			++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			M->INGRESO += CA->INGRESO
			M->EGRESO  += CA->EGRESO
			M->TINGRESO += CA->INGRESO
			M->TEGRESO  += CA->EGRESO
			skip
		enddo
		CABEZA( 5 )
		I_CL += 5
		? I_esp + ARMOLIN(I_cab+2)
		?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+3)
		? I_esp + ARMOLIN(I_cab)
     FREABRIR({"CAJA"})
		select CA
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
		
ELSEIF listado = "CAJXCOND"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		select 99;  dbclosearea()
     select CON
		aux:="";  dbeval( {|a|aux+="-"+CON->CODCONC}, {||CON->MARCA==""} )
		select CA
		dbseek(ftoc(DESDE),.T.)
		copy to (cBaseAux) rest for CA->CODCONC+"-"$aux .and. !empty(TURNO) while CA->FECHA<=HASTA
		select 99
		use (cBaseAux) alias X exclusive
		index on X->CODCONC to (cBaseAux)
		dbgotop()
		M->INGRESO := M->TINGRESO := X->INGRESO
		M->EGRESO  := M->TEGRESO  := X->EGRESO
		I_codaux = X->CONCEPTO
     skip
		DO WHILE !salir().and. !EOF()
			if left(I_codaux,10) # left(X->CONCEPTO,10)
				CABEZA( 1 )
				?  I_esp + ARMOLIN(I_cab+1)
				++I_CL
				I_codaux = X->CONCEPTO
				STORE 0 TO M->INGRESO, M->EGRESO
			ENDIF
			CABEZA( 1 )
			M->INGRESO  += X->INGRESO
			M->EGRESO   += X->EGRESO
			M->TINGRESO += X->INGRESO
			M->TEGRESO  += X->EGRESO
			SKIP
		ENDDO
		SET SOFTSEEK OFF
		CABEZA( 5 )
		? I_esp + ARMOLIN(I_cab+1)
		?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		? I_esp + ARMOLIN(I_cab)
		I_CL = I_CL + 4
		SELECT CA
		LISTADOR( "FIN" )
		RECUPAN()
	ENDIF
endif

return
