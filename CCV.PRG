#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

private FACTURA2, aux, auxaux, lastcolor, aaux

LOGO(.T., " COBROS CUENTAS CORRIENTES " )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
FBASES({ "CLIENTES", "REM","REM2", "CHEQCAR", "TARJETAS", "CCV","CCV2" },.F.)

aCpo:={;
	{ "NUMCOB",		 "N§;Cobro",    						'', 'E',  '',	0, 0 },;
	{ "FECHA", 		 "Fecha;Cierre",						'', 'E',  '',	0, 0 },;
	{ "APAGAR", 	 "a Pagar;",							'', 'E',  '',	0, 0 },;
	{ "PAGADO", 	 "Total;Pagado",						'', 'E',  '',	0, 0 },;
	{ "SALDO",		 "Diferen;",							'', 'F',  '',	0, 0 },;
	{ "SALDOACUM",  "Saldo",								'', 'E',  '',	0, 0 },;
	{ "BORRADOR",	 "Borrador",							'', 'E',  '',	0, 0 },;
	{ "FACTURA",	 "Factura; ",							'', 'E',  '',	0, 0 },;
	{ "NUMCOB", 	 "N§;Cobro",	 						'', 'F',  '',	0, 0 }}
select CCV
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )

#define FAC_FECHA	     1
#define FAC_TURNO 		  2
#define FAC_APAGAR		  3
#define FAC_PAGADO		  4
#define FAC_SALDO 		  5
#define FAC_SALDOACUM	  6
#define FAC_REGISTRO 	  7

#define CCV2_XFECHPAGO 	1
#define CCV2_XTURNO   		2
#define CCV2_XEFECTIVO		3
#define CCV2_XCHEQUE		4
#define CCV2_XTARJETA		5
#define CCV2_XNUMREC		6
#define CCV2_XREGISTRO		7

apago := array( 9, CCV2_XREGISTRO )
cTIPOFAC := "A"
nNUMFAC	:= 0
XF = "FAC"
XF2 = "FAC2"
M->CODCLI = CL->CODCLI
M->FECHA := DATE()
if VA->RECALCCCV
	RECALCREM( {||CL->RECALCCCV}, .T. )
endif
RECUPAN()

SETCOLOR(C_MENU)
ACC := NEWEDIT( "CCV",,.T. )
do while .T.
	store .T. to NUEVO, MODIFICABLE
	do while .T.
		select CL
		set order to 1
		MENUDOWN({"   F7    º    F9    º    F10   º  F   º   TAB    º   ENTER    º ESC ",;
					 "         º recaclc. º  cierra  º fac- º lista de º  cuentas   º     ",;
					 "listados º  saldos  º quincena º tura º clientes º corrientes º sale"})
		k := FVERREG( ACC, {|K|K==K_TAB.or.K==K_ENTER.or.K==K_ESC.or.K==K_F8.or.K==K_ALT_F8.or.K==K_F9.or.K==K_F7.or.chr(k)$'0123456789'} )
		if K == K_ENTER
			exit

		elseif K==K_F2 .or. chr(K)$'0123456789'
			xmenu:=MENUDOWN({ "  <+>  º   TAB    º   F10    º  ESC   ",;
									"       º tablas de º graba y  º        ",;
									" mueve º opciones  º contin£a º  sale  "})
			FEDITOR(ACC,"LEER")
			ACC[ED_I] := 1
			ACC[ED_REGISTRO] := 0
			ACC[ED_MODE] = "MOSTRARTODO"
			if K#K_F2
				keyboard chr(K)
			endif
			do while .T.
				FEDITAR( ACC, { K_TAB, K_F10 } )
				if ACC[ED_UPDATE] .or. ACC[ED_TECLA] == K_TAB
					ACC[ED_MODE] = "MOSTRARTODO"
					if ACC[ED_TECLA] == K_TAB
						if FELEGIR("CLI") # 0
							EDPONE(ACC,,CL->CODCLI)
						endif
					else
						if !dbseek(EDCONT(ACC,"CL->CODCLI"))
							EDPONE(ACC,,ACC[ED_LAST])
						endif
					endif
				elseif ACC[ED_TECLA]==K_ENTER
					keyboard CHR(K_ENTER)
					exit
				elseif ACC[ED_TECLA] == K_ESC
					exit
				endif
			enddo
			PONEPAN(xmenu)
		elseif K == K_F10
			if MARCARCLI()
				if QUEFECHA2( 10, 25 )
					MENSAJE( 99, 99, 0, .F., " CERRANDO QUINCENA... " )
					select CL
					DBGOTOP()
					do while !CL->(EOF())
						@ 24,60 SAY PADL(str(CL->(RECNO()),4)+"-"+CL->RAZONSOC,19," ")
						if CL->MARCA == ""
							select RE
							set order to FORDER({"CODCLI","FECHA"})
							SEEK str(CL->(RECNO()),4) + FTOC(CTOD(''))
							do while RE->CODCLI==CL->(RECNO()) .and. empty(RE->FECHA)
								if RE->FECHA>=DESDE .and. RE->FECHA<=HASTA
									select CCV
									set order to CCV_CODCLI_FECHA
									SET SOFTSEEK ON
									SEEK str(RE->CODCLI) + FTOC(RE->FECHA)
									if CCV->FECHA < RE->FECHA
										DBGOTOP()
										if CCV->CODCLI # 0
											ADD_REC()
										endif
										frlock()
										CCV->CODCLI 	 := CL->(RECNO())
										CCV->FECHA := FCIERRE(RE->FECHA)
									endif
									frlock()
									CCV->APAGAR 	 += RE->TOTAL
									CCV->SALDO		 += RE->TOTAL
									SET SOFTSEEK OFF
									select RE
									frlock()
									RE->FECHA := CCV->FECHA
									SEEK str(CL->(RECNO()),4) + FTOC(CTOD(''))
								else
									skip 1 alias RE
								endif
							enddo
							M->CODCLI := CL->(RECNO())
							select CCV
							SET SOFTSEEK ON
							SEEK str(M->CODCLI,4)
							if CCV->CODCLI == M->CODCLI
								SALDARCCV()
							endif
							SET SOFTSEEK OFF
						endif
						skip 1 alias CL
					enddo
					RECUPAN()
				endif
			endif

			*** factura los remitos marcados
		elseif CHR(K) $ "Ff"
			if MARCARCLI()
				M->FECHA := DESDE
				MARCO( 10,25,11,55, "", "S", .T., 0 )
				@ 10, 25 SAY "        Fecha Cierre:" GET DESDE
				@ 11, 25 SAY "Fecha de Facturaci¢n:" GET M->FECHA
				READ
				RECUPAN()
				if LASTKEY() == K_ENTER
					M->TIPOVENTA = "2"
					M->FECHVENC = VA->FECHA
					nNUMFAC	 := 0
					cTIPOFAC  := "A"
					select CL
					DBGOTOP()
					do while !CL->(EOF()) .and. INKEY(1) # K_ESC
						if CL->MARCA == ""
							M->CODCLI := CL->(RECNO())
							aaux:=SETVARSIVA(CL->CATIVA)
							select CCV
							SEEK str(M->CODCLI,4)+FTOC(DESDE)
							if FOUND()
								AXR:=FACCCV()
							endif
						endif
						skip 1 alias CL
					enddo
				endif
			endif

		elseif k == K_ALT_F8
			op2 = MENUFLASH( 10, 30, 1, .T., "", "Asignar NUMCOB a CHEQCAR" )
			if op2==1
				if MARCARCLI()
					MENSAJE( 99, 99, 0, .F., "REVISANDO... " )
              select CHC
        		dbsetorder(CHC_NUMCOB)
              CL->(dbgotop())
              do while !CL->(eof())
              	if !empty(CL->MARCA)
							CCV->(dbseek( str(CL->CODCLI,FLEN(CCV->CODCLI)), .T. ))
              		do while CCV->CODCLI==CL->CODCLI .and. !CCV->(eof())
								CCV2->(dbseek(CCV->NUMCOB,.T.))
              			do while CCV2->NUMCOB==CCV->NUMCOB .and. !CCV2->(eof())
                       	if CCV2->CHEQUE # 0
                    			aaux := {}
                       		CHC->(dbseek(space(len(CHC->NUMCOB))))
                             do while empty(CHC->NUMCOB) .and. !CHC->(eof())
                             	if CHC->CODCLI==CL->CODCLI .and. CHC->MONTO=CCV2->CHEQUE
                                	aadd( aaux, recno() )
                                endif
                             	skip 1 alias CHC
                             enddo
                       		fflock()
                       		aeval(aaux,{|a| dbgoto(a), CHC->NUMCOB:=CCV2->NUMCOB})
                       		dbunlock()
                          endif
                    		skip 1 alias CCV2
                    	enddo
                    	skip 1 alias CCV
                    enddo
                 endif
                 skip 1 alias CL
              enddo
              RECUPAN()
           endif
        endif

			*** selecciona los clientes con deuda
		elseif k == K_F8
			op2 = MENUFLASH( 10, 30, 1, .T., "", "TODOS        ", "EXCLUIR BAJAS")
			if LASTKEY()==K_ENTER
				MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
				bAux:=if(op2==1,{||.T.},{||empty(CL->FECHBAJA)})
				aaux := {}
				select CL
				DBGOTOP()
				select CCV
				set order to CCV_CODCLI_FECHA
				SET SOFTSEEK ON
				do while !CL->(EOF())
					if Eval(bAux)
						aux := 0
						SEEK str(CL->(RECNO()),4)
						do while FIELD->CODCLI == CL->(RECNO())
							aux := FIELD->SALDOACUM
							skip
						enddo
						if aux # 0
							AADD( aaux, str(CL->(RECNO()),4) +"³"+ CL->RAZONSOC +"³"+ str(aux,10,2) )
						endif
					endif
					skip 1 alias CL
				enddo
				select CL
				DBGOTOP()
				select RE
				set order to FORDER({"CODCLI","FECHA"})
				do while !CL->(EOF())
					if !CL->(DELETED()) .and. Eval(bAux)
						aux := 0
						SEEK str(CL->(RECNO()),4) + FTOC(CTOD(''))
						do while FIELD->CODCLI == CL->(RECNO()) .and. empty(FIELD->FECHA)
							if FIELD->CODCLI # -2
								aux += FIELD->TOTAL
							endif
							skip
						enddo
						if aux # 0
							i := ASCAN( aaux, {|a| val(a)==CL->(RECNO()) } )
							if i == 0
								AADD( aaux, "" )
								i := LEN(aaux)
							else
								aux += val(right(aaux[i],10))
							endif
							aaux[i] := str(CL->(RECNO()),4) +"³"+ CL->RAZONSOC +"³"+ str(aux,10,2)
						endif
					endif
					skip 1 alias CL
				enddo
				ASORT( aaux )
				xaux := 0
				AEval( aaux, {|a| xaux+=val(right(a,10)) })
				RECUPAN()
				if LEN(aaux) == 0
					MENSAJE( 0, 0, 10, .T., " NO HAY CLIENTES CON DEUDAS !!!" )
				else
					MENUDOWN({"º     º  ENTER   º ESC  º",;
								 "º       º          º      º",;
								 "º mueve º confirma º sale º"})
					aux := {"C¢d.³"+ JUSTIF("Cliente",LEN(CL->RAZONSOC)) +"³Deuda     ",;
						"ÄÄÄÄÅ"+ 	REPLIC("Ä",LEN(CL->RAZONSOC)) 	+"ÅÄÄÄÄÄÄÄÄÄÄ" }
					ele := PP_SELEC( 7, 30, 0, 0, aaux, 1, {aux,{"Total:"+str(xaux,10,2),">"}}, "S", .T.)
					if LASTKEY() == K_ENTER
						M->CODCLI = val( aaux[ele] )
					endif
					RECUPAN()
				endif
			endif
		elseif k == K_F9
			MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
			aaux := {}
			select CL
			nReg:=recno()
			dbgotop()
			select RE
			set order to RE_CODCLI_NUMCOB
			select CCV
			set order to CCV_CODCLI_FECHA
			do while ROSCA().and.!CL->(EOF())
				select CCV
				M->CODCLI := CL->CODCLI
				dbseek( str(M->CODCLI,flen(CCV->CODCLI)), .T. )
				if CCV->CODCLI == M->CODCLI
					SALDARCCV()
				endif
				nAux:=0
				select RE
				dbseek( str(M->CODCLI,flen(CCV->CODCLI)), .T. )
				do while RE->CODCLI==M->CODCLI .and. empty(RE->NUMCOB)
					nAux += RE->TOTAL
					skip
				enddo
				fflock("CL")
				CL->REMAPAGAR := nAux
				CL->(dbunlock())
				skip 1 alias CL
			enddo
			select CL
			go nReg
			RECUPAN()
		elseif k == K_TAB
			if FELEGIR("CLICCV") # 0
				M->CODCLI = CL->CODCLI
			endif
		elseif K == K_F7
     	nReg:=CCV->(recno())
			op = MENUFLASH( 10, 30, 1, .T., "LISTADOS", "Remitos x Per¡odo", "C.C.a Cobrar", "Detalle de Cobros", "Estado CCV" )
			if op == 1
				if MARCARCLI()
					if QUEFECHA2(10,30)
						MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
						select CL; aaux:={};  dbeval( {|| aadd(aaux,CL->CODCLI)}, {|| CL->MARCA==''} )
						select RE
						nReg := RECNO()
						nOrden := INDEXORD()
						select RE
						dbsetorder( forder({"FECHA","TURNO"}) )
						dbseek( ftoc(DESDE), .T. )
						cBaseAux:=XNAME("XAUX")
						copy to (cBaseAux) rest for FECHA>=DESDE .and. ascan(aaux,CODCLI)#0 while FECHA<=HASTA
#ifdef SUR
						select 99
						use (cBaseAux) alias X
						append from \SUR2\EST\REM for BETWEEN(FECHA,DESDE,HASTA) .and. ASCAN(aaux,CODCLI)#0
						select 99;	dbclosearea()
#endif
						RECUPAN()
						LISTADOR("REMXCLI")
						select RE
						set order to nOrden
						GO nReg
					endif
				endif
			elseif op == 2
				LISTAR("CCACOB")
			elseif op == 3
				LISTADOR("CCV2")
			elseif op == 4
				op3 = MENUFLASH( 12, 40, 1, .T., "", "x Corredor", "x Cliente")
           lAux:=.F.
           if op3==1
        		lAux:=CORR(,.T.,.T.)
           elseif op3==2
					lAux:=MARCARCLI()
           endif
           if lAux
           	lAux:=QUEFECHA2(15,40)
           endif
           if lAux
*					bLastErr := ErrorBlock()
*					bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
 					begin sequence
					LISTADOR( "INI" )
 					if !SETIMPRESORA("INI");  break(nil);  endif
					DO ICARGA WITH "CCV"
              if op3==1
              	select COR
              	go top
              	do while !COR->(eof())
              		if COR->MARCA==''
								I_CL = UT_largo + 1
								CABEZA( 2 );  I_CL += 2
								?
								? I_esp + "Corr:"+COR->CORREDOR
                 		select CL
                    	go top
                    	do while !CL->(eof())
                    		if CL->CODCORR==COR->CODCORR
										CABEZA( 2 );  I_CL += 2
										?
										? I_esp +"Cli:"+CL->RAZONSOC
                    			select CCV
                          	set order to 1
                    			dbseek( str(CL->CODCLI,flen(CCV->CODCLI))+ftoc(DESDE), .T. )
                          	do while CCV->CODCLI==CL->CODCLI .and. BETWEEN(CCV->FECHA,DESDE,HASTA)
											CABEZA(1);  I_CL += 1
											? I_esp + ARMOLIN(I_cab+1)
                          		skip 1 alias CCV
                          	enddo

           						aRemito := JUNTARFAC("SOLO SIN MARCAR")
           						M->TOTAL  :=0;  aeval( aRemito, {|a| M->TOTAL += if(empty(right(a,1)),val(right(a,11)),0) })
										M->SALDOACUM := CL->SALDOINI + CL->SALDOACUM + M->TOTAL

										CABEZA( 1 );  I_CL += 1
										? I_esp + ARMOLIN(I_cab+2)
                       	endif
                       	skip 1 alias CL
                    	enddo
								for x=1 to UT_largo-I_CL;  ?;  next x
                 	endif
              		skip 1 alias COR
              	enddo
              else
              	select CL
              	go top
                 do while !CL->(eof())
              		if CL->MARCA==''
								CABEZA( 2 );  I_CL += 2
								?
								? I_esp +"Cli:"+CL->RAZONSOC
                    	select CCV
                       set order to 1
                    	dbseek( str(CL->CODCLI,flen(CCV->CODCLI))+ftoc(DESDE), .T. )
                       do while CCV->CODCLI==CL->CODCLI .and. BETWEEN(CCV->FECHA,DESDE,HASTA)
									CABEZA(1);  I_CL += 1
									? I_esp + ARMOLIN(I_cab+1)
                          skip 1 alias CCV
                       enddo
*             			aaux := DEUDAXCLI( CL->CODCLI )
*								M->TOTAL     := aaux[2]+aaux[3]
*								M->SALDOACUM := aaux[1] + M->TOTAL

aRemito := {}
          				aRemito := JUNTARFAC("SOLO SIN MARCAR")
           				M->TOTAL  :=0;  aeval( aRemito, {|a| M->TOTAL += if(empty(right(a,1)),val(right(a,11)),0) })
								M->SALDOACUM := CL->SALDOINI + CL->SALDOACUM + M->TOTAL

								CABEZA( 1 );  I_CL += 1
								? I_esp + ARMOLIN(I_cab+2)
                    endif
                    skip 1 alias CL
						enddo
              endif
              ******************
					RECUPAN()
              break
					end sequence
*					ErrorBlock(bLastErr)
					LISTADOR("FIN")
           endif
***************
			endif
*			RECUPAN()
			CCV->(dbgoto(nReg))
		elseif K == K_ESC
			exit
		endif
	enddo
	if K == K_ESC;  exit;  endif

	M->CODCLI := CL->CODCLI
	M->PIVA1 := M->PIVA2 := 0
	if CL->CATIVA=="RI " .or. CL->CATIVA=="RNI"
		cTIPOFAC = "A"
		XF  = "FAC"
		XF2 = "FAC2"
		FBASES({"-FACBCC","-FACBCC2"})
		FBASES({"+FACACC","+FACACC2"})
		M->PIVA1 = VA->PIVA1
		if CL->CATIVA=="RNI"
			M->PIVA2 = VA->PIVA2
		endif
	else
		cTIPOFAC = "B"
		XF = "FAC"
		XF2 = "FAC2"
		FBASES({"-FACACC","-FACACC2"})
		FBASES({"+FACBCC","+FACBCC2"})
		if CL->CATIVA=="CF "
			M->PIVA1 = VA->PIVA1
		endif
	endif


	MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
	*:
	*: Set‚a las variables y totales por defecto
	*:
	STORE 0 TO M->TPRECBASE, M->PORCDESC, M->TDESCUENTO, M->SUBTOTAL,;
		M->TIMPINT, M->TPIVA1, M->TPIVA2, M->TOTAL, ;
		M->PAGADO, M->EFECTIVO, M->CHEQCAR, M->TARJETA
	M->TIPOVENTA = "2"
	M->FECHVENC = VA->FECHA

	select CCV
	set order to FORDER({"CODCLI","FECHA"})
	dbseek( str(M->CODCLI,FLEN(CCV->CODCLI)), .T. )
	if CCV->CODCLI # M->CODCLI
		select CCV
		F_ALTA( {||CODCLI#0} )
		frlock()
		CCV->NUMCOB   := NUEVOCOD(dbf(),"NUMCOB",CCV_NUMCOB)
		CCV->CODCLI   := M->CODCLI
		CCV->FECHA := DATE()
		SALDARCCV()
	endif

	APAG := NEWEDIT( "PAGOSCCV", .F. )

	RECUPAN()



*	SETCOLOR( "W/N,N/W" )
	SETCOLOR( C_MENU )
	OX := MYBROWSE( 8, 1, 20, 78, aCpo )
	OX:skipBLOCK := { |X| TBWV(X) }
	OX:GOTOPBLOCK	  := { || TBWV(-(LASTREC())) }
	OX:GOBOTTOMBLOCK := { || TBWV(LASTREC()) }
	OX:CARGO[TB_REFRESH] := 10

	MENUDOWN({"  <+>  º   TAB   º     F5      º    F7   º    F9     º    D    º  ESC  ",;
				 "       º remitos º   agrega    º         º recalcula º detalle º       ",;
				 " mueve º a pagar º fech.cierre º imprime º  saldos   º cobros  º  sale "})

	do while .T.
		if CL->RECALCCCV
			RECALCREM( {||CL->RECALCCCV}, .F. )
		endif
		FVERREG( ACC,, .T. )
		MOVBROW( OX, {||nK==9.or.nK==37.or.nK==27.or.nK==-6.or.nK==-4.or.nK==-8.or.nK==-5.or.nK==K_BS.or.CHR(nK)$'FfDd'},, {||FIELD->FECHA>VA->FECHSEG} )

		if OX:Cargo[TB_MSGE] == "MODIF" .and. CCV->FECHA>VA->FECHSEG
			auxtb := FIELD->&(TBNOC(OX))
			if TBNOC(OX) == "NUMCOB"
        else
				frlock()
				FIELD->&(TBNOC(OX)) := OX:CARGO[TB_CONT]
			endif
			SALDARCCV()
			TBPOS(OX)

		elseif CHR(OX:Cargo[TB_RET]) $ "Ff"
			if FIELD->FECHA>VA->FECHSEG
				FACCCV()
				TBPOS(OX)
			endif

		elseif OX:Cargo[TB_RET] == K_F5
			dAux := VA->FECHA
			dAux := INGRval( 10, 20, "Fecha de Cierre", dAux, "", "")
			if lastkey()==K_ENTER .and. dAux>VA->FECHSEG
				OX:GOBOTTOM()
				select CCV
				F_ALTA( {||!empty(CCV->NUMCOB)}, forder({"NUMCOB"}) )
				frlock()
				CCV->NUMCOB  := NUEVOCOD(dbf(),"NUMCOB",CCV_NUMCOB)
				CCV->CODCLI  := M->CODCLI
				CCV->FECHA := dAux
				SALDARCCV()
				TBPOS(OX,.T.)
			endif

		elseif oX:Cargo[TB_RET] == K_BS .and. FIELD->FECHA>VA->FECHSEG
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			if CL->CATIVA=="CF "
				cTIPOFAC := "FB"
				FBASES({"+FACB"})
			else
				cTIPOFAC := "FA"
				FBASES({"+FACA"})
			endif
			aremito := {}; xcant:=0
			dbselectarea( cTIPOFAC )
			set order to FORDER({"CODCLI","NUMCOB"})
			DBSEEK( str(CCV->CODCLI), .T. )
			do while FIELD->CODCLI==CCV->CODCLI .and. !EOF()
				if FIELD->NUMCOB==CCV->NUMCOB
					AADD( aremito, str(FIELD->NUMFAC) +"³"+ DTOC(FIELD->FECHA) +"³"+ str(FIELD->TOTAL,10,3) + "" )
					++xcant
				elseif LEFT(FIELD->NUMCOB,3)=="CCV"
					AADD( aremito, str(FIELD->NUMFAC) +"³"+ DTOC(FIELD->FECHA) +"³"+ str(FIELD->TOTAL,10,3) + " " )
				endif
				skip
			enddo
			select CCV
			ASORT( aremito,,, {|x,y| CTOD(substr(x,10)) < CTOD(substr(y,10)) } )
			RECUPAN()
			if LEN(aremito) == 0
				MENSAJE( 0, 0, 10, .T., "NO HAY FACTURAS !!!" )
			else
				xaux := CCV->TOTAL
				xmenu:=MENUDOWN({"     º ESPACIO  º     F5     º     F6     º  F9    º   ENTER    º ESC  ",;
									  "       º marca y  º   marca    º  desmarca  º recal- º pone saldo º      ",;
									  " mueve º desmarca ºhacia abajo ºhacia abajo º  cula  º en Cta.Cte º sale "})
				ym3 = 7
				xm3 = 45
				RELE := rrel := 0
				modo = 0
				btecla := {|k|k==43.or.k=45.or.k=32.or.k==13.or.K==-8}
				ym33 = ym3 + LEN(aremito) - 1
				ym33 = if( ym33+2>20, 20, ym33 )
				xm33 = xm3+LEN(aremito[1])
				lastcolor = SETCOLOR("+W/N,N/W")
				MARCO( ym3, xm3, ym33, xm33, "FACTURAS", "S", .T. )
				do while .T.
					@ ym33+1, xm3+1 SAY xcant PICT "(999)"
					@ ym33+1, xm33-11 SAY xaux PICT "#######.##"
					e = ACHOICE(ym3, xm3, ym33, xm33, aremito, .T., "achfunc", RELE, Rrel)
					if modo == K_SPACE
						if right(aremito[e],1) = " "
							if CTOD(substr(aremito[e],AT('³',aremito[e])+1,8)) > CCV->FECHA
								MENSAJE( 0, 0, 10, .T., "LA FECHA DE LA FACTURA ES MAYOR", "A LA FECHA DE CIERRE !!!" )
							else
								xaux += val(right(aremito[e],11))
								aremito[e] := LEFT(aremito[e],LEN(aremito[e])-1) + ""
								++xcant
							endif
						else
							xaux -= val(right(aremito[e],11))
							aremito[e] := LEFT(aremito[e],LEN(aremito[e])-1) + " "
							--xcant
						endif
						keyboard CHR(K_DOWN)
					elseif modo == 43
						aux := 0
						FOR i=e TO LEN(aremito)
							if right(aremito[i],1) = " "
								if CTOD(substr(aremito[i],AT('³',aremito[i])+1,8)) > CCV->FECHA
									++aux
								else
									xaux += val(right(aremito[i],11))
									aremito[i] := LEFT(aremito[i],LEN(aremito[i])-1) + ""
									++xcant
								endif
							endif
						NEXT
						if aux > 0
							MENSAJE( 0, 0, 10, .T., "NO SE MARCARON"+ str(aux,5) +" FCATURAS !!!","(FECHA FACTURA MAYOR A FECHA CIERRE)" )
						endif
					elseif modo == 45
						FOR i=e TO LEN(aremito)
							if right(aremito[i],1) == ""
								xaux -= val(right(aremito[i],11))
								aremito[i] := LEFT(aremito[i],LEN(aremito[i])-1) + " "
								--xcant
							endif
						NEXT
					elseif modo == K_F9
						xaux := xcant := 0
						FOR i=1 TO LEN(aremito)
							if right(aremito[i],1) == ""
								xaux += val(right(aremito[i],11))
								++xcant
							endif
						NEXT
					elseif modo == K_ESC .or. modo==K_ENTER
						exit
					endif
				enddo
				if modo == K_ENTER
					MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
					dbselectarea( cTIPOFAC )
					set order to FORDER({"NUMFAC"})
					fflock()
					FOR i=1 TO LEN(aremito)
						if dbseek( val(aremito[i]) )
							aux := if( right(aremito[i],1) == " ", 'CCV', CCV->NUMCOB )
							if FIELD->NUMCOB # aux
								FIELD->NUMCOB := aux
							endif
						endif
					NEXT
					dbunlock()
					select CCV
					frlock()
					CCV->TOTAL := xaux
					CCV->SALDO := CCV->TOTAL - CCV->PAGADO
					SALDARCCV()
					RECUPAN()
				endif
				RECUPAN()
				PONEPAN(xmenu)
				CLEARTYPEAHEAD()
				SETCOLOR(lastcolor)
				oFAC:RefreshAll()
			endif

		elseif OX:Cargo[TB_RET] == K_F7
     	LISTAR("FACTURAS")

		elseif OX:Cargo[TB_RET] == K_TAB
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
			if empty(CCV->NUMCOB);	frlock();  CCV->NUMCOB:=NUEVOCOD("CCV","NUMCOB",CCV_NUMCOB);	dbunlock();  endif
			aremito := JUNTARFAC()
			RECUPAN()
			if LEN(aremito) == 0
				MENSAJE( 0, 0, 10, .T., "NO HAY FACTURAS !!!" )
			else
				xaux := CCV->APAGAR
				xmenu:=MENUDOWN({"     º ESPACIO  º     +      º     -      º   ENTER    º ESC  ",;
									  "       º marca y  º   marca    º  desmarca  º pone saldo º      ",;
									  " mueve º desmarca ºhacia abajo ºhacia abajo º en Cta.Cte º sale "})
				ym3 = 7
				xm3 = 45
				RELE := rrel := 0
				modo = 0
 				if FIELD->FECHA>VA->FECHSEG
					btecla := {|k|k==43.or.k=45.or.k=32.or.k==13}
           else
					btecla := {|k|k==13}
           endif
				ym33 = ym3 + LEN(aremito) - 1
				ym33 = if( ym33+2>20, 20, ym33 )
				xm33 = xm3+LEN(aremito[1])
				lastcolor = SETCOLOR("+W/N,N/W")
				MARCO( ym3, xm3, ym33, xm33, "COMPROBANTES", "S", .T. )
				do while .T.
					xaux := xcant := 0
					FOR i=1 TO LEN(aremito)
						if right(aremito[i],1) == ""
							xaux += val(right(aremito[i],11))
							++xcant
						endif
					NEXT
					@ ym33+1, xm3+1 SAY xcant PICT "(999)"
					@ ym33+1, xm33-11 SAY xaux PICT "#######.##"
					e = ACHOICE(ym3, xm3, ym33, xm33, aremito, .T., "achfunc", RELE, Rrel)
					if modo == K_SPACE
						if right(aremito[e],1) = " "
							if CTOD(substr(aremito[e],AT('³',aremito[e])+1,8)) > CCV->FECHA
								MENSAJE( 0, 0, 10, .T., "LA FECHA DEL COMPROBANTE ES MAYOR", "A LA FECHA DE CIERRE !!!" )
							else
								aremito[e] := LEFT(aremito[e],LEN(aremito[e])-1) + ""
							endif
						else
							aremito[e] := LEFT(aremito[e],LEN(aremito[e])-1) + " "
						endif
						keyboard CHR(K_DOWN)
					elseif modo == 43
						aux := 0
						FOR i=e TO LEN(aremito)
							if right(aremito[i],1) = " "
								if CTOD(substr(aremito[i],AT('³',aremito[i])+1,8)) > CCV->FECHA
									++aux
								else
									aremito[i] := LEFT(aremito[i],LEN(aremito[i])-1) + ""
								endif
							endif
						NEXT
						if aux > 0
							MENSAJE( 0, 0, 10, .T., "NO SE MARCARON"+ str(aux,5) +" COMPROBANTES !!!","(FECHA COMPROBANTE MAYOR A FECHA CIERRE)" )
						endif
					elseif modo == 45
						FOR i=e TO LEN(aremito)
							if right(aremito[i],1) == ""
								aremito[i] := LEFT(aremito[i],LEN(aremito[i])-1) + " "
							endif
						NEXT
					elseif modo == K_ESC .or. modo==K_ENTER
						exit
					endif
				enddo
				if modo == K_ENTER .and. FIELD->FECHA>VA->FECHSEG
					MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
              F_ABASE({"FA","FB"},"CERRAR")
              asort(aRemito)
              z1:="@"
        		for b=1 to len(aRemito)
              	if z1 # cSUCURSAL
              		F_ABASE({XF},"CERRAR")
           			cSUCURSAL:=substr(aRemito[b],4,1)
              		XF:=left(aRemito[b],2)
							#ifdef SUR
								cDir := if( substr(aremito[b],4,1)$"56", "\"+strtran(curdir(),"\EST","2\EST")+"\", "" )
                    #else
                    	cDir :=""
							#endif
              		FBASES({"+"+cDir+if(XF=="FA","FACA","FACB")},.F.)
							select (XF)
							set order to FORDER({"NUMFAC"})
                 endif
						if dbseek( val(substr(aRemito[b],6,8)) )
							aux := if( right(aremito[b],1)==" ", "", CCV->NUMCOB )
							if FIELD->NUMCOB # aux
								frlock()
								FIELD->NUMCOB := aux
							endif
                 endif
					next
					dbunlock()
					select CCV
					frlock()
					CCV->APAGAR := xaux
					CCV->SALDO := CCV->APAGAR - CCV->PAGADO
					SALDARCCV()
					RECUPAN()
 					RECALCREM( {||.T.}, .F. )
				endif
				RECUPAN()
				PONEPAN(xmenu)
				CLEARTYPEAHEAD()
				SETCOLOR(lastcolor)
				OX:RefreshAll()
			endif

		elseif OX:Cargo[TB_RET] == K_TAB
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
			if empty(CCV->NUMCOB);	frlock();  CCV->NUMCOB:=NUEVOCOD("CCV","NUMCOB",CCV_NUMCOB);	dbunlock();  endif
			aremito := {}; xcant:=0
			select RE
			set order to RE_CODCLI_NUMCOB
			dbseek( str(CCV->CODCLI)+CCV->NUMCOB )
			do while RE->NUMCOB==CCV->NUMCOB .and. !eof()
				if RE->CODCLI # -2 .and. RE->TOTAL#0
					AADD( aremito, str(RE->NUMFAC) +"³"+ DTOC(RE->FECHA) +"³"+ str(RE->TOTAL,10,3) + "" )
				endif
				skip
			enddo
			dbseek( str(CCV->CODCLI)+space(len(CCV->NUMCOB)), .T. )
			do while RE->CODCLI==CCV->CODCLI .and. empty(RE->NUMCOB) .and. !eof()
				*			IF RE->CODCLI # -2 .and. RE->TOTAL#0
				if RE->CODCLI==CCV->CODCLI .and. RE->TOTAL#0
					AADD( aremito, str(RE->NUMFAC) +"³"+ DTOC(FIELD->FECHA) +"³"+ str(FIELD->TOTAL,10,3) + " " )
				endif
				skip
			enddo
			select CCV
			ASORT( aremito,,, {|x,y| CTOD(substr(x,10)) < CTOD(substr(y,10)) } )
			RECUPAN()
			if LEN(aremito) == 0
				MENSAJE( 0, 0, 10, .T., "NO HAY COMPROBANTES !!!" )
			else
				xaux := CCV->APAGAR
				xmenu:=MENUDOWN({"     º ESPACIO  º     +      º     -      º   ENTER    º ESC  ",;
									  "       º marca y  º   marca    º  desmarca  º pone saldo º      ",;
									  " mueve º desmarca ºhacia abajo ºhacia abajo º en Cta.Cte º sale "})
				ym3 = 7
				xm3 = 45
				RELE := rrel := 0
				modo = 0
 				if FIELD->FECHA>VA->FECHSEG
					btecla := {|k|k==43.or.k=45.or.k=32.or.k==13}
           else
					btecla := {|k|k==13}
           endif
				ym33 = ym3 + LEN(aremito) - 1
				ym33 = if( ym33+2>20, 20, ym33 )
				xm33 = xm3+LEN(aremito[1])
				lastcolor = SETCOLOR("+W/N,N/W")
				MARCO( ym3, xm3, ym33, xm33, "COMPROBANTES", "S", .T. )
				do while .T.
					xaux := xcant := 0
					FOR i=1 TO LEN(aremito)
						if right(aremito[i],1) == ""
							xaux += val(right(aremito[i],11))
							++xcant
						endif
					NEXT
					@ ym33+1, xm3+1 SAY xcant PICT "(999)"
					@ ym33+1, xm33-11 SAY xaux PICT "#######.##"
					e = ACHOICE(ym3, xm3, ym33, xm33, aremito, .T., "achfunc", RELE, Rrel)
					if modo == K_SPACE
						if right(aremito[e],1) = " "
							if CTOD(substr(aremito[e],AT('³',aremito[e])+1,8)) > CCV->FECHA
								MENSAJE( 0, 0, 10, .T., "LA FECHA DEL COMPROBANTE ES MAYOR", "A LA FECHA DE CIERRE !!!" )
							else
								aremito[e] := LEFT(aremito[e],LEN(aremito[e])-1) + ""
							endif
						else
							aremito[e] := LEFT(aremito[e],LEN(aremito[e])-1) + " "
						endif
						keyboard CHR(K_DOWN)
					elseif modo == 43
						aux := 0
						FOR i=e TO LEN(aremito)
							if right(aremito[i],1) = " "
								if CTOD(substr(aremito[i],AT('³',aremito[i])+1,8)) > CCV->FECHA
									++aux
								else
									aremito[i] := LEFT(aremito[i],LEN(aremito[i])-1) + ""
								endif
							endif
						NEXT
						if aux > 0
							MENSAJE( 0, 0, 10, .T., "NO SE MARCARON"+ str(aux,5) +" COMPROBANTES !!!","(FECHA COMPROBANTE MAYOR A FECHA CIERRE)" )
						endif
					elseif modo == 45
						FOR i=e TO LEN(aremito)
							if right(aremito[i],1) == ""
								aremito[i] := LEFT(aremito[i],LEN(aremito[i])-1) + " "
							endif
						NEXT
					elseif modo == K_ESC .or. modo==K_ENTER
						exit
					endif
				enddo
				if modo == K_ENTER .and. FIELD->FECHA>VA->FECHSEG
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					dbselectarea("RE")
					set order to FORDER({"NUMFAC"})
					fflock()
					FOR i=1 TO LEN(aremito)
						if dbseek( val(aremito[i]) )
							aux := if( right(aremito[i],1) == " ", "", CCV->NUMCOB )
							if FIELD->NUMCOB # aux
								FIELD->NUMCOB := aux
							endif
						endif
					NEXT
					dbunlock()
					select CCV
					frlock()
					CCV->APAGAR := xaux
					CCV->SALDO := CCV->APAGAR - CCV->PAGADO
					SALDARCCV()
					RECUPAN()
 					RECALCREM( {||.T.}, .F. )
				endif
				RECUPAN()
				PONEPAN(xmenu)
				CLEARTYPEAHEAD()
				SETCOLOR(lastcolor)
				OX:RefreshAll()
			endif

		elseif OX:Cargo[TB_RET] == K_F9
			TBWV(-999)
			SALDARCCV()
			TBPOS(OX,.T.)

		elseif OX:Cargo[TB_RET] == K_F6 .and. FIELD->FECHA>VA->FECHSEG
     	CHCCV("INI")
        count to nAux for XCH->ESTADO=="DEP"
        if nAux>0
				MENSAJE(0,0,0,.F.,"hay "+str(nAux,2)+" cheques depositados.")
        else
				if PREGUNTA( 12, " ¨ ESTA SEGURO   [ S / N ] ?", "SsNn") $ "Ss"
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					aaux := {}
					select RE
					set order to RE_CODCLI_NUMCOB
					fflock()
					dbseek(str(CCV->CODCLI)+CCV->NUMCOB )
					do while RE->CODCLI==CCV->CODCLI .and. RE->NUMCOB==CCV->NUMCOB
						RE->NUMCOB := "CCV"
                 skip
					enddo
					select CCV2
					fflock()
					do while dbseek(str(CCV->CODCLI)+CCV->NUMCOB)
						blankreg()
					enddo
					select ccv
					blankreg()
					dbseek(str(CL->CODCLI),.T.)
              if CCV->CODCLI#CL->CODCLI;  RECUPAN();  exit;  endif
					SALDARCCV()
					RECUPAN()
					CLEARTYPEAHEAD()
					OX:REFRESHALL()
           endif
			endif

		elseif chr(OX:Cargo[TB_RET]) $ 'Dd' 	//.and. FIELD->FECHA>VA->FECHSEG
			MENSAJE(0,0,0,.F.,"AGUARDE..." )
			M->EFECTIVO := M->CHEQCAR := M->TARJETA := 0
			select CCV2
			y := 1
			dbseek( CCV->NUMCOB, .T. )
			do while CCV2->NUMCOB==CCV->NUMCOB .and. y<=len(apago)
				apago[y,CCV2_XFECHPAGO] := CCV2->FECHA
				apago[y,CCV2_XTURNO   ] := CCV2->TURNO
				apago[y,CCV2_XEFECTIVO] := CCV2->EFECTIVO
				apago[y,CCV2_XCHEQUE  ] := CCV2->CHEQUE
				apago[y,CCV2_XTARJETA ] := CCV2->TARJETA
				apago[y,CCV2_XNUMREC  ] := CCV2->NUMREC
				apago[y,CCV2_XREGISTRO] := RECNO()
				M->EFECTIVO += apago[y,CCV2_XEFECTIVO]
				M->CHEQCAR	+= apago[y,CCV2_XCHEQUE ]
				M->TARJETA	+= apago[y,CCV2_XTARJETA]
				++y
				skip
			enddo
			aeval( apago, {|a,y| apago[y,CCV2_XFECHPAGO]:=CTOD(''), ;
				apago[y,CCV2_XTURNO]    := " "		  ,;
				apago[y,CCV2_XEFECTIVO] := 0 		  ,;
				apago[y,CCV2_XCHEQUE  ] := 0 		  ,;
				apago[y,CCV2_XTARJETA ] := 0 		  ,;
				apago[y,CCV2_XTARJETA ] := 0        ,;
				apago[y,CCV2_XNUMREC  ] := space(6) ,;
				apago[y,CCV2_XREGISTRO] := 0 		 }, y )
			CHCCV("INI")
			TACCV("INI")
			RECUPAN()
			xmenu:=MENUDOWN({"º  <+>  º   TAB   º  ENTER   º    F9     º ESC  º",;
								  "º       º cheques, º          º           º      º",;
								  "º mueve º tarjetas º confirma º recalcula º sale º"})
			FEDITOR2( APAG, "PONEPAN" )
			FVERREG( APAG,, .T. )
			APAG[ED_REGISTRO] := 0
        APAG[ED_EDIT]:=if( CCV->FECHA>VA->FECHSEG, upper(APAG[ED_EDIT]), lower(APAG[ED_EDIT]) )
			lRecalc:=.T.
			do while .T.
           if lRecalc
					M->CHEQCAR := M->TARJETA := M->EFECTIVO := 0
					AEval(apago, {|a,i| M->EFECTIVO+=apago[i,CCV2_XEFECTIVO],M->CHEQCAR+=apago[i,CCV2_XCHEQUE],M->TARJETA+=apago[i,CCV2_XTARJETA]} )
					APAG[ED_MODE] = "MOSTRARTODO"
					lRecalc:=.F.
           endif
				FEDITAR2( APAG, { K_TAB, K_F9, K_F10 } )
				if APAG[ED_UPDATE]
					lModif:=.T.
					if right(EDNOM(APAG),3) == "," + str(CCV2_XFECHPAGO,1) +"]"
					elseif right(EDNOM(APAG),3) == "," + str(CCV2_XEFECTIVO,1) +"]"
						M->EFECTIVO += &(EDNOM(APAG)) - APAG[ED_LAST]
                 lRecalc:=.T.
					endif
					APAG[ED_MODE] := "MOSTRARTODO"
				elseif APAG[ED_TECLA] == K_TAB
					nPago := val( substr(EDNOM(APAG),7) )
					if empty( apago[nPago,CCV2_XFECHPAGO] )
						MENSAJE( 0, 0, 10, .T., "FALTA LA FECHA DE PAGO !!!" )
					elseif val( apago[nPago,CCV2_XNUMREC] )==0
						MENSAJE( 0, 0, 10, .T., "FALTA N§ RECIBO !!!" )
					else
						if right(EDNOM(APAG),3) == ","+ str(CCV2_XCHEQUE,1) +"]"
							aPago[nPago,CCV2_XCHEQUE] := CHCCV( "ELEGIR", nPago, aPago[nPago,CCV2_XCHEQUE] )
                 	lRecalc:=.T.
						elseif right(EDNOM(APAG),3) == ","+ str(CCV2_XTARJETA,1) +"]"
							aPago[nPago,CCV2_XTARJETA] := TACCV( "ELEGIR", nPago, aPago[nPago,CCV2_XTARJETA] )
                 	lRecalc:=.T.
						endif
						APAG[ED_MODE] = "MOSTRARTODO"
					endif
				elseif APAG[ED_TECLA] == K_ESC
        		if CCV->FECHA>VA->FECHSEG
						cAux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
              	if cAux#"C";  exit;  endif
              else
              	exit
              endif
				elseif APAG[ED_TECLA] == K_F10
           	cAux:= if( CCV->FECHA>VA->FECHSEG,"G", "S" )
					exit
				endif
			enddo
			if cAux=="G"
				select CCV2
				fflock()
				for i=1 to len(apago)
					if apago[i,CCV2_XEFECTIVO]+apago[i,CCV2_XCHEQUE]+apago[i,CCV2_XTARJETA] == 0
						if apago[i,CCV2_XREGISTRO] # 0
							DBGOTO( apago[i,CCV2_XREGISTRO] )
							BLANKREG()
						endif
					else
						if apago[i,CCV2_XREGISTRO] == 0
							F_ALTA({|| FIELD->CODCLI#0})
						else
							DBGOTO( apago[i,CCV2_XREGISTRO] )
						endif
						frlock()
						CCV2->CODCLI	  := CCV->CODCLI
						CCV2->NUMCOB	  := CCV->NUMCOB
						CCV2->FECHA      := apago[i,CCV2_XFECHPAGO]
						CCV2->TURNO      := apago[i,CCV2_XTURNO]
						CCV2->EFECTIVO   := apago[i,CCV2_XEFECTIVO]
						CCV2->CHEQUE	  := apago[i,CCV2_XCHEQUE]
						CCV2->TARJETA	  := apago[i,CCV2_XTARJETA]
						CCV2->NUMREC 	  := apago[i,CCV2_XNUMREC]
					endif
				next
				CHCCV( "GRABAR" )
				TACCV( "GRABAR" )
				select CCV
				frlock()
				CCV->PAGADO := M->EFECTIVO + M->CHEQCAR + M->TARJETA
				dbunlockall()
				dbcommitall()
				SALDARCCV()
			endif
			select CCV
			FEDITOR2( APAG, "SACAPAN" )
			PONEPAN(xmenu)
			dbunlockALL()
			TBPOS(OX,.T.)

		elseif OX:Cargo[TB_RET] == K_ESC
			exit
		endif
	enddo
	dbunlockall()
	dbcommitall()
	RELLENAPAN(8,0,21,80,"°",C_FONDO)

enddo
select CL
SET FILTER TO

RETURN


***************************

FUNC RECALCREM( bBlock, lTodos )

***************************
local cBase:=dbf(), nReg:=recno()
DEFAULT lTodos TO .F.

select CL
if lTodos;  dbgotop();  endif
aBase:={ {"FACA","FA"},;
			 {"FACB","FB"} }
do while !CL->(eof())
	nAux:=0
	for b=1 to len(aBase)
		z1:=DESDE_SUC
  	z2:=HASTA_SUC
  	for z=z1 to z2
  		cSUCURSAL:=str(z,1)
     	XF:=aBase[b,2]
     	F_ABASE({XF},"CERRAR")
     	FBASES({"+"+aBase[b,1]},.F.)
			select (XF)
			set order to FAC_CODCLI_NUMCOB
			dbseek( str(CCV->CODCLI)+"2", .T. )
			do while (XF)->CODCLI==CCV->CODCLI .and. (XF)->TIPOVENTA=="2" .and. val((XF)->NUMCOB)==0 .and. !eof()
				nAux += (XF)->TOTAL
				skip
			enddo
		next z
	next b
  frlock("CL")
	CL->REMAPAGAR := nAux
	CL->RECALCCCV := .F.
  CL->(dbunlock())
  if !lTodos;  exit;  endif
	skip 1 alias CL
enddo
F_ABASE({XF},"CERRAR")
frlock("VA");	VA->RECALCCCV:=.F.
dbunlockall()
select (cBase)
go nReg
cSUCURSAL:=ACTUAL_SUC

return

************

FUNC SALDARCCV

************
LOCAL xreg:=RECNO(), nSaldo

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
fflock()
skip -1
if CCV->CODCLI # M->CODCLI
	GO xreg
endif
if RECNO() == xreg
	FIELD->SALDO := CL->SALDOINI + FIELD->APAGAR - FIELD->PAGADO
	FIELD->SALDOACUM := FIELD->SALDO
endif
nSaldo := FIELD->SALDOACUM
skip
do while CCV->CODCLI == M->CODCLI .and. !EOF()
	FIELD->SALDO := FIELD->APAGAR - FIELD->PAGADO
	FIELD->SALDOACUM := nSaldo + FIELD->SALDO
	nSaldo := FIELD->SALDOACUM
	skip
enddo
DBGOTO( xreg )
frlock("CL");	CL->SALDOACUM:=nSaldo;	CL->(dbunlock())
dbunlock()
RECUPAN()

RETURN .T.


***************************

STATIC FUNCTION TBWV(N)

***************************
LOCAL I := 0

if N == 0 .or. LASTREC() == 0
	skip 0

elseif N > 0 .and. RECNO() != LASTREC() + 1
	do while I < N
		skip 1
		if ( EOF() .or. FIELD->CODCLI # M->CODCLI )
			skip -1
			exit
		endif
		I++
	enddo

elseif N < 0
	do while I > N
		skip -1
		if FIELD->CODCLI # M->CODCLI
			skip
			exit
		elseif BOF()
			exit
		endif
		I--
	enddo

endif

RETURN I


*********************************

FUNC DEUDAXCLI( cualcli, _fecha )

*********************************
LOCAL nSaldoCC := nRemNoMarc:=0, nFacNoMarc:=0, cBase:=dbf(), nOrder
DEFAULT _fecha TO ctod('31/12/2100')

* * *   toma el £ltimo saldo acumulado
select CCV
nOrder := INDEXORD()
set order to CCV_CODCLI_FECHA
seek str(cualcli,FLEN(CCV->CODCLI))
do while CCV->CODCLI==cualcli .and. CCV->FECHA <= _fecha
	nSaldoCC := CCV->SALDOACUM
	skip
enddo
* * *   junta todos los remitos no marcados
select RE
set order to RE_CODCLI_NUMCOB
seek str(cualcli,FLEN(CCV->CODCLI))
do while FIELD->CODCLI==cualcli .and. empty(FIELD->NUMCOB)
	if FIELD->CODCLI # -2 .and. RE->FECHA <= _fecha
		nRemNoMarc += FIELD->TOTAL
	endif
	skip
enddo
**************
#ifdef NADA
	* * *   junta todos las facturas ccv no marcadas
if CL->CATIVA $ "CF EX "
	cTIPOFAC := "FB"
  FBASES({"+FACB"},.F.)
else
	cTIPOFAC := "FA"
	FBASES({"+FACA"},.F.)
endif
select (cTIPOFAC)
set order to FAC_CODCLI_NUMCOB
dbseek( str(cualcli,FLEN(CCV->CODCLI)), .T. )
do while FIELD->CODCLI==cualcli
	if left(FIELD->NUMCOB,3)=='CCV'.and.empty(substr(FIELD->NUMCOB,4))
		nFacNoMarc += FIELD->TOTAL
  endif
	skip
enddo
#endif
**************
select CCV
set order to nOrder
select (cBase)

return( {nSaldoCC, nRemNoMarc, nFacNoMarc} )


*********************************

STATIC FUNC CHCCV( cModo, nPago, nCHEQUE )

*********************************
local cMenu, cMenu2, r
local cBaseAux:=XNAME('XCH')

if cModo=="INI"
	aaux:=CHC->(dbstruct())
	aadd(aaux,{"MARCA2","C",1,0})
	aadd(aaux,{"MODIFICADO","L",1,0})
	aadd(aaux,{"REGISTRO","N",6,0})
	select 99;	dbclosearea()
	dbcreate(cBaseAux,aaux)
	select 99
	use (cBaseAux) alias XCH exclusive
	index on XCH->NUMCOB+ftoc(XCH->FECHEMI) to (cBaseAux)
	select CHC
	set order to CHC_NUMCOB
  CCV2->(dbseek(CCV->NUMCOB))
  do while CCV2->NUMCOB==CCV->NUMCOB .and. !CCV2->(eof())
		CHC->(dbseek( CCV2->NUMCOB ))
		aaux:=CHC->(dbstruct())
		select XCH
		do while CHC->NUMCOB==CCV2->NUMCOB .and. !CHC->(eof())
     	if CHC->NUMREC==CCV2->NUMREC
				append blank
				aeval( aaux, {|a,i| fieldput(i,CHC->(fieldget(i)))} )
				XCH->MARCA := XCH->MARCA2 := ""
				XCH->REGISTRO := CHC->(recno())
        endif
			skip 1 alias CHC
		enddo
     skip 1 alias CCV2
  enddo
  select CHC
	set order to CHC_ESTADO
	dbseek( "CAR" )
  select XCH
	do while CHC->ESTADO == "CAR"
		if (CHC->CODCLI=0 .or. CHC->CODCLI==CCV->CODCLI) .and. empty(CHC->NUMCOB)
			append blank
			aeval( aaux, {|a,i| fieldput(i,CHC->(fieldget(i)))} )
			XCH->MARCA := XCH->MARCA2 := " "
			XCH->REGISTRO := CHC->(recno())
		endif
		skip 1 alias CHC
	enddo

elseif cModo=="ELEGIR"
	aCp:={{ "FECHEMI",	 "Fecha;Emisi¢n", 							'', 'F',  '',	0, 0 },;
			{ "TURNO",		 "T", 											'', 'F',  '',	0, 0 },;
			{ "FVECTOR(vbanco,XCH->CODBAN)", "Banco; ",				'', 'F', 'F',   15, 0 },;
			{ "NUMCHEQ",    "N§de;Cheque",								'', 'F',  '',	0, 0 },;
			{ "MONTO",		 "Monto; ", 									'', 'F',  '',	0, 0 },;
			{ "FECHCOB",	 "Fecha;Efect",								'', 'F',  '',	0, 0 },;
			{ "ESTADO", 	 "EST",											'', 'F',  '',	0, 0 },;
			{ "MARCA",		 "M", 											'', 'F',  '',	0, 0 }}
	select XCH
	aCp := FBASEAUX( aCp, dbf(), select(), .F. )
	set index to
	locate for XCH->NUMREC==aPago[nPago,CCV2_XNUMREC]
	if !found();	append blank;	XCH->NUMREC:=aPago[nPago,CCV2_XNUMREC];  endif
	index on XCH->FECHEMI to (cBaseAux) for XCH->NUMREC==aPago[nPago,CCV2_XNUMREC]
	DBGOBOTTOM()

	cMenu:=MENUDOWN({" <+> º F2 modif. º  F5  º   F6  º ESPACIO  º  +      -  º ENTER  º ESC  ",;
						  "     º F3 busca  º      º       º marca y  ºmarca/desmarº        º      ",;
						  "mueveº F4 busca+ ºagregaºeliminaº desmarca ºhacia abajo ºconfirmaº sale "})
	SETCOLOR(C_MENU)
	MARCO(10,1,17,65," CHEQUES EN CARTERA ", "S", .T., 0 )
	OCH := MYBROWSE(10,1,17,65, aCp )
	OCH:CARGO[TB_REFRESH] := 0
	OCH:GOBOTTOM()
	TBCOLOR(OCH)
	lDispTot:=lRecontar:=.T.
	M->MARCADOS := M->MONTO:=0
	do while .T.
		if lRecontar
			M->MONTO:=0
			FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot:=.T.
			lRecontar:=.F.
		endif
		if lDispTot
			nReg:=recno()
        sum MONTO to M->MONTO for XCH->MARCA==""
     	go nReg
			OTC := OCH:GETCOLUMN( 5 )
			OTC:FOOTING := TRANS(M->MONTO,"#######.##")
			OTC:FOOTSEP := "Ä"
			OCH:SETCOLUMN( 5, OTC )
			lDispTot := .F.
			TBPOS(OCH,.t.)
		endif
		@ 18,55 say "Marc."+str(M->MARCADOS,4) color "+"+C_FONDO
		MOVBROW( OCH, {||nK==K_TAB.or.nK==K_F2.or.nK==K_F5.or.nK==K_F6.or.nK==K_F9.or.nK==K_ESC.or.chr(nK)$" +-".or.nK==K_ENTER.or.nK==K_ALT_F8} )
		if OCH:Cargo[TB_MSGE] == "MODIF"
			frlock()
			FIELD->&(TBNOC(OCH)) := OCH:CARGO[TB_CONT]
			TBPOS(OCH)
		elseif OCH:Cargo[TB_RET]==K_F2 .or. OCH:Cargo[TB_RET]==K_F5
			cMenu2:=MENUDOWN({"     º PgUp PgDown º presione   º  F10   º ESC  ",;
									"       º             º TAB en cam-º graba  º      ",;
									" mueve º    mueve+   º pos con   º y sale º sale "})
			ACHE := NEWEDIT( "CHCAUX" )
			FEDITOR( ACHE, "SETVARS", OCH:Cargo[TB_RET] )
        ACHE[ED_EDIT]:=if( CCV->FECHA>VA->FECHSEG, upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
			ACHE[ED_EDIT] := if( EDCONT(ACHE,"XCH->ESTADO")$"CAR   ", upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
			if empty(EDCONT(ACHE,"XCH->ESTADO"));	EDPONE(ACHE,"XCH->ESTADO","CAR");  endif
			EDPONE(ACHE,"XCH->FECHEMI",aPago[nPago,CCV2_XFECHPAGO])
			EDPONE(ACHE,"XCH->TURNO",aPago[nPago,CCV2_XTURNO])
			ACHE[ED_MODE] := "MOSTRARTODO"
			do while .T.
				FEDITAR( ACHE, { 9, K_F10 } )
				if ACHE[ED_UPDATE]
					ACHE[ED_MODE] = "MOSTRAR"
					if EDNOM(ACHE) == "XCH->FECHACOB"
              	if EDCONT(ACHE,"XCH->FECHCOB")<EDCONT(ACHE,"XCH->FECHEMI")
							MENSAJE(0,0,10,.T., "LA FECHA DE EFECTIVIZACION","DEBE SER MAYOR O IGUAL A LA DE EMISION !" )
							EDPONE(ACHE,,ACHE[ED_LAST])
                    ACHE[ED_TECLA]:=0
                 endif
              endif
				elseif ACHE[ED_TECLA] == K_TAB
					ACHE[ED_MODE] = "MOSTRAR"
					if EDNOM(ACHE) == "XCH->CODBAN"
						e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbanco', EDCONT(ACHE), 'BANCOS')
						if LASTKEY() == K_ENTER
							EDPONE(ACHE,,LEFT( vbanco[e], 3 ))
						endif
					elseif EDNOM(ACHE) == "XCH->TURNO"
						e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, aturno, EDCONT(ACHE), "", "S", .T.)
						if LASTKEY() == K_ENTER
							EDPONE(ACHE,,LEFT(aturno[e],1))
						endif
						RECUPAN()
					endif
				elseif ( ACHE[ED_TECLA]==K_ENTER .and. ACHE[ED_I]==LEN(ACHE[ED_FIELDS]) ) .or. ACHE[ED_TECLA]==K_ESC .or. ACHE[ED_TECLA]==K_F10
					if ACHE[ED_TECLA]==K_F10
						cAux:="G"
					elseif FEDITOR( ACHE, "HUBOCAMBIOS" )
						cAux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					endif
					if cAux=="G"
						set order to
						if "AGRE" $ ACHE[ED_MODAPP]
							locate for empty(XCH->FECHEMI) .and. !eof()
							ACHE[ED_REGISTRO] := if(found(), recno(),lastrec()+1)
						endif
						FEDITOR( ACHE, "GRABAR", .F. )
						XCH->MODIFICADO := .T.
						XCH->NUMREC	 := aPago[nPago,CCV2_XNUMREC]
						if "AGRE" $ ACHE[ED_MODAPP]
							XCH->MARCA:=''
						endif
						set order to 1
						reindex
						M->MONTO:=0;  FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
						lDispTot := .T.
						exit
					elseif cAux == "S"
						exit
					endif
				endif
				dbunlock()
			enddo
			FEDITOR2( ACHE, "SACAPAN" )
			PONEPAN(cMenu2)
			TBPOS(OCH,.T.)
		elseif OCH:Cargo[TB_RET]==K_F9
			lRecontar := .T.
			TBPOS(OCH,.T.)
		elseif chr(OCH:Cargo[TB_RET])$" +-"
			FMARCA( OCH:Cargo[TB_RET], "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot := .T.
			TBPOS(OCH,.T.)
		elseif OCH:Cargo[TB_RET] == K_F6 .and. XCH->ESTADO$"CAR   "
			if UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
				BLANKREG(.F.,{"NUMCOB","NUMREC","REGISTRO","MODIFICADO"})
				lRecontar := .T.
				TBPOS(OCH,.T.)
			endif
		elseif OCH:Cargo[TB_RET]==K_ALT_F8
			if !empty(FIELD->NUMCOB)
				MENSAJE( 0, 0, 10, .T., "ESTA MARCADO CON COBRO "+FIELD->NUMCOB )
        else
        	nAux:=CL->(recno())
				if FELEGIR("CLI") # 0
           	FIELD->CODCLI := CL->CODCLI
           endif
           CL->(dbgoto(nAux))
        endif
		elseif OCH:Cargo[TB_RET] == K_ESC
			replace XCH->MARCA with XCH->MARCA2 all
			r := nCHEQUE
			exit
		elseif OCH:Cargo[TB_RET] == K_ENTER
			replace XCH->MARCA2 with XCH->MARCA all
			lModifCh:=(nCHEQUE#M->MONTO)
			r := M->MONTO
			exit
		endif
	enddo
	RECUPAN()
	PONEPAN(cMenu)
	dbunlockall()
	dbcommitall()

elseif cModo=="GRABAR"
	select XCH
	dbgotop()
	select CHC
	do while !XCH->(eof())
		if XCH->MONTO==0
			if XCH->REGISTRO#0
				dbgoto(XCH->REGISTRO);	blankreg()
			endif
		else
     	if empty(XCH->MARCA)
				if XCH->REGISTRO#0
					dbgoto(XCH->REGISTRO)
					frlock()
					CHC->NUMCOB := ""
				endif
        else
				if XCH->REGISTRO#0
					dbgoto(XCH->REGISTRO)
				else
					F_ALTA({||!empty(CHC->NUMCOB)})
				endif
				frlock()
				aeval(dbstruct(),{|a,i|fieldput(i,XCH->(fieldget(i)))})
				CHC->CODCLI := CCV->CODCLI
				CHC->NUMCOB := CCV->NUMCOB
        endif
		endif
		skip 1 alias XCH
  enddo
	dbunlockall()
  dbcommitall()

elseif cModo=="CHEQUES"
	select CHC
	set order to CHC_NUMREC
	dbseek( str(CCV->CODCLI)+CCV->NUMCOB )

endif

return r


*********************************

STATIC FUNC TACCV( cModo, nPago, nTARJETA )

*********************************
local cMenu, cMenu2, r
local cBaseAux:=XNAME('XTA')

if cModo=="INI"
	aaux:=TA->(dbstruct())
	aadd(aaux,{"MARCA2","C",1,0})
	aadd(aaux,{"MODIFICADO","L",1,0})
	aadd(aaux,{"REGISTRO","N",6,0})
	select 98;	dbclosearea()
	dbcreate(cBaseAux,aaux)
	select 98
	use (cBaseAux) alias XTA exclusive
	index on XTA->NUMREC to (cBaseAux)
	select TA
	set order to TA_NUMREC
	dbseek( str(CCV->CODCLI)+CCV->NUMCOB )
	aaux:=TA->(dbstruct())
	select XTA
	do while TA->CODCLI==CCV->CODCLI .and. TA->NUMCOB==CCV->NUMCOB .and. !TA->(eof())
		append blank
		aeval( aaux, {|a,i| fieldput(i,TA->(fieldget(i)))} )
		XTA->MARCA := XTA->MARCA2 := ""
		XTA->REGISTRO := TA->(recno())
		skip 1 alias TA
	enddo
  select TA
	set order to TA_ESTADO
	dbseek( "CAR" )
  select XTA
	do while TA->ESTADO == "CAR"
		if TA->CODCLI==CCV->CODCLI .and. empty(TA->NUMCOB)
			append blank
			aeval( aaux, {|a,i| fieldput(i,TA->(fieldget(i)))} )
			XTA->MARCA := XTA->MARCA2 := " "
			XTA->REGISTRO := TA->(recno())
		endif
		skip 1 alias TA
	enddo

elseif cModo=="ELEGIR"
	aCp:={{ "FECHPAGO",	 "Fecha;Emisi¢n", 							'', 'F',  '',	0, 0 },;
			{ "TURNO",		 "T", 											'', 'F',  '',	0, 0 },;
			{ "FVECTOR(vtarjeta,XTA->CODTARJ)", "Tarjeta; ",		'', 'F',  '',	0, 0 },;
			{ "NUMTARJ",    "N§de;Tarjeta",								'', 'F',  '',	0, 0 },;
			{ "MONTO",		 "Monto; ", 									'', 'F',  '',	0, 0 },;
			{ "ESTADO", 	 "EST",											'', 'F',  '',	0, 0 },;
			{ "MARCA",		 "M", 											'', 'F',  '',	0, 0 }}
	select XTA
	aCp := FBASEAUX( aCp, dbf(), select(), .F. )
	set index to
	locate for XTA->NUMREC==aPago[nPago,CCV2_XNUMREC]
	if !found();	append blank;	XTA->NUMREC:=aPago[nPago,CCV2_XNUMREC];  endif
	index on XTA->FECHPAGO to (cBaseAux) for XTA->NUMREC==aPago[nPago,CCV2_XNUMREC]
	DBGOBOTTOM()

	cMenu:=MENUDOWN({" <+> º F2 modif. º  F5  º   F6  º ESPACIO  º  +      -  º ENTER  º ESC  ",;
						  "     º F3 busca  º      º       º marca y  ºmarca/desmarº        º      ",;
						  "mueveº F4 busca+ ºagregaºeliminaº desmarca ºhacia abajo ºconfirmaº sale "})
	SETCOLOR(C_MENU)
	MARCO(10,1,17,65," TARJETAS EN CARTERA ", "S", .T., 0 )
	OTA := MYBROWSE(10,1,17,65, aCp )
	OTA:CARGO[TB_REFRESH] := 0
	OTA:GOBOTTOM()
	TBCOLOR(OTA)
	lDispTot:=lRecontar:=.T.
	M->MARCADOS := M->MONTO:=0
	do while .T.
		if lRecontar
			M->MONTO:=0
			FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot:=.T.
			lRecontar:=.F.
		endif
		if lDispTot
			nReg:=recno()
        sum MONTO to M->MONTO for XTA->MARCA==""
     	go nReg
			OTC := OTA:GETCOLUMN( 5 )
			OTC:FOOTING := TRANS(M->MONTO,"#######.##")
			OTC:FOOTSEP := "Ä"
			OTA:SETCOLUMN( 5, OTC )
			lDispTot := .F.
			TBPOS(OTA,.t.)
		endif
		@ 18,55 say "Marc."+str(M->MARCADOS,4) color "+"+C_FONDO
		MOVBROW( OTA, {||nK==K_TAB.or.nK==K_F2.or.nK==K_F5.or.nK==K_F6.or.nK==K_F9.or.nK==K_ESC.or.chr(nK)$" +-".or.nK==K_ENTER} )
		if OTA:Cargo[TB_MSGE] == "MODIF"
			frlock()
			FIELD->&(TBNOC(OTA)) := OTA:CARGO[TB_CONT]
			TBPOS(OTA)
		elseif OTA:Cargo[TB_RET]==K_F2 .or. OTA:Cargo[TB_RET]==K_F5
			cMenu2:=MENUDOWN({"     º PgUp PgDown º presione   º  F10   º ESC  ",;
									"       º             º TAB en cam-º graba  º      ",;
									" mueve º    mueve+   º pos con   º y sale º sale "})
			ATAR := NEWEDIT( "TARAUX" )
			FEDITOR( ATAR, "SETVARS", OTA:Cargo[TB_RET] )
        ATAR[ED_EDIT]:=if( CCV->FECHA>VA->FECHSEG, upper(ATAR[ED_EDIT]), lower(ATAR[ED_EDIT]) )
			ATAR[ED_EDIT] := if( EDCONT(ATAR,"XTA->ESTADO")$"CAR   ", upper(ATAR[ED_EDIT]), lower(ATAR[ED_EDIT]) )
			if empty(EDCONT(ATAR,"XTA->ESTADO"));	EDPONE(ATAR,"XTA->ESTADO","CAR");  endif
			EDPONE(ATAR,"XTA->FECHPAGO",aPago[nPago,CCV2_XFECHPAGO])
			EDPONE(ATAR,"XTA->TURNO",aPago[nPago,CCV2_XTURNO])
			ATAR[ED_MODE] := "MOSTRARTODO"
			do while .T.
				FEDITAR( ATAR, { 9, K_F10 } )
				if ATAR[ED_UPDATE]
					ATAR[ED_MODE] = "MOSTRAR"
					if EDNOM(ATAR) == "XTA->FECHA"
              endif
				elseif ATAR[ED_TECLA] == K_TAB
					ATAR[ED_MODE] = "MOSTRAR"
					if EDNOM(ATAR) == "XTA->CODTARJ"
						e = ABRW( ATAR[ED_Y], ATAR[ED_X], 0, 'vtarjeta', EDCONT(ATAR), 'TARJETAS')
						if LASTKEY() == K_ENTER
							EDPONE(ATAR,,LEFT( vtarjeta[e], 3 ))
						endif
					elseif EDNOM(ATAR) == "XTA->TURNO"
						e = PP_SELEC( ATAR[ED_Y], ATAR[ED_X], 0, 0, aturno, EDCONT(ATAR), "", "S", .T.)
						if LASTKEY() == K_ENTER
							EDPONE(ATAR,,LEFT(aturno[e],1))
						endif
						RECUPAN()
					endif
				elseif ( ATAR[ED_TECLA]==K_ENTER .and. ATAR[ED_I]==LEN(ATAR[ED_FIELDS]) ) .or. ATAR[ED_TECLA]==K_ESC .or. ATAR[ED_TECLA]==K_F10
					if ATAR[ED_TECLA]==K_F10
						cAux:="G"
					elseif FEDITOR( ATAR, "HUBOCAMBIOS" )
						cAux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					endif
					if cAux=="G"
						set order to
						if "AGRE" $ ATAR[ED_MODAPP]
							locate for empty(XTA->FECHPAGO) .and. !eof()
							ATAR[ED_REGISTRO] := if(found(), recno(),lastrec()+1)
						endif
						FEDITOR( ATAR, "GRABAR", .F. )
						XTA->MODIFICADO := .T.
						XTA->NUMREC	 := aPago[nPago,CCV2_XNUMREC]
						if "AGRE" $ ATAR[ED_MODAPP]
							XTA->MARCA:=''
						endif
						set order to 1
						reindex
						M->MONTO:=0;  FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
						lDispTot := .T.
						exit
					elseif cAux == "S"
						exit
					endif
				endif
				dbunlock()
			enddo
			FEDITOR2( ATAR, "SACAPAN" )
			PONEPAN(cMenu2)
			TBPOS(OTA,.T.)
		elseif OTA:Cargo[TB_RET]==K_F9
			lRecontar := .T.
			TBPOS(OTA,.T.)
		elseif chr(OTA:Cargo[TB_RET])$" +-"
			FMARCA( OTA:Cargo[TB_RET], "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot := .T.
			TBPOS(OTA,.T.)
		elseif OTA:Cargo[TB_RET] == K_F6 .and. TA->ESTADO$"CAR   "
			if UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
				BLANKREG(.F.,{"NUMREC","REGISTRO","MODIFICADO"})
				lRecontar := .T.
				TBPOS(OTA,.T.)
			endif
		elseif OTA:Cargo[TB_RET] == K_ESC
			replace XTA->MARCA with XTA->MARCA2 all
			r := nTARJETA
			exit
		elseif OTA:Cargo[TB_RET] == K_ENTER
			replace XTA->MARCA2 with XTA->MARCA all
			lModifTa:=(nTARJETA#M->MONTO)
			r := M->MONTO
			exit
		endif
	enddo
	RECUPAN()
	PONEPAN(cMenu)
	dbunlockall()
	dbcommitall()

elseif cModo=="GRABAR"
	select XTA
	dbgotop()
	select TA
	do while !XTA->(eof())
		if XTA->MONTO==0
			if XTA->REGISTRO#0
				dbgoto(XTA->REGISTRO);	blankreg()
			endif
		else
			if XTA->REGISTRO#0
				dbgoto(XTA->REGISTRO)
			else
				F_ALTA({||!empty(TA->NUMCOB)})
			endif
			frlock()
			aeval(dbstruct(),{|a,i|fieldput(i,XTA->(fieldget(i)))})
			TA->CODCLI := CCV->CODCLI
			TA->NUMCOB := CCV->NUMCOB
		endif
		skip 1 alias XTA
	enddo

elseif cModo=="TARJETAS"
	select TA
	set order to TA_NUMREC
	dbseek( str(CCV->CODCLI)+CCV->NUMCOB )

endif

return r


******************************

FUNC JUNTARFAC( cModo )

******************************
DEFAULT cModo TO ""
aremito := {}
aDir:={""}
#ifdef SUR
	aDir:={"","\"+strtran(curdir(),"\EST","2\EST")+"\"}
#endif
aBase:={{"FACA","FA"},;
			{"FACB","FB"} }
for d=1 to len(aDir)
	for b=1 to len(aBase)
  	z1:=DESDE_SUC
     z2:=HASTA_SUC
     for z=z1 to z2
     	cSUCURSAL:=str(z,1)
			XF:=aBase[b,2]
        F_ABASE({XF},"CERRAR")
        FBASES({"+"+aDir[d]+aBase[b,1]},.F.)
			select (XF)
			set order to FORDER({"NUMCOB"})
        if cModo # "SOLO SIN MARCAR"
				dbseek( str(CCV->CODCLI)+"2"+CCV->NUMCOB )
				do while (XF)->CODCLI==CCV->CODCLI .and. (XF)->TIPOVENTA=="2" .and. (XF)->NUMCOB==CCV->NUMCOB .and. !eof()
					aadd( aremito, XF+" "+cSUCURSAL+"-"+str((XF)->NUMFAC) +"³"+ dtoc((XF)->FECHA) +"³"+ str((XF)->TOTAL,10,3) + "" )
					skip
				enddo
        endif
        if cModo # "SOLO MARCADO"
			dbseek( str(CL->CODCLI)+"2", .T. )
			do while (XF)->CODCLI==CL->CODCLI .and. (XF)->TIPOVENTA=="2" .and. val((XF)->NUMCOB)==0 .and. !eof() .and. len(aRemito)<1000
				if (XF)->TOTAL#0
					aadd( aremito, XF+" "+cSUCURSAL+"-"+str((XF)->NUMFAC) +"³"+ dtoc((XF)->FECHA) +"³"+ str((XF)->TOTAL,10,3) + " " )
				endif
				skip
			enddo
		endif
		next z
	next b
next d
cSUCURSAL:=ACTUAL_SUC
select CCV
if cModo # "SOLO SIN MARCAR"
	asort( aremito,,, {|x,y| ctod(substr(x,15)) < ctod(substr(y,15)) } )
endif

return aremito

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nReg

if listado == "FACTURAS"
	MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
	aremito := JUNTARFAC()
	RECUPAN()
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
*	DO ICARGA WITH listado
	xaux := xcant := 0
*	CABEZA( 2 );  I_CL += 2
	cAux := str(CL->(RECNO()),4)+"-"+CL->RAZONSOC
  ? cAux
  ? replic("=",len(aremito[1]))
	for i=1 to len(aremito)
  	if !empty(right(aremito[i],1))
*			CABEZA( 1 );  I_CL += 1
  		? aremito[i]
			xaux += val(right(aremito[i],11))
			++xcant
     endif
	next
*	CABEZA( 2 );  I_CL += 2
  ? replic("-",len(aremito[1]))
  ? str(xcant,3)+space(20)+str(xaux,10,2)
  for i=1 to 3
  	?
  next
	I_IMPRIMIO := .T.
	LISTADOR( "FIN" )

		
elseif listado = "CCACOB"
	if MARCARCLI()
		LISTADOR( "INI" )
		DO ICARGA WITH listado
		if !SETIMPRESORA("INI");  break(nil);  endif
		M->TSALDO := M->TREMITOS := M->TFACTURAS := M->TTOTAL := 0
		select CL
     nReg:=recno()
		dbgotop()
		do while !CL->(EOF())
			if CL->MARCA==""
					* * *   junta todas las cuentas no pagas
           aRemito := JUNTARFAC("SOLO SIN MARCAR")
				M->SALDO := CL->SALDOINI + CL->SALDOACUM
				M->REMITOS := 0
           aeval( aRemito, {|a| M->REMITOS += if(empty(right(a,1)),val(right(a,11)),0) })
				M->FACTURAS := 0
				M->TOTAL := M->SALDO + M->REMITOS + M->FACTURAS
				if M->TOTAL != 0
					CABEZA( 2 )
					?
					? I_esp + ARMOLIN(I_cab+1)
					I_CL = I_CL + 2
					TSALDO    += M->SALDO
					TREMITOS  += M->REMITOS
					TFACTURAS += M->FACTURAS
					TTOTAL    += M->TOTAL
				endif
			endif
			skip 1 alias CL
		enddo
		CABEZA( 3 )
		?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		I_CL = I_CL + 3
     select CL
     go nReg
		LISTADOR( "FIN" )
	endif
endif
RECUPAN()

return
