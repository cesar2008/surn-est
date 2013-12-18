PARAMETERS _fecha, _turno
LOCAL aaux, aa

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"



MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
FBASES({ "+REM", "+PLAN", "+PLAN2", "+..\LB\CHEQCAR", "+TARJETAS", "+CCV2" }, .F.)

SETIMPRESORA("INI","")
? _fecha, "     ", FARRAY(aturno,_turno)
				
		***   suma los Remitos   ***
ENCABEZADO( "REMITOS", 80 )
aaux := {}
SELECT RE
DBSETORDER( FORDER({"FECHA","TURNO"}) )
n1 := VAL(_turno)
n2 := IF( "SUR" $ CURDIR() .AND. _turno == "3", ++n1, n1 )
FOR i=n1 TO n2
	dff := _fecha + i
  ctt := STR(VAL(_turno)+1,1)
	SEEK FTOC(dff) + ctt
	DO WHILE FIELD->FECHA == dff .AND. FIELD->TURNO==ctt
		AADD( aaux, { FIELD->CODCLI, FIELD->FECHA, FIELD->TURNO, FIELD->TIPOREM, FIELD->NUMFAC, FIELD->TOTAL } )
		SKIP
	ENDDO
ENDIF
IF LEN(aaux) == 0
	? "* * *    NO HAY REMITOS   * * *"
ELSE
	ASORT( aaux,,,{|x,y| x[1] <y[1] } )
	xant:=xtot:=xcant:=xtcant:=xttot:=0
	aa := {}
	FOR i=1 TO LEN(aaux)
		IF aaux[i,1] # xant
  		IF xant # 0
				AADD(aa,       "|-----------+----------|")
				AADD(aa, USING("|cant:üüü   |üüüüüüü.üü|",{xcant,xtot}) )
        	AADD(aa,       "========================")
        	AADD(aa,       "                        ")
			ENDIF
			AADD(aa,          "========================")
			AADD(aa,          "|                      |")
			AADD(aa, STRINSTR("|                      |", ALLTRIM(FCLI(aaux[i,1])) ))
			AADD(aa,          "|                      |")
			AADD(aa,          "|----------------------|")
			AADD(aa,          "|T|Remito   |Importe   |")
			AADD(aa,          "|-+---------+----------|")
			xant:=aaux[i,1]; xtot := 0; xcant := 0
		ENDIF
		AADD(aa,USING(       "|ƒ|ƒüüüüüüüü|üüüüüüü.üü|",{aaux[i,3],aaux[i,4],aaux[i,5],aaux[i,6]}) )
  	xtot += aaux[i,6]; ++xcant
  	xttot += aaux[i,6]; ++xtcant
	NEXT
	AADD(aa,       "|-----------+----------|")
	AADD(aa, USING("|cant:üüü   |üüüüüüü.üü|",{xcant,xtot}) )
	AADD(aa,       "========================")
	AADD(aa,       "                       ")
	AADD(aa,       "***********************")
	AADD(aa, USING("*Total üüü  *üüüüüüü.üü",{xtcant,xttot}))
	AADD(aa,       "***********************")
	aux := INT( LEN(aa) / 3 )
	FOR i=1 TO aux
		? aa[i] +SPACE(4)+ aa[i+aux] +SPACE(4)+ aa[i+aux*2]
	NEXT
	FOR i=aux*3+1 TO LEN(aa)
		? SPACE(LEN(aa[1])) +SPACE(4)+ SPACE(LEN(aa[1])) +SPACE(4)+ aa[i]
	NEXT
ENDIF
				


	* * *  suma las planillas
ENCABEZADO( "RESUMEN PLANILLAS", 80 )
aaux := {}
SELECT PL2
DBSETORDER( FORDER({"FECHA","TURNO"}) )
SEEK FTOC(_fecha) + _turno
DO WHILE PL2->FECHA == _fecha .AND. PL2->TURNO == _turno
	FPRODUCTO(FIELD->CODPROD)
	i := ASCAN( aaux, {|a| a[1]==NGRUPO } )
	IF i == 0
		AADD( aaux, { NGRUPO, FGRUPO(NGRUPO), 0, 0 } )
		i := LEN(aaux)
  ENDIF
	aaux[i,3] += FIELD->CANTIDAD
	aaux[i,4] += FIELD->IMPORTE
	SKIP
ENDDO
ASORT( aaux,,,{|x,y| x[1] < y[1]} )
x1 := xtot := 0
?         "============================================"
?         "|Descripci¢n         |Cantidad  |Importe   |"
?         "|--------------------+----------+----------|"
FOR i=1 TO LEN(aaux)
	? USING("|ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ|üüüüüü.üüü|üüüüüü.üüü|",{aaux[i,2],aaux[i,3],aaux[i,4]})
  x1 += aaux[i,3];  xtot += aaux[i,4]
NEXT
?         "|--------------------+----------+----------|"
?   USING("|Total               |üüüüüü.üüü|üüüüüü.üüü|",{x1,xtot} )
?         "============================================"

x1 := x2 := 0
aaux := {}
SELECT PL2
DBSETORDER( FORDER({"FECHA","TURNO"}) )
SEEK FTOC(_fecha) + _turno
DO WHILE PL2->FECHA == _fecha .AND. PL2->TURNO == _turno
	IF FIELD->CANTIDAD # 0
		i := ASCAN( aaux, {|a| a[1]==FIELD->CODPROD.AND.a[2]==FIELD->SURTIDOR } )
		IF i == 0
			AADD( aaux, { FIELD->CODPROD, FIELD->SURTIDOR, FIELD->DESCPROD, FIELD->ABRIO, 0, 0, 0 } )
			i := LEN(aaux)
  	ENDIF
		aaux[i,5] += FIELD->CERRO
		aaux[i,6] += FIELD->CANTIDAD
		aaux[i,7] += FIELD->IMPORTE
  	x2 += FIELD->IMPORTE
  ENDIF
	SKIP
ENDDO
ASORT( aaux,,,{|x,y| IF(x[2]==0,99,x[2]) < IF(y[2]==0,99,y[2])} )
?         "==========================================================================="
?         "|Surt|Descripci¢n         |Abri¢       |Cerr¢       |Cantidad  |Importe   |"
?         "|----+--------------------+------------+------------+----------+----------|"
FOR i=1 TO LEN(aaux)
	? USING("| üü |ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ|üüüüüüüü.üüü|üüüüüüüü.üüü|üüüüüü.üüü|üüüüüü.üüü|",{aaux[i,2],aaux[i,3],aaux[i,4],aaux[i,5],aaux[i,6],aaux[i,7]})
NEXT
?         "|--------------------------------------------------------------+----------|"
? USING(  "|                                                              |üüüüüü.üüü|",{x2})
?         "==========================================================================="



	* * *  suma los cheques
ENCABEZADO( "CHEQUES", 80 )
aaux := {}
SELECT CH
DBSETORDER( FORDER({"FECHEMI","TURNO"}) )
SEEK FTOC(_fecha) + _turno
DO WHILE FIELD->FECHEMI == _fecha .AND. FIELD->TURNO==_turno
	AADD( aaux, { FIELD->TURNO, FIELD->BANCO, FIELD->NUMCHEQUE, FIELD->MONTO } )
	SKIP
ENDDO
IF LEN(aaux) == 0
	? "* * *    NO HAY CHEQUES   * * *"
ELSE
	ASORT( aaux,,,{|x,y| x[1]+x[2] <y[1]+y[2] } )
	xant:= ""
	xtot:=xcant:=xtcant:=xttot:=0
	aa := {}
	FOR i=1 TO LEN(aaux)
		IF aaux[i,2] # xant
  		IF xant # ''
				AADD(aa,       "|----------------+----------|")
				AADD(aa, USING("|cant:üüü        |üüüüüüü.üü|",{xcant,xtot}) )
				AADD(aa,       "=============================")
        	AADD(aa,       "                             ")
			ENDIF
			AADD(aa,          "=============================")
			AADD(aa,          "|                           |")
			AADD(aa, STRINSTR("|                           |",ALLTRIM(aaux[i,2]) ))
			AADD(aa,          "|                           |")
			AADD(aa,          "|---------------------------|")
			AADD(aa,          "|T|n§ Cheque     |Monto     |")
			AADD(aa,          "|-+--------------+----------|")
			xant:=aaux[i,2]; xtot := 0; xcant := 0
		ENDIF
  	AADD(aa, USING(      "|ƒ|ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ|üüüüüüü.üü|", {aaux[i,1],aaux[i,3],aaux[i,4]}) )
  	xtot += aaux[i,4]; ++xcant
  	xttot += aaux[i,4]; ++xtcant
	NEXT
	AADD(aa,                "|----------------+----------|")
	AADD(aa, USING(         "|cant:üüü        |üüüüüüü.üü|",{xcant,xtot}) )
	AADD(aa,                "=============================")
	AADD(aa,                "                             ")
	AADD(aa,                "*****************************")
	AADD(aa, USING(         "*Total: üüü      *üüüüüüü.üü*",{xtcant,xttot}) )
	AADD(aa,                "*****************************")
		aux := INT( LEN(aa) / 2 )
		FOR i=1 TO aux
			? aa[i] +SPACE(5)+ aa[i+aux]
		NEXT
		FOR i=aux*2+1 TO LEN(aa)
			? SPACE(LEN(aa[1])) +SPACE(5)+ aa[i]
		NEXT
ENDIF



	* * *  suma las tarjetas
ENCABEZADO( "TARJETAS", 80 )
aaux := {}
SELECT TA
DBSETORDER( FORDER({"FECHEMI","TURNO"}) )
SEEK FTOC(_fecha) + _turno
DO WHILE FIELD->FECHEMI == _fecha .AND. FIELD->TURNO == _turno
	AADD( aaux, { FIELD->TURNO, FIELD->CODTARJ, FIELD->NUMTARJ, FIELD->MONTO } )
	SKIP
ENDDO
IF LEN(aaux) == 0
	? "* * *    NO HAY TARJETAS   * * *"
ELSE
	ASORT( aaux,,,{|x,y| x[1]+x[2] < y[1]+y[2] } )
	xant:=""
	xtot:=xcant:=xtcant:=xttot:=0
	aa := {}
	FOR i=1 TO LEN(aaux)
		IF aaux[i,2] # xant
  		IF xant # ""
				AADD(aa,       "|----------------+----------|")
				AADD(aa, USING("|cant:üüü        |üüüüüüü.üü|",{xcant,xtot}) )
				AADD(aa,       "=============================")
        	AADD(aa,       "                             ")
			ENDIF
			AADD(aa,          "=============================")
			AADD(aa,          "|                           |")
			AADD(aa, STRINSTR("|                           |",ALLTRIM(aaux[i,2]) ))
			AADD(aa,          "|                           |")
			AADD(aa,          "|---------------------------|")
			AADD(aa,          "|T|n§ Tarjeta    |Monto     |")
			AADD(aa,          "|-+--------------+----------|")
			xant:=aaux[i,2]; xtot := 0; xcant := 0
		ENDIF
  	AADD(aa, USING(      "|ƒ|ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ|üüüüüüü.üü|", {aaux[i,1],aaux[i,3],aaux[i,4]}) )
  	xtot += aaux[i,4]; ++xcant
  	xttot += aaux[i,4]; ++xtcant
	NEXT
	AADD(aa,                "|----------------+----------|")
	AADD(aa, USING(         "|cant:üüü        |üüüüüüü.üü|",{xcant,xtot}) )
	AADD(aa,                "=============================")
	AADD(aa,                "                             ")
	AADD(aa,                "*****************************")
	AADD(aa, USING(         "*Total: üüü      *üüüüüüü.üü*",{xtcant,xttot}) )
	AADD(aa,                "*****************************")
		aux := INT( LEN(aa) / 2 )
		FOR i=1 TO aux
			? aa[i] +SPACE(5)+ aa[i+aux]
		NEXT
		FOR i=aux*2+1 TO LEN(aa)
			? SPACE(LEN(aa[1])) +SPACE(5)+ aa[i]
		NEXT
ENDIF
				

SETIMPRESORA("FIN","")

RECUPAN()
RECUPAN()
IF EST->SALIDA == "TXT" .AND. FILE("..\VERTXT.COM")
	SALVAPAN( 0, 0, 24, 79 )
*	RUN ..\VERTXT LISTADO.TXT
  aux := "..\VERTXT "+ XNAME("XLIS")+".TXT"
 	RUN &aux
	RECUPAN()
ENDIF
CLEARTYPEAHEAD()

RETURN niL

				* * *  suma las ccv si TURNO == 'E'
				IF VA->CCV == 'S'
					IF _turno == "E"
						SELECT CCV2
						SET ORDER TO CCV2_FECHEMI
						SEEK FTOC(_fecha)
						DO WHILE CCV2->FECHEMI == _fecha
							aaux[nCCV,1] += ( CCV2->EFECTIVO + CCV2->CHEQUE + CCV2->TARJETA )
							SKIP
						ENDDO
					ENDIF
				ENDIF
				
		RECUPAN()

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

  IF (x<y .AND. y#0) .OR. (y==0.AND. x#0)			// es numerico
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
  	_masc:=STUFF( _masc, xi, LEN(sm), TRANS(aa[i],sm) )

  ENDIF
NEXT

RETURN _masc
