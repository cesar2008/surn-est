set date british
clear

aBase:={"FACA_2","FACA2_2","FACB_2","FACB2_2",;
        "FACA_3","FACA2_3","FACB_3","FACB2_3",;
        "FACA_4","FACA2_4","FACB_4","FACB2_4"}

for aa=1998 to 1998
	for mm=1 to 12
     cDir:=strzero(aa,4)+"\"+strzero(mm,2)+"\"
     ? cDir
     for b=1 to len(aBase)
			COPIAR( aBase[b], aa, mm )
     next
	next
next
QUIT



***********************

func COPIAR(cCual,aa,mm)

***********************
use (cCual)
cAAM:=strtran(cDir,"\","")
locate for left(dtos(FECHA),6)==cAAM

if found()
	if len(directory( strzero(aa,4)+"\", "D" )) == 0
  	cAux:="MD "+strzero(aa,4)
  	run &cAux
	endif
	if len(directory( strzero(aa,4)+"\"+strzero(mm,2)+"\", "D" )) == 0
  	cAux:="MD "+strzero(aa,4)+"\"+strzero(mm,2)
  	run &cAux
	endif
	copy to (cDir+cCual) rest for left(dtos(FECHA),6)==cAAM
endif

return .f.
