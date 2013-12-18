* * * * * *
*http://dfe.arba.gov.ar/DomicilioElectronico/dfeDescargarPadron.do?dispatch=preDes
*30-63973431-1
*sur311
*
*Percepcion ->ventas
*Retencion  ->compras
*
* * * * * *
#include "INKEY.CH"
#include "..\EST.CH"
#include "EST.CH"
#include "EDI.CH"
cPath := "\SISTEMAS\IIBB\"

op := MENUFLASH( ym2+2, xm2-2, 1, .F., "Ingr.Brutos",  "Configuraci¢n", "Importar Percepciones", "Exportar Retenciones", "Exportar Percepciones" )
if op == 1
			xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
								  "       º graba y º        ",;
								  " mueve º procede º  sale  "})
			select VA
			aaux := NEWEDIT( "IIBB",,.T. )
			FEDITOR( aaux, "LEER" )
 			aaux[ED_I] := 1
 			aaux[ED_REGISTRO] := RECNO()
			aaux[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( aaux, { K_F10 } )
				IF aaux[ED_UPDATE]
					aaux[ED_MODE] = "MOSTRAR"
				ELSEIF aaux[ED_TECLA] == K_TAB
           	if EDNOM(aaux)=="VA->PIB_COM1" .or. EDNOM(aaux)=="VA->PIB_VEN1"
              endif
					aaux[ED_MODE] = "MOSTRARTODO"
				ELSEIF ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_F10
           	FRLOCK("VA")
           	FRLOCK("EST")
					FEDITOR(aaux,"GRABAR",.F.)
					EXIT
				ELSEIF aaux[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			FEDITOR(aaux,"SACAPAN")
			MENUDOWN(xmenu)

elseif op==2
	MENSAJE( 5, 0, 0, .F., "Este proceso puede durar varios minutos", "","Primero bajar el archivo correspondiente al mes","y descomprimir en: "+ cPath,"con nombre no mayor a 8 caracteres y extension .TXT" )
*	if UPPER( PREGUNTA( 11, "Comenzar ? [S/N]", "SsNn") )=="S"
  cAux := VA->ANOMESIB
  do while .T.
		cAux := INGRVAL( 12, 20, "A¤o/Mes a importar", cAux, "99/99", "")
     if lastkey()==K_ESC
     	exit
     elseif lastkey()=K_ENTER
     	if (val(cAux)+2000 > year(date())+1) .or. (val(cAux)+2000<year(date())-1)
				MENSAJE( 0, 0, 10, .T., "ERROR", "A¤o incorrecto !" )
     	elseif val(right(cAux,2))<1 .or. val(right(cAux,2))>12
				MENSAJE( 0, 0, 10, .T., "ERROR", "Mes incorrecto !" )
        else
        	exit
     	endif
     endif
  enddo
  if lastkey()=K_ENTER
  	frlock("VA")
     VA->ANOMESIB := cAux
    	VA->(dbunlock())
  	RECUPAN()
		txt := "PADRON~1.TXT"
		aa := directory(cPath+"*.txt")
		ASORT( aa,,, {|x,y| x[3]>y[3] } )
		txt:=""
		if len(aa)<1
			MENSAJE( 0, 0, 10, .T., "ERROR", "NO HAY ARCHIVO A IMPORTAR !" )
  		return
		endif
		i := len(aa)
		txt := cPath+aa[1][1]		// me quedo con el primero
		fechatxt := aa[1][3]

		na := FOPEN(txt)
		if FERROR() != 0
			MENSAJE( 0, 0, 10, .T., "No puedo abrir el archivo, DOS error ", FERROR() )
  		return
		endif


		aa := MENSAJE( 0, 0, 0, .F., justif("AGUARDE ...",30,"="),"","" )

		FBASES( { "PADRONIB" }, .F. )
*		@aa[1]+2,aa[2] say "Cambiano estado..."
*		flock()
*		replace ESTADO with "I" for ROSCA()


		nPPERC_MAX := 0
		nPRET_MAX := 0

		RECUPAN()
		aa := MENSAJE( 0, 0, 0, .F., justif("IMPORTANDO...",40,"="),"","" )
		@aa[1]+1,aa[2] say txt +" del "+ dtoc(fechatxt) +"..."
		block = 62
		FSEEK(na, 0)
		t := lastrec()
		n := 0
		for x:=1 to 10000000
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
  		if bytes<>block
  			exit
  		endif

			if !dbseek(substr(buffer,28,11))
				ADD_REC()
				PIB->CUIT  := substr(buffer,28,11)
  		endif
			nPPERC := val(strtran(substr(buffer,46,4),",","."))
			nPRET  := val(strtran(substr(buffer,51,4),",","."))
  		if nPPERC<>PIB->PPERC .or. nPRET<>PIB->PRET .or. PIB->ANOMES<>VA->ANOMESIB
  			FRLOCK()
				PIB->PPERC := nPPERC
				PIB->PRET  := nPRET
           PIB->ANOMES := VA->ANOMESIB
     		DBUNLOCK()
     		++n
  		endif
			nPPERC_MAX := max(nPPERC_MAX,nPPERC)
			nPRET_MAX := max(nPRET_MAX,nPRET)
  		--t
  		if mod(t,1000)=0
				@aa[1]+2,aa[2] say t pict "##########"
    			?? n
        	if inkey()==27
        		exit
        	endif
        endif
		next x
		FCLOSE( na )

		select VA
		frlock("VA")
		replace VA->PIB_COM1 with nPRET_MAX, VA->PIB_VEN1 with nPPERC_MAX
		VA->(dbunlock())
		RECUPAN()
		MENSAJE( 0, 0, 10, .T., "Se actualizaron "+ str(n,10) +" registros." )
  else
  	RECUPAN()
  endif

elseif op==3		//RETENCIONES
	cAux :=  "\"+ left( curdir(), rat("\",curdir())-1 )
  cAux := cAux + "\IIBB"
  cAux := VA->ANOMESIB
  do while .T.
		cAux := INGRVAL( 10, 20, "Año/Mes-Quincena(1 o 2) a preparar", cAux, "99/99-9", "")
  	RECUPAN()
     if lastkey()==K_ESC
     	exit
     elseif lastkey()=K_ENTER
     	if (val(cAux)+2000 > year(date())+1) .or. (val(cAux)+2000<year(date())-2)
				MENSAJE( 0, 0, 10, .T., "ERROR", "Año incorrecto !" )
     	elseif val(substr(cAux,4,2))<1 .or. val(substr(cAux,4,2))>12
				MENSAJE( 0, 0, 10, .T., "ERROR", "Mes incorrecto !" )
     	elseif !substr(cAux,7,1) $ "12"
				MENSAJE( 0, 0, 10, .T., "ERROR", "La quincena debe ser 1 o 2")
        else
        	exit
     	endif
     endif
  enddo
  if lastkey()=K_ENTER
  	frlock("VA");	VA->ANOMESIB:=cAux;	VA->(dbunlock())
  	aa := str(val(cAux)+2000,4)
  	mm := substr(cAux,4,2)
     qq := substr(cAux,7,1)
  	txt := "R"+ aa + mm + qq +".TXT"
	txt := cPath+ txt

	MENSAJE( 0, 0, 0, .F., justif("AGUARDE ...",30,"="),"","" )

	FBASES( { "+CCC" }, .F. )
    set century on

     if file(txt)
     	erase(txt)
     endif
		na = fcreate( txt, 0 )
		if FERROR() != 0
			MENSAJE( 0, 0, 10, .T., "No puedo abrir el archivo, DOS error " )
  		return
		endif
		fseek( na, 0 )
		n := 0

		if qq="1"
			bBlock:={||day(CCC->FECHA)<16}
     else
			bBlock:={||day(CCC->FECHA)>15}
     endif

     	M->TIPOPROV := "@"
			select CCC
     	locate for CCC->RETIB<>0
     	do while !CCC->(eof())
     		if year(CCC->FECHA)=val(aa) .and.  month(CCC->FECHA)=val(mm) .and. eval(bBlock) .and. !CCC->(eof())
     			if CCC->RETIB<>0
                 if M->TIPOPROV<>CCC->TIPOPROV
  						F_ABASE({"PRV"},"CERRAR")
              		if CCC->TIPOPROV=="V"
     						FBASES({"+PROVEEV"})
                 	else
     						FBASES({"+PROVEE"})
                 	endif
                    select CCC
                 endif
                 M->TIPOPROV := CCC->TIPOPROV
                 PRV->(dbseek(CCC->CODPROV))
     				cReg := PRV->CUIT
           		cReg += dtoc(CCC->FECHA)
                 creg += "000000000"
           		cReg += substr(CCC->NUMPAG,4,4)
           		cReg += substr(CCC->NUMPAG,9,8)
           		cReg += strzero(CCC->RETIB,11,2)
           		cReg += "A" + chr(13)+chr(10)
						block = len(cReg)
                 while .T.
							bytes = FWRITE( na, cReg, block )
                    if bytes==block
                       exit
                    endif
                 enddo
        			++n
        		endif
        	endif
        	skip 1 alias CCC
     	enddo
		fclose( na )
     if n==0 .and. file(txt)
     	erase(txt)
     endif
     set century off

		RECUPAN()
		MENSAJE( 0, 0, 10, .F., "Se exportaron "+ str(n,10) +" registros." )
  endif

elseif op==4
	cAux :=  "\"+ left( curdir(), rat("\",curdir())-1 )
  cAux := cAux + "\IIBB"
  cAux := VA->ANOMESIB
  do while .T.
		cAux := INGRVAL( 10, 20, "A¤o/Mes a preparar", cAux, "99/99", "")
  	RECUPAN()
     if lastkey()==K_ESC
     	exit
     elseif lastkey()=K_ENTER
     	if (val(cAux)+2000 > year(date())+1) .or. (val(cAux)+2000<year(date())-2)
				MENSAJE( 0, 0, 10, .T., "ERROR", "A¤o incorrecto !" )
     	elseif val(right(cAux,2))<1 .or. val(right(cAux,2))>12
				MENSAJE( 0, 0, 10, .T., "ERROR", "Mes incorrecto !" )
        else
        	exit
     	endif
     endif
  enddo
  if lastkey()=K_ENTER
  	frlock("VA");	VA->ANOMESIB:=cAux;	VA->(dbunlock())
  	aa := str(val(cAux)+2000,4)
  	mm := right(cAux,2)
  	fdde := ctod( "01/" + mm +"/"+ aa )
  	txt := "P"+ aa + mm +"0.TXT"
		txt := cPath+ txt

		MENSAJE( 0, 0, 0, .F., justif("AGUARDE ...",30,"="),"","" )
		na = fcreate( txt, 0 )
		fseek( na, 0 )
		n := 0
		if FERROR() != 0
			MENSAJE( 0, 0, 10, .T., "No puedo abrir el archivo, DOS error " )
  		return
		endif
     set century on

     aBase:={{"FACA","FA"},{"FACB","FB"}}
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
           XF:=aBase[b,2]
           set order to forder({"FECHA"})
           dbseek(ftoc(fdde),.T.)
           while year((XF)->(fecha))=val(aa) .and. month((XF)->FECHA)=val(mm) .and. !(XF)->(eof())
 					if FIELD->PERCIB<>0
     				cReg := FIELD->CUIT
           		cReg += dtoc(FIELD->FECHA)
                 cReg += abase[b,2]
           		cReg += strzero(z,4,0)
           		cReg += strzero(FIELD->NUMFAC,8,0)
        			baseimponible := FIELD->TOTAL - FIELD->TIVA1 - FIELD->TIVA2
           		cReg += strzero(baseimponible,12,2)
           		cReg += strzero(FIELD->PERCIB,11,2)
           		cReg += "A" + chr(13)+chr(10)
						block = len(cReg)
                 while .T.
							bytes = FWRITE( na, cReg, block )
                    if bytes==block
                       exit
                    endif
                 enddo
        			++n
        		endif
     			skip
           enddo
        	skip
     	next z
     next b
		fclose( na )
     if n==0 .and. file(txt)
     	erase(txt)
     endif
     set century off

		RECUPAN()
		MENSAJE( 0, 0, 10, .F., "Se exportaron "+ str(n,10) +" registros." )
  endif
endif

return
