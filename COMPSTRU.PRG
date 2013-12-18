SET DATE BRITISH
SET TALK OFF
SET EXCLUSIVE OFF


SET ALTERNATE TO QQ.
SET ALTERNATE ON

PARAMETERS cualpath
IF PCOUNT() = 0
	cualpath = "A:"
ENDIF
IF RIGHT(cualpath,1) # "\"
	cualpath = cualpath + "\"
ENDIF


cant1 = ADIR( "*.DBF" )
DECLARE ABASE1[cant1]
ADIR( "*.DBF", ABASE1 )
ASORT( ABASE1 )
cant1 = BORRARX( ABASE1 )

cant2 = ADIR( cualpath+"*.DBF" )
DECLARE ABASE2[cant2]
ADIR( cualpath+"*.DBF", ABASE2 )
ASORT( ABASE2 )
cant2 = BORRARX( ABASE2 )

CLEAR
IF cant1 > cant2
	? "en "+ CURDIR() +" hay" + str(cant1-cant2,3) + " bases m s que en "+ cualpath
  FOR i=1 TO cant1
  	IF ASCAN( ABASE2, ABASE1[i] ) == 0
     	? ABASE1[i]
     ENDIF
  NEXT
  WAIT
ELSEIF cant1 < cant2
	? "en "+ cualpath +" hay" + str(cant2-cant1,3) + " bases m s que en "+ CURDIR()
  FOR i=1 TO cant2
  	IF ASCAN( ABASE1, ABASE2[i] ) == 0
     	? ABASE2[i]
     ENDIF
  NEXT
  WAIT
ENDIF

CLEAR
XM = "   "
FOR _i=1 TO cant1
	x = ASCAN( ABASE2, ABASE1[_i] )
  IF x==0
		aux = SPACE(15)
  ELSE
		aux = ABASE2[x]

     base = ABASE1[_i]
		ABRIR(Base,"X", .F. )
     DECLARE aname1[FCOUNT()], atipo1[FCOUNT()], alargo1[FCOUNT()], adec1[FCOUNT()], aaux1[FCOUNT()]
     AFIELDS( aname1, atipo1, alargo1, adec1 )
     FOR x=1 TO FCOUNT()
     	aaux1[x] = aname1[x] +" "+ atipo1[x] + STR(alargo1[x],5) + STR(adec1[x],3)
     NEXT
     ASORT( aaux1 )

     base = cualpath + ABASE1[_i]
		ABRIR(Base,"X", .F. )
     DECLARE aname2[FCOUNT()], atipo2[FCOUNT()], alargo2[FCOUNT()], adec2[FCOUNT()], aaux2[FCOUNT()]
     AFIELDS( aname2, atipo2, alargo2, adec2 )
     FOR x=1 TO FCOUNT()
     	aaux2[x] = aname2[x]  +" "+ atipo2[x] + STR(alargo2[x],5) + STR(adec2[x],3)
     NEXT
     ASORT( aaux2 )
		@ 24, 0 SAY ABASE1[_i]

*************************************
		XM = "   "
     abaux := {}
		FOR y=1 TO LEN(aname2)
     	 x := ASCAN( aname1, aname2[y] )
         IF x # 0
         	IF atipo2[y] # atipo1[x]
           	XM := "NO "
              EXIT
           ELSE
*        		AADD( abaux, &("{||X2->"+ aname2[y] +":=X1->"+ aname1[x] +"}") )
              AADD( aBaux, {y,x})
           ENDIF
         ENDIF
     NEXT

*************************************
		@ 24, 20 SAY cualpath + aux
		@ 24, 50 SAY XM
     IF XM == "NO "
     	DO MOSTRARDIF

     ELSE
     	XM := "   "
     	IF LEN(aaux1) # LEN(aaux2)
        	XM := "SI "
        ELSE
        	FOR y=1 TO LEN(aaux1)
           	IF aaux1[y] # aaux2[y]
              	XM := "SI "
                 EXIT
              ENDIF
           NEXT
        ENDIF
        IF XM == "SI "
				DO PASARDE WITH ABASE1[_i], abaux
			ENDIF

     ENDIF

  ENDIF
  SCROLL( 0, 0, 24, 79, 1 )
	@ 24, 0 SAY ABASE1[_i]
	@ 24, 20 SAY cualpath + aux
	@ 24, 50 SAY XM
* INKEY(3)
NEXT
SET ALTERNATE TO
ERASE XTEMP.DBF

RETURN


************
FUNC BORRARX
************
PARAMETERS base

cant = LEN( base )
SET EXACT OFF
i = ASCAN( base, "X" )
DO WHILE i > 0
	ADEL( base, i )
  base[LEN(base)] = ""
	i = ASCAN( base, "X" )
  cant = cant - 1
ENDDO
SET EXACT ON

RETURN cant


************

PROC PASARDE

************
PARAMETERS a, abaux
@ 24,70 SAY "LO PASO ?"
OP=" "
DO WHILE .NOT. OP $ "SsNn"
	OP = CHR(INKEY(0))
ENDDO
IF .NOT. op $ "Ss"
	DO MOSTRARDIF
	RETURN
ENDIF
aa := IF("."$a,LEFT(a,AT(".",a)-1),a)
a1  = aa + ".DBF"
a11 = aa + ".DBT"
a2 = cualpath + aa +".DBF"

IF FILE(a1) .AND. FILE(a2)
	CLOSE DATABASES

	ABRIR(a2,"X", .F. )
  COPY STRU TO XTEMP.DBF

	SELECT 2
	ABRIR("XTEMP","X2", .F. )

*	SELECT 1
* GO TOP
  xcant := LASTREC()
  SELECT X2
  APPEND FROM (a1) FOR VER()

* DO WHILE !X1->(EOF())
* 	APPEND BLANK
*    AEVAL(abaux,{|a,i| DBEVAL(abaux[i])} )
*		@ 24,73 SAY --xcant PICT "99999"
*    SKIP 1 ALIAS X1
* ENDDO

	SELECT 1
	ABRIR( a1,"X1", .F. )

	IF X1->(LASTREC()) == X2->(LASTREC())
  	CLOSE DATABASES
 		ERASE (a1)
 		ERASE (a11)
 		RENAME XTEMP.DBF TO (a1)
 		RENAME XTEMP.DBT TO (a11)
  ELSE
  	?? "MAL PASADO "+ABASE1[_i]+ALLTRIM(STR(X1->(LASTREC())))+"   "+ABASE2[_i]+ALLTRIM(STR(X2->(LASTREC())))
  ENDIF
	CLOSE DATABASES

ENDIF

RETURN


*********

FUNC VER

********

@ 24,73 SAY RECNO() PICT "999999"

RETURN .T.


*********

FUNC MOSTRARDIF

********

     	WAIT "MOSTRAR DIFERENCIAS  [S / N ] ?" TO OP
        IF OP $ "Ss"
     		?
     		? base, "/", CURDIR(), cualpath
        	? "------------------------------------------"
     		FOR x=1 TO LEN(aaux1)
           	y := ASCAN( aaux2, {|a| LEFT(a,10)==LEFT(aaux1[x],10)} )
              IF y == 0
        			? PADL(aaux1[x],25," "), REPLIC("*",25)
              ELSE
        			? PADL(aaux1[x],25," "), PADL(aaux2[y],25," "), IF(aaux1[x]#aaux2[y]," #","")
                 ADEL( aaux2, y )
                 ASIZE( aaux2, LEN(aaux2)-1 )
              ENDIF
        	NEXT
     		FOR x=1 TO LEN(aaux2)
        		? REPLIC("*",25), PADL(aaux2[x],25," ")
           NEXT
           ?
        ENDIF
WAIT

RETURN


************************
FUNC ABRIR(cBase,cAlias,lModo)
************************
do while .t.
	if lModo
		use (cBase) alias (cAlias) shared
  else
		use (cBase) alias (cAlias) exclusive
  endif
  if dbf() # ""
  	exit
   endif
enddo

return
