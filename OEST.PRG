#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

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


*@0,0 say cPath + cBase +space(10)
SET EXCLUSIVE OFF
SET EXACT ON

IF cBase == "PROD"
	FALIAS("PRD",cual)
	ABRIRBASE2( cPath+"PROD", "PRD",{{"PRD->CODPROD",cPath+"PRDCOD"},;
	                                  {"PRD->DESCPROD",cPath+"PRDDESC"}} )
	
ELSEIF cBase == "ARTIC"
	FALIAS("ART",cual)
	ABRIRBASE2( cPath+cBase, "ART",{{"ART->CODPROD",cPath+"ARTCOD"},;
	                                {"STR(ART->RUBRO)+STR(ART->CODPROD)", cPath+"ARTRUCOD"},;
	                                {"ART->CODSCAN", cPath+"ARTSCAN"}} )
	
ELSEIF cBase == "ARTIC2"
	FALIAS("ART2",cual)
	ABRIRBASE2( cPath+cBase, "ART2", {{"ART2->CODPROD"}} )
	
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
	                                  {"FTOC(CA->FECHA)+CA->TURNO", cPath+"CAJAU", .T.}} )
ELSEIF cBase == "CAJA2"
	FALIAS("CA2",cual)
	ABRIRBASE2( (cPath+cBase), "CA2", {{"FTOC(CA2->FECHA)+CA2->TURNO"}} )
	
	
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
	ABRIRBASE2( cPath+cBase, "GR", {{"GR->CODGRUP"}} )
	IF LASTREC() < 1
		ADD_REC()
	ENDIF

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
	
ELSEIF cBase == "REM"
	FALIAS("RE",cual)
	ABRIRBASE2( cPath+cBase, "RE", {{"RE->NUMFAC", cPath+"RENUMFAC"},;
	                                {"FTOC(RE->FECHA)+RE->TURNO", cPath+"REFECTUR"},;
	                                {"STR(RE->CODCLI)+RE->NUMCOB", cPath+"RECLINC"}} )

ELSEIF cBase == "REM2"
	FALIAS("RE2",cual)
	ABRIRBASE2( cPath+cBase, "RE2", {{"RE2->NUMFAC", cPath+cBase}} )
	
ELSEIF left(cBase,5) == "FACA2"
	if !"_" $ cBase
		if(HASTA_SUC-DESDE_SUC#0);  cBase:=cBase+"_"+cSUCURSAL;  endif
  endif
	cPath += cDirAno
	FALIAS("FA2",cual)
	ABRIRBASE2( cPath+cBase, "FA2", {{"FA2->NUMFAC", cPath+cBase}} )
ELSEIF left(cBase,4) == "FACA"
	if !"_" $ cBase
		if(HASTA_SUC-DESDE_SUC#0);  cBase:=cBase+"_"+cSUCURSAL;  endif
  endif
	cPath += cDirAno
	FALIAS("FA",cual)
	ABRIRBASE2( cPath+cBase, "FA", {{"FA->NUMFAC", cPath+"FA"+cSUCURSAL+"NUM"},;
	                                {"FTOC(FA->FECHA)+FA->TURNO", cPath+"FA"+cSUCURSAL+"FETU"},;
	                                {"STR(FA->CODCLI)+FA->TIPOVENTA+FA->NUMCOB", cPath+"FA"+cSUCURSAL+"CLVNC"}} )
	
	
ELSEIF left(cBase,5) == "FACB2"
	if !"_" $ cBase
		if(HASTA_SUC-DESDE_SUC#0);  cBase:=cBase+"_"+cSUCURSAL;  endif
  endif
	cPath += cDirAno
	FALIAS("FB2",cual)
	ABRIRBASE2( cPath+cBase, "FB2", {{"FB2->NUMFAC",cPath+cBase}} )
ELSEIF left(cBase,4) == "FACB"
	if !"_" $ cBase
		if(HASTA_SUC-DESDE_SUC#0);  cBase:=cBase+"_"+cSUCURSAL;  endif
  endif
	cPath += cDirAno
	FALIAS("FB",cual)
	ABRIRBASE2( cPath+cBase, "FB", {{"FB->NUMFAC", cPath+"FB"+cSUCURSAL+"NUM"},;
	                                {"FTOC(FB->FECHA)+FB->TURNO", cPath+"FB"+cSUCURSAL+"FETU"},;
	                                {"STR(FB->CODCLI)+FB->TIPOVENTA+FB->NUMCOB", cPath+"FB"+cSUCURSAL+"CLVNC"}} )
	
ELSEIF cBase == "TICKETS"
	cPath := FDIR(cPath,cDirAno,cBase)
	FALIAS("TI",cual)
	ABRIRBASE2( cPath+cBase, "TI", {{"TI->NUMFAC", cPath+"TINUM"},;
	                       			  {"FTOC(TI->FECHA)+TI->TURNO", cPath+"TIFECTU"}} )
ELSEIF cBase == "TICKETS2"
	cPath := FDIR(cPath,cDirAno,cBase)
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
	
ELSEIF cBase == "VM"
	cPath += cDirAno
	FALIAS("VM",cual)
	ABRIRBASE2( cPath+cBase, "VM", {{"FTOC(VM->FECHA)+STR(VM->CODCLI)", cPath+cBase}} )
	
ELSEIF cBase == "CCV"
	FALIAS("CCV",cual)
	ABRIRBASE2( cPath+cBase, "CCV", {{"STR(CCV->CODCLI)+FTOC(CCV->FECHA)", cPath+"CCVCLFE"},;
	                                 {"CCV->NUMCOB", cPath+"CCVNC"}} )
ELSEIF cBase == "CCV2"
	FALIAS("CCV2",cual)
	ABRIRBASE2( cPath+cBase, "CCV2", {{"CCV2->NUMCOB+CCV2->NUMREC", cPath+"CCV2NCNR" },;
	                                  {"CCV2->NUMREC", cPath+"CCV2NR"}} )
	
	
ELSEIF cBase == "PCOR"
	FALIAS("PC",cual)
	ABRIRBASE2( cPath+cBase, "PC", {{"STR(PC->CODCORR)+FTOC(PC->FECHCIERRE)", cPath+cBase}} )

ELSEIF cBase == "EMPLEADO"
	FALIAS("EM",cual)
	ABRIRBASE2( cPath+"EMPLEADO", "EM", {{"EM->CODEMP"}} )
	
ELSEIF cBase == "OPROVIS"
	FALIAS("OP",cual)
	ABRIRBASE2( cPath+cBase, "OP",{{"OP->OPROVIS","OPNOP"},;
											 {"FTOC(OP->FECHA)","OPFE"}} )
ELSEIF cBase == "OPROVIS2"
	FALIAS("OP2",cual)
	ABRIRBASE2( cPath+cBase, "OP2",{{"str(OP2->OPROVIS)+str(OP2->CODPROD)"}} )


ELSEIF cBase == "CCC"
	FALIAS("CCC",cual)
	ABRIRBASE2( cPath+"CCC", "CCC", {{"CCC->TIPOPROV+str(CCC->CODPROV)+FTOC(CCC->FECHA)","CCCTCPFE"},;
	                                 {"CCC->NUMPAG","CCCNP"}} )

ELSEIF cBase == "COMPRAS"
	FALIAS("CO",cual)
	ABRIRBASE2( cPath+cBase, "CO", {{"STR(CO->CODPROV)+CO->NUMFAC", cPath+"COPRONF"},;
	                               {"FTOC(CO->FECHA)+STR(CO->CODPROV)", cPath+"COFEPR"},;
	                               {"STR(CO->CODPROV)+CO->NUMPAG", cPath+"COPRNP"},;
	                               {"FTOC(CO->FECHVENC)", cPath+"COFEVEN"}} )
ELSEIF cBase == "COMPRAS2"
	FALIAS("CO2",cual)
	ABRIRBASE2( cPath+cBase, "CO2",{{"STR(CO2->CODPROV)+CO2->NUMFAC", cPath+"CO2PRNF"},;
	                               {"STR(CO2->CODPROD)+FTOC(CO2->FECHA)", cPath+"CO2PRDFE"}} )

ELSEIF cBase == "COMPRET"
	FALIAS("CR",cual)
	ABRIRBASE2( cPath+cBase, "CR", {{"FTOC(CR->FECHA)","CRFE"},;
                                  {"STR(CR->CODCLI)+CR->NUMCOB","CRCLNC"},;
                                  {"CR->NUMFAC","CRNF"}} )
	
ELSEIF cBase == "COMPRASV"
	FALIAS("CO",cual)
	ABRIRBASE2( cPath+cBase, "CO", {{"STR(CO->CODPROV)+CO->NUMFAC", cPath+"CVPRONF"},;
	                               {"FTOC(CO->FECHA)+STR(CO->CODPROV)", cPath+"CVFEPR"},;
	                               {"STR(CO->CODPROV)+CO->NUMPAG", cPath+"CVPRNP"}} )

ELSEIF cBase == "GASTOS"
	cPath += cDirAno
	FALIAS("GA",cual)
	ABRIRBASE2( cPath+cBase, "GA", {{"FTOC(GA->FECHA)+GA->TURNO"}} )
ELSEIF cBase == "GASTOS2"
	FALIAS("GA2",cual)
	ABRIRBASE2( cPath+cBase, "GA2", {{"FTOC(GA2->FECHA)"}} )
	
ELSEIF "CHEQCAR" $ cBase
	FALIAS("CHC",cual)
	ABRIRBASE2( cPath+cBase, "CHC", {{"CHC->ESTADO", cPath+"CHCEST"},;
	                                 {"CHC->NUMOPAG", cPath+"CHCNOP"},;
	                                 {"CHC->CODBAN+CHC->ESTADO", cPath+"CHCBAES"},;
	                                 {"FTOC(CHC->FECHEMI)", cPath+"CHCFE"},;
	                                 {"CHC->NUMCOB", cPath+"CHCNCB"}} )
	
ELSEIF cBase == "RETIB"
	FALIAS("RI",cual)
	ABRIRBASE2( cPath+cBase, "RI", {{"RI->CODRET"}} )

ELSEIF cBase == "OPAGO"
	FALIAS("OPG",cual)
	ABRIRBASE2( cPath+cBase, "OPG", {{"OPG->TIPOPROV+str(OPG->CODPROV)+FTOC(OPG->FECHA)","OPGPRFE"},;
	                                {"OPG->NUMPAG","OPGNP"},;
                                  {"FTOC(OPG->FECHA)+OPG->TURNO","OPGFET"},;
                                  {"OPG->NUMOPAG","OPGNOP"}} )
ELSEIF cBase == "PROVEE"
	FALIAS("PRV",cual)
	ABRIRBASE2( cPath+cBase, "PRV",{{"PRV->CODPROV", cPath+"PROCOD"},;
											 {"PRV->CUIT", cPath+"PROCUIT"}} )
	
ELSEIF cBase == "PROVEEV"
	FALIAS("PRV",cual)
	ABRIRBASE2( cPath+"PROVEEV", "PRV", {{"PRV->CODPROV","PRCOD"},;
	                                     {"PRV->CUIT","PRCUIT"}} )
	
ELSEIF "CHEQEMI" $ cBase
	FALIAS("CHE",cual)
	ABRIRBASE2( cPath+cBase, "CHE", {{"CHE->ESTADO", cPath+"CHEEST"},;
	                                 {"CHE->NUMOPAG", cPath+"CHENOP"},;
	                                 {"CHE->CODBAN+CHE->ESTADO", cPath+"CHEBAES"},;
	                                 {"FTOC(CHE->FECHEMI)", cPath+"CHEFE"}} )
	
ELSEIF "CHEQUES" $ cBase .and. val(right(cBase,1))==0
	FALIAS("CH",cual)
	ABRIRBASE2( cPath+cBase, "CH", {{"CH->ESTADO", cPath+"CHEST"},;
	                               {"STR(CH->CODCLI)+CH->ID_CCV", cPath+"CHCLIFC"},;
	                               {"FTOC(CH->FECHPAGO)+CH->TURNO", cPath+"CHFPTUR"},;
	                               {"STR(CH->CODPROV)+CH->NUMPAG", cPath+"CHPRONP"}} )
	
	
ELSEIF cBase == "BANCO"
	FALIAS("BA",cual)
	ABRIRBASE2( cPath+cBase, "BA", {{"BA->CODBAN",cPath+cBase}} )
	
ELSEIF cBase == "TARJETAS"
	FALIAS("TA",cual)
	ABRIRBASE2( (cPath+cBase), "TA", {{"TA->ESTADO", cPath+"TAREST"},;
	                                 {"STR(TA->CODCLI)+TA->NUMCOB", cPath+"TACLINC"},;
	                                 {"FTOC(TA->FECHPAGO)+TA->TURNO", cPath+"TAFPTUR"},;
	                                 {"TA->NUMREC", cPath+"TANR"}} )
	
ELSEIF cBase == "POSNET"
	FALIAS("PN",cual)
	ABRIRBASE2( (cPath+cBase), "PN", {{"PN->ESTADO", cPath+"PNEST"},;
	                                  {"STR(PN->CODCLI)+FTOC(PN->FECHCIERRE)", cPath+"PNCLIFC"},;
	                                  {"FTOC(PN->FECHPAGO)+PN->TURNO", cPath+"PNFPTUR"},;
	                                  {"PN->CODTARJ+STR(PN->LOTE)", cPath+"PNCODLT"}} )
	
ELSEIF cBase == "COPRES"
	FALIAS("COP",cual)
	ABRIRBASE2( (cPath+cBase), "COP",{{"COP->ESTADO+FTOC(COP->FECHA)+COP->TURNO", cPath+"COPESTFT"},;
	                                 {"FTOC(COP->FECHA)+COP->TURNO", cPath+"COPFETUR"}} )
	
ELSEIF "CAJCH" $ cBase
	FALIAS("CAC",cual)
	ABRIRBASE2( cPath+cBase, "CAC", {{"FTOC(CAC->FECHA)"}} )
	
ELSEIF cBase == "BANCO"
	FALIAS("BA",cual)
	ABRIRBASE2( cPath+cBase, "BA", {{"BA->CODBAN",cPath+cBase}} )
	
ELSEIF "LIBAN" $ cBase
	FALIAS("LB",cual)
	ABRIRBASE2( cPath+cBase, "LB", {{"FTOC(LB->FECHA)+LB->ORDEN",cPath+cBase}} )

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
	ABRIRBASE2(cPath+cBase, "Z", {{"Z->SUCURSAL+str(Z->NUMZ)"},;
	                              {"FTOC(Z->FECHA)",cPath+"ZFE"}} )
	
ELSEIF cBase == "DBFS"
	FALIAS("DBF",cual)
	ABRIRBASE2(cPath+"DBFS", "DBF", {{"DBF->NOMBASE",cPath+"DBFS"}},,,9999)
	
ELSEIF cBase == "PLTPRD"
	FALIAS("PLP",cual)
	ABRIRBASE2(cPath+cBase, "PLP", {{"PLP->CODPLT"}} )
ELSEIF cBase == "PLTPRD2"
	FALIAS("PLP2",cual)
	ABRIRBASE2(cPath+cBase, "PLP2", {{"STR(PLP2->CODPLT)+STR(PLP2->CODPROD)"}} )
	
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

ELSEIF cBase == "CONC"
	FALIAS("CON",cual)
	ABRIRBASE2( cPath+cBase, "CON",{{"CON->CODCONC"}} )

ELSEIF cBase == "CODPOS"
	FALIAS("CP",cual)
	ABRIRBASE2(cPath+cBase, "CP", {{"CP->CODLOC",cPath+"CPCODLOC"},;
	                         		 {"CP->LOCALIDAD",cPath+"CPLOC"}} )
ELSEIF cBase == "TRANS"
	FALIAS("TRN",cual)
	ABRIRBASE2( cPath+cBase, "TRN" )

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
	
ELSEIF cBase == "MOV"
	cPath := UT_PERIODO +".CG\"
	FALIAS("MV",cual)
	ABRIRBASE2( cPath+cBase, "MV",{{"MV->NUMAS",cPath+"MVNA"},;
  										 {"FTOC(MV->FECHA)",cPath+"MVFE"}} )
ELSEIF cBase == "MOV2"
	cPath := UT_PERIODO +".CG\"
	FALIAS("MV2",cual)
	ABRIRBASE2( cPath+cBase, "MV2", {{"MV2->NUMAS","MV2NA"},;
                                	{"MV2->CODPLAN","MV2CP"}} )
	
ELSEIF cBase == "MINUTA"
	cPath := UT_PERIODO +".CG\"
	FALIAS("MI",cual)
	ABRIRBASE2( cPath+cBase, "MI",{{"MI->NUMAS",cPath+"MINA"},;
  										 {"FTOC(MI->FECHA)",cPath+"MIFE"}} )
ELSEIF cBase == "MINUTA2"
	cPath := UT_PERIODO +".CG\"
	FALIAS("MI2",cual)
	ABRIRBASE2( cPath+cBase, "MI2", {{"MI2->NUMAS","MI2NA"},;
                                	{"MI2->CODPLAN","MI2CP"}} )
ELSEIF cBase == "FGAS"
	FALIAS("GA",cual)
	ABRIRBASE2( cPath+cBase, "GA", {{"FTOC(GA->FECHA)+GA->TURNO",cPath+cBase}} )

ELSEIF cBase == "PADRONIB"
	FALIAS("PIB",cual)
	ABRIRBASE2( cPath+cBase, "PIB", {{"PIB->CUIT",cPath+cBase}} )

	
ENDIF
if lastrec()==0
	add_rec()
endif

return NIL

***************

FUNC NUEVOCOD(cCualBase,cCualCod,nCualOrder)

***************
local r, cBase:=DBF(), nReg, nOrder
DEFAULT nOrder TO 1

select (cCualBase)
nOrder:=INDEXORD()
set order to nCualOrder
nReg:=recno()
go bottom
r := STRZERO(val((cCualBase)->&(cCualCod))+1,len((cCualBase)->&(cCualCod)))
do while dbseek( r )
	r := STRZERO(val(r)+1,len((cCualBase)->&(cCualCod)))
enddo
go nReg
select (cBase)
set order to nOrder

return r

************

FUNC FDIR( cPath, cDir, cBase )

************
LOCAL r:=""

if file(cPath+cDir+cBase+".DBF")
	r := cPath+cDir
else
	r := cPath
endif

return r
