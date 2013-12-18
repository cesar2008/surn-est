LOCAL aCpo, oX, nreg, AX, aux, xmenu, xmenu2, cBase:=DBF()
PARAMETERS cual, lBrowser

#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

DEFAULT lBrowser TO .F.

select EM
nReg:=recno()
set order to 1
if cual # NIL
	r := dbseek( cual )
endif
if !lBrowser
	if r
		r := EM->EMPLEADO
  else
		r := SPACE(LEN(EM->EMPLEADO))
  endif
  SELECT (cBase)
 	RETURN(r)
endif
if eof()
	go top
endif

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
DO CARGAVEC WITH "CATEG", 15

aCpo:={;
	{ "CODEMP",            "C¢d;Empl",                             '', 'F',  '',  0, 0 },;
	{ "EMPLEADO",          "Apellido;Nombre",                      '', 'F',  '',  0, 0 },;
	{ "CODCAT",            "C¢d;Cat",                              '', 'F',  '',  0, 0 } }

FBASES({"+EMPLEADO"},.F.)
SELECT EM
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
IF cual==NIL .OR. EMPTY(cual)
	DBGOTOP()
ELSE
	SEEK cual
ENDIF
RECUPAN()

xmenu:=MENUDOWN({"  <+>  º    F2    º   F5   º  ENTER   º ESC  ",;
			  			"       º          º        º confirma º      ",;
						" mueve º modifica º agrega º elecci¢n º sale "})

SETCOLOR( "W/N,N/W" )
MARCO( 7, 20, 20, 78, "", "S", .T., 0 )
OX := MYBROWSE( 7, 20, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 10


nreg := RECNO()
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_ENTER.OR.nK==K_TAB.OR.nK==K_F12 } )

	IF OX:Cargo[TB_MSGE] == "MODIF"

	ELSEIF OX:Cargo[TB_RET] == K_F2 .OR. OX:Cargo[TB_RET] == K_F5
		xmenu2:=MENUDOWN({"     º   F10   º  ESC   ",;
								"       º graba y º        ",;
								" mueve º  sale   º  sale  "})
		AX := NEWEDIT( "EMP",,.T. )
		FEDITOR( AX, "SETVARS", OX:CARGO[TB_RET] )
		AX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( AX, { K_F10 } )
			IF AX[ED_UPDATE]
				AX[ED_MODE] = "MOSTRAR"
           IF EDNOM(AX) == "EM->CODEMP"
					IF FREPEAT( EDCONT(AX), AX[ED_MODAPP] )
						MENSAJE ( 0, 0, 10, .T.,"CODIGO REPETIDO !!! ")
						EDPONE( AX,, AX[ED_LAST] )
						AX[ED_TECLA] := 0
					ENDIF
					AX[ED_MODE] := "MOSTRARTODO"
           ENDIF
			ELSEIF AX[ED_TECLA] == K_TAB
           IF EDNOM(AX) == "EM->CODCAT"
					aux := ABRW( AX[ED_Y], AX[ED_X], 0, 'vcateg', EDCONT(AX), 'CATEGORIAS')
					IF LASTKEY() == K_ENTER
						EDPONE( AX, "EM->CODCAT", LEFT(vcateg[aux],3) )
					ENDIF
           ELSEIF EDNOM(AX) == "EM->TIPODOC"
					aux = PP_SELEC( AX[ED_Y], AX[ED_X], 0, 0, aTipoDoc, ascan(aTipoDoc,{|a|left(a,3)==EDCONT(AX)}), "", "S", .T. )
              RECUPAN()
					IF LASTKEY() == K_ENTER
						EDPONE( AX,, LEFT(aTipoDoc[aux],3) )
					ENDIF
           ELSEIF EDNOM(AX) == "EM->SEXO"
					aux = PP_SELEC( AX[ED_Y], AX[ED_X], 0, 0, aSexo, ascan(aSexo,{|a|left(a,1)==EDCONT(AX)}), "", "S", .T. )
              RECUPAN()
					IF LASTKEY() == K_ENTER
						EDPONE( AX,, LEFT(aSexo[aux],1) )
					ENDIF
           ELSEIF EDNOM(AX) == "EM->NACIONALID"
					aux = PP_SELEC( AX[ED_Y], AX[ED_X], 0, 0, aNacion, ascan(aNacion,{|a|left(a,1)==EDCONT(AX)}), "", "S", .T. )
              RECUPAN()
					IF LASTKEY() == K_ENTER
						EDPONE( AX,, left(aNacion[aux],1) )
					ENDIF
           ELSEIF EDNOM(AX) == "EM->ESTADOCIV"
					aux = PP_SELEC( AX[ED_Y], AX[ED_X], 0, 0, aEstCiv, ascan(aEstCiv,{|a|left(a,1)==EDCONT(AX)}), "", "S", .T. )
              RECUPAN()
					IF LASTKEY() == K_ENTER
						EDPONE( AX,, left(aEstCiv[aux],1) )
					ENDIF
           ENDIF
				AX[ED_MODE] = "MOSTRARTODO"
			ELSEIF ( AX[ED_TECLA] == K_ENTER .AND. AX[ED_I] == LEN(AX[ED_EDIT]) ) .OR. AX[ED_TECLA]==K_ESC
        	if FEDITOR(AX,"HUBOCAMBIOS")
					cAux:=FEDITOR(AX,"GRABAR",.T.)
              if cAux $ "GS"
						exit
              endif
           else
           	exit
           endif
			ELSEIF AX[ED_TECLA] == K_F10
				FEDITOR(AX,"GRABAR",.F.)
				EXIT
			ENDIF
		ENDDO
		FEDITOR(AX,"SACAPAN")
		MENUDOWN(xmenu2)
 		TBPOS(OX,.T.)

	ELSEIF OX:Cargo[TB_RET] == K_ESC
  	GO nreg
		nreg := 0
     EXIT

	ELSEIF OX:Cargo[TB_RET] == K_ENTER
  	nreg := RECNO()
		EXIT

	ENDIF

ENDDO
RECUPAN()
MENUDOWN(xmenu)
DBSELECTAREA(cBase)

RETURN(OX:Cargo[TB_RET]==K_ENTER)


**************

FUNC CLAVEMP( lBuscar )

**************
local r:=.F., cBase:=dbf()
DEFAULT lBuscar TO .T.

select EM
MARCO( 10, 30, 10, 60, "", "S", .T., 0 )
cAux = ""
do while .t.
	@ 10,30 SAY " INGRESAR CLAVE :" + padr(replic("*",len(cAux)),len(EM->CLAVEMP),' ')
	k = INKEY(0)
	if k = K_BS .and. len(cAux) > 1
  	cAux := left(cAux,len(cAux)-1)
	elseif k=K_ENTER
		if upper(alltrim(cAux))==upper(alltrim(UT_CLAVECER))
 			frlock("EST");  EST->CODEMP:=UT_CLAVECER;  EST->(dbunlock())
     	r := .T.
        exit
     else
     	if lBuscar
				locate for upper(alltrim(cAux))==upper(alltrim(EM->CLAVEMP)) .and. !empty(cAux)
        endif
			if upper(alltrim(cAux))==upper(alltrim(EM->CLAVEMP)) .and. !empty(cAux)
        	cAux := alltrim(EM->EMPLEADO)
        	cAux := if( empty(EM->APODO), substr(cAux,rat(" ",cAux)), cAux )
				MENSAJE( 0, 0, 0, .F., "Hola "+alltrim(cAux)+"." )
     		inkey(1)
           RECUPAN()
  			r := .T.
 				frlock("EST");  EST->CODEMP:=EM->CODEMP;  EST->NIVEL:=EM->NIVEL;  EST->(dbunlock())
           exit
     	else
				MENSAJE( 0, 0, 10, .t., "Clave INCORRECTA !!!" )
        	cAux := ""
  		endif
     endif
	elseif k==K_ESC
  	exit
	endif
  if k > 32
		cAux := left( cAux+upper(chr(k)), len(EM->CLAVEMP) )
  endif
enddo
RECUPAN()
select (cBase)

RETURN r
