#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

aNtx:={;
{"Caja       ",{"CAJ*"}},;
{"Cta.Cte.   ",{"CC*"}},;
{"Cheques    ",{"CH*"}},;
{"Clientes   ",{"CL*"}},;
{"Compras    ",{"COF*","COM*","CO2*","OPROVIS"}},;
{"Copres     ",{"COP*"}},;
{"Empleado   ",{"EMPLEADO"}},;
{"Facturas A ",{"FACA*"}},;
{"Facturas B ",{"FACB*"}},;
{"Feriados   ",{"FERIADOS"}},;
{"Gastos     ",{"GASTOS"}},;
{"Lubricentro",{"LU*","MO*"}},;
{"Lavadero   ",{"LAV*","PLANTLAV*"}},;
{"Planillas  ",{"PL*"}},;
{"Posnet     ",{"PN*"}},;
{"Productos  ",{"PRD*"}},;
{"Proveedores",{"PROV*"}},;
{"Remitos    ",{"RE*"}},;
{"Tarjetas   ",{"TA*"}}}

aaux := ARRAY(LEN(aNTX))
aeval(aNtx,{|a,i|aaux[i]:=a[1]+" "})

clear
@ 0,0 SAY PADC("ARREGLAR INDICES DE :",80," ") COLOR "N/W"
IF MARCABRW( 3, 35, aaux, len(aaux) ) # 0
	clear
	for i=1 to len(aaux)
  	if right(aaux[i],1)==''
     	? aaux[i]
     	FOR n=1 to len(aNtx[i,2])
  			aa := DIRECTORY( aNTX[i,2,n]+".NTX" )
           for a=1 to len(aa)
           	IF FILE( aa[a,1] )
           		nE := ferase( aa[a,1] )
              	if nE == -1
							MENSAJE( 0, 0, 10, .T., "NO se puede actualizar el indice ",;
                 									"de "+upper(alltrim(aNtx[i,1]))+" ...",;
                                         	"EL ARCHIVO NO DEBE ESTAR ABIERTO X NINGUNA TERMINAL !")
                 endif
              endif
           next
        NEXT
     endif
  next
ENDIF

RETURN
