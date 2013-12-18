PARAMETERS base, indice
CLEAR

IF PCOUNT() < 1
	? " Sintaxis:        REPE <nomarch> <campo clave> "
	RETURN
ENDIF
? base, indice
USE &base
INDEX ON &indice TO QQ

GO TOP
X = 0
R = &indice
SKIP
? "      cant   "+indice
? "----------    ------------"
aaux := {}
DO WHILE !EOF()
	IF R == &indice
  	x=x+1
  	? X, R, recno()
     aadd(aaux,recno())
  ENDIF
  R = &indice
  SKIP
ENDDO
for n=1 to len(aaux)
	go aaux[N]
  delete
next
pack
