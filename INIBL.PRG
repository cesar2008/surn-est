CLEAR
PARAMETERS base, alias

SELECT 1
USE _BL2 ALIAS _BL2

SELECT 2
USE (base) ALIAS (alias)
astru := DBSTRUCT()

SELECT 1
FOR i=1 TO LEN(astru)
	APPEND BLANK
  _BL2->CODBL     := 1
  _BL2->POSY      := 999
  _BL2->POSX      := 999
  _BL2->TIPOLETRA := 1
  _BL2->PASADAS   := 1
  _BL2->DESC      := UPPER(LEFT(astru[i,1],1)) + LOWER(SUBSTR(astru[i,1],2))
  _BL2->MACRO     := alias +"->"+ astru[i,1]
  _BL2->LADO      := 1
  _BL2->IMPRIMIR  := 'S'
  _BL2->COND      := ''
NEXT
