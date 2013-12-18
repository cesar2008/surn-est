#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

LOCAL aux := SPACE(5), cBase:=DBF()
LOCAL nNETO,nTIMPINT,nTIVA1,nTIVA2,nTOTAL,cAux
aux := UPPER( INGRVAL( 10, 20, "CLAVE:", aux, "XXXXX", "") )
IF aux # "RASEC"
	RETURN
ENDIF

DO WHILE .T.
	aaux := {;
			"1  Poner las fechas a los cuerpos de fact. ",;
 			"2  Pone Imp.Int.al cuerpo de las compras   ",;
      	"3  Pone * a las Facturas c/art. del Servic ",;
        "4  Set‚o de Impresora                      ",;
        "5  Configuraci¢n Sistema                   ",;
        "6  Dise¤o de Boletas                       ",;
 			"7  Recalcular detalle de remitos en 0      ",;
 			"8  Cambiar Fechas a Fact/Remitos           ",;
 			"9  Verificar Facturaci¢n                   ",;
 			"10 Prorratear Precios de Compras           ",;
 			"11 Agregar pedazos de archivos al actual   ",;
 			"12 Poner Percep.IB a las fact.q'les falte  ",;
 			"13 Extraer porci¢n de archivo              ",;
 			"14 Verificar Facturaci¢n NETO+IMP==TOTAL.  ",;
			"15 Poner datos de Proveedores a las Compras",;
			"16 Desmarcar Remitos con referencia erronea",;
			"17 Poner Fecha de Emisi¢n a Fac/Rem/Tick.  ",;
			"18 Contar Facturas y Tickets               ",;
			"19 Actualizar N§ Cobro                     ",;
			"20 Renumerar clientes repetidos            ",;
			"21 Arreglar Tickets irregulares            "}

	op = PP_SELEC( 10, 30, 0, 0, aaux, 1, "", "S", .T. )
	RECUPAN()

	IF op == 1
		op2 = MENUFLASH( 10, 30, 1, .T., "PONER FECHAS A LOS CUERPOS",;
     			"COMPRAS", "REMITOS", "TICKETS", "FACA", "FACB" )
		MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
     IF op2 == 1
			FBASES({"COMPRAS","COMPRAS2"},.F.)
  		SELECT CO2
     	FFLOCK()
  		GO TOP
			SELECT CO
  		DO WHILE !CO2->(EOF())
  			SEEK STR(CO2->CODPROV)+CO2->NUMFAC
     		IF FOUND()
     			CO2->FECHA := CO->FECHA
     		ENDIF
     		SKIP 1 ALIAS CO2
  		ENDDO
     ELSEIF op2 == 2
			FBASES({"REM","REM2"},.F.)
  		SELECT RE2
     	FFLOCK()
  		GO TOP
			SELECT RE
  		DO WHILE !RE2->(EOF())
     		IF EMPTY(RE2->FECHA)
  				IF DBSEEK( RE2->NUMFAC )
     				RE2->FECHA := RE->FECHA
                 @ 24,70 SAY FECHA
     			ENDIF
        	ENDIF
     		SKIP 1 ALIAS RE2
  		ENDDO
     ELSEIF op2 == 3
			FBASES({UT_SISTEMA+"\MIN\TICKETS",UT_SISTEMA+"\MIN\TICKETS2"},.F.)
  		SELECT TI2
     	FFLOCK()
  		GO TOP
			SELECT TI
  		DO WHILE !TI2->(EOF())
     		IF EMPTY(TI2->FECHA)
  				IF DBSEEK( TI2->NUMFAC )
     				TI2->FECHA := TI->FECHA
                 @ 24,70 SAY FECHA
     			ENDIF
        	ENDIF
     		SKIP 1 ALIAS TI2
  		ENDDO
     ELSEIF op2 == 4
			FBASES({"FACA","FACA2"},.F.)
  		SELECT FA2
     	FFLOCK()
  		GO TOP
			SELECT FA
  		DO WHILE !FA2->(EOF())
     		IF EMPTY(FA2->FECHA)
  				IF DBSEEK( FA2->NUMFAC )
     				FA2->FECHA := FA->FECHA
                 @ 24,70 SAY FECHA
     			ENDIF
        	ENDIF
     		SKIP 1 ALIAS FA2
  		ENDDO
     ELSEIF op2 == 5
			FBASES({"FACB","FACB2"},.F.)
  		SELECT FB2
     	FFLOCK()
  		GO TOP
			SELECT FB
  		DO WHILE !FB2->(EOF())
     		IF EMPTY(FB2->FECHA)
  				IF DBSEEK( FB2->NUMFAC )
     				FB2->FECHA := FB->FECHA
                 @ 24,70 SAY FECHA
     			ENDIF
        	ENDIF
     		SKIP 1 ALIAS FB2
  		ENDDO
     ENDIF
    	RECUPAN()

	ELSEIF op == 2
		MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
		FBASES({"COMPRAS","COMPRAS2"},.F.)
  	SELECT CO2
     FFLOCK()
  	GO TOP
		SELECT PRD
  	DO WHILE !CO2->(EOF())
  		SEEK STR(CO2->CODPROD)
     	IF FOUND()
*       	CO2->PRECBASE := PRD->PRECCOMPRA
     		CO2->IMPINT   := PRD->IMPINT
     	ENDIF
     	SKIP 1 ALIAS CO2
  	ENDDO
    	RECUPAN()

	ELSEIF op == 3
  		// pone un "*" a todos las facturas que se usaron con art.del servRcompras
		MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
  	cBase := DBF()
     nReg  := RECNO()
     aux := "FA"; aux2 := "FA2"
     FOR z=1 TO 2
  		DBSELECTAREA(aux2)
     	LOCATE FOR FIELD->NEGOCIO == "*"
  		DBSELECTAREA(aux)
     	FFLOCK()
     	DO WHILE !(aux2)->(EOF())
     		IF (aux2)->NEGOCIO == "*"
        		SEEK (aux2)->NUMFAC
           	IF FOUND() .AND. (aux)->NEGOCIO#"*"
        			(aux)->NEGOCIO := "*"
           	ENDIF
        	ENDIF
     		SKIP 1 ALIAS (aux2)
     	ENDDO
     	DBUNLOCK()
     	aux := "FB"; aux2 := "FB2"
     NEXT
     DBSELECTAREA( cBase )
     GO nReg
     RECUPAN()

	ELSEIF op == 4
  	SETIMP()

	ELSEIF op == 5					// configuraci¢n del Sistema
		xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
							  "       º graba y º        ",;
							  " mueve º procede º  sale  "})
		SELECT VA
		aaux := NEWEDIT( "CFG",,.T. )
		FEDITOR( aaux, "LEER" )
		aaux[ED_I] := 1
		aaux[ED_REGISTRO] := RECNO()
		aaux[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( aaux, { K_F10 } )
			IF aaux[ED_UPDATE]
				aaux[ED_MODE] = "MOSTRAR"
			ELSEIF ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_F10
     		frlock("VA")
     		frlock("EST")
				FEDITOR(aaux,"GRABAR",.F.)
     		VA->(dbunlock())
     		EST->(dbunlock())
				EXIT
			ELSEIF aaux[ED_TECLA] == K_ESC
				EXIT
			ENDIF
		ENDDO
		FEDITOR(aaux,"SACAPAN")
		MENUDOWN(xmenu)

	ELSEIF op == 6					// Dise¤o de boletas
  	BL( 10, 30 )

	ELSEIF op == 7					// PRECIOS DE REMITOS
		MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
		FBASES({"REM","REM2"},.F.)
  	SELECT RE2
     nOrder:=INDEXORD()
     SET ORDER TO
     FFLOCK()
  	GO TOP
     aux:=0
  	DO WHILE !RE2->(EOF())
     	IF RE2->TPRECBASE == 0
  			IF !EMPTY(FPRODUCTO(RE2->CODPROD))
					RE2->TPRECBASE := FPRECBASE * RE2->CANTIDAD
     			RE2->TIMPINT   := FIMPINT * RE2->CANTIDAD
        		RE2->TIVA1     := RE2->TPRECBASE * VA->PIVA1 / 100
              RE2->IMPORTE   := RE2->PRECUNIT * RE2->CANTIDAD
					RE2->TPRECBASE := RE2->IMPORTE - RE2->TIMPINT - RE2->TIVA1
        		@ 23,70 SAY ++aux PICT "999999"
        		@ 24,70 SAY RE2->(LASTREC())-RE2->(RECNO()) PICT "99999"
     		ENDIF
        ENDIF
     	SKIP 1 ALIAS RE2
  	ENDDO
     SELECT RE2
     SET ORDER TO nOrder
     DBUNLOCKALL()
    	RECUPAN()

	ELSEIF op == 8					// SUBDIRECTORIO SISTEMA
  	nAux1 := nAux2 := FIELD->NUMFAC
  	dAux := FIELD->FECHA
		cAl :=dbf()
		MARCO( 10, 20, 13, 70, "", "S", .T., 0 )
		SET CONFIRM ON
		SETCURSOR(SC_ON)
		@ 10,20 SAY "   Cambiar x :" GET dAux
		@ 11,20 SAY "Dede  N§ Fact:" GET nAux1
		@ 12,20 SAY "Hasta N§ Fact:" GET nAux2
		@ 13,20 SAY "        Alias:" GET cAl pict "!!!!!!!!"
		READ
		RECUPAN()
     if lastkey() == K_ENTER
			MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
     	cAl2:=cAl+"2"
     	select (cAl)
			set order to 1
        dbseek(nAux1)
     	do while ROSCA().and.BETWEEN((cAl)->NUMFAC,nAux1,nAux2) .and. !(cAl)->(eof())
        	(cAl2)->(dbseek((cAl)->NUMFAC))
           frlock(cAl)
           (cAl)->FECHA := dAux
           (cAl)->(dbunlock())
           do while (cAl2)->NUMFAC==(cAl)->NUMFAC
           	frlock(cAl2)
              (cAl2)->FECHA := dAux
              (cAl2)->(dbunlock())
					skip 1 alias (cAl2)
           enddo
				skip 1 alias (cAl)
			enddo
        RECUPAN()
     ENDIF

	ELSEIF op == 9					// verificar facturas
  	nTOL := 0.1
		IF QUEFECHA2( 10, 25 )
        aFF := {"FA ","FB ","TI "}
			aach := NEWACHO( aFF,,{7,30,20,0} )
			IF MARCARACH( 7, 20, aFF,,{""}) == K_ENTER
				MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
				FBASES({"+FACA","+FACA2", "+FACB","+FACB2", "+"+UT_SISTEMA+"\MIN\TICKETS", "+"+UT_SISTEMA+"\MIN\TICKETS2"},.F.)
     		SET CONSOLE OFF
     		SET ALTERNATE TO QQ
     		SET ALTERNATE ON
     		FOR z=1 TO LEN(aFF)
           	IF "" $ aFF[z]
        		XF  := LEFT(aFF[z],LEN(aFF[z])-1)
        		XF2 := XF + "2"
     			? CHR(15)
     			? "<< "+ XF +" >>"
        		? "N§factur³FECHA   ³XF->TNETO      nTNETO³XF->TIMPIN   nTIMPINT³ XF->TIVA1     nTIVA1³ XF->TIVA2     nTIVA2³ XF->TOTAL     nTOTAL"
        		? "========³========³========== ==========³========== ==========³========== ==========³========== ==========³========== =========="
     			aux:=0
     			SELECT (XF)
  				GO TOP
        		SET ORDER TO FORDER({"FECHA"})
        		DBSEEK( FTOC(DESDE), .T. )
     			SELECT (XF2)
  				DO WHILE (XF)->FECHA>=DESDE .AND. (XF)->FECHA<=HASTA .AND. !(XF)->(EOF()) .AND. INKEY()#K_ESC
*             	IF 1==2
        			IF (XF)->CODCLI == -2			// ANULADA
           			FRLOCK(XF)
     					(XF)->TNETO     := 0
        				(XF)->TIMPINT   := 0
        				(XF)->TIVA1     := 0
        				(XF)->TIVA2     := 0
        				(XF)->TOTAL     := 0
           		ELSE
     					nTNETO   := 0
        				nTIMPINT := 0
        				nTIVA1   := 0
        				nTIVA2   := 0
        				nTOTAL   := 0
     					DBSEEK( (XF)->NUMFAC )
        				DO WHILE (XF2)->NUMFAC == (XF)->NUMFAC
     						nTNETO   += (XF2)->TPRECBASE
        					nTIMPINT += (XF2)->TIMPINT
        					nTIVA1   += (XF2)->TIVA1
        					nTIVA2   += (XF2)->TIVA2
        					nTOTAL   += (XF2)->IMPORTE
           				SKIP
        				ENDDO
        				IF ROUND(ABS((XF)->TNETO-nTNETO),0)>nTOL .OR. ROUND(ABS((XF)->TIMPINT-nTIMPINT),0)>nTOL .OR. ROUND(ABS(nTIVA1-(XF)->TIVA1),0)>nTOL .OR. ROUND(ABS(nTIVA2-(XF)->TIVA2),0)>nTOL .OR. ROUND(ABS((XF)->TOTAL-nTOTAL),0)>nTOL
              			++aux
              			aaux := {{0,0},{0,0},{0,0},{0,0},{0,0}}
        					IF ROUND(ABS((XF)->TNETO-nTNETO),0)>nTOL
                 			aaux[1] := { (XF)->TNETO, nTNETO }
              			ENDIF
								IF ROUND(ABS((XF)->TIMPINT-nTIMPINT),0)>nTOL
									aaux[2] := { (XF)->TIMPINT, nTIMPINT }
              			ENDIF
								IF ROUND(ABS(nTIVA1-(XF)->TIVA1),0)>nTOL
									aaux[3] := { (XF)->TIVA1, nTIVA1 }
              			ENDIF
								IF ROUND(ABS(nTIVA2-(XF)->TIVA2),0)>nTOL
									aaux[4] := { (XF)->TIVA2, nTIVA2 }
              			ENDIF
								IF ROUND(ABS((XF)->TOTAL-nTOTAL),0)>nTOL
									aaux[5] := { (XF)->TOTAL, nTOTAL }
              			ENDIF
        					? STR((XF)->NUMFAC) +"³"+ DTOC((XF)->FECHA) +"³"+ ;
              			TRANS(aaux[1,1],"@Z ######.###")+" "+TRANS(aaux[1,2],"@Z ######.###")+"³"+;
              			TRANS(aaux[2,1],"@Z ######.###")+" "+TRANS(aaux[2,2],"@Z ######.###")+"³"+;
              			TRANS(aaux[3,1],"@Z ######.###")+" "+TRANS(aaux[3,2],"@Z ######.###")+"³"+;
              			TRANS(aaux[4,1],"@Z ######.###")+" "+TRANS(aaux[4,2],"@Z ######.###")+"³"+;
              			TRANS(aaux[5,1],"@Z ######.###")+" "+TRANS(aaux[5,2],"@Z ######.###")
        				ENDIF
           		ENDIF
*                endif
*       			IF left(str( (XF)->TNETO*VA->PIVA1/100,10,2 ),7) # left(str( (XF)->TIVA1 ,10,2 ),7)
*       				? STR((XF)->NUMFAC) +"³"+ DTOC((XF)->FECHA) +"³", (XF)->TNETO, str( (XF)->TIVA1,10,2 ), str( (XF)->TNETO*VA->PIVA1/100, 10,2 ), " <<<"
*       			ENDIF
        			SKIP 1 ALIAS (XF)
     			ENDDO
        		? replicate("-",80)
        		? aux
        		?
              ENDIF
     		NEXT
           SELECT (XF)
       		SET ORDER TO 1
     		SET ALTERNATE OFF
     		SET CONSOLE ON
     		DBUNLOCKALL()
    			RECUPAN()
        ENDIF
     ENDIF

	ELSEIF op == 10					// facturas de compra (prorrateo)
		MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
		FBASES({"COMPRAS","COMPRAS2"},.F.)
		SELECT CO
     GO TOP
     SELECT CO2
     FFLOCK()
     DO WHILE !CO->(EOF())
*			M->TOTAL  := ( CO->SUBTOTAL -CO->BONIF ) + CO->TIMPINT + CO->TIVA1 + CO->PERCEPCION + CO->FINANC
			M->CARGAS := - CO->BONIF + CO->TIMPINT + CO->TIVA1 + CO->PERCEPCION + CO->FINANC
			SEEK STR(CO->CODPROV) + CO->NUMFAC
        DO WHILE CO2->CODPROV==CO->CODPROV .AND. CO2->NUMFAC==CO->NUMFAC
           nporc := CO2->IMPORTE * 100 / CO->TPRECBASE
				CO2->PFCOMPRA := CO2->IMPORTE + ( M->CARGAS * nporc / 100 )
           SKIP
        ENDDO
        @ 24,70 SAY CO->(RECNO()) PICT "9999"
     	SKIP 1 ALIAS CO
     ENDDO
     DBUNLOCKALL()
     RECUPAN()

	ELSEIF op == 11					// agrerga boletas de otro archivo
  	? cSUCURSAL
     WAIT
  	FBASES({"FACB"})
  	select FB
     append from QQ

	ELSEIF op == 12
		IF QUEFECHA2( 10, 30 )
wait "Reemplazar (S/N) ?" to op
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
        aBase:={{"FACA","FA"},{"FACB","FB"}}	//,{"REM","RE"}}
			FBASES({"+PADRONIB"})
        t := 0
        set alternate to qq
        set alternate on
        ? "XF, FIELD->FECHA, z,FIELD->NUMFAC, FIELD->TOTAL, M->TOTAL, nAux, M->TPERCIB"
        for b=1 to len(aBase)
        	z1:=z2:=0
           if aBase[b,2] $ "FA FB"
           	z1:=DESDE_SUC
              z2:=HASTA_SUC
           endif
           for z=z1 to z2
         		cSUCURSAL := str(z,1)
              @ 23,70 say aBase[b,1] +" "+cSUCURSAL
					FBASES({"-"+aBase[b,1]})
					FBASES({"+"+aBase[b,1]})
              XF:=aBase[b,2];  XF2:=XF+"2"
					select (XF)
              set order to forder({"FECHA"})
					dbseek( ftoc(DESDE), .T. )
					do while BETWEEN( (XF)->FECHA, DESDE, HASTA ) .and. !(XF)->(eof())
						M->TOTAL := (XF)->TPRECBASE + (XF)->TIMPINT + (XF)->TIVA1 + (XF)->TIVA2 + (XF)->PERCIB
                 nAux := (XF)->TOTAL - M->TOTAL
                 if abs(nAux)>0.5
							M->TPERCIB := 0
        				baseimponible := (XF)->TPRECBASE + (XF)->TIMPINT
        				if baseimponible>50 .and. (FIELD->CATIVA $ " RM RI ")
           				M->TPERCIB := FPPERC(FIELD->CUIT)
								M->TPERCIB := baseimponible * M->TPERCIB / 100
     					endif
                 	? XF, FIELD->FECHA, z,FIELD->NUMFAC, FIELD->TOTAL, M->TOTAL, nAux, M->TPERCIB
                    if op=="S"
                    	frlock()
                    	(XF)->PERCIB := nAux
                    	dbunlock()
                    endif
                    ++t
                 endif
						skip
					enddo
           next z
			next b
        ? t
        set alternate to
        RECUPAN()
     endif

	ELSEIF op == 13					// extraer porcion
		cArchivo := space(40)
		cAlias   := space(8)
     cArch2   := " "
		MARCO( 10, 20, 15, 70, "", "S", .T., 0 )
		SET CONFIRM ON
		SETCURSOR(SC_ON)
		@ 10,20 SAY "DESDE:" GET DESDE
		@ 11,20 SAY "HASTA:" GET HASTA
		@ 12,20 SAY "Archivo  :" GET cArchivo pict "@!"
		@ 13,20 SAY "Alias    :" GET cAlias pict "!!!!!!!!"
		@ 14,20 SAY "Extraer 2(SùSI):" GET cArch2 pict "!" valid cArch2$"S "
		READ
		RECUPAN()
		SET CONFIRM OFF
     IF lastkey() == K_ENTER
			MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
			cAlias :=alltrim(cAlias)
			cArchivo :=alltrim(cArchivo)
			FBASES({alltrim(cArchivo)},.F.)
        select (cAlias)
     	set order to forder({"FECHA"})
     	dbseek(ftoc(DESDE),.T.)
     	copy to qq rest for ROSCA().and. FECHA>=DESDE while FECHA<=HASTA
        if cArch2=="S"
        	select 99
           use QQ alias X exclusive
           index on X->NUMFAC to QQ
           go top
       		cAlias2   := cAlias+"2"
				cArchivo2 := alltrim(cArchivo)+"2"
				FBASES({cArchivo2},.F.)
           select (cAlias2)
           dbseek( X->NUMFAC, .T. )
*          set relation to (cAlias2)->NUMFAC into X
     		copy to qq2 rest for ROSCA().and. FECHA>=DESDE while FECHA<=HASTA
       		SET ORDER TO 1
        else
        endif
    		RECUPAN()
     ENDIF

	ELSEIF op == 14					// verificar facturas NETO+IMPs=TOTAL
  	nTOL := 5
		IF QUEFECHA2( 10, 25 )
        aFF := {"FA ","FB ","TI "}
			aach := NEWACHO( aFF,,{7,30,20,0} )
			IF MARCARACH( 7, 20, aFF,,{""}) == K_ENTER
				MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
				FBASES({"+FACA","+FACA2", "+FACB","+FACB2", "+"+UT_SISTEMA+"\MIN\TICKETS", "+"+UT_SISTEMA+"\MIN\TICKETS2"},.F.)
     		SET CONSOLE OFF
     		SET ALTERNATE TO QQ
     		SET ALTERNATE ON
     		FOR z=1 TO LEN(aFF)
           	IF "" $ aFF[z]
        		XF  := LEFT(aFF[z],LEN(aFF[z])-1)
        		XF2 := XF + "2"
     			? CHR(15)
     			? "<< "+ XF +" >>"
        		? "N§factur³FECHA   ³XF->TNETO ³XF->TIMPIN³ XF->TIVA1³ XF->TIVA2³    nTOTAL³ XF->TOTAL³DIFERENCIA"
        		? "========³========³==========³==========³==========³==========³==========³==========³=========="
     			aux:=0
              M->TOTAL  := 0
              M->NTOTAL := 0
              M->TDIF   := 0
     			SELECT (XF)
  				GO TOP
        		SET ORDER TO FORDER({"FECHA"})
        		DBSEEK( FTOC(DESDE), .T. )
  				DO WHILE (XF)->FECHA>=DESDE .AND. (XF)->FECHA<=HASTA .AND. !(XF)->(EOF()) .AND. INKEY()#K_ESC
        			IF (XF)->CODCLI == -2			// ANULADA
           			FRLOCK(XF)
     					(XF)->TNETO     := 0
        				(XF)->TIMPINT   := 0
        				(XF)->TIVA1     := 0
        				(XF)->TIVA2     := 0
        				(XF)->TOTAL     := 0
           		ELSE
        				nTOTAL   := (XF)->TNETO+ (XF)->TIVA1+ (XF)->TIVA2+ (XF)->TIMPINT
        				IF ROUND( ABS(nTOTAL-(XF)->TOTAL),0 ) >nTOL
              			++aux
								M->DIF := nTOTAL - (XF)->TOTAL
        					? STR((XF)->NUMFAC) +"³"+ DTOC((XF)->FECHA)+"³"+;
              			TRANS((XF)->TNETO,  "@Z ######.###")+"³"+;
              			TRANS((XF)->TIVA1,  "@Z ######.###")+"³"+;
              			TRANS((XF)->TIVA2,  "@Z ######.###")+"³"+;
              			TRANS((XF)->TIMPINT,"@Z ######.###")+"³"+;
								TRANS(nTOTAL,"######.###" )+"³"+;
              			TRANS((XF)->TOTAL,"@Z ######.###")+"³"+;
								TRANS( M->DIF,"######.###" )
                       M->TOTAL  += (XF)->TOTAL
                       M->NTOTAL += nTOTAL
                       M->TDIF   += M->DIF
        				ENDIF
           		ENDIF
        			SKIP 1 ALIAS (XF)
     			ENDDO
        		? replicate("-",80)
        		? "Cant:=",str(aux,5)
              ? "XF->TOTAL =", STR(M->TOTAL,10,2)
              ? "nTOTAL    =", STR(M->NTOTAL,10,2)
              ? "DIFERENCIA=", STR(M->TDIF,10,2)
        		?
              ENDIF
     		NEXT
           SELECT (XF)
       		SET ORDER TO 1
     		SET ALTERNATE OFF
     		SET CONSOLE ON
     		DBUNLOCKALL()
    			RECUPAN()
        ENDIF
     ENDIF

	ELSEIF op == 15
		MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
		FBASES({"COMPRAS","COMPRAS2","PROVEE"},.F.)
  	select CO2
     set order to 1
     FFLOCK()
  	SELECT CO
     set order to
     FFLOCK()
  	GO TOP
  	do while !CO->(EOF())
        if !empty( CO->NUMFAC )
     		if empty(CO->RAZONSOC)
  				if !empty(FPROVEE(CO->CODPROV,.T.))
						CO->RAZONSOC := M->PROVEEDOR
     				CO->CATIVA   := M->CATIVA
     				CO->CUIT     := M->CUIT
           	endif
     		endif
        	aaux := FNUMFAC(CO->NUMFAC)
           aaux[1]:=alltrim(CO->TIPOFAC)
           if empty(aaux[1])
					aaux[1]  := if(CO->CATIVA=="RNI","FC","FA")
           elseif left(aaux[1],1)=="A"
					aaux[1]  := "FA"
           elseif left(aaux[1],1)=="B"
					aaux[1]  := "FB"
           elseif left(aaux[1],1)=="C"
					aaux[1]  := "FC"
           else
					aaux[1]  := aaux[1]
           endif
        	cAux := padr(left(aaux[1],3),3,' ')+aaux[2]+"-"+aaux[3]
				select CO2
        	do while dbseek(str(CO->CODPROV)+CO->NUMFAC)
        		CO2->NUMFAC := cAux
        	enddo
        	select CO
        	CO->NUMFAC := cAux
        endif
        @ 24,70 say lastrec()-recno() pict "#####"
     	skip 1 alias CO
  	enddo
     set order to 1
    	RECUPAN()

	ELSEIF op == 16
     FBASES({"+CCV","+REM"})
  	select CCV
     set order to forder({"CODCLI","ID_CCV"})
     select RE
     set order to forder({"FECHA"})
     nAux:=0
     XF:="RE"
     ym2:=10;  xm2:=30
     if QUEFECHA2()
        dbseek( ftoc(DESDE), .T. )
        select CCV
        do while BETWEEN((XF)->FECHA,DESDE,HASTA) .and. !(XF)->(eof())
     		if dbseek(str((XF)->CODCLI,FLEN(CCV->CODCLI))+(XF)->ID_CCV)
     		else
					frlock(XF)
              (XF)->ID_CCV:=""
              (XF)->(dbunlock())
              @24,70 say ++nAux pict "######"
     		endif
           skip 1 alias (XF)
        enddo
     	select PRD
     endif
     select CCV
     set order to 1
     select RE
     set order to 1

	ELSEIF op == 17
		MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
     ah:={{"06:01","14:00"},{"14:01","10:00"},{"10:01","23:59","00:00","06:00"}}
     aBase:={"FACA","FACB","REM","TICKETS"}
     for b=1 to len(aBase)
     	@ 24,60 say aBase[b]
  		FBASES({aBase[b]})
     	set order to 1
        	***   primero se fija que no se halla echo este proceso
        lAux:=.T.
        i:=100
        go top
        do while !eof() .and. --i>0
        	if !empty(FIELD->FECHEMI)
					MENSAJE( 0, 0, 10, .t., "YA FUE PASADO !" )
              lAux:=.F.
              exit
           endif
           skip
        enddo
        if lAux
     		FFLOCK()
#ifdef POWEROIL
  			wait "paso 5 a 3" to cAux
     		if upper(cAux)=="S"
     			replace FIELD->TURNO with if(FIELD->TURNO=="5","3","2") for FIELD->TURNO>"1"
     		endif
#endif
     		replace FIELD->FECHEMI with FIELD->FECHA for ROSCA()
     		go top
     		dFecha:=FIELD->FECHA
     		do while ROSCA().and.!eof()
     			if FIELD->FECHA>dFecha
     				dAux:=FIELD->FECHA
     				do while FIELD->FECHA==dAux .and. FIELD->TURNO=="3" .and. !eof()
           			FIELD->FECHA := dFecha
           			skip
						enddo
     				dFecha:=FIELD->FECHA
        		endif
           	@ 24,70 say FIELD->FECHA
     			skip
     		enddo
     		DBUNLOCKALL()
        endif
     next b
     RECUPAN()

	ELSEIF op == 18
		IF QUEFECHA2( 10, 25 )
		MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
     aBase:={"FACA","FACB","TICKETS"}
     aAlias:={"FA","FB","TI"}
     aaux := {0,0,0}
     for s=1 to 6
     	cSUCURSAL := str(s,1)
     	for b=1 to len(aBase)
     		@ 24,60 say aBase[b]
           F_ABASE({aAlias[b]},"CERRAR")
  			FBASES({aBase[b]})
				select (aAlias[b])
     		set order to forder({"FECHA"})
        	dbseek(ftoc(DESDE),.T.)
        	do while BETWEEN(FIELD->FECHA,DESDE,HASTA) .and. !eof()
        		++aaux[b]
           	skip
        	enddo
     	next b
        aSize(aBase,2)
        aSize(aAlias,2)
     next s
     set alternate to QQ.TXT
     set alternate on
     ? "FACA", aaux[1]
     ? "FACB", aaux[2]
     ? "TICK", aaux[3]
     set alternate to
     RECUPAN()
     ENDIF

	ELSEIF op == 19
  	select 99;  dbclosearea()
     select 99
     use \SURN2\EST\ANT\FACB_5 alias X
     nAux := lastrec()
     cSUCURSAL:="5"
     F_ABASE({"FB"},"CERRAR")
     FBASES({"\SURN2\EST\FACB"},.F.)
     select FB
     do while ROSCA() .and. !X->(eof())
     	if dbseek(X->NUMFAC)
        	frlock()
        	FB->NUMCOB := X->NUMCOB
           dbunlock()
        endif
        @ 24, 70 say --nAux pict "9999999"
     	skip 1 alias X
     enddo

	ELSEIF op == 20
  	fbases({"CLA"})
     select CLA
     dbgobottom()
     nAux2 := CLA->CODCLI
		nAux := INGRVAL( 10, 20, "Cliente", 0, "99999", "")
     if lastkey()=K_ENTER
     	dbgotop()
        do while dbseek(nAux)
           ++nAux2
        	frlock()
           CLA->CODCLI := nAux2
           dbunlock()
        	skip
        enddo
			MENSAJE( 0, 0, 10, .t., "listo" )
     endif

	ELSEIF op == 21
		if QUEFECHA2( 10, 25 )
			FBASES({"+TICKETS"},.T.)
     	set order to FORDER({"FECHA"})
        DBSEEK( FTOC(DESDE), .T. )
        fflock()
        replace CATIVA with "", TEXENTO with 0, ANULADO with "", NEGOCIO with "",CODEMP with "" rest for TI->FECHA<=HASTA
        dbunlockall()
			MENSAJE( 0, 0, 10, .t., "listo" )
     endif

  ELSEIF LASTKEY() == K_ESC
  	EXIT

	ENDIF

ENDDO
select VA

RETURN

***************

FUNC FG(nCod)

**************
local r:=0

if PRD->( dbseek(nCod) )
	r := PRD->GRUPO
endif

return r
