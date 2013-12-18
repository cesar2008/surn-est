#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

******************

FUNC BASES_SISTEMA( cual )

******************
LOCAL cBase := SUBSTR(__aBase[cual,1],2), aux
LOCAL cPath := "", cAux
IF "\" $ cBase
	cPath := LEFT( cBase, RAT("\",cBase) )
	cBase := SUBSTR( cBase, LEN(cPath)+1 )
ENDIF
IF EMPTY(cPath)
	IF cBase # "DBFS"
		cAux := cBase + IF('.'$cBase,"",".DBF")
		SELECT DBF
		DBSEEK(PADR(cAux,12))
		DO WHILE ALLTRIM(DBF->NOMBASE)==cAux .AND. !DBF->(EOF())
			cPath := IF( LEFT(DBF->DISCO,1)==' ', '', DBF->DISCO ) + ALLTRIM(&(DBF->CAMINO))
			SKIP
		ENDDO
	ENDIF
ENDIF


SET EXCLUSIVE OFF
SET EXACT ON

IF cBase == "PROD"
	FALIAS("PRD",cual)
	ABRIRBASE2( cPath+"PROD", "PRD",{{"PRD->CODPROD","PRDCOD"},;
	                                  {"PRD->DESCPROD","PRDDESC"}} )
	
ELSEIF cBase == "ARTIC"
	FALIAS("ART",cual)
	ABRIRBASE2( cPath+"PROD", "ART", {{"ART->CODPROD", cPath+"ARTCOD"},;
	                                  {"ART->CODSCAN", cPath+"ARTSCAN"}} )
ELSEIF cBase == "PROD2"
	FALIAS("ART2",cual)
	ABRIRBASE2( cPath+"PROD2", "ART2", {{"ART2->CODPROD"}} )
	
ELSEIF cBase == "VARIOS"
	FALIAS("VA",cual)
	ABRIRBASE2( cPath+"VARIOS", "VA" )
	IF LASTREC() < 1
		ADD_REC()
	ENDIF
	IF EMPTY(VA->FECHA)
		FRLOCK()
		REPLACE VA->FECHA WITH DATE()
		UNLOCK
	ENDIF
	
ELSEIF cBase == "ESTADOS"
	FALIAS("EST",cual)
	ABRIRBASE2( cPath+"ESTADOS", "EST" )
	
ELSEIF cBase == "FERIADOS"
	FALIAS("FE",cual)
	ABRIRBASE2( cPath+cBase, "FE", {{"FTOC(FE->FERIADO)", cPath+cBase}} )
	
ELSEIF cBase == "CAJA"
	FALIAS("CA",cual)
	ABRIRBASE2( (cPath+cBase), "CA", {{"FTOC(CA->FECHA)+CA->TURNO", cPath+"CAJA"},;
	                                  {"FTOC(CA->FECHA)+CA->TURNO", cPath+"CAJAU",.T.}} )
	
ELSEIF cBase == "PROVEE"
	FALIAS("PRV",cual)
	ABRIRBASE2( cPath+cBase, "PRV",{{"PRV->CODPROV", cPath+"PROCOD"},;
											 {"PRV->CUIT", cPath+"PROCUIT"}} )
	
ELSEIF cBase == "PROVEEV"
	FALIAS("PRV",cual)
	ABRIRBASE2( cPath+"PROVEEV", "PRV", {{"PRV->CODPROV","PRCOD"},;
	                                     {"PRV->CUIT","PRCUIT"}} )
	
ELSEIF cBase == "PLANT"
	FALIAS("PLT",cual)
	ABRIRBASE2( cPath+cBase, "PLT" )
	
ELSEIF cBase == "CLIENTES" .OR. cBase == "CLI"
	FALIAS("CL",cual)
	ABRIRBASE2( cPath+"CLIENTES", "CL", {{"CL->CODCLI", cPath+"CLCOD"},;
	                                     {"CL->RAZONSOC", cPath+"CLRAZSOC"},;
	                                     {"CL->CUIT", cPath+"CLCUIT"}} )
	SET ORDER TO 1
	FOR i=1 TO FCOUNT()
		campo = FIELD(i)
		PUBLIC &campo
	NEXT i
	
ELSEIF cBase == "GRUPO"
	FALIAS("GR",cual)
	ABRIRBASE2( cPath+cBase, "GR",{{"GR->CODGRUP"}} )
	IF LASTREC() < 1
		ADD_REC()
	ENDIF
	
ELSEIF cBase == "REM"
	FALIAS("RE",cual)
	ABRIRBASE2( cPath+cBase, "RE", {{"RE->NUMFAC", cPath+"RENUMFAC"},;
	                                {"STR(RE->CODCLI)+RE->ID_CCV", cPath+"RECLIFC"},;
	                                {"FTOC(RE->FECHA)+RE->TURNO", cPath+"REFECTUR"}} )
ELSEIF cBase == "REM$"
	cBase := "REM"
	FALIAS("RE",cual)
	ABRIRBASE2( cPath+cBase, "RE", {{"RE->NUMFAC", cPath+"RENUMFAC"},;
	                                {"FTOC(RE->FECHA)", cPath+"REFECH"}} )
ELSEIF cBase == "REM2"
	FALIAS("RE2",cual)
	ABRIRBASE2( cPath+cBase, "RE2", {{"RE2->NUMFAC", cPath+cBase}} )
	
ELSEIF cBase == "FACA"
	cPath += cDirAno
	FALIAS("FA",cual)
	ABRIRBASE2( cPath+cBase, "FA", {{"FA->NUMFAC", cPath+"FANUM"},;
	                                {"FTOC(FA->FECHA)", cPath+"FAFECH"},;
	                                {"STR(FA->CODCLI)+FA->ID_CCV", cPath+"FACLIDCC"}} )
ELSEIF cBase == "FACA2"
	cPath += cDirAno
	FALIAS("FA2",cual)
	ABRIRBASE2( cPath+cBase, "FA2", {{"FA2->NUMFAC", cPath+cBase}} )
	
ELSEIF cBase == "FACACC"
	FALIAS("FAC",cual)
	ABRIRBASE2( cPath+cBase, "FAC", {{"FAC->NUMFAC", cPath+"FACCNF"},;
	                                 {"FAC->NUMFACC", cPath+"FACCNFC"}})
ELSEIF cBase == "FACACC2"
	FALIAS("FAC2",cual)
	ABRIRBASE2( cPath+cBase, "FAC2", {{"FAC2->NUMFAC", cPath+cBase }})
	
ELSEIF cBase == "FACBCC"
	FALIAS("FAC",cual)
	ABRIRBASE2( cPath+cBase, "FAC", {{"FAC->NUMFAC", cPath+"FBCCNF"},;
	                                 {"FAC->NUMFACC", cPath+"FBCCNFC"}} )
ELSEIF cBase == "FACBCC2"
	FALIAS("FAC2",cual)
	ABRIRBASE2( cPath+cBase, "FAC2", {{"FAC2->NUMFAC", cPath+cBase}} )
	
ELSEIF cBase == "FACB"
	cPath += cDirAno
	FALIAS("FB",cual)
	ABRIRBASE2( cPath+cBase, "FB", {{"FB->NUMFAC", cPath+"FBNUM"},;
	                                {"FTOC(FB->FECHA)", cPath+"FBFECH"},;
	                                {"STR(FB->CODCLI)+FB->ID_CCV", cPath+"FBCLIDCC"}} )
ELSEIF cBase == "FACB2"
	cPath += cDirAno
	FALIAS("FB2",cual)
	ABRIRBASE2( cPath+cBase, "FB2", {{"FB2->NUMFAC",cPath+cBase}} )
	
ELSEIF cBase == "TICKETS"
	cPath += cDirAno
	FALIAS("TI",cual)
	ABRIRBASE2( cPath+cBase, "TI", {{"TI->NUMFAC", cPath+"TINUM"},;
	                       			  {"FTOC(TI->FECHA)", cPath+"TIFECH"}} )
ELSEIF cBase == "TICKETS2"
	cPath += cDirAno
	FALIAS("TI2",cual)
	ABRIRBASE2( cPath+cBase, "TI2", {{"TI2->NUMFAC", cPath+cBase}} )
	
ELSEIF cBase == "PLAN"
	cPath += cDirAno
	FALIAS("PL",cual)
	ABRIRBASE2( cPath+cBase, "PL", {{"FTOC(PL->FECHA)+PL->TURNO", cPath+cBase}} )
ELSEIF cBase == "PLAN2"
	cPath += cDirAno
	FALIAS("PL2",cual)
	aux:=''; AEVAL(aturno,{|a,i| aux+=LEFT(aturno[LEN(aturno)-i+1],1) })
	ABRIRBASE2( cPath+cBase, "PL2", {{"FTOC(PL2->FECHA)+PL2->TURNO", cPath+"PL2FETUR"},;
	                                 {"STR(PL2->SURTIDOR)+STR(PL2->CODPROD)+FTOCI(PL2->FECHA)+CHR(AT(PL2->TURNO,'"+aux+"'))", cPath+"PL2SCFT"},;
	                                 {"STR(PL2->CODPROD)+FTOC(PL2->FECHA)", cPath+"PL2PRDFE"}} )
	
ELSEIF cBase == "CCV"
	FALIAS("CCV",cual)
	ABRIRBASE2( cPath+cBase, "CCV", {{"STR(CCV->CODCLI)+FTOC(CCV->FECHCIERRE)", cPath+"CCVCLFC"},;
	                                 {"STR(CCV->CODCLI)+CCV->ID_CCV", cPath+"CCVCLID"}} )
ELSEIF cBase == "CCV2"
	FALIAS("CCV2",cual)
	ABRIRBASE2( cPath+cBase, "CCV2", {{"STR(CCV2->CODCLI)+CCV2->ID_CCV", cPath+"CCV2CLFC" },;
	                                  {"FTOC(CCV2->FECHPAGO)", cPath+"CCV2FP"}} )
	
	
ELSEIF cBase == "PCOR"
	FALIAS("PC",cual)
	ABRIRBASE2( cPath+cBase, "PC", {{"STR(PC->CODCORR)+FTOC(PC->FECHCIERRE)", cPath+cBase}} )

ELSEIF cBase == "EMPLEADO"
	FALIAS("EM",cual)
	ABRIRBASE2( cPath+"EMPLEADO", "EM", {{"EM->CODEMP"}} )
	
ELSEIF cBase == "COMPRAS"
	FALIAS("CO",cual)
	ABRIRBASE2( cPath+cBase, "CO", {{"STR(CO->CODPROV)+CO->NUMFAC", cPath+"COPRONF"},;
	                               {"STR(CO->CODPROV)+FTOC(CO->FECHCC)", cPath+"COPROFCC"},;
	                               {"FTOC(CO->FECHA)+STR(CO->CODPROV)", cPath+"COFEPR"},;
	                               {"FTOC(CO->FECHVENC)", cPath+"COFEVEN"}} )
ELSEIF cBase == "COMPRAS2"
	FALIAS("CO2",cual)
	ABRIRBASE2( cPath+cBase, "CO2",{{"STR(CO2->CODPROV)+CO2->NUMFAC", cPath+"CO2PRNF"},;
	                               {"STR(CO2->CODPROD)+FTOC(CO2->FECHA)", cPath+"CO2PRDFE"}} )
ELSEIF cBase == "OPROVIS"
	FALIAS("OP",cual)
	ABRIRBASE2( cPath+cBase, "OP",{{"OP->OPROVIS"}} )
ELSEIF cBase == "OPROVIS2"
	FALIAS("OP2",cual)
	ABRIRBASE2( cPath+cBase, "OP2",{{"str(OP2->OPROVIS)+str(OP2->CODPROD)"}} )

ELSEIF cBase == "COMPRASV"
	FALIAS("CV",cual)
	ABRIRBASE2( cPath+"COMPRASV", "CV", {{"FTOC(CV->FECHA)"}} )
	
ELSEIF cBase == "CCC"
	FALIAS("CCC",cual)
	ABRIRBASE2( cPath+"CCC", "CCC", {{"STR(CCC->CODPROV)+FTOC(CCC->FECHCC)"}} )
ELSEIF cBase == "CCC2"
	FALIAS("CCC2",cual)
	ABRIRBASE2( cPath+"CCC2", "CCC2", {{"STR(CCC2->CODPROV)+FTOC(CCC2->FECHCC)"}} )
	
ELSEIF cBase == "GASTOS"
	cPath += cDirAno
	FALIAS("GA",cual)
	ABRIRBASE2( cPath+cBase, "GA", {{"FTOC(GA->FECHA)+GA->TURNO"}} )
ELSEIF cBase == "GASTOS2"
	FALIAS("GA2",cual)
	ABRIRBASE2( cPath+cBase, "GA2", {{"FTOC(GA2->FECHA)"}} )
	
ELSEIF "CHEQUEST" $ cBase
	FALIAS("CHC",cual)
	ABRIRBASE2( cPath+cBase, "CHC", {{"CHC->ESTADO", cPath+"CHCESTADO"},;
	                                 {"STR(CHC->CODPROV)+FTOC(CHC->FECHCC)", cPath+"CHCPROFC"},;
	                                 {"FTOC(CHC->FECHA)", cPath+"CHCFECH"},;
	                                 {"CHC->BANCO", cPath+"CHCBAN"}} )
	
ELSEIF "CHEQUES" $ cBase .and. val(right(cBase,1))==0
	FALIAS("CH",cual)
	ABRIRBASE2( cPath+cBase, "CH", {{"CH->ESTADO", cPath+"CHESTADO"},;
	                               {"STR(CH->CODCLI)+CH->ID_CCV", cPath+"CHCLIFC"},;
	                               {"FTOC(CH->FECHPAGO)+CH->TURNO", cPath+"CHFPTUR"},;
	                               {"STR(CH->CODPROV)+FTOC(CH->FECHCC)", cPath+"CHPROFCC"}} )
	
ELSEIF cBase == "TARJETAS"
	FALIAS("TA",cual)
	ABRIRBASE2( (cPath+cBase), "TA", {{"TA->ESTADO", cPath+"TAREST"},;
	                                 {"STR(TA->CODCLI)+TA->ID_CCV", cPath+"TACLIFC"},;
	                                 {"FTOC(TA->FECHPAGO)+TA->TURNO", cPath+"TAFPTUR"}} )
	
ELSEIF cBase == "POSNET"
	FALIAS("PN",cual)
	ABRIRBASE2( (cPath+cBase), "PN", {{"PN->ESTADO", cPath+"PNEST"},;
	                                  {"STR(PN->CODCLI)+FTOC(PN->FECHCIERRE)", cPath+"PNCLIFC"},;
	                                  {"FTOC(PN->FECHPAGO)+PN->TURNO", cPath+"PNFPTUR"}} )
	
ELSEIF cBase == "COPRES"
	FALIAS("CO",cual)
	ABRIRBASE2( (cPath+cBase), "CO",{{"CO->ESTADO", cPath+"COPEST"},;
	                                 {"FTOC(CO->FECHA)+CO->TURNO", cPath+"COPFETUR"}} )
	
ELSEIF "CAJCH" $ cBase
	FALIAS("CAC",cual)
	ABRIRBASE2( cPath+cBase, "CAC", {{"FTOC(CAC->FECHA)"}} )
	
ELSEIF cBase == "BANCO"
	FALIAS("BA",cual)
	ABRIRBASE2( cPath+cBase, "BA" )
	
ELSEIF "LIBANCO" $ cBase
	FALIAS("LI",cual)
	ABRIRBASE2( cPath+cBase, "LI", {{"FTOC(LI->FECHA)+LI->ORDEN",cPath+cBase}} )

ELSEIF "CHEQUES" $ cBase
	FALIAS("CH",cual)
	ABRIRBASE2( cPath+cBase, "CH", {{"FTOC(CH->FECHA)",cPath+cBase}} )

	
ELSEIF cBase == "_BL"
	FALIAS("_BL",cual)
	ABRIRBASE2( cPath+"_BL", "_BL", {{"_BL->ORDEN"}} )
ELSEIF cBase == "_BL2"
	FALIAS("_BL2",cual)
	ABRIRBASE2( cPath+"_BL2", "_BL2", {{"STR(_BL2->NUMBL)+STR(_BL2->POSY)+STR(_BL2->POSX)"}} )
	
ELSEIF cBase == "SREM"
	FALIAS("SR",cual)
	ABRIRBASE2( cPath+"SREM", "SR" )
	
ELSEIF cBase == "CLA"
	FALIAS("CLA",cual)
	ABRIRBASE2( cPath+cBase, "CLA", {{"CLA->CODCLI", cPath+"CLACOD"},;
	                                 {"CLA->RAZONSOC", cPath+"CLARZSOC"},;
	                                 {"CLA->CUIT", cPath+"CLACUIT"}} )
	
ELSEIF cBase == "AJUSTES"
	FALIAS("AJ",cual)
	ABRIRBASE2( cPath+cBase, "AJ", {{"FTOC(AJ->FECHA)+STR(AJ->CODPROD)", cPath+"AJFEPRD"},;
	                               {"STR(AJ->CODPROD)+FTOC(AJ->FECHA)", cPath+"AJPRDFE"}})
	
ELSEIF cBase == "FACTURAS"
	FALIAS("FAC",cual)
	ABRIRBASE2( cPath+"FACTURAS", "FAC", {{"FTOC(FAC->FECHA)"}} )
	
ELSEIF cBase == "VARI"
	FALIAS("VR",cual)
	ABRIRBASE2( cPath+"VARI", "VR", {{"FTOC(VR->FECHA)"}} )
	
	
ELSEIF cBase == "AGENDA"
	FALIAS("AG",cual)
	ABRIRBASE2( cPath+"AGENDA", "AG", {{"AG->APENOM"}} )
	
ELSEIF cBase == "RUBRO"
	FALIAS("RU",cual)
	ABRIRBASE2( cPath+cBase, "RU" )
	
	
ELSEIF cBase == "SETIMP"
	FALIAS("SI",cual)
	ABRIRBASE2(cPath+cBase, "SI" )
	
ELSEIF cBase == "ESTSIT"
	FALIAS("ES",cual)
	ABRIRBASE2(cPath+cBase, "ES", {{"FTOC(ES->FECHA)"}} )
	
ELSEIF cBase == "Z"
	FALIAS("Z",cual)
	ABRIRBASE2(cPath+cBase, "Z", {{"FTOC(Z->FECHA)"}} )
ELSEIF cBase == "Z2"
	FALIAS("Z2",cual)
	ABRIRBASE2(cPath+cBase, "Z2", {{"Z2->NUMZ"}} )
	
ELSEIF cBase == "DBFS"
	FALIAS("DBF",cual)
	ABRIRBASE2(cPath+"DBFS", "DBF", {{"DBF->NOMBASE",cPath+"DBFS"}},,,9999)
	
ELSEIF cBase == "PLTPRD"
	FALIAS("PLP",cual)
	ABRIRBASE2(cPath+cBase, "PLP", {{"PLP->CODPLT"}} )
ELSEIF cBase == "PLTPRD2"
	FALIAS("PLP2",cual)
	ABRIRBASE2(cPath+cBase, "PLP2", {{"STR(PLP2->CODPLT)+STR(PLP2->CODPROD)"}} )
	
ELSEIF cBase == "AS"
	FALIAS("AS",cual)
	ABRIRBASE2(cPath+cBase, "AS",{{"AS->TIPOAS+STR(AS->ASIENTO)"}},,.F.)
	
ELSEIF cBase == "AS2"
	FALIAS("AS2",cual)
	ABRIRBASE2(cPath+cBase, "AS2",{{"AS2->TIPOAS+STR(AS2->ASIENTO)+AS2->TIPOCONC"}},,.F.)
	
ELSEIF cBase == "LUB"
	cPath += cDirAno
	FALIAS("LU",cual)
	ABRIRBASE2( cPath+cBase, "LU", {{"LU->NUMPARTE", cPath+"LUNPART"},;
	                                {"FTOC(LU->FECHA)+LU->TURNO", cPath+"LUFETU"}} )
ELSEIF cBase == "LUB2"
	cPath += cDirAno
	FALIAS("LU2",cual)
	ABRIRBASE2( cPath+cBase, "LU2", {{"LU2->NUMPARTE", cPath+"LU2NPART"}} )
ELSEIF cBase == "MODU"
	FALIAS("MO",cual)
	ABRIRBASE2( cPath+cBase, "MO" )
	
ELSEIF cBase == "TANQUES"
	FALIAS("TAN",cual)
	ABRIRBASE2( cPath+cBase, "TAN", {{"TAN->NUMTANQ"}} )

ELSEIF cBase == "CORR"
	FALIAS("COR",cual)
	ABRIRBASE2( cPath+cBase, "COR",{{"COR->CODCORR"}} )

ELSEIF cBase == "PLANCTA"
	FALIAS("PC",cual)
	ABRIRBASE2( cPath+cBase, "PC",{{"PC->CODPLAN"}} )

ELSEIF cBase == "CODPOS"
	FALIAS("CP",cual)
	ABRIRBASE2(cPath+cBase, "CP", {{"CP->CODLOC",cPath+"CPCODLOC"},;
	                         		 {"CP->LOCALIDAD",cPath+"CPLOC"}} )
ELSEIF cBase == "TRANS"
	FALIAS("TRN",cual)
	ABRIRBASE2( cPath+cBase, "TRN" )

ELSEIF cBase == "OPAG"
	FALIAS("OPG",cual)
	ABRIRBASE2( cPath+cBase, "OPG",{{"OPG->NUMOPAG"}} )
	
ELSEIF cBase == "LAV"
	cPath += cDirAno
	FALIAS("LV",cual)
	ABRIRBASE2( cPath+cBase, "LV", {{"LV->NUMPARTE", cPath+"LVNPART"},;
	                                {"FTOC(LV->FECHA)+LV->TURNO", cPath+"LVFETU"}} )
ELSEIF cBase == "LAV2"
	cPath += cDirAno
	FALIAS("LV2",cual)
	ABRIRBASE2( cPath+cBase, "LV2", {{"LV2->NUMPARTE", cPath+"LV2NPART"}} )
	
ELSEIF cBase == "PLANTLAV"
	FALIAS("PLT",cual)
	ABRIRBASE2( cPath+cBase, "PLT" )
	
ELSEIF cBase == "COMPRET"
	FALIAS("CR",cual)
	ABRIRBASE2( cPath+cBase, "CR", {{"FTOC(CR->FECHA)"}} )
	
ENDIF

IF LASTREC()==0
	ADD_REC()
ENDIF

RETURN NIL
