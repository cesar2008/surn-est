FUNC FISCAL
#include "HFISCAL.CH"
#include "COMMON.CH"
#define Se    CHR(28)				//* Separador de campos
#define CRLF  CHR(13)+CHR(10)
***
*		39H  64   9
*		40H  64   @
*		41H  65   A
*		42H  66   B
*		43H  67   C
*		44H  68   D
*		45H  69   E
***
parameters cTipoCompr
public Handler

aRet:=array(F_ERRORES)
aeval(aRet,{|a,i|aRet[i]:=0},1,F_ERRORES-3)
aRet[F_FECHA]:=ctod("")
aRet[F_HORA]:=""
aRet[F_ERRORES]:={}
if EST->PORTFISCAL==0
	frlock("EST");  EST->PORTFISCAL:=1;   EST->(dbunlock())
	MENSAJE( 0, 0, 10, .T., "FALTA ESPECIFICAR EL PUERTO DEL CONTROLADOR FISCAL !" )
  aRet[F_ERRORES] := {"FALTA PUERTO DEL CONTROLADOR"}
  return aRet
endif
MENSAJE( 0, 0, 0, .F., "IMPRIMIENDO..." )

* Abro el Port de Comunicaciones
nPort := EST->PORTFISCAL
Handler = OpenPort (nPort)

If (Handler < 0)
    return aRet
endif

*na := if( file(cTipoCompr+".TXT"), fopen(cTipoCompr+".TXT",2), fcreate(cTipoCompr+".TXT",0) )
na := fcreate(cTipoCompr+".TXT",0)
*fseek(na,0,2)
cReg:=replic("-",20)+CRLF
cReg+=dtoc(dFECHA)+" "+ cTURNO +" "+ alltrim(str(nNUMERO))+" "+ time()+CRLF
bytes = FWRITE( na, cReg, len(cReg) )

* Inicializo el Printer
InitFiscal (Handler)

if cTipoCompr == "TI"
	PrintTicket ()
elseif cTipoCompr == "FA"
	PrintFact ("A")
elseif cTipoCompr == "FB"
	PrintFact ("B")
elseif cTipoCompr == "RE"
	PrintRemito ()
elseif cTipoCompr == "X"
	s = "9" + Se + "X"
	r := Enviar(s)
  if r=="-1"
  	aadd( aRet[F_ERRORES], "Error enviando el comando" )
  endif
elseif cTipoCompr == "Z"
  	// toma fecha y hora
  dAux := date()
  cAux := time()
	s = "Y"
	r := Enviar(s)
	aaux := SPLIT( r )
  if len(aaux)>2;  dAux := ctod(right(aaux[3],2) +'/'+ substr(aaux[3],3,2) +'/'+left(aaux[3],2));  endif
  if len(aaux)>3;  cAux  := left(aaux[4],2) +':'+ substr(aaux[4],3,2);  endif
  	//
	cAlias:=alias()
	s = "9" + Se + "Z"
	r := Enviar (s)
  aaux := SPLIT( r )
  FBASES({"+Z"})
  if !dbseek(cSUCURSAL+aaux[1])
  	add_rec()
  endif
  frlock()
  Z->SUCURSAL   := cSUCURSAL
  Z->NUMZ       := val(aaux[3])
  Z->FECHA      := dAux
  Z->HORA       := cAux
  Z->CANTDFCANC := val(aaux[4])
  Z->CANTDNFH   := val(aaux[5])
  Z->CANTDNF    := val(aaux[6])
  Z->CANTTI     := val(aaux[7])
  Z->ULTTI      := val(aaux[9])
  Z->ULTFA      := val(aaux[10])
  Z->TOTAL      := val(aaux[11])
  Z->TIVA1      := val(aaux[12])
  Z->TIMPINT    := val(aaux[13])
  Z->TNETO      := Z->TOTAL - Z->TIVA1 - Z->TIMPINT
  	// toma fecha y hora
	s = "Y"
	r := Enviar(s)
	aaux := SPLIT( r )
  if len(aaux)>2;  aRet[F_FECHA] := ctod(right(aaux[3],2) +'/'+ substr(aaux[3],3,2) +'/'+left(aaux[3],2));  endif
  if len(aaux)>3;  aRet[F_HORA]  := left(aaux[4],2) +':'+ substr(aaux[4],3,2);  endif
  dbcommit()
  dbunlock()
  F_ABASE({"Z"},"CERRAR")
  select (cAlias)
elseif cTipoCompr == "CANCELAR"
	s = "D" + Se + " " + Se + "0.00" + Se + "C" + Se + "0" 		//+ CHR(10)
	Enviar (s)
************
*	s = "D" + Se + "CANCELAR" + Se +"0" + Se + "C" + Se + "0"
*	Enviar (s)
*************
	s = "E"		// Cerrar DF
	Enviar (s)
	s = "J"		// Cerrar DNF
	Enviar (s)
elseif cTipoCompr == "GETDATETIME"
	s = "Y"
	r := Enviar(s)
	aaux := SPLIT( r )
  if len(aaux)>2;  aRet[F_FECHA] := ctod(right(aaux[3],2) +'/'+ substr(aaux[3],3,2) +'/'+left(aaux[3],2));  endif
  if len(aaux)>3;  aRet[F_HORA]  := left(aaux[4],2) +':'+ substr(aaux[4],3,2);  endif
endif

* Cierra el Port
ClosePort (Handler)
FCLOSE( na )
RECUPAN()

return aRet

******************

FUNC PrintFact( cCual )

******************
if cCATIVA=="RI "
  cFCATIVA:="I"
elseif cCATIVA=="RNI"
  cFCATIVA:="N"
elseif cCATIVA=="EX "
  cFCATIVA:="E"
elseif cCATIVA=="RM "
  cFCATIVA:="M"
* cFCATIVA:="C"
else
  cFCATIVA:="C"
endif


// C:CUIT
// 0:Libreta de enrolamiento
// 1:Libreta C¡vica
// 2:Documento Nacional de Identidad
// 3:Pasaporte
// 4:C‚dula de Identidad
if cFCATIVA=="C"			// Encabezado para CONS.FINAL
	s = "b" + Se + left(alltrim(cCLIENTE),30) + Se + " " + Se + "C" + Se + " "
elseif cFCATIVA=="M"			// Encabezado para MONOTRIBUTISTA
	s = "b" + Se + left(alltrim(cCLIENTE),30) + Se + strtran(cCUIT,"-","") + Se + "C" + Se + "C"
else
	s = "b" + Se + left(alltrim(cCLIENTE),30) + Se + strtran(cCUIT,"-","") + Se + cFCATIVA + Se + "C"
endif
Enviar (s)

if cCATIVA=="RM "
	s :=  "]" +Se+ "9" +Se+ "Responsable Monotributo"
	Enviar (s,.F.)
else
  s :=  "]" +Se+ "9" +Se+ chr(127)
	Enviar (s,.F.)
endif

lHayCombustible:=.F.
for f=1 to len(AXR)
	PRD->(dbseek(AXR[F,RG_CODPROD]))
  if PRD->CONSIG=="S"
		lHayCombustibles:=.T.
     exit
	endif
next

if cFCATIVA=="C"
	s :=  "]" +Se+ "12" +Se+ "Orientaci¢n al Cons."
	Enviar (s,.F.)
	s :=  "]" +Se+ "13" +Se+ "Prov. Bs.As. 0800-222-9042"
	Enviar (s,.F.)
else
  s :=  "]" +Se+ "12" +Se+ chr(127)
	Enviar (s,.F.)
  s :=  "]" +Se+ "13" +Se+ chr(127)
	Enviar (s,.F.)
endif

s = "@" + Se + cCual + Se + "T"
Enviar (s)

nCantItems := 0
n:=0
for f=1 to len(AXR)
	if AXR[f,RG_IMPORTE]#0
		* Texto Fiscal
*		s = "A" + Se + "Cantidad:"+str(AXR[F,RG_CANTIDAD],10,4) + Se + "0"
*		s = "A" + Se + "Cant.:"+alltrim(str(AXR[F,RG_CANTIDAD],10,2)) + "  PU $"+alltrim(str(AXR[F,RG_PRECUNIT],10,3))+ Se + "0"

     if lHayCombustible //.and. cTipoCompr=="FA"
        s := ""
     	PRD->(dbseek(AXR[f,RG_CODPROD]))
        if PRD->ITC<>0
        	s += "itc " +alltrim(str(PRD->ITC))
        endif
        if PRD->PPP<>0
        	s += "  TH " +alltrim(str(PRD->PPP))
        endif
			s = "A" + Se + s + Se + "0"
 			Enviar (s)
     endif

*		s = "A" + Se + "Cnt:"+alltrim(str(AXR[F,RG_CANTIDAD],10,2)) + " C¢d:"+alltrim(str(AXR[F,RG_CODPROD],6))+ Se + "0"
		s = "A" + Se + "C:"+alltrim(str(AXR[F,RG_CANTIDAD],10,2)) +" II$"+alltrim(str(AXR[F,RG_IMPINT],10,3)) +" PU$"+alltrim(str(AXR[F,RG_PRECUNIT],10,3)) +Se+ "0"
		Enviar (s,.F.)

		if AXR[F,RG_IMPINT] == 0
			nCII := 0
     else
			nCII := 1 / ( 1 + ( AXR[F,RG_IMPINT] / AXR[F,RG_PRECBASE] ) )
		endif
     nPIVA:=if(AXR[F,RG_IVA1]==0,0,VA->PIVA1)

*		nPU := round(AXR[F,RG_PRECUNIT],2)
*		nCant2 := AXR[F,RG_IMPORTE] / nPU
     nCant2 := 1
		nPU := round(AXR[F,RG_IMPORTE],2)
		s2 := "B" + Se +;
			alltrim(left(AXR[F,RG_DESCPROD],20))+;
			Se+ alltrim(str(nCant2,14,10))+;
 			Se+ alltrim(str(nPU,9,2))+;
			Se+ alltrim(str(nPIVA,5,2))+;
			Se+ "M"+;
			Se+ +"+"+ alltrim(str(nCII,10,8))+;
			Se+ "0"+;
			Se+ "T"
     do while .T.
			Enviar (s2)
			s = "C" + Se + " " + Se +"0" + Se + "0"     // Subtotal
			aaux:=SPLIT( Enviar(s) )
        // si cambi¢ la cantidad de Items est  bien y sale
			if len(aaux)>2
				if val(aaux[3]) # nCantItems
					nCantItems := val(aaux[3])
           	exit
           endif
			endif
     enddo

*    if AXR[F,RG_DESCUENTO] # 0
*    	s = "U" +"descuento"+ str(AXR[F,RG_DESCUENTO],9,2) +Se+ "m" +Se+ "0" +Se+ " "
*			Enviar (s)
*    endif
	endif
next

s = "C" + Se + " " + Se +"0" + Se + "0"     // Subtotal
aaux:=SPLIT( Enviar(s) )
if len(aaux)>2;  aRet[F_CANTITEMS] :=val(aaux[3]);  endif
if len(aaux)>3;  aRet[F_TOTAL] :=val(aaux[4]);  endif
if len(aaux)>4;  aRet[F_IVA1] :=val(aaux[5]);  endif
if len(aaux)>6;  aRet[F_IVA2] :=val(aaux[7]);  endif

if cCATIVA=="RNI"		//Corrige el IVA p/RNI
	s="a" +Se+ str(M->TIVA2,9,2)
	Enviar(s)
endif

if M->TPERCIB<>0
	cAux := alltrim(str(M->TPERCIB,9,2))
	s = "`" + Se + "**.**" + Se+ "IIBB          " +Se + cAux
	Enviar (s)
endif


s = "D" + Se + " " + Se+ alltrim(str(M->TOTAL,10,2)) +Se + "T" + Se + "0"
Enviar (s)


s = "E"			// Cierra Comprobate Fiscal
aaux := SPLIT( Enviar(s) )
if len(aaux)>2
	if cCual=="A"
		aRet[F_ULTFACA] := val(aaux[3])
	elseif cCual=="B"
		aRet[F_ULTFACB] := val(aaux[3])
	endif
endif

s = "Y"					// Lee Fecha y Hora
aaux := SPLIT( Enviar (s) )
if len(aaux)>2;  aRet[F_FECHA] := ctod(right(aaux[3],2) +'/'+ substr(aaux[3],3,2) +'/'+left(aaux[3],2));  endif
if len(aaux)>3;  aRet[F_HORA]  := left(aaux[4],2) +':'+ substr(aaux[4],3,2);  endif

return 0


********************

FUNC PrintTicket

********************
* Abre Ticket
s = "@" + Se + "T" + Se + "T"
Enviar (s)

	s :=  "A" + Se + "Orientaci¢n al Cons." + Se + "0"
	Enviar (s,.F.)
	s :=  "A" + Se + "Bs.As.0800-222-9042" + Se + "0"
	Enviar (s,.F.)

* Texto Fiscal
s = "A" + Se + "       D E S C R I P C I O N" + Se + "0"
Enviar (s)

nCantItems := 0
n:=0
for f=1 to len(AXR)
	if AXR[f,RG_IMPORTE]#0
		if AXR[F,RG_IMPINT] == 0
			nCII := 0
     else
			nCII := 1 / ( 1 + ( AXR[F,RG_IMPINT] / AXR[F,RG_PRECBASE] ) )
		endif
     nPIVA:=if(AXR[F,RG_IVA1]==0,0,VA->PIVA1)

		s2 := "B" + Se +;
			alltrim(left(AXR[F,RG_DESCPROD],20))+;
			Se+ alltrim(str(AXR[F,RG_CANTIDAD],7,3))+;
 			Se+ alltrim(str(AXR[F,RG_PRECUNIT],9,2))+;
			Se+ alltrim(str(nPIVA,5,2))+;
			Se+ "M"+;
			Se+ +"+"+ alltrim(str(nCII,7,5))+;
			Se+ "0"+;
			Se+ "T"
     do while .T.
			Enviar (s2)
			s = "C" + Se + " " + Se +"0" + Se + "0"     // Subtotal
			aaux:=SPLIT( Enviar(s) )
        // si cambi¢ la cantidad de Items est  bien y sale
			if len(aaux)>2
				if val(aaux[3]) # nCantItems
					nCantItems := val(aaux[3])
           	exit
           endif
			endif
     enddo

	endif
next

s = "C" + Se + " " + Se +"0" + Se + "0"     // Subtotal
aaux:=SPLIT( Enviar(s) )
if len(aaux)>2;  aRet[F_CANTITEMS] :=val(aaux[3]);  endif
if len(aaux)>3;  aRet[F_TOTAL] :=val(aaux[4]);  endif
if len(aaux)>4;  aRet[F_IVA1] :=val(aaux[5]);  endif
if len(aaux)>6;  aRet[F_IVA2] :=val(aaux[7]);  endif

s = "D" + Se + "TOTAL" + Se+ alltrim(str(M->TOTAL,10,2)) +Se + "T" + Se + "0"
Enviar (s)

s = "E"			// Cierra Comprobate Fiscal
r := Enviar(s)
aaux:=SPLIT( r )
if len(aaux)>2
	aRet[F_ULTTICK] := val(aaux[3])
endif

s = "Y"					// Lee Fecha y Hora
aaux := SPLIT( Enviar (s) )
if len(aaux)>2;  aRet[F_FECHA] := ctod(right(aaux[3],2) +'/'+ substr(aaux[3],3,2) +'/'+left(aaux[3],2));  endif
if len(aaux)>3;  aRet[F_HORA]  := left(aaux[4],2) +':'+ substr(aaux[4],3,2);  endif

return 0

**********************

FUNC PrintRemito()

**********************
zz2 := 2
#ifdef SUR
	zz2 := 1
#endif
for zz=1 to zz2
	*Abre comprobante NO FISCAL
	s = "H"
	Enviar (s)

	cRaya:=replic('-',40)
	s = "I" +Se+ cRaya +Se+ "0";  Enviar(s)
	s = "I" +Se+ "Remito     "+chr(34)+"X"+chr(34)+"     Nro.0000-"+strzero(nNUMERO,8) +Se+ "0";  Enviar(s)
	s = "I" +Se+ "Nombre : "+ alltrim(str(nCODCLI,4))+' '+left(cCLIENTE,30) +Se+"0";  Enviar(s)
	s = "I" +Se+ "C.U.I.T :"+ cCUIT +Se+"0";  Enviar(s)
	s = "I" +Se+ substr(FARRAY(aCatIva,cCATIVA),5) +Se+"0";  Enviar(s)
	s = "I" +Se+ cRaya +Se+ "0";  Enviar(s)
	s = "I" +Se+ "CANTIDAD/PRECIO UNIT" +Se+ "0";  Enviar(s)
	s = "I" +Se+ "DESCRIPCION                      IMPORTE" +Se+ "0";  Enviar(s)

	n:=0
	cAux := ""
	for f=1 to len(AXR)
		if AXR[f,RG_IMPORTE]#0
  		s := str(AXR[F,RG_CANTIDAD],10,3) +"/"+ str(AXR[F,RG_PRECUNIT],9,3)
			s = "I" +Se+ s +Se+ "0";  Enviar(s)
  		s := justif(AXR[F,RG_DESCPROD],30,"<") + str(AXR[F,RG_IMPORTE],10,2)
			s = "I" +Se+ s +Se+ "0";  Enviar(s)
		endif
	next
	s = "I" +Se+ cRaya +Se+ "0";  Enviar(s)
	s = "I" +Se+ chr(244)+"TOTAL     "+str(M->TOTAL,10,2) +Se+ "0";  Enviar(s)

#ifdef SUR
#else
	if zz==1
		for z=1 to 3
			s = "I" +Se+ " " +Se+ "0";  Enviar(s)
		next
		s = "I" +Se+ "Firma ....................." +Se+ "0";  Enviar(s)
  endif
#endif

	s = "J"			// Cierra Comprobate NO FISCAL
	aaux := SPLIT( Enviar(s) )
next zz

s = "Y"					// Lee Fecha y Hora
aaux := SPLIT( Enviar (s) )
if len(aaux)>2;  aRet[F_FECHA] := ctod(right(aaux[3],2) +'/'+ substr(aaux[3],3,2) +'/'+left(aaux[3],2));  endif
if len(aaux)>3;  aRet[F_HORA]  := left(aaux[4],2) +':'+ substr(aaux[4],3,2);  endif

return 0


*************************

FUNCTION Enviar( String, lConError )

*************************
private Result
DEFAULT lConError TO .T.

cReg := "Comm: " + String +CRLF;  bytes = FWRITE( na, cReg, len(cReg) )

* Si la funcion MandaPaq retorna un numero menor que cero retornar el
* error para arriba.
* Esto puede ser por un problema de comunicaciones con el impresor.
for i=1 to 3		// Intenta 3 veces
	nn:= MandaPaq (Handler, String)
  if nn>=0;  exit;  endif
next
IF nn < 0
	cReg := "Error enviando el comando" +CRLF
	bytes = FWRITE( na, cReg, len(cReg) )
	return "-1"
ENDIF

* Levanta la respuesta.
Result = Respuesta (Handler)

cReg:= "Resp: " +Result +CRLF;  bytes:= FWRITE( na, cReg, len(cReg) )

if lConError
	* Analiza si existe algun error.
	GetErrors (Result)
endif

return Result


****
FUNCTION GetErrors( Resp )
*
* Esta funcion levanta la respuesta del printer e imprime 
* el mensaje de error si es que existe.
****
private Origen, OffsetSep, i, c

declare FiscalErrors [16]
declare PrinterErrors[16]

FiscalErrors[1] = 	"Error en chequeo de memoria fiscal"
FiscalErrors[2] = 	"Error en chequeo de la memoria de trabajo"
FiscalErrors[3] = 	"Carga de bateria baja"
FiscalErrors[4] = 	"Comando desconocido"
FiscalErrors[5] = 	"Datos no validos en un campo"
FiscalErrors[6] = 	"Comando no valido para el estado fiscal actual"
FiscalErrors[7] = 	"Desborde del total"
FiscalErrors[8] = 	"Memoria fiscal llena"
FiscalErrors[9] = 	"Memoria fiscal a punto de llenarse"
FiscalErrors[10] = 	""
FiscalErrors[11] = 	""
FiscalErrors[12] = 	"Error en ingreso de fecha"
FiscalErrors[13] = 	"Recibo fiscal abierto"
FiscalErrors[14] = 	"Recibo abierto"
FiscalErrors[15] = 	"Factura abierta"
FiscalErrors[16] = 	""

PrinterErrors[1]  = ""
PrinterErrors[2]  = ""
PrinterErrors[3]  = "Error de Impresora"
PrinterErrors[4]  = "Impresora Offline"
PrinterErrors[5]  = "Falta papel del diario"
PrinterErrors[6]  = "Falta papel de tickets"
PrinterErrors[7]  = "Buffer de Impresora lleno"
PrinterErrors[8]  = ""
PrinterErrors[9]  = ""
PrinterErrors[10] = ""
PrinterErrors[11] = ""
PrinterErrors[12] = ""
PrinterErrors[13] = ""
PrinterErrors[14] = ""
PrinterErrors[15] = "Caj¢n Abierto"
PrinterErrors[16] = ""

Origen = 0

OffsetSep = at ( Se, Resp )

* Convierte en hexa el status del impresor
PrinterStatus = HexaToInt (substr ( Resp, Origen, OffsetSep - 1))

if PrinterStatus < 0
	return -1
endif
Origen = OffsetSep

* Analiza los bits comenzando del menos significativo
for i = 1 to 16
	if ( int (PrinterStatus % 2) == 1 )
		if ( len (PrinterErrors[i]) > 0 )
			if !"" $ PrinterErrors[i]
				cReg:= PrinterErrors[i] +CRLF;  bytes:= FWRITE( na, cReg, len(cReg) )
				aadd( aRet[F_ERRORES], PrinterErrors[i] )
        endif
		endif
	endif
	PrinterStatus = PrinterStatus / 2	
next

OffsetSep = at ( Se, substr (Resp, Origen + 1) )

if OffsetSep == 0
	OffsetSep = len(Resp)
endif

* Convierte en hexa el status fiscal
FiscalStatus = HexaToInt (substr (Resp, Origen + 1, OffsetSep - 1))

if FiscalStatus < 0
	return -1
endif


* Analiza los bits comenzando del menos significativo
for i = 1 to 16
	if ( int (FiscalStatus % 2) == 1 )
		if ( len(FiscalErrors[i]) > 0 )
			if !"" $ FiscalErrors[i]
				cReg:= FiscalErrors[i] +CRLF;  bytes:= FWRITE( na, cReg, len(cReg) )
				aadd( aRet[F_ERRORES], FiscalErrors[i] )
        endif
		endif
	endif
	FiscalStatus = FiscalStatus / 2	
next

return 0


****
* FUNCTION HexaToInt 
*
* Esta funcion convierte un numero hexadecimal en su equivalente
* en binario.
****

FUNCTION HexaToInt 

PARAMETERS HexValue

PRIVATE i, Value, Status

Status = 0

FOR i = 4 TO 1 STEP -1

	Value = ASC (SUBSTR(HexValue, i, 1))

	IF ( Value >= ASC("A") .AND. Value <= ASC("F") )

		Value = Value - ASC("A") + 10

	ELSEIF ( Value >= ASC("a") .AND. Value <= ASC("f") )


        Value = Value - ASC("a") + 10
	ELSEIF ( Value >= ASC("0") .AND. Value <= ASC("9") )

		Value = Value - ASC("0")

	ELSE
		? "HexaToInt: Numero hexadecimal incorrecto: " + HexValue
		RETURN -1
	ENDIF

	Status = Status + Value * (16 ** ( 4 - i ))

NEXT

RETURN Status


*************************

STATIC FUNC SPLIT( Resp )

*************************
local i
aaux:={}

if valtype( Resp )=="C"
	i = at ( Se, Resp )
	do while i#0
		aadd( aaux, left(Resp,i-1) )
  	Resp := substr(Resp,i+1)
		i = at ( Se, Resp )
	enddo
	aadd( aaux, Resp )
endif

return aaux
