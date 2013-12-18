local xmenu, xmenu2, K, lastcolor:=SETCOLOR("W/N,N/W"), lastbase,;
	lastreg, aaux
private EDX

#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

LOGO(.T., " CLIENTES ")
MENSAJE( 0, 0, 0, .F., "AGUARDE . . " )
FBASES({ "CLIENTES", "CORR" }, .F.)
MENUDOWN({ "     º  ENTER   º   F5   º   F6    º   F7    º   TAB   º ESC ",;
				"       º  o  F2   º        º         º         º  elige  º     ",;
				" mueve º modifica º agrega º elimina º imprime º cliente º sale"})
RECUPAN()

select CL
set order to 1
EDX := NEWEDIT( "CLI" )

do while .t.
	k := FVERREG( EDX, {|K|K==K_TAB.OR.K==K_F5.OR.K==K_F6.OR.K==K_F7} )

	if k == K_TAB
		SETCOLOR("W/N,N/W")
		FELEGIR( "CLIENTE" )

	elseif k == K_ENTER .or. K==K_F2 .OR. k == K_F5
		xmenu:= MENUDOWN({"     º PgUp PgDown º presione TAB para obtener una º   ESC    ",;
								"       º             º lista de opciones. (solo fun- º          ",;
								" mueve º    mueve+   º ciona en los campos con  ).  º   sale   "})
		FEDITOR( EDX, "SETVARS", K )
		EDX[ED_MODE] := "MOSTRARTODO"
		IF EDCONT(EDX,"CL->CODCLI") == 0
			EDPONE(EDX,"CL->CODCLI",ULTIMO(dbf(),"CODCLI",1)+1)
		ENDIF
		nSaldoIni:=if(k==K_F5,0,CL->SALDOINI)
		DO WHILE .T.
			FEDITAR( EDX, { K_TAB, K_F10 } )

			IF EDX[ED_UPDATE]
				EDX[ED_MODE] = "MOSTRAR"
				if EDNOM(EDX) == "CL->CUIT" .and. val(EDCONT(EDX))#0
        		if !FCUIT( EDCONT(EDX) )
						MENSAJE( 0, 0, 10, .T., "C.U.I.T. ERRONEO !!!" )
						EDPONE( EDX, "CLA->CUIT", EDX[ED_LAST] )
           		EDX[ED_TECLA] := 0
           	endif
           endif
			elseif EDX[ED_TECLA] == K_TAB
				EDX[ED_MODE] = "MOSTRAR"
				IF EDNOM(EDX) == "CL->CATIVA"
					ele = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, acativa, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(acativa[ele],3))
					ENDIF
					RECUPAN()
				elseif EDNOM(EDX) == "CL->BANCO"
					ele = ABRW( EDX[ED_Y], EDX[ED_X], 0, 'vbanco', EDCONT(EDX), 'BANCOS')
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(vbanco[ele],3))
					ENDIF
				elseif EDNOM(EDX) $ "CL->LOCALIDAD CL->CODPOS"	//.AND.1==2
					IF CP( EDCONT(EDX,"CL->LOCALIDAD") )
						EDPONE(EDX,"CL->LOCALIDAD",CP->LOCALIDAD)
						EDPONE(EDX,"CL->CODPOS",CP->CODPOS)
						EDX[ED_MODE] = "MOSTRARTODO"
					ENDIF
				elseif "CODPROD" $ EDNOM(EDX)
					IF FELEGIR( "PRODUCTO", EDCONT(EDX) ) # 0
						EDPONE(EDX,,PRD->CODPROD)
					ENDIF
				elseif EDNOM(EDX) == "CL->TARJETA"
					ele = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, vtarjeta, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(vtarjeta[ele],3))
					ENDIF
					RECUPAN()
				elseif EDNOM(EDX) == "CL->CODCORR"
					IF CORR(EDCONT(EDX),.T.)
						EDPONE(EDX,,COR->CODCORR)
					ENDIF
				elseif EDNOM(EDX) == "CL->CODPLAN"
					IF PC( EDCONT(EDX), .T. )
						EDPONE(EDX,,PC->CODPLAN)
					ENDIF
				ENDIF

			elseif EDX[ED_TECLA]==K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .or. EDX[ED_TECLA]==K_F10
        	aux := "S"
				if EDX[ED_TECLA]==K_F10
           	aux := "G"
				elseif FEDITOR( EDX, "HUBOCAMBIOS" )
					aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
           endif
				if aux == "G"
					if EMPTY(EDCONT(EDX,"CL->RAZONSOC"))
						MENSAJE( 0, 0, 10, .T., "DATOS INCOMPLETOS !!!" )
					elseif VAL(EDCONT(EDX,"CL->CUIT"))==0
						MENSAJE( 0, 0, 10, .T., "FALTA C.U.I.T. !!!" )
					else
						FEDITOR( EDX, "GRABAR", .F. )
						select CL
						frlock();  CL->FECHMODIF:=date();	dbunlock()
						if nSaldoIni#CL->SALDOINI
							M->CODCLI:=CL->CODCLI
							CL->RECALCCCV:=.T.
							FBASES({"+CCV"})
							dbseek(str(CL->CODCLI),.T.)
							SALDARCCV()
							select CL
						endif
						EXIT
					ENDIF
				elseif aux == "S"
					EXIT
				endif
			endif
		ENDDO
		PONEPAN(xmenu)

	elseif K == K_F6
		IF PREGUNTA( 12, "¨ ESTAS SEGURO DE ELIMINARLO  [ S / N ]", "SsNn") $ "Ss"
			BLANKREG(.T.)
			DBGOTOP()
		ENDIF

	elseif K == K_F7
		nReg:=RECNO()
		LISTADOR("CLIENTES")
		GO nReg

	elseif K == K_ESC
		exit

	endif
enddo
FEDITOR( EDX, "SACAPAN" )

setcolor(lastcolor)

return nil


*************

FUNC CLA( k )

*************
local aux, EDX, xmenu

xmenu:=MENUDOWN({"     º presione TAB para º  F10  º  ESC   ",;
						"       º obtener una lista º       º        ",;
						" mueve º de Cat.IVA y Loc. º graba º  sale  "})
select CLA
set order to 1
EDX := NEWEDIT( "CLA" )
if K == K_F5
	SET ORDER TO FORDER({"RAZONSOCIAL"})
	seek space(len(CLA->RAZONSOC))
	EDX[ED_REGISTRO] := IF( FOUND(), RECNO(), LASTREC()+1 )
	FEDITOR( EDX, "SETVARS", K, .F. )
	if val(cCLIENTE) == 0
		EDPONE(EDX,"CLA->RAZONSOC",cCLIENTE)
	else
		EDPONE(EDX,"CLA->CUIT",ALLTRIM(cCLIENTE))
	endif

	set order to 1
	bAux := .F.
  if !dbseek(VA->CODCLI,.F.)
		dbgotop()
  endif
	locate for CODCLI>0 rest
	aux=CLA->CODCLI
	do while !eof()
    	if CLA->CODCLI<>aux
     	bAux := !eof()
     	EXIT
    	endif
     do while CLA->CODCLI=aux .and. !eof()
       	skip
     enddo
    	aux=aux+1
	enddo
  if bAux
		EDPONE(EDX,"CLA->CODCLI",aux)
     frlock("VA")
     VA->CODCLI := aux
     VA->(dbunlock())
  else
		EDPONE(EDX,"CLA->CODCLI",ULTIMO(dbf(),"CODCLI",1)+1)
  endif
else
	EDX[ED_REGISTRO] := RECNO()
	FEDITOR( EDX, "SETVARS", K, .F. )
endif
EDX[ED_MODE] = "MOSTRARTODO"
if EDCONT(EDX,"CLA->CODCLI") == 0
#ifdef NADA
	nAux := ULTIMO(dbf(),"CODCLI",1)+1
	if VA->SUCURSAL=="2"
		nAux := ULTIMO(dbf(),"CODCLI",1)+1
		if nAux < 5000
			nAux := 5000
		endif
	else
		if dbseek(5000)
			nAux := CLA->CODCLI
			do while nAux>=5000 .and. !bof()
				nAux := CLA->CODCLI
				skip -1
			enddo
		else
			dbgobottom()
			nAux := CLA->CODCLI
		endif
		++nAux
	endif
	EDPONE(EDX,"CLA->CODCLI",nAux)
#else
*	EDPONE(EDX,"CLA->CODCLI",ULTIMO(dbf(),"CODCLI",1)+1)
#endif
endif

do while .t.
	FEDITAR( EDX, { K_F10 } )
	IF EDX[ED_UPDATE]
		EDX[ED_MODE] = "MOSTRARTODO"
		if EDNOM(EDX) == "CLA->CUIT" .and.val(EDCONT(EDX))#0
        if !FCUIT( EDCONT(EDX) )
				MENSAJE( 0, 0, 10, .T., "C.U.I.T. ERRONEO !!!" )
				EDPONE( EDX, "CLA->CUIT", EDX[ED_LAST] )
           EDX[ED_TECLA] := 0
     	else
				nOrder := indexord()
				set order to FORDER({"CUIT"})
				if FREPEAT( EDCONT(EDX,"CLA->CUIT"), EDX[ED_MODAPP] )
					MENSAJE( 0, 0, 10, .T., "C.U.I.T. YA REGISTRADO !!!" )
					EDPONE( EDX, "CLA->CUIT", EDX[ED_LAST] )
				endif
				set order to nOrder
     	endif
		endif
	elseif EDX[ED_TECLA] == K_TAB
		IF EDNOM(EDX) == "CLA->CATIVA"
			ELE = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, ACATIVA, EDCONT(EDX), "", "S", .T.)
			RECUPAN()
			IF LASTKEY() == K_ENTER
				EDPONE( EDX, , LEFT(acativa[ele],3) )
			ENDIF
		elseif EDNOM(EDX) $ "CLA->LOCALIDAD CLA->CODPOS"	//.AND.1==2
			IF CP( EDCONT(EDX,"CLA->LOCALIDAD") )
				EDPONE(EDX,"CLA->LOCALIDAD",CP->LOCALIDAD)
				EDPONE(EDX,"CLA->CODPOS",CP->CODPOS)
				EDX[ED_MODE] = "MOSTRARTODO"
			ENDIF
		elseif "CODPROD" $ EDNOM(EDX)
			IF FELEGIR( "PRODUCTO", EDCONT(EDX) ) # 0
				EDPONE(EDX,,PRD->CODPROD)
			ENDIF
		elseif EDNOM(EDX) == "CLA->CODPLAN"
			IF PC( EDCONT(EDX), .T. )
				EDPONE(EDX,,PC->CODPLAN)
			ENDIF
		ENDIF
		EDX[ED_MODE] = "MOSTRARTODO"
	elseif EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
		aux := "S"
		IF EDX[ED_TECLA] == K_F10
			aux := "G"
		elseif FEDITOR( EDX, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
		ENDIF
		IF aux == "G"
			IF EMPTY(EDCONT(EDX,"CLA->RAZONSOC"))
				MENSAJE( 0, 0, 10, .T., " FALTA LA RAZON SOCIAL !!!" )
			elseif ascan(aCatIva,{|a|left(a,3)==EDCONT(EDX,"CLA->CATIVA")})==0
				MENSAJE( 0, 0, 10, .T., "CATEGORIA DE IVA INCORRECTA !!!" )
			elseif VAL(EDCONT(EDX,"CLA->CUIT")) == 0
				MENSAJE( 0, 0, 10, .T., "FALTA C.U.I.T.!!!" )
			ELSE
				FEDITOR( EDX, "GRABAR", .F. )
				frlock()
				CLA->FECHMODIF:=date()
				dbunlock()
				exit
			ENDIF
		elseif aux == "S"
			exit
		endif
	endif
enddo
FEDITOR(EDX,"SACAPAN")
MENUDOWN(xmenu)

RETURN ( aux=="G" )
