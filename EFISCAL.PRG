FUNC FISCAL
parameters cOpcion

#include "INKEY.CH"
#include "COMMON.CH"
#include "FDL_CLP.CH" 	// Soporte para Impresora Fiscal para CA-Clipper
// bajo DOS
// E: Fiscal Printer DOS for CA-Clipper support
#define  FDOS_SAMPLE_OP_STATUSREQ 				1
#define  FDOS_SAMPLE_OP_FEEDRECEIPT 			2
#define  FDOS_SAMPLE_OP_DAILYCLOSE_X			10
#define  FDOS_SAMPLE_OP_DAILYCLOSE_Z			11
#define  FDOS_SAMPLE_OP_FISCALOPEN				20
#define  FDOS_SAMPLE_OP_FISCALTEXT				21
#define  FDOS_SAMPLE_OP_FISCALITEM_1			22
#define  FDOS_SAMPLE_OP_FISCALITEM_2			23
#define  FDOS_SAMPLE_OP_FISCALTOTAL 			24
#define  FDOS_SAMPLE_OP_FISCALCLOSE 			25
#define  FDOS_SAMPLE_OP_FISCALSUBTOTAL      26
#define  FDOS_SAMPLE_OP_NONOPEN 				30
#define  FDOS_SAMPLE_OP_NONTEXT 				31
#define  FDOS_SAMPLE_OP_NONCLOSE				32

#define  FDOS_SAMPLE_OP_FISCALDUMP				100
//--- #define  FDOS_SAMPLE_OP_

// IDs para posiciones
// E: position IDs
#define  FDOS_POS_VALUE 				 1
#define  FDOS_POS_NAME					 2
#define  FDOS_POS_FIELDS				 3
#define  FDOS_POS_CODE					 4
#define  FDOS_POS_CMDDATA 			 5
#define  FDOS_POS_DATA					 6	// sin uso [E: unused (old)]

//--- #define  FDOS_API_PAR 					 /* ( */ @cCmdData, @cAnswer, @nApiRc /* ) */

#define  _FDL_DEMO_KEY_ABOUT				K_F1
#define  _FDL_DEMO_KEY_ABOUT_STR		"F1"

#define  FDOS_CODEBLOCK_API( apifun ) 	{  | cSrc, cAnswer, nApiRc | apifun ( @cSrc, @cAnswer, @nApiRc ) }

// errorlevels
#define  FDOS_SAMPLE_ERRORLEVEL_OK					 0
#define  FDOS_SAMPLE_ERRORLEVEL_ERROR 			 1
#define  CRLF   CHR(13)+CHR(10)

DEFAULT cOpcion TO "T"

// Variables locales
private cAnswer := "", cCmdData, nApiRc, bApiCall,;
	cField, lCmdAnswer, lCmdSuccess, lTemp,;
	cSep := FDOS_FLDSEP_STR,;
			nOptionID,;
			cOptionString,;
			nQtyFields
// Variables estaticas y globales
public	scLastResp

MENSAJE(0,0,0,.F.,"IMPRIMIENDO...")

// setea algunos defaults
lCmdSuccess := .T.
nQtyFields := 0
cCmdData := ""
FD_VERIFY_OPTIONAL bApiCall TYPE "B" DEFAULT {|| .T. }

lAux:=.F.
//	bLastErr := ErrorBlock()
//	bErr     := ErrorBlock( { |eObj| FISCAL_ERROR(eObj) } )
begin sequence
	na := if( file("Q.TXT"), fopen("Q.TXT",2), fcreate("Q.TXT",0) )
	fseek(na,0,2)
	cEnc:=replic("-",20)+CRLF
	cEnc+=dtoc(dFECHA)+" "+ cTURNO +" "+ alltrim(str(nNUMERO))+" "+ time()+CRLF

	nOptionID 		:= FDOS_SAMPLE_OP_STATUSREQ
	cOptionString := "Status Request"
	nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_STATUSREQ
	cCmdData			:= ""
	bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_STATUSREQ )
  if cOpcion $ "ZX"
		MANDAR(.f.)
  else
		if !MANDAR();  break;  endif
  endif

	if cOpcion=="T"
		cOptionString := "Fiscal Open"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALOPEN
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALOPEN
		cCmdData			:= ""
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALOPEN )
		lAux:=MANDAR()

		cOptionString := "Fiscal Text"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALTEXT
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALTEXT
		cCmdData			:= " Turno "+ cTurno
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALTEXT )
		MANDAR()
		cOptionString := "Fiscal Text"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALTEXT
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALTEXT
		cCmdData			:= "          D E S C R P C I O N"
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALTEXT )
		lAux:=MANDAR()

		n:=0
		for f=1 to len(AXR)
			if AXR[f,RG_IMPORTE]#0

				if AXR[F,RG_IMPINT] == 0
					nTAJ := 0
           else
					nDif := AXR[F,RG_PRECUNIT] - (AXR[F,RG_IMPINT]+AXR[F,RG_PRECBASE])
					nDif := nDif * 100 / AXR[F,RG_PRECUNIT]
           	nDif := if(nDif<0,0,nDif)
					nTAJ := nDif * 1000000
           endif

           nPIVA:=if(AXR[F,RG_IVA1]==0,0,VA->PIVA1)

				cOptionString := "Fiscal iTEM #1"
				nOptionID 		:= FDOS_SAMPLE_OP_FISCALITEM_1
				nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALITEM
				cCmdData			:= alltrim(left(AXR[F,RG_DESCPROD],20))+;
										cSep+ str0(AXR[F,RG_CANTIDAD],7,3)+;
 										cSep+ str0(AXR[F,RG_PRECUNIT],8,2)+;
										cSep+ str0(nPIVA,5,2)+;
										cSep+ "M"+;
										cSep+ "00001"+;
										cSep+ strzero(nTAJ,8)
				bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALITEM )
				lAux:=MANDAR()		//;  if !lAux;  exit;  endif
*          inkey(.5)
			endif
		next

 		cOptionString := "Subtotal"
 		nOptionID 		:= FDOS_SAMPLE_OP_FISCALSUBTOTAL
 		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALSUBTOTAL
 		cCmdData			:= " "+ cSep+ "000000000"+ cSep + "P"
 		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALSUBTOTAL )
 		lAux:=MANDAR()
		cAux := FDGetField( cAnswer, 5, @cField )
		nT := val(stuff( cField, 11, 0, "." ))

		cOptionString := "Fiscal Total"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALTOTAL
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALTOTAL
		cCmdData			:= " "+ cSep+ "000000000"+ cSep + "T"
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALTOTAL )
		lAux:=MANDAR()

		cOptionString := "Fiscal Close"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALCLOSE
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALCLOSE
		cCmdData			:= ""
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALCLOSE )
		lAux:=MANDAR()
     nUT := val(substr(scLastResp,rat(chr(28),scLastResp)+1))

	elseif cOpcion=="X"
		cOptionString := "Fiscal X"
		nOptionID 		:= FDOS_SAMPLE_OP_DAILYCLOSE_X
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_DAILYCLOSE
		cCmdData			:= "X" + cSep + "P"
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_DAILYCLOSE )
		lAux:=MANDAR(.F.)

	elseif cOpcion=="Z"
		cOptionString := "Fiscal Z"
		nOptionID 		:= FDOS_SAMPLE_OP_DAILYCLOSE_Z
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_DAILYCLOSE
		cCmdData			:= "Z"
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_DAILYCLOSE )
		lAux:=MANDAR(.F.)

	elseif cOpcion=="C"
		cOptionString := "Fiscal Open"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALOPEN
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALOPEN
		cCmdData			:= ""
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALOPEN )
		MANDAR()

		cOptionString := "Fiscal Total"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALTOTAL
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALTOTAL
		cCmdData			:= " "+ cSep+ "000000000"+ cSep + "T"
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALTOTAL )
		MANDAR()

		cOptionString := "Fiscal Close"
		nOptionID 		:= FDOS_SAMPLE_OP_FISCALCLOSE
		nQtyFields		:= FDOS_QTY_STATUSFIELDS + FDOS_QTY_FLDS_FISCALCLOSE
		cCmdData			:= ""
		bApiCall			:= FDOS_CODEBLOCK_API( _FDOS_FCMD_EXTERNAL_FISCALCLOSE )
		MANDAR()

	endif
	break
end sequence
//	ErrorBlock(bLastErr)
FCLOSE( na )
RECUPAN()

return lAux


*************

FUNC MANDAR( lVerificarErrores )

*************
local nMal:=0
DEFAULT lVerificarErrores TO .T.

// preparar los datos del comando
#ifdef	 FDOS_SEPARATORATBEGINNING
if len( cCmdData ) > 0
	cCmdData := cSep + cCmdData
endif
#endif	 // FDOS_SEPARATORATBEGINNING

do while .T.
	aErrores:={}
	// llama funcion del API
	lCmdAnswer := eval( bApiCall, @cCmdData, @cAnswer, @nApiRc )
	// hacer la accion necesaria
	scLastResp := cAnswer
  if ascan({0,128},int(val(substr(cAnswer,2))))==0
 		if ++nMal < 3
  		loop
     endif
  endif

	// actualiza la bandera de continuacion
	lCmdSuccess := (lCmdAnswer)
*****************************
if nMal > 0
	cReg:=cEnc; cEnc:=""
	cReg:="cOptionString:"+ cOptionString+CRLF
	cReg+="Data Sent: " + cCmdData+CRLF
	cReg+="Full Answer: " + cAnswer+CRLF
	for nI := 1 to nQtyFields
		lTemp := FDGetField( cAnswer, nI, @cField )
		cReg+= "field #" + alltrim(str(nI)) + ": " + iif( lTemp, cField, "<error>" )+CRLF
	next
	bytes = FWRITE( na, cReg, len(cReg) )
endif
*****************************
  if lVerificarErrores
		if lCmdSuccess
*			aErrores:=DemoShwBits()
			if len(aErrores) > 0
				++nMal
     	else
     		exit
  		endif
  	else
  		++nMal
		endif
  	if nMal>0
			if !lCmdSuccess
				// muestra la respuesta del comando
				aErrores:={ "Error de Estado: Api RC: " + alltrim( str( nApiRc ) ) + " [" + DescApiRc( nApiRc ) + "]" }
        endif
  		exit
  	endif
  else
  	exit
  endif
enddo
if len(aErrores) > 0
	MARCO( 10, 10, 10+len(aErrores)-1, 70, "<< ERROR >>", "D", .T., 0 )
  for i=1 to len(aErrores)
  	@ 10+i-1,10 say aErrores[i] color C_MENSAJE1
  next
	inkey(10)
  RECUPAN()

 	SET CONSOLE OFF
 	SET ALTERNATE TO QQ ADDITIVE
 	SET ALTERNATE ON
  ? replic("-",30)
  ? dFECHA, cTURNO, nNUMERO, time()
  ? replic("-",30)
	? "cOptionString:", cOptionString
	for i=1 to len(aErrores)
  	? "////", aErrores[i]
  next
	// muestra los datos enviados
	? "Data Sent: " + cCmdData

	// muestra los datos recibidos como respuesta
	? "Full Answer: " + cAnswer
	for nI := 1 to nQtyFields
		lTemp := FDGetField( cAnswer, nI, @cField )

		? "field #" + alltrim(str(nI)) + ": " + iif( lTemp, cField, "<error>" )

		// implement? hex conversion?
		// show hex conversion
		// if lTemp .and. 1 <= nI .and. nI <= 2
			// ?? " (0x" + alltrim(...) + ")"
		// endif

		// actualiza la variable global con la ultima respuesta
	next
 	SET ALTERNATE TO
 	SET CONSOLE ON
	lCmdAnswer := .F.
endif

return lCmdAnswer


**************************************
// 'explica' el codigo de retorno del API del usuario
function DescApiRc( nApiRc, lSuccess )
**************************************
local cDesc := ""
static	 aRcDescArray := { ;
			{  FDOS_DRV_SUCCESS, "Ok", .T. },;
			{  FDOS_DRV_NOAPIFUNCALLED, "No se llamo ninguna funcion de bajo nivel", .F. },;
			{  FDOS_DRV_UNKNOWNRETCODE, "Codigo de retorno desconocido", .F. },;
			{  FDOS_DRV_INVALIDFUNCTION, "Funcion invalida", .F. },;
			{  FDOS_DRV_FILENOTFOUND, "Archivo no encontrado", .F. },;
			{  FDOS_DRV_PATHNOTFOUND, "Ruta de acceso no encontrada", .F. },;
			{  FDOS_DRV_NOHANDLES, "No quedan manejadores de archivos", .F. },;
			{  FDOS_DRV_ACCESSDENIED, "Acceso denegado", .F. },;
			{  FDOS_DRV_INVALIDHANDLE, "Manejador invalido", .F. },;
			{  FDOS_DRV_INVALIDACCESSCODE, "Codigo de acceso invalido", .F. },;
			{  FDOS_DRV_SENDFAILED, "Fallo el envio", .F. },;
			{  FDOS_DRV_RECIEVEFAILED, "Fallo la recepcion", .F. } ;
			}
// verifica parametros
FD_VERIFY_OPTIONAL lSuccess TYPE "L" DEFAULT .T.

// busca el codigo de retorno y devuelve el string
if lSuccess
	lSuccess := .F.
	aeval( aRcDescArray, {| aElem | ;
	lSuccess := iif( lSuccess, lSuccess, ;
	iif( aElem[ 1 ] == nApiRc, ;
	eval( {| cElem | cDesc := cElem, .T. }, ;
				aElem[ 2 ] ;
		 ), ;
	lSuccess ;
		 ) ;
		 ) ;
} )
endif

return ( cDesc )
// End Function


// muestra los bits de la ultima respuesta
function DemoShwBits()
static	 caPrnStBits := { 													;
	 {	FDOS_FP_BIT_ERRORFAILED,												;
		FDOS_FP_BIT_ERRORFAILED,												;
		"Error/falla de impresora", 0 },									 	;
	 {	FDOS_FP_BIT_OFFLINE,														;
		FDOS_FP_BIT_OFFLINE,														;
		"Impresora fuera de linea", 0 },									 	;
	 {	FDOS_FP_BIT_JOURNALLOW, 												;
		FDOS_FP_BIT_JOURNALLOW, 												;
		"Poco papel para la cinta de auditoria", 0 }, 		 			;
	 {	FDOS_FP_BIT_RECEIPTLOW, 												;
		FDOS_FP_BIT_RECEIPTLOW, 												;
		"Poco papel para comprobantes o Tickets", 0 },		 			;
	 {	FDOS_FP_BIT_BUFFERFULL, 												;
		FDOS_FP_BIT_BUFFERFULL, 												;
		"Buffer de impresora lleno" },										;
	 {	FDOS_FP_BIT_BUFFEREMPTY,												;
		FDOS_FP_BIT_BUFFEREMPTY,												;
		"Buffer de impresora vacio" },										;
	 {	FDOS_FP_BIT_SLIPPREPARED, 											 	;
		FDOS_FP_BIT_SLIPPREPARED, 												;
		"Toma de hojas sueltas frontal separada", 0 },		 			;
	 {	FDOS_FP_BIT_SLIPPAPER,													;
		FDOS_FP_BIT_SLIPPAPER,													;
		"Hoja suelta frontal preparada", 0 }, 						 		;
	 {	FDOS_FP_BIT_VALIDPREPARED,												;
		FDOS_FP_BIT_VALIDPREPARED,												;
		"Toma de hojas para validacion preparada" },			 			;
	 {	FDOS_FP_BIT_VALIDPAPER, 												;
		FDOS_FP_BIT_VALIDPAPER, 												;
		"Papel para la validacion presente", 0 }, 				 		;
	 {	FDOS_FP_BIT_LOGICALOR_0_6,												;
		FDOS_FP_BIT_LOGICALOR_0_6,												;
		"OR logico entre los bits 0-6" }									 	;
			},																			;
	 caFisStBits := { 															;
	 {	FDOS_FS_BIT_FISCALMEMCHKFAILED, 								 		;
		FDOS_FS_BIT_FISCALMEMCHKFAILED, 									 	;
		"Error de comprobacion de memoria fiscal", 0 }, 	 			;
	 {	FDOS_FS_BIT_WORKMEMCHECKFAILED, 								 		;
		FDOS_FS_BIT_WORKMEMCHECKFAILED, 									 	;
		"Error de comprobacion de memoria de trabajo", 0 },			;
	 {	FDOS_FS_BIT_BATTERYLOW, 												;
		FDOS_FS_BIT_BATTERYLOW, 												;
		"Poca Bateria", 0 },														;
	 {	FDOS_FS_BIT_UNRECOGNIZEDCOMMAND,									 	;
		FDOS_FS_BIT_UNRECOGNIZEDCOMMAND,									 	;
		"Comando no reconocido", 0 }, 										;
	 {	FDOS_FS_BIT_INVALIDDATAFIELD, 										;
		FDOS_FS_BIT_INVALIDDATAFIELD, 										;
		"Campo de datos invalido", 0 }, 									 	;
	 {	FDOS_FS_BIT_INVALIDCMDFORSTATUS,									 	;
		FDOS_FS_BIT_INVALIDCMDFORSTATUS,									 	;
		"Comando no valido para el estado fiscal", 0 }, 	 			;
	 {	FDOS_FS_BIT_OVERFLOW, 													;
		FDOS_FS_BIT_OVERFLOW, 													;
		"Desbordamiento de totales", 0 }, 								 	;
	 {	FDOS_FS_BIT_FISCALMEMFULL,												;
		FDOS_FS_BIT_FISCALMEMFULL,												;
		"Memoria fiscal llena", 0 },											;
	 {	FDOS_FS_BIT_FISCALMEMALMOSTFULL,										;
		FDOS_FS_BIT_FISCALMEMALMOSTFULL,									 	;
		"Memoria fiscal casi llena", 0 }, 								 	;
	 {	FDOS_FS_BIT_FISSTATUS_FIRST,										 	;
		FDOS_FS_BIT_FISSTATUS_LAST, 											;
		"Estado de Fiscalizacion/Certificacion" },				 		;
	 {	FDOS_FS_BIT_DAILYCLOSENEEDED, 									 	;
		FDOS_FS_BIT_DAILYCLOSENEEDED, 										;
		"Se necesita cierre de jornada fiscal", 0 },						;
	 {	FDOS_FS_BIT_DOCUMENT_FIRST, 											;
		FDOS_FS_BIT_DOCUMENT_LAST,												;
		"Estado/tipo de comprobante abierto" }, 					 		;
	 {	FDOS_FS_BIT_SLIP,                                           ;
		FDOS_FS_BIT_SLIP, 														;
		"Factura o impresion en hoja suelta inicializada" }, 			;
	 {	FDOS_FS_BIT_LOGICALOR_0_8,												;
		FDOS_FS_BIT_LOGICALOR_0_8,												;
		"OR logico entre los bits 0-8" }									 	;
		} 																											 ;
			// end

// si no se llama antes del primer comando
if scLastResp != NIL

// muestra error de impresora y fiscal
	aErrores:={}
	// "Palabra de estado de la Impresora"
	aa:=D_ShowStat( caPrnStBits, scLastResp, FDOS_FIELD_PRINTERSTATUS )
	if len(aa) > 0
		aeval(aa,{|a|aadd(aErrores,a)})
	endif

	// "Palabra de estado Fiscal"
	aa:=D_ShowStat( caFisStBits, scLastResp, FDOS_FIELD_FISCALSTATUS )
	if len(aa) > 0
		aeval(aa,{|a|aadd(aErrores,a)})
	endif

endif # scLastResp != NIL

return aErrores
// End Function



function D_ShowStat( acDescs, cAnswer, nField )
local 	 nArrSize, nNow, nDiff, nBitFrom, nBitTo, cFieldDesc,;
	 nStatus, cTmpStatus,;
	 nTmpData, nTmpIndex,;
	 acMyDescs, nMaxDescLen := 0

FD_VERIFY_REQUIRED	 acDescs TYPE "A"
FD_VERIFY_REQUIRED	 cAnswer TYPE "C"
FD_VERIFY_REQUIRED	 nField  TYPE "N"

// toma el tama¤o del array de descripciones
nArrSize := len( acDescs )
// toma el estado de la respuesta
if .not. FDGetField( cAnswer, nField, @cTmpStatus )
	return {}
endif
// muestra el valor del estado
// //?? " (" + cTmpStatus + ")"
// //?
// convierte el dato a numerico
nStatus := val( cTmpStatus )

acMyDescs := {}
nArrSize := len(acDescs)

for nNow := 1 to nArrSize
	if len(acDescs[nNow]) > 3
			// toma el elemento del array
		nBitFrom := acDescs[ nNow ][ 1 ]
		nBitTo := acDescs[ nNow ][ 2 ]
		cFieldDesc := acDescs[ nNow, 3 ]
			// calcula sobre los datos tomados
		nDiff := nBitTo - nBitFrom
			// muestra el estado del o de los bits
		nValorActual:=acDescs[nNow,4]
#ifdef	 GR_NEVER_DEFINED
			// forma el dato a 'andear'
		nTmpData := 0
		for nTmpIndex := nBitFrom to nBitTo
			nTmpData := _FDOS_FCMD_EXTERNAL_BIT_OR (				;
			nTmpData, 														;
			_FDOS_FCMD_EXTERNAL_BIT_SHIFTL ( 1, nTmpIndex ) 	;
				 )
		next
			// toma el string que corresponde a los bits
		nValorActual:=_FDOS_FCMD_EXTERNAL_BIT_SHIFTR (							;
					_FDOS_FCMD_EXTERNAL_BIT_AND ( 									;
					nStatus,																	;
					nTmpData																	;
			 ), 																				;
					nBitFrom																	;
			 )
#else
		nValorActual:=	_FDOS_FCMD_EXTERNAL_BIT_GETBITS ( 					;
					nStatus, nBitFrom, nBitTo 											;
			 )
#endif	 /* GR_NEVER_DEFINED */
		if nValorActual # acDescs[nNow,4]
			// //? cFieldDesc + " "
			// //?? "[" + alltrim(str( nBitFrom )) + iif( nDiff > 0, "-" + alltrim(str( nBitTo )), "" ) + "]: "
			aadd( acMyDescs, cFieldDesc )
		endif
	endif
next

return ( acMyDescs )
// End Function


*************************
func str0(nNum,nEnt,nDec)
local r:=""

r:=strtran(alltrim(str(nNum,nEnt,nDec)),".","")
r:=right(replic("0",nEnt)+r,nEnt)

return r


****************

FUNC FISCAL_ERROR( eObj )

****************

	set alternate to qq.txt
	set alternate on
	r := ERRORSYS(eObj)
	set alternate to
	return .T.

if --I_errores > 0
	return .T.
else
  break(nil)
	return .F.
endif
