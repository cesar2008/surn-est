#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

#define RG_ORDEN     1
#define RG_ANTES     2
#define RG_DESPUES   3
#define RG_DESCIMP   4
#define RG_SETS      5

LOCAL aCPO, OX, xmenu, cBase:=DBF()

aCpo := {;
			{ "IMPRESORA",    "Impresora",                     '', 'E', 'F',  0, 0 } }

xmenu:=MENUDOWN({"  <+>  º    F2    º   F5   º    TAB    º ESC  ",;
			  			"       º          º        º actualiza º      ",;
			  			" mueve º modifica º agrega º   set‚o   º sale "})

SELECT SI
aCpo := FARRAYAUX( aCpo )
MARCO( 13, 40, 20, 78, " IMPRESORAS ", "D", .T., 0 )
OX := MYBROWSE( 13, 40, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 10
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F5.OR.nK==K_TAB} )
	IF OX:Cargo[TB_MSGE] == "MODIF"
  	TBPUT(OX)
		TBPOS(OX)
	ELSEIF OX:CARGO[TB_RET] == K_TAB
  	aaux := STOA( SI->SETS )
     AEVAL( aaux, {|a,i| aaux[i,RG_SETS]:=PADR(a[RG_SETS],250)} )
  	IF FSET( @aaux, SI->IMPRESORA )
     	FRLOCK()
     	AEVAL( aaux, {|a,i| aaux[i,RG_SETS]:=ALLTRIM(a[RG_SETS]) } )
			SI->SETS := ATOS( aaux )
        DBUNLOCK()
     ENDIF
	ELSEIF OX:CARGO[TB_RET] == K_F5
     LOCATE FOR EMPTY(SI->IMPRESORA)
     IF !FOUND() .OR. LASTREC()==0
        ADD_REC()
     ENDIF
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_ESC
     r := .F.
     EXIT
	ELSEIF OX:Cargo[TB_RET] == K_ENTER
     r := .T.
     EXIT
	ENDIF
  CLEARTYPEAHEAD()
ENDDO
RECUPAN()
PONEPAN(xmenu)
DBSELECTAREA(cBase)

RETURN r


********************

FUNC FSETIMP( cualImp, cual )

********************
LOCAL cSet:='', cBase:=DBF(), nReg, aaux, i
DEFAULT cual TO "ANTES"
IF "ANT"$cual .OR. "INI"$cual
	cual := RG_ANTES
ELSE
	cual := RG_DESPUES
ENDIF

SELECT SI
IF cualImp # NIL
	nReg:=RECNO()
	LOCATE FOR cualImp $ SI->IMPRESORA
  IF !FOUND()
  	GO nReg
     DBSELECTAREA( cBase )
  	RETURN ''
  ENDIF
ENDIF
aaux := STOA( SI->SETS )
FOR i=1 TO LEN(aaux)
	IF aaux[i,cual]=='*'
		aux := aaux[i,RG_SETS]
  	cSet += FT_PCHR(aux)
  ENDIF
NEXT
DBSELECTAREA( cBase )

RETURN cSet




******************

STATIC FUNC FSET(aaux,ctitulo)

******************
LOCAL aCPO, OX, NROWR, xmenu, r
ctitulo := ALLTRIM( IF( ctitulo==NIL, "IMPRESORA", ctitulo ) )

aCpo := {	                                                                      ;
			{ "ORDEN",        "Orden",                      '999', 'M', 'N',  3, 0 },;
			{ "ANTES",        "Antes",                        'X', 'E', 'C',  1, 0 },;
			{ "DESPUES",      "Desp",                         'X', 'E', 'C',  1, 0 },;
			{ "DESCIMP",      "Descripci¢n",      REPLIC("X", 20), 'E', 'C', 20, 0 },;
			{ "SETS",         "SET",      "@S30 "+REPLIC("X",250), 'E', 'C',250, 0 } }
*aCpo := FARRAYAUX( aCpo )

SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

IF TYPE("NROW") == "N"
	NROWR := NROW
ENDIF
NROW := 1
IF LEN(aaux) == 0
	AADD( aaux, AREG0( aCpo ) )
ENDIF

xmenu:=MENUDOWN({"    F2    º   F5   º     ESPACIO      º en el SET colocar º  F10  º ESC  ",;
			  			"          º        º Activa/Desactiva º s¢lo digitos  se- º       º      ",;
			  			" modifica º agrega º los c¢digos Impr.º parados con  /    º graba º sale "})

SETCOLOR( "W/N,N/W" )
MARCO( 5, 10, 19, 78, ctitulo, "D", .T., 0 )
OX := MYABROWSE( 5, 10, 19, 78, aCpo, aaux, "aaux" )
OX:CARGO[TB_REFRESH] := 0
OX:GOTOP()
	
guardar = .F.
DO WHILE .T.
		
	MOVABROW( OX, aaux, {||nK==K_F5.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F6.OR.nK==32},;
		{||nK==999} )

	IF OX:Cargo[TB_MSGE] == "MODIF"
  	IF TBNOC(OX) == "SETS"
			aux := STRTRAN(ALLTRIM(OX:CARGO[TB_CONT]),"/",",")
			aux := STRTRAN(aux," ",",")
			aux := STRTRAN(aux,"\",",")
			aux := STRTRAN(aux,CHR(34),"'")
        aux := IF( LEFT(aux,1)$",", SUBSTR(aux,2), aux )
        aux := IF( RIGHT(aux,1)$",", LEFT(aux,LEN(aux)-1), aux )
			aux2 := FT_PCHR( aux )
        IF TYPE("aux2") # "C"
        	MENSAJE( 0, 0, 10, .T., "ERROR DE SINTAXIS !!!" )
        ELSE
				aaux[NROW,OX:ColPos] := PADR(aux,250)
        ENDIF
  	ELSEIF TBNOC(OX) == "ORDEN"
			aaux[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
        AEVAL( aaux, {|a,i| aaux[i,RG_ORDEN]:=i} )
     ELSE
			aaux[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
     ENDIF
		TBPOS(OX)
	ELSEIF OX:CARGO[TB_RET] == 32
  	IF TBNOC(OX) $ "ANTES DESPUES"
  		FRLOCK()
  		aaux[NROW,OX:ColPos] := IF( EMPTY(aaux[NROW,OX:ColPos]) ,"*", " " )
     	DBUNLOCK()
			TBPOS(OX)
     ENDIF
	ELSEIF OX:CARGO[TB_RET] == K_F5
		AADD( aaux, AREG0( aCpo ) )
     AINS( aaux, NROW )
     aaux[NROW] := AREG0( aCpo )
     AEVAL( aaux, {|a,i| aaux[i,RG_ORDEN]:=i} )
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. LEN(aaux) > 1
     ADEL( aaux, NROW )
     ASIZE( aaux, LEN(aaux)-1 )
     AEVAL( aaux, {|a,i| aaux[i,RG_ORDEN]:=i} )
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == 999
		IF !EMPTY(aaux[NROW,RG_DESCIMP]) .AND. NROW==LEN(aaux)
			AADD( aaux, AREG0(aCpo) )
			aaux[LEN(aaux),RG_ORDEN] := LEN(aaux)
		ENDIF
		OX:RefreshAll()
	ELSEIF OX:Cargo[TB_RET] == K_ESC
     r := .F.
     EXIT
	ELSEIF OX:Cargo[TB_RET] == K_F10
     r := .T.
     EXIT
	ENDIF

ENDDO
NROW := NROWR
RECUPAN()
PONEPAN(xmenu)


RETURN r



************************

Function FT_PCHR(c_nums)

************************
Local c_ret:='', c_st:=0,c_part,c_st2,c_hex:="0123456789ABCDEF"
Local c_upper,c_t1,c_t2

   If Substr(c_nums,1,1)=','.or.Trim(c_nums)==''
      Return ""
   Endif

   c_nums := Trim(c_nums) + ",~,"
   c_part := Substr(c_nums,c_st+1,At(",",Substr(c_nums,c_st+2)))

   Do While .not.(c_part=="~".or.c_part=="")
      
      If Substr(c_part,1,1)=Chr(39)
      
         c_st2:=At(Chr(39),Substr(c_part,2))+1
         c_ret:=c_ret+Substr(c_part,2,c_st2-2)
      
      Elseif Substr(c_part,1,1)="&"
      
         c_upper=Upper(c_part)
         c_t1=At(Substr(c_upper,2,1),c_hex)-1
         If c_t1>-1
            c_t2=At(Substr(c_upper,3,1),c_hex)-1
            If c_t2>-1
               c_t1=c_t1*16+c_t2
            Endif
            c_ret=c_ret+Chr(c_t1)
         Endif
      
      ElseIf (Val(c_part)>0.and.Val(c_part)<256).or.c_part="0"
      
         c_ret=c_ret+Chr(Val(c_part))
      
      Endif

      c_st = At(",",Substr(c_nums,c_st+1))+c_st
      c_part = Substr(c_nums,c_st+1,At(",",Substr(c_nums,c_st+2)))

   Enddo

Return c_ret
