#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

local r:=.T., cBaseAux:=XNAME('XAUX')
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
cDirAno := ""
cDestino := "A:\"
cDirFiscal := if("2"$curdir(),"\SURN2\MIN\","\SURN\MIN\")

op = MENUFLASH( 10, 25, 1, .T., "", "PASAR NOVEDADES A DISKETTE", "TRAER NOVEDADES DE DISKETTE" )
if lastkey()#K_ENTER
	return .F.
endif


FBASES({"*DBFS","*TRANS","*ARTIC"})
IF LASTREC() == 0
	APPEND BLANK
ENDIF

xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
                 "       º graba y º        ",;
                 " mueve º procede º  sale  "})
SELECT TRN
if op==1
	ATRN := NEWEDIT( "TRAER1A2",,.T. )
else
	ATRN := NEWEDIT( "TRANS1A2",,.T. )
endif
FEDITOR( ATRN, "LEER" )
ATRN[ED_I] := 1
ATRN[ED_REGISTRO] := RECNO()
ATRN[ED_MODE] = "MOSTRARTODO"
do while .T.
	FEDITAR( ATRN, { K_F10 } )
	if ATRN[ED_UPDATE]
		ATRN[ED_MODE] = "MOSTRAR"
     if !EDNOM(ATRN) $ "TRN->XDISCO TRN->DESDE TRN->HASTA"
			EDPONE(ATRN,,IF(EDCONT(ATRN)==' ',' ','S'))
     endif
	ELSEIF ( ATRN[ED_TECLA] == K_ENTER .AND. ATRN[ED_I] == LEN(ATRN[ED_EDIT]) ) .OR. ATRN[ED_TECLA] == K_F10
		FEDITOR(ATRN,"GRABAR",.F.)
		EXIT
	ELSEIF ATRN[ED_TECLA] == K_ESC
		exit
	endif
enddo
FEDITOR(ATRN,"SACAPAN")
MENUDOWN(xmenu)
if ATRN[ED_TECLA] == K_ESC
	return .F.
endif

cDisco := alltrim(TRN->XDISCO)
DO WHILE !DISCOESTA(LEFT(cDisco,1))
	MENSAJE( 0, 0, 0, .F., "No Puedo Grabar en el disco "+cDisco,"ENTER reintenta","ESC cancela" )
	INKEY(0)
	RECUPAN()
	IF LASTKEY() == K_ESC
		RETURN .F.
	ENDIF
ENDDO
cDestino := cDisco+":\"
bBlock := {||(XF)->PASADO==' '}
bBlock := {||BETWEEN((XF)->FECHMODIF,TRN->DESDE,TRN->HASTA)}
if TRN->PASARTODO=="S"
	bBlock := {||.T.}
endif

if op==1
	
	nOpc := MENUFLASH( 10, 25, 1, .T., "", "AGREGAR", "CREAR" )
  if lastkey()#K_ENTER
  	return .F.
  endif
	ATRN :={{"XPROD", "PROD","", "PRD","", "CODPROD", "PROD.ESTACION" },;
	        {"XART", "ARTIC","", "ART","", "CODPROD", "ART.SERVICOMPRAS" },;
	        {"XCLCC", "CLIENTES","", "CL","", "CODCLI", "CLIENTES C.C."},;
	        {"XCLA", "CLA","", "CLA","", "CODCLI", "CLIENTES C/CUIT" }}
	cDestinoTmp := curdir()+"\MANDAR\"
	for nB=1 to len(ATRN)
		if TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			MENSAJE( 99, 99, 0, .F., "Copiando "+ATRN[nB,TR_TIT]+" a "+cDestinoTmp+"..." )
		
			FBASES({ ATRN[nB,TR_BASE] } )
			XF  := ATRN[nB,TR_ALIAS]
			select (XF)
			if !file( cDestinoTmp+ATRN[nB,TR_BASE]+".DBF" ) .or. nOpc==2
				copy stru to (cDestinoTmp+ATRN[nB,TR_BASE])
        endif
			select 98;  dbclosearea()
			select 98;  use (cDestinoTmp+ATRN[nB,TR_BASE]) alias X exclusive
			aBlock:=dbstruct()
		
			nCantidad := 0
			select (XF)
        go top
 			locate for ROSCA().and.eval(bBlock) rest
			do while !(XF)->(eof())
        	if eval(bBlock)
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
		endif
	next
  if TRN->XRUB=="S"
     FBASES({"GRUPO"})
  	copy to (cDestinoTmp+"GRUPO.DBF")
  	copy file ("\SUR\EST\RUBRO.VEC") to (cDestinoTmp+"RUBRO.VEC")
     FBASES({"RUBRO"})
     select RU
  	copy to (cDestinoTmp+"RUBRO.DBF")
  endif

else
	ATRN :={{"XFACA", "FACA_5","FACA2_5", "FA","FA2", "NUMFAC", "FACTURAS A 5"},;
	        {"XFACB", "FACB_5","FACB2_5", "FB","FB2", "NUMFAC", "FACTURAS B 5"},;
          {"XFACA", "FACA_6","FACA2_6", "FA","FA2", "NUMFAC", "FACTURAS A 6"},;
	        {"XFACB", "FACB_6","FACB2_6", "FB","FB2", "NUMFAC", "FACTURAS B 6"},;
	        {"XTICK", "TICKETS",  "TICKETS2",   "TI","TI2", "NUMFAC", "TICKETS"}}
	cDestinoTmp := curdir()+"\TRAER\"
	FOR nB=1 TO LEN(ATRN)
		IF TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			
			if file( cDestinoTmp+ATRN[nB,TR_BASE]+".DBF" )
				MENSAJE( 99, 99, 0, .F., "Actualizando "+ATRN[nB,TR_TIT]+" de "+cDestinoTmp+"...")
				cAux  := ATRN[nB,TR_BASE]
				cAux2 := ATRN[nB,TR_BASE2]
				if left(right(ATRN[nB,TR_BASE],2),1)=="_" .and. val(right(ATRN[nB,TR_BASE],1))#0
        		cSUCURSAL := right(ATRN[nB,TR_BASE],1)
           	cAux  := left(cAux,at("_",cAux)-1)
           	cAux2 := left(cAux2,at("_",cAux2)-1)
        	endif
				XF  := ATRN[nB,TR_ALIAS]
				XF2 := ATRN[nB,TR_ALIAS2]
				F_ABASE({XF,XF2},"CERRAR")
				FBASES({ cAux, cAux2 } )
				cNUMERO := ATRN[nB,TR_CLAVE]

           select (XF)
				set order to forder({cNUMERO})
				
				select 98;  dbclosearea()
				select 98;  use (cDestinoTmp+ATRN[nB,TR_BASE]) alias X exclusive
				go top
				aBlock:=dbstruct()
           i:=ascan(aBlock,{|a|a[1]=="NUMCOB"})
           if i#0
           	adel(aBlock,i)
              asize(aBlock,len(aBlock)-1)
           endif
				
				select 99;  dbclosearea()
				select 99;  use (cDestinoTmp+ATRN[nB,TR_BASE2]) alias X2 exclusive
           index on &("X2->"+cNUMERO) to (cBaseAux)
				go top
				aBlock2:=dbstruct()
				
				nCantidad := 0
				do while !X->(eof())
           	select (XF2)
              aaux:={}
					dbseek( X->&(cNUMERO) )
              do while (XF2)->&(cNUMERO)==X->&(cNUMERO) .and. !(XF2)->(eof())
						aadd(aaux,recno())
                 skip
					enddo
					X2->(dbseek( X->&(cNUMERO) ))
              do while X2->&(cNUMERO)==X->&(cNUMERO) .and. !X2->(eof())
              	if len(aaux)>0
                 	go aaux[1]
                    adel(aaux,1)
                    asize(aaux,len(aaux)-1)
                    if XF#"Z"
                 		if (XF2)->NEGOCIO=="*"
                 			if ART->(dbseek((XF2)->CODPROD))
                    			FRLOCK("ART")
                       		ART->STOCKACT += (XF2)->CANTIDAD
                       		ART->(dbunlock())
                    		endif
                 		endif
                    endif
                 else
                 	F_ALTA( {||(XF2)->&(cNUMERO)#0} )
                 endif
						frlock()
						aeval(aBlock2,{|a,i| (XF2)->(fieldput(i,X2->(fieldget(i)))) })
						dbunlock()
                 if XF#"Z"
                 	if X2->NEGOCIO=="*"
                 		if ART->(dbseek(X2->CODPROD))
                    		FRLOCK("ART")
                       	ART->STOCKACT -= X2->CANTIDAD
                       	ART->(dbunlock())
                    	endif
                 	endif
                 endif
                 skip 1 alias X2
					enddo
              for i=1 to len(aaux)
              	dbgoto(aaux[i])
                 if XF#"Z"
                		if (XF2)->NEGOCIO=="*"
                 		if ART->( dbseek((XF2)->CODPROD) )
                    		FRLOCK("ART")
                       	ART->STOCKACT += (XF2)->CANTIDAD
                       	ART->(dbunlock())
                    	endif
                 	endif
                 endif
              	BLANKREG()
              next

					select (XF)
					if !dbseek( X->&(cNUMERO) )
						F_ALTA({||(XF)->&(cNUMERO)#0})
					endif
					frlock()
              if XF $ "FA FB RE"
						cNUMCOB := (XF)->NUMCOB
              endif
					aeval(aBlock,{|a,i| (XF)->(fieldput(i,X->(fieldget(i)))) })
              if XF $ "FA FB RE"
              	if !empty(cNUMCOB)
							(XF)->NUMCOB := cNUMCOB
                 endif
              endif
					dbunlock()
					@24,70 say ++nCantidad pict "#####"
					skip 1 alias X
				enddo
				RECUPAN()
			else
				MENSAJE( 0, 0, 10, .T., "No se encuentra el archivo "+cDestinoTmp+ATRN[nB,TR_BASE]+".DBF  !!!" )
			endif
		ENDIF
	NEXT

	ATRN :={{"XCLA", "CLA","", "CLA","", "X->CODCLI", "CLIENTES C/CUIT" },;
	        {"XZ",   "Z",  "", "Z",  "", "X->SUCURSAL+str(X->NUMZ)",   "Z" }}
	FOR nB=1 TO LEN(ATRN)
		IF TRN->&(ATRN[nB,TR_TIPO]) == 'S'
			
			if file( cDestinoTmp+ATRN[nB,TR_BASE]+".DBF" )
				MENSAJE( 99, 99, 0, .F., "Actualizando "+ATRN[nB,TR_TIT]+" de "+cDestinoTmp+"...")
				XF  := ATRN[nB,TR_ALIAS]
				F_ABASE({XF},"CERRAR")
				FBASES({ ATRN[nB,TR_BASE]} )
				cNUMERO := ATRN[nB,TR_CLAVE]
           select (XF)
				set order to forder({cNUMERO})
				
				select 98;  dbclosearea()
				select 98;  use (cDestinoTmp+ATRN[nB,TR_BASE]) alias X exclusive
				go top
				aBlock:=dbstruct()
				
				nCantidad := 0
				do while !X->(eof())
					select (XF)
*					if !dbseek( X->&(cNUMERO) )
					if !dbseek( &(cNUMERO) )
						ADD_REC()
					endif
					frlock()
					aeval(aBlock,{|a,i| (XF)->(fieldput(i,X->(fieldget(i)))) })
					dbunlock()
					@24,70 say ++nCantidad pict "#####"
					skip 1 alias X
				enddo
				RECUPAN()
			else
				MENSAJE( 0, 0, 10, .T., "No se encuentra el archivo "+cDestinoTmp+ATRN[nB,TR_BASE]+".DBF  !!!" )
			endif
		ENDIF
	NEXT
endif


RETURN r
