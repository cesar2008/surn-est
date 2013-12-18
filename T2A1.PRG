#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

local r:=.T.
#ifndef SUR
	return
#endif
SET TALK OFF
SET STATUS OFF
SET SCOREBOARD OFF
SET DELETED ON
SET DATE FRENCH
SET CONFIRM ON
SET EPOCH TO (year(date())-50)

EXTERNAL Clear_gets
CLEAR

#define  TR_TIPO    1
#define  TR_BASE    2
#define  TR_BASE2   3
#define  TR_ALIAS   4
#define  TR_ALIAS2  5
#define  TR_CLAVE   6
#define  TR_TIT     7

cDestino := "A:\"
cDirAno := ""

op = MENUFLASH( 10, 25, 1, .T., "", "PASAR NOVEDADES A DISKETTE", "TRAER NOVEDADES DE DISKETTE" )
if lastkey()#K_ENTER
	return .F.
endif


FBASES({"*DBFS","*TRANS"})
IF LASTREC() == 0
	APPEND BLANK
ENDIF

xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
                 "       º graba y º        ",;
                 " mueve º procede º  sale  "})
SELECT TRN
if op==1
	ATRN := NEWEDIT( "TRANS2A1",,.T. )
else
	ATRN := NEWEDIT( "TRAER2A1",,.T. )
endif
FEDITOR( ATRN, "LEER" )
ATRN[ED_I] := 1
ATRN[ED_REGISTRO] := RECNO()
ATRN[ED_MODE] = "MOSTRARTODO"
DO WHILE .T.
	FEDITAR( ATRN, { K_F10 } )
	IF ATRN[ED_UPDATE]
		ATRN[ED_MODE] = "MOSTRAR"
     if EDNOM(ATRN) # "TRN->XDISCO"
			EDPONE(ATRN,"TRN->DISCOX",if(EDCONT(ATRN,"TRN->DISCOX")==' ',' ','S'))
     endif
	ELSEIF ( ATRN[ED_TECLA] == K_ENTER .AND. ATRN[ED_I] == LEN(ATRN[ED_EDIT]) ) .OR. ATRN[ED_TECLA] == K_F10
		FEDITOR(ATRN,"GRABAR",.F.)
		EXIT
	ELSEIF ATRN[ED_TECLA] == K_ESC
		EXIT
	ENDIF
ENDDO
FEDITOR(ATRN,"SACAPAN")
MENUDOWN(xmenu)
IF ATRN[ED_TECLA] == K_ESC
	RETURN .F.
ENDIF

cDisco := alltrim(TRN->XDISCO)
DO WHILE !DISCOESTA(LEFT(cDisco,1))
	MENSAJE( 0, 0, 0, .F., "No Puedo Grabar en el disco "+cDisco,"ENTER reintenta","ESC cancela" )
	INKEY(0)
	RECUPAN()
	IF LASTKEY() == K_ESC
		RETURN .F.
	ENDIF
ENDDO
cDisco := TRN->XDISCO
cDestino := cDisco+":\"
bBlock := {||(XF)->PASADO==' '}
if TRN->PASARTODO=="S"
	bBlock := {||.T.}
endif


if op==1
*	nOpc := MENUFLASH( 10, 25, 1, .T., "", "AGREGAR", "CREAR" )
* if lastkey()#K_ENTER
* 	return .F.
* endif
	ATRN :={{"XFACA", "FACA_5","FACA2_5", "FA","FA2", "NUMFAC", "FACTURAS A 5" },;
	        {"XFACB", "FACB_5","FACB2_5", "FB","FB2", "NUMFAC", "FACTURAS B 5" },;
	        {"XFACA", "FACA_6","FACA2_6", "FA","FA2", "NUMFAC", "FACTURAS A 6" },;
	        {"XFACB", "FACB_6","FACB2_6", "FB","FB2", "NUMFAC", "FACTURAS B 6" },;
	        {"XTICK", "TICKETS",  "TICKETS2",   "TI","TI2", "NUMFAC", "TICKETS" }}
	FOR nB=1 TO LEN(ATRN)
		IF TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			MENSAJE( 99, 99, 0, .F., "Copiando "+ATRN[nB,TR_TIT]+" a "+cDestino+"..." )
			
			cAux  := ATRN[nB,TR_BASE]
			cAux2 := ATRN[nB,TR_BASE2]
			if left(right(ATRN[nB,TR_BASE],2),1)=="_" .and. val(right(ATRN[nB,TR_BASE],1))#0
        	cSUCURSAL := right(ATRN[nB,TR_BASE],1)
           cAux  := left(cAux,at("_",cAux)-1)
           cAux2 := left(cAux2,at("_",cAux2)-1)
        endif
*			FBASES({ ATRN[nB,TR_BASE], ATRN[nB,TR_BASE2]} )
			XF  := ATRN[nB,TR_ALIAS]
			XF2 := ATRN[nB,TR_ALIAS2]
			F_ABASE({XF,XF2},"CERRAR")
			FBASES({ cAux, cAux2 } )
			cNUMERO := ATRN[nB,TR_CLAVE]
			
			select (XF)
*			if !file( cDestino+ATRN[nB,TR_BASE]+".DBF" ) 		//.or. nOpc==2
				copy stru to (cDestino+ATRN[nB,TR_BASE])
*       endif
			select 98;  dbclosearea()
			select 98;  use (cDestino+ATRN[nB,TR_BASE]) alias X exclusive
			aBlock:=dbstruct()
			
			select (XF2)
			copy stru to (cDestino+ATRN[nB,TR_BASE2])
			select 99;  dbclosearea()
			select 99;  use (cDestino+ATRN[nB,TR_BASE2]) alias X2 exclusive
			aBlock2:=dbstruct()
			
			
			nCantidad := 0
			select (XF)
        set order to FORDER({"FECHA"})
        dbseek(ftoc(TRN->DESDE),.T.)
*			locate for ROSCA().and.eval(bBlock).and.(XF)->&(cNUMERO)#0 rest
			do while BETWEEN((XF)->FECHA,TRN->DESDE,TRN->HASTA) .and. !(XF)->(eof())
*       	if eval(bBlock).and.(XF)->&(cNUMERO)#0
        	if (XF)->&(cNUMERO)#0
					(XF2)->( dbseek((XF)->&(cNUMERO)) )
					select X2
					do while (XF2)->&(cNUMERO)==(XF)->&(cNUMERO)
						append blank
						aeval(aBlock2,{|a,i| X2->(fieldput(i,(XF2)->(fieldget(i)))) })
						skip 1 alias (XF2)
					enddo
					select X
					append blank
					aeval(aBlock,{|a,i| X->(fieldput(i,(XF)->(fieldget(i)))) })
*					FRLOCK(XF)
*					(XF)->PASADO:="S"
*					(XF)->(DBUNLOCK())
					@24,70 say ++nCantidad pict "#####"
           endif
				skip 1 alias (XF)
			enddo
			RECUPAN()
		ENDIF
	NEXT

	if TRN->XZ=="S"
		MENSAJE( 99, 99, 0, .F., "Copiando Z a "+cDestino+"..." )
     XF :="Z"
     FBASES({"Z"})
     select (XF)
     set order to forder({"FECHA"})
     copy to (cDestino+"Z") rest while BETWEEN((XF)->FECHA,TRN->DESDE,TRN->HASTA)
     RECUPAN()
  endif

	ATRN := {{"XCLA", "CLA","", "CLA","", "CODCLI", "CLIENTES C/CUIT" }}
	FOR nB=1 TO LEN(ATRN)
		if TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			MENSAJE( 99, 99, 0, .F., "Copiando "+ATRN[nB,TR_TIT]+" a "+cDestino+"..." )
		
			FBASES({ ATRN[nB,TR_BASE] } )
			XF  := ATRN[nB,TR_ALIAS]
			select (XF)
			copy stru to (cDestino+ATRN[nB,TR_BASE])
			select 98;  dbclosearea()
			select 98;  use (cDestino+ATRN[nB,TR_BASE]) alias X exclusive
			aBlock:=dbstruct()
		
			nCantidad := 0
			select (XF)
        go top
			locate for ROSCA().and.(XF)->PASADO==' ' rest
			do while !(XF)->(eof())
				select X
				append blank
				aeval(aBlock,{|a,i| X->(fieldput(i,(XF)->(fieldget(i)))) })
				frlock(XF)
				(XF)->PASADO:="S"
				(XF)->(dbunlock())
				@24,70 say ++nCantidad pict "#####"
				skip 1 alias (XF)
			enddo
			RECUPAN()
		endif
	NEXT

else
	
#ifdef ARIES
	ATRN :={{"XART", "ARTIC","", "ART","", "CODPROD", "ART.SERVICOMPRAS" }}
#else
	ATRN :={{"XPROD", "PROD","", "PRD","", "CODPROD", "PROD.ESTACION" },;
	        {"XART", "ARTIC","", "ART","", "CODPROD", "ART.SERVICOMPRAS" },;
	        {"XCLCC", "CLIENTES","", "CL","", "CODCLI", "CLIENTES C.C." }}
#endif
	for nB=1 to len(ATRN)
		if TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			
			if file( cDestino+ATRN[nB,TR_BASE]+".DBF" )
				MENSAJE( 99, 99, 0, .F., "Actualizando "+ATRN[nB,TR_TIT]+" de "+cDestino+"...")
				XF  := ATRN[nB,TR_ALIAS]
				F_ABASE({XF},"CERRAR")
				FBASES({ ATRN[nB,TR_BASE] } )
				cNUMERO := ATRN[nB,TR_CLAVE]
				set order to forder({cNUMERO})
				
				select 98;  dbclosearea()
				select 98;  use (cDestino+ATRN[nB,TR_BASE]) alias X exclusive
				go top
           aaux:=(XF)->(dbstruct())
				aBlock:=dbstruct()
           for i=1 to len(aBlock)
           	if ascan(aaux,{|a|a[1]==aBlock[i,1]}) == 0
              	aBlock[i,1] := "@"
              endif
           next i
           i:=ascan(aBlock,{|a,i|a[1]=="@"})
           do while i#0
           	adel(aBlock,i)
              asize(aBlock,len(aBlock))
           	i:=ascan(aBlock,{|a|a[1]=="@"})
           enddo
				
				nCantidad := 0
				select (XF)
				do while !X->(eof())
					if !dbseek( X->&(cNUMERO) )
						ADD_REC()
					endif
					frlock()
*					aeval(aBlock,{|a,i| (XF)->(fieldput(i,X->(fieldget(i)))) })
					aeval(aBlock,{|a,i| (XF)->&(a[1]):=X->&(a[1]) })
					dbunlock()
					@24,70 say ++nCantidad pict "#####"
					skip 1 alias X
				enddo
				RECUPAN()
			else
				MENSAJE( 0, 0, 10, .T., "No se encuentra el archivo "+cDestino+ATRN[nB,TR_BASE]+".DBF  !!!" )
			endif
		endif
	next
	
#ifdef ARIES
	ATRN :={{"XRUB", "RUBRO","", "RU","", "", "RUBROS" }}
#else
	ATRN :={{"XRUB", "RUBRO","", "RU","", "", "RUBROS" },;
	        {"XRUB", "GRUPO","", "GR","", "", "GRUPOS" }}
#endif
	FOR nB=1 TO LEN(ATRN)
		IF TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			
			if file( cDestino+ATRN[nB,TR_BASE]+".DBF" )
				MENSAJE( 99, 99, 0, .F., "Actualizando "+ATRN[nB,TR_TIT]+" de "+cDestino+"...")
				XF  := ATRN[nB,TR_ALIAS]
				F_ABASE({XF},"CERRAR")
				FBASES({ ATRN[nB,TR_BASE] } )
				cNUMERO := ATRN[nB,TR_CLAVE]
				set order to forder({cNUMERO})
				
				select 98;  dbclosearea()
				select 98;  use (cDestino+ATRN[nB,TR_BASE]) alias X exclusive
				go top
				aBlock:=dbstruct()
				
				nCantidad := 0
				select (XF)
				do while !X->(eof())
					if X->(recno()) > (XF)->(lastrec())
						ADD_REC()
					endif
					frlock()
					aeval(aBlock,{|a,i| (XF)->(fieldput(i,X->(fieldget(i)))) })
					dbunlock()
					@24,70 say ++nCantidad pict "#####"
					skip 1 alias X
				enddo
				RECUPAN()
			endif
		ENDIF
	NEXT
	if TRN->xrub=="S"
  	if file( cDestino+"RUBRO.VEC" )
  		copy file (cDestino+"RUBRO.VEC") to RUBRO.VEC
     endif
  endif
endif

RETURN r
