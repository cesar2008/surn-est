proc FISCAL( cOpcion )
#include "COMMON.CH"
#include "pfiscal.ch"
#include "HFISCAL.CH"
#define CRLF  chr(13)+chr(10)


aRet:=array(F_ERRORES)
aeval(aRet,{|a,i|aRet[i]:=0},1,F_ERRORES-3)
aRet[F_FECHA]:=ctod("")
aRet[F_HORA]:=""
aRet[F_ERRORES]:={}

lAux := .F.
if EST->PORTFISCAL==1
	lAux := PF_PuertoInit( 1,"3F8", 4)
elseif EST->PORTFISCAL==2
	lAux := PF_PuertoInit( 2,"2F8", 3)
else
	frlock("EST");  EST->PORTFISCAL:=1;   EST->(dbunlock())
	MENSAJE( 0, 0, 10, .T., "FALTA ESPECIFICAR EL PUERTO DEL CONTROLADOR FISCAL !" )
  aRet[F_ERRORES] := {"FALTA PUERTO DEL CONTROLADOR"}
  return aRet
endif

MENSAJE( 99, 99, 0, .F., "IMPRIMIENDO..." )
if lAux
	* Debe ser ejecutado para poder iniciar la comunicaci¢n con la impresora
	*--------------------------------
	*function PF_PuertoInit ( PuertoNro, PuertoIO, PuertoIRQ )
	*--------------------------------
	* Funci¢n   : Inicializa y abre el puerto serie para la impresora
	*             PuertoNro  = N£mero de puerto serie 1 a 4
	*             PuertoIO   = Direcci¢n de Entrada/Salida asignada al puerto
	*             PuertoIRQ  = N£mero de Interrupci¢n asignada al puerto
	* Respuesta : Verdadero, puerto abierto
	* NOTA
	* Direcci¢n de memoria de Entrada / Salida ( Num‚rico es direcci¢n decimal
	* alfab‚tico es direcci¢n Hexadecimal
	*  INFORMACION SOBRE LAS ALTERNATIVAS DE PARAMETROS
	*    Puerto Direcci¢n   IRQ
	*     COM1    3F8H       4  Usualmente
	*     COM2    2F8H       3  Usualmente
	*     COM3    3E8H       4  Sin definir especificamente
	*     COM4    2E8H       3  Sin definir especificamente
	*
	*    Si tiene problemas para abrir el puerto debe verificar que las
	*    direcciones de memoria y el IRQ correspondan con el hardware
	*    Para mayor informaci¢n lea la ayuda de Clipper Tools
	fHandle := fcreate(cOpcion+".TXT",0)
	cReg:=replic("-",20)+CRLF
  if cOpcion  $ "FA FB TI"
		cReg+=dtoc(dFECHA)+" "+ cTURNO +" "+ alltrim(str(nNUMERO))+" "+ time()+CRLF
		bytes = FWRITE( fHandle, cReg, len(cReg) )
  endif

	
	*-----------------------------------------------------
	* Llamado a la funci¢n para reestablecer el equipo
	* Esta funci¢n es una herramienta que no es necesario
	* utilizar pero es util el caso de problemas con algun
	* comprobante abierto, para cancelarlo
	*-----------------------------------------------------
	Continuar = PF_Sincronizar()
	
	do PF_IniciarSalida
	
	* Debe ser ejecutado antes de cargar los campos de cada comando
	*--------------------------------
	*procedure     PF_IniciarSalida
	*--------------------------------
	* Funcion   : Inicializa el vector de campos a enviar
	
	
	
	if cOpcion=="X"
		Continuar = PF_AgregaCampoSalida("X")
		* Se usa esta funci¢n para agregar los campos que se enviar n con el comando
		* Hay comandos que no llevan par metros, donde no es necesario usarla y
		* otros que llevan mas de uno y hay que repetirla para cada uno
		*--------------------------------
		* function PF_AgregaCampoSalida ( dato )
		*--------------------------------
		* Funcion   : Agrega un campo a el array de datos a enviar del comando
		* Entrada   : dato ( string a agregar )
		* Salida    : True Ejecuci¢n correcta
		
		Continuar = PF_AgregaCampoSalida("P")
		if Continuar .or. .T.
			if PF_EnviarComando( PF_CierreX )
				
				* Env¡a el comando con los campos cargados antes
				*--------------------------------
				*function PF_EnviarComando( Comando )
				*--------------------------------
				* Funci¢n   : Env¡a un comando a la impresora Fiscal
				* Entrada:
				*             comando= n£mero del comando que se ejecutara
				* Respuesta :
				*             true  ==> OK
				*             false ==> Problemas en la ejecuci¢n
				
				Continuar = .T.
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
				* Esta funci¢n puede ser usada en cualquier momento y sirve para
				* saber el estado de la impresora y el m¢dulo fiscal
				* especialmente cuando se produce un error de comando
				* Vea la funci¢n como ejemplo de an lisis de estado de la impresora
				*--------------------------------
				*function PF_MensajeEstado( opcion )
				*--------------------------------
				* Funci¢n   : Devuelve un string con el detalle del estado fiscal y de la impresora
				* Entrada:
				*             opcion = 1 estado de la impresora
				*                      2 estado fiscal
				* Respuesta :
				*             String con el detalle del estado
			endif
		endif
		if Continuar .or. .T.
			i=1
			do while PF_DatoRecibido[i] <> NIL .and. i <= 25
				fout( PF_DatoRecibido[i] )
				i = i + 1
				* PF_DatoRecibido[25] es un array que contiene los datos respondidos
				* por el impresor fiscal y el resto de los elementos inicializados
				* a NIL
			enddo
		endif
		
		
	elseif cOpcion == "Z"
		*--------------------------------------------
		* De este modo fuerzo un cierre de d¡a
		*--------------------------------------------
		Continuar =.T.
		*--------------------------------------------
		* Armado y env¡o del comando de Cierre de D¡a
		*--------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			Nada = PF_AgregaCampoSalida("Z")
			Nada = PF_AgregaCampoSalida("P")
			if PF_EnviarComando( PF_CierreZ )
				Continuar = .T.
				fout( "Cierre de D¡a" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor,"I" ) )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
				* La aplicaci¢n aca debe analizar por que se produjo el error del comando
			endif
		endif
		
		
	elseif cOpcion == "CANCELAR"
		Continuar =.T.
		*--------------------------------------------
		* Armado y env¡o del comando de Cancelacion
		*--------------------------------------------
		*--------------------------------------------
		* Armado y env¡o del comando de Pago
		*--------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida("CONTADO")
			nada = PF_AgregaCampoSalida("10000")
			nada = PF_AgregaCampoSalida("C")
			if PF_EnviarComando( PF_TQPago )
				Continuar = .T.
				fout( "Pago ingresado" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
     endif
		if Continuar .or. .T.
     	cAux := "ABCT"
     	for z=1 to len(cAux)
				do PF_IniciarSalida
				nada = PF_AgregaCampoSalida( "T" )
				nada = PF_AgregaCampoSalida( substr(cAux,z,1) )
				nada = PF_AgregaCampoSalida("TOTAL")
				if PF_EnviarComando( PF_FCCerrar )
					Continuar = .T.
					fout( "Tique cerrado "+ str( val(PF_DatoRecibido[3]) ) )
				else
					Continuar = .F.
					fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
					fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
				endif
        next z
		endif


	elseif cOpcion=="RE"
		*------------------------------------------
		* Armado y env¡o del comando de abrir Tique
		*------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			if PF_EnviarComando( PF_NFAbre )
				Continuar = .T.
				fout( "Abre Comprobante NF" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I", )
				fout( PF_MensajeEstado(PF_ModuloFiscal) ,"F" )
			endif
		endif

		*-------------------------------------------
		* Armado y env¡o del comando de Texto NO Fiscal
		*-------------------------------------------
		cRaya:=replic('-',40)
     aaux := {;
					cRaya,;
					"Remito     "+chr(34)+"X"+chr(34)+"     Nro.0000-"+strzero(nNUMERO,8),;
					"Nombre : "+ alltrim(str(nCODCLI,4))+' '+left(cCLIENTE,30),;
					"C.U.I.T :"+ cCUIT,;
					substr(FARRAY(aCatIva,cCATIVA),5),;
					cRaya,;
					"CANTIDAD/PRECIO UNIT",;
					"DESCRIPCION                      IMPORTE"}
*					cRaya }

		for f=1 to len(AXR)
			if AXR[f,RG_IMPORTE]#0
  			aadd( aaux, str(AXR[F,RG_CANTIDAD],10,3) +"/"+ str(AXR[F,RG_PRECUNIT],8,2) )
  			aadd( aaux, justif(AXR[F,RG_DESCPROD],30,"<") + str(AXR[F,RG_IMPORTE],10,2) )
			endif
		next
		aadd( aaux, cRaya )
		aadd( aaux, "T O T A L                     "+str(M->TOTAL,10,2) )
     for i=1 to 3;  aadd( aaux, "");  next
		aadd( aaux, "Firma ....................." )


		for zz=1 to len(aaux)
			if Continuar .or. .T.
				do PF_IniciarSalida
				nada = PF_AgregaCampoSalida( aaux[zz] )
				if PF_EnviarComando( PF_NFItem )
					Continuar = .T.
					fout( aaux[zz] )
				else
					Continuar = .F.
					fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
					fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
				endif
			endif
     next zz
		if Continuar .or. .T.
			do PF_IniciarSalida
			if PF_EnviarComando( PF_NFCerrar )
				Continuar = .T.
				fout( "Cierre Remito" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
		endif
		
		

	elseif cOpcion=="TI"
		*------------------------------------------
		* Armado y env¡o del comando de abrir Tique
		*------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			Nada = PF_AgregaCampoSalida("G")
			if PF_EnviarComando( PF_TQAbre )
				Continuar = .T.
				fout( "Abre Comprobante" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I", )
           cAux := PF_MensajeEstado(PF_ModuloFiscal)
				fout( cAux,"F" )
				aRet[F_ERRORES] := SPLIT(cAux)
			endif
		endif

		*-------------------------------------------
		* Armado y env¡o del comando de Texto Fiscal
		*-------------------------------------------
		if continuar
			do PF_IniciarSalida
			cCmdData = " Turno "+ cTurno
			nada = PF_AgregaCampoSalida( cCmdData )
			if PF_EnviarComando( PF_TQDescExtra )
				Continuar = .T.
				fout( cCmdData )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
		endif
		if continuar
			do PF_IniciarSalida
			cCmdData = "      D E S C R P C I O N"
			nada = PF_AgregaCampoSalida( cCmdData )
			if PF_EnviarComando( PF_TQDescExtra )
				Continuar = .T.
				fout( cCmdData )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
		endif
		for f=1 to len(AXR)
			if AXR[f,RG_CANTIDAD]#0
				*--------------------------------------------
				* Armado y env¡o del comando de Item de L¡nea
				*--------------------------------------------
				if Continuar .or. .T.
					do PF_IniciarSalida

					cCmdData = alltrim(left(AXR[F,RG_DESCPROD],20))
              fout( cCmdData,"³" )
					nada = PF_AgregaCampoSalida( cCmdData )

					cCmdData = str0(AXR[F,RG_CANTIDAD],7,3)
              fout( cCmdData,"³" )
					nada = PF_AgregaCampoSalida( cCmdData )

					cCmdData = str0(AXR[F,RG_PRECUNIT],8,2)
              fout( cCmdData, "³" )
					nada = PF_AgregaCampoSalida( cCmdData )

					cCmdData = str0(VA->PIVA1,5,2)
              fout( cCmdData, "³" )
					nada = PF_AgregaCampoSalida( cCmdData )

					nada = PF_AgregaCampoSalida("M")
					nada = PF_AgregaCampoSalida("1")
					nada = PF_AgregaCampoSalida("00000000")
					nada = PF_AgregaCampoSalida("00000000")
					* El comando PF_AgregaCampoSalida da error si se sobrepasan los 20 elementos
					if PF_EnviarComando( PF_TQItemDeLinea )
						Continuar = .T.
						fout( "Item " +str(F,2) + " Vendido" )
					else
						Continuar = .F.
						fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
						fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
					endif
				endif
        endif
     next F
		*--------------------------------------------
		* Armado y env¡o del comando de Subtotal
		*--------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida("P")
			nada = PF_AgregaCampoSalida("Subtotal")
			* El comando PF_AgregaCampoSalida da error si se sobrepasan los 20 elementos
			if PF_EnviarComando( PF_TQSubTotal )
				Continuar = .T.
				fout( "Subtotal Impreso" )
				aRet[F_CANTITEMS] := val(PF_DatoRecibido[4])
				aRet[F_TOTAL]     := val(stuff(PF_DatoRecibido[5],11,0,"."))
				aRet[F_IVA1]      := val(stuff(PF_DatoRecibido[6],11,0,"."))
				aRet[F_IMPINT]    := val(stuff(PF_DatoRecibido[9],11,0,"."))
				aRet[F_NETO]      := val(stuff(PF_DatoRecibido[10],11,0,"."))
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
			fout( PF_DatoRecibido )
		endif
#ifdef NADA
		*--------------------------------------------
		* Armado y env¡o del comando de Pago
		*--------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida("CONTADO")
			nada = PF_AgregaCampoSalida("10000")
			nada = PF_AgregaCampoSalida("T")
			* El comando PF_AgregaCampoSalida da error si se sobrepasan los 20 elementos
			if PF_EnviarComando( PF_TQPago )
				Continuar = .T.
				fout( "Pago ingresado" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
				* La aplicaci¢n aca debe analizar por que se produjo el error del comando
				* y tomar la decisi¢n si cancela el comprobante, o avisa que no hay papel
			endif
				i=1
				do while PF_DatoRecibido[i] <> NIL .and. i <= 25
					fout( PF_DatoRecibido[i] )
					i = i + 1
					* PF_DatoRecibido[25] es un array que contiene los datos respondidos
					* por el impresor fiscal y el resto de los elementos inicializados
					* a NIL
				enddo
		endif
#endif
		*----------------------------------------------
		* Armado y env¡o del comando de Cierre de Tique
		*----------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida("T")
			* El comando PF_AgregaCampoSalida da error si se sobrepasan los 20 elementos
			if PF_EnviarComando( PF_TQCerrar )
				Continuar = .T.
				fout( "Tique cerrado" )
           aRet[F_ULTTICK] := val(PF_DatoRecibido[3])
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
			fout( PF_DatoRecibido )
		endif
		*----------------------------------------------
		* Pide Fecha, Hora
		*----------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			if PF_EnviarComando( PF_PideHora )
				Continuar = .T.
				fout( "Pide Hora" )
           aRet[F_FECHA] := ctod( right(PF_DatoRecibido[3],2) +"/"+ substr(PF_DatoRecibido[3],3,2) +"/"+ left(PF_DatoRecibido[3],2) )
           aRet[F_HORA ] := stuff(PF_DatoRecibido[4],3,0,":")
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
			fout( PF_DatoRecibido )
		endif
		
		
		
	elseif cOpcion $ "FA FB "
     lHayCombustible := .F.
		for f=1 to len(AXR)
			if AXR[f,RG_CODPROD]#0 .and. PRD->(dbseek(AXR[F,RG_CODPROD]))
  			if PRD->CONSIG=="S"
        		lHayCombustible := .T.
     			exit
				endif
        endif
		next
		Continuar = PF_Sincronizar()
		
		*------------------------------------------
		* Armado y env¡o del comando de abrir Tiquet-Factura
		*------------------------------------------
		if Continuar .or. .T.
			
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida( "T" )           && Documento Tique-Factura
			nada = PF_AgregaCampoSalida( "C" )           && Formulario Continuo
			nada = PF_AgregaCampoSalida( substr(cOpcion,2) )  && Letra "A, B o C"
			nada = PF_AgregaCampoSalida( "1" )           && Copias
			nada = PF_AgregaCampoSalida( "F" )           && Preimpreso
			nada = PF_AgregaCampoSalida( "10" )          && CPI
			nada = PF_AgregaCampoSalida( "I" )           && Iva Vendedor
        if cCATIVA=="RI "
        	sCatIva := "I"
        elseif cCATIVA=="RNI"
        	sCatIva := "R"
        elseif cCATIVA=="EX "
        	sCatIva := "E"
        elseif cCATIVA=="RM "
        	sCatIva := "M"
        else
        	sCatIva := "F"
        endif
        sTipoDoc := "DNI"
        sCUIT  := " "
        if val(cCUIT)#0
        	sTipoDoc := "CUIT"
				sCUIT := strtran(cCUIT,"-","")
        endif
        fout( sCatIva +"³"+ cCLIENTE +"³"+ sTipoDoc +"³"+ sCUIT )
			nada = PF_AgregaCampoSalida( sCatIva )           		&& Resp Iva Comprador
			nada = PF_AgregaCampoSalida( cCLIENTE )   		 		&& Nombre Comprador
			nada = PF_AgregaCampoSalida( " " )   		 				&& Nombre Comprador
			nada = PF_AgregaCampoSalida( sTipoDoc )           		&& Tipo de documento o CUIT
			nada = PF_AgregaCampoSalida( sCUIT )  						&& Nro CUIT
			nada = PF_AgregaCampoSalida( "N" )                    && Bien de Uso
 			nada = PF_AgregaCampoSalida( "" )							&& Domi Comprador Linea 1
 			nada = PF_AgregaCampoSalida( "" )							&& Domi Comprador Linea 2
 			nada = PF_AgregaCampoSalida( "" )							&& Domi Comprador Linea 3
 			nada = PF_AgregaCampoSalida( "" )     						&& Remitos Linea 1
 			nada = PF_AgregaCampoSalida( "" )     						&& Remitos Linea 2
			nada = PF_AgregaCampoSalida( "C" )                    && Tipo de lista de almacenamiento
			
			if PF_EnviarComando( PF_FCAbre )
				Continuar = .T.
				fout( "Comprobante Abierto" )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
           cAux := PF_MensajeEstado(PF_ModuloFiscal)
				fout( cAux )
				aRet[F_ERRORES] := SPLIT(cAux)
			endif
		endif
		*--------------------------------------------
		* Armado y env¡o del comando de Item de L¡nea
		*--------------------------------------------
		for f=1 to len(AXR)
			if AXR[f,RG_CANTIDAD]#0
				if Continuar .or. .T.
					do PF_IniciarSalida
					sDescProd := alltrim(left(AXR[f,RG_DESCPROD],20))
					sCantidad := str0(AXR[f,RG_CANTIDAD],7,3)
              sTAj      := "00000000"
					sPiva     := str0( VA->PIVA1, 5, 2 )
					sPiva2    := "00000"
              sImpInt   := "00000000"
              sDescr2   := ""
              sDescr3   := ""
              sDescr4   := ""
              if cOpcion=="FA"
						sPrecio := str0(AXR[f,RG_TPRECBASE],8,2)
                 if AXR[f,RG_IMPINT] # 0
                		nAux    := AXR[f,RG_TPRECBASE] / ( AXR[f,RG_TPRECBASE] + AXR[f,RG_TIMPINT] )
            			sTAj    := right(str0(nAux,17,8),8)
 							sPrecio   := str0(1,8,2)
 							sCantidad := str0(AXR[f,RG_TPRECBASE],7,3)
                    sDescr2   := alltrim(str(AXR[f,RG_CANTIDAD],9,2)) +"x"+ alltrim(str(AXR[f,RG_PRECBASE],9,4))
                    if lHayCombustible
                       PRD->(dbseek(AXR[f,RG_CODPROD]))
                       if PRD->ITC<>0
                    		sDescr3 += "itc " +alltrim(str(PRD->ITC))
                       endif
                       if PRD->PPP<>0
                           sDescr3 += "  ppp " +alltrim(str(PRD->PPP))
                       endif
                    endif
                 else
							sPrecio := str0(AXR[f,RG_PRECBASE],8,2)
                 endif
              else
						sPrecio := str0(AXR[f,RG_PRECUNIT],8,2)
                 if AXR[f,RG_IMPINT] # 0
                 	nAux    := AXR[f,RG_TIVA1] / AXR[f,RG_IMPORTE]
            			sTAj    := right(str0( nAux, 17,8 ),8)
                    sPrecio   := str0(1,8,2)
                    sCantidad := str0(AXR[f,RG_IMPORTE],7,3)
                    sDescr2   := alltrim(str(AXR[f,RG_CANTIDAD],9,2)) +"x"+ alltrim(str(AXR[f,RG_PRECBASE],9,4))
                 endif
              endif
              fout( sDescProd +"³Cant:"+ sCantidad +"³Prec:"+ sPrecio +"³Iva:"+ sPiva +"³ta:"+ sTAj +"³ii:"+ sImpInt  )
     			if lHayCombustible
						//        "123456789-123456789-12345678
						sDescr4 := sDescr2
*						sDescr2 := "NAFTAS Y GASOIL POR"
*						sDescr3 := "CTA.Y ORDEN DE YPF"
 						sDescr2 := "NAFTAS/G.OIL x CT/O YPF"
     				lHayCombustible := .F.
     			endif

					nada = PF_AgregaCampoSalida( sDescProd )		&& Descripci¢n
					nada = PF_AgregaCampoSalida( sCantidad )		&& Cantidad  3,000
					nada = PF_AgregaCampoSalida( sPrecio )			&& Precio   12,50
					nada = PF_AgregaCampoSalida( sPiva )  			&& Tasa IVA 21,00%
					nada = PF_AgregaCampoSalida( "M" )				&& Monto vendido de mercaderia
					nada = PF_AgregaCampoSalida( "0" )				&& Bultos
					nada = PF_AgregaCampoSalida( sTAj )				&& Tasa de Ajuste Imp.Int.
 					nada = PF_AgregaCampoSalida( sDescr2 ) 		&& DEscrip adicional 2
 					nada = PF_AgregaCampoSalida( sDescr3 )			&& DEscrip adicional 3
 					nada = PF_AgregaCampoSalida( sDescr4 )			&& DEscrip adicional 4
 					nada = PF_AgregaCampoSalida( sPiva2 ) 			&& IVA Incremento no inscripto
					nada = PF_AgregaCampoSalida( sImpInt )			&& Imp.Int. monto fijo
					* El comando PF_AgregaCampoSalida da error si se sobrepasan los 25 elementos
					if PF_EnviarComando( PF_FCItemDeLinea )
						Continuar = .T.
						fout( "Primer Item Vendido" )
					else
						Continuar = .F.
						fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
						fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
					endif
           endif
			endif
     next
		*--------------------------------------------
		* Armado y env¡o del comando de Subtotal
		*--------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida("P")
			nada = PF_AgregaCampoSalida("Subtotal")
			if PF_EnviarComando( PF_TQSubTotal )
				Continuar = .T.
				fout( "Subtotal Impreso" )
				aRet[F_CANTITEMS] := val(PF_DatoRecibido[4])
				aRet[F_TOTAL]     := val(stuff(PF_DatoRecibido[5],11,0,"."))
				aRet[F_IVA1]      := val(stuff(PF_DatoRecibido[6],11,0,"."))
				aRet[F_IMPINT]    := val(stuff(PF_DatoRecibido[9],11,0,"."))
				aRet[F_NETO]      := val(stuff(PF_DatoRecibido[10],11,0,"."))
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
		endif
#ifdef NADA
		*--------------------------------------------
		* Armado y env¡o del comando de Pago
		*--------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida("Contado")
			nada = PF_AgregaCampoSalida(str0(aRet[F_TOTAL],8,2))
			nada = PF_AgregaCampoSalida("T")
			if PF_EnviarComando( PF_FCPago )
				Continuar = .T.
				fout( "Pago ingresado "+str0(aRet[F_TOTAL],8,2) )
				fout( "Saldo         " + PF_DatoRecibido[3] )
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
				* La aplicaci¢n aca debe analizar por que se produjo el error del comando
				* y tomar la decisi¢n si cancela el comprobante, o avisa que no hay papel
			endif
		endif
#endif
		*----------------------------------------------
		* Armado y env¡o del comando de Cierre de Tique
		*----------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			nada = PF_AgregaCampoSalida( "T" )
			nada = PF_AgregaCampoSalida( substr(cOpcion,2) )  && Letra "A, B o C"
			nada = PF_AgregaCampoSalida("TOTAL")
			* El comando PF_AgregaCampoSalida da error si se sobrepasan los 20 elementos
			if PF_EnviarComando( PF_FCCerrar )
				Continuar = .T.
				fout( "Tique cerrado "+ str( val(PF_DatoRecibido[3]) ) )
           aRet[if(cOpcion=="FA",F_ULTFACA,F_ULTFACB)] := val(PF_DatoRecibido[3])
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
		endif
		*----------------------------------------------
		* Pide Fecha, Hora
		*----------------------------------------------
		if Continuar .or. .T.
			do PF_IniciarSalida
			if PF_EnviarComando( PF_PideHora )
				Continuar = .T.
				fout( "Pide Hora" )
           aRet[F_FECHA] := ctod( right(PF_DatoRecibido[3],2) +"/"+ substr(PF_DatoRecibido[3],3,2) +"/"+ left(PF_DatoRecibido[3],2) )
           aRet[F_HORA ] := stuff(PF_DatoRecibido[4],3,0,":")
			else
				Continuar = .F.
				fout( PF_MensajeEstado( PF_ModuloImpresor ),"I" )
				fout( PF_MensajeEstado( PF_ModuloFiscal ),"F" )
			endif
			fout( PF_DatoRecibido )
		endif
	endif
endif

*----------------------------------------------------------------------
* Esta Funci¢n debe ser ejecutada para cerrar el puerto serie usado con
* la impresora antes de cerrar la aplicaci¢n
*----------------------------------------------------------------------
PF_PuertoCierra()
fclose( fHandle )
RECUPAN()

return aRet


*******************

FUNC FOUT( xString, cTipo, cSep )

*******************
DEFAULT cTipo TO ""

if valtype(xString)=="A"
	i=1
	do while xString[i] <> NIL .and. i <= 25
		cReg := xString[i]+CRLF
		bytes = FWRITE( fHandle, cReg, len(cReg) )
		i = i + 1
	enddo
else
	if cTipo=="I"
  	xString := "Estado Impresor: "+xString
	elseif cTipo=="F"
  	xString := "Estado Fiscal: "+xString
  endif
	cReg := xString + if(cSep==nil,CRLF,cSep)
	bytes = FWRITE( fHandle, cReg, len(cReg) )
endif

return .t.

*************************

FUNC STR0(nNum,nEnt,nDec)

*************************
local r:=""

r:=strtran(alltrim(str(nNum,nEnt,nDec)),".","")
r:=right(replic("0",nEnt)+r,nEnt)

return r


**********************

FUNC SPLIT( cAux, cSep )

**********************
local aaux:= {}

i:=at( chr(13)+chr(10), cAux )
do while i<> 0
	if !empty(left(cAux,i))
		aadd( aaux, left(cAux,i) )
  endif
  cAux := substr( cAux, i+2 )
	i:=at( chr(13)+chr(10), cAux )
enddo

return aaux
