// --------------------------------------------------------------
#include "oop.ch"
// --------------------------------------------------------------
CLASS ARCH_AUX
	VAR cNombreX
	VAR cAliasX
	VAR nSelectX
	VAR cAliasOrig
	VAR bCond0
	VAR bCondCarga
	VAR bFuncAlta
	VAR bCondAlta
	VAR lModif
	VAR bGrabar
  MESSAGE New
  MESSAGE Crear
  MESSAGE Cargar
  MESSAGE Grabar
  MESSAGE Eliminar
  MESSAGE Cerrar
ENDCLASS

// --------------------------------------------------------------
METHOD New()
	::cNombreX     := XNAME('XAUX')
	::cAliasX      := 'X'
	::nSelectX     := 99
  ::cAliasOrig   := alias()
	::bCondCarga   := {||.T.}
  ::bCond0       := {||(::cAliasOrig)->(dbgotop())}
  ::bCondCarga   := {||.T.}
  ::bFuncAlta    := {||F_ALTA({||.T.})}
  ::bGrabar      := {||.T.}
  ::lModif       := .F.
return Self

// --------------------------------------------------------------
METHOD Crear()
local aaux:=(::cAliasOrig)->(dbstruct())

aadd(aaux,{"REGISTRO","N",6,0})
select(::nSelectX);  dbclosearea()
dbcreate(::cNombreX,aaux)
select(::nSelectX)
use (::cNombreX) alias (::cAliasX) exclusive
select (::cAliasOrig)

return Self

// --------------------------------------------------------------
METHOD Cargar()
local aa:={}

select (::cAliasOrig)
eval(::bCond0)
select (::cAliasX)
zap
for i=1 to fcount()
  if (::cAliasOrig)->(fieldpos(fieldname(i))) # 0
     aadd(aa,"{||"+ ::cAliasX +"->"+ fieldname(i) +":="+ ::cAliasOrig +"->"+ fieldname(i) +"}" )
  endif
next i
aeval(aa,{|a,i|aa[i]:=&(a)} )
do while eval(::bCondCarga) .and. !(::cAliasOrig)->(eof())
  append blank
  aeval(aa,{|a,i|eval(aa[i])})
  FIELD->REGISTRO := (::cAliasOrig)->(recno())
  skip 1 alias (::cAliasOrig)
enddo

return Self

// --------------------------------------------------------------
METHOD Grabar()
local aa:={}

select (::cAliasX)
dbgotop()
for i=1 to fcount()
  if (::cAliasOrig)->(fieldpos(fieldname(i))) # 0
     aadd(aa,"{||"+ ::cAliasOrig +"->"+ fieldname(i) +":="+ ::cAliasX +"->"+ fieldname(i) +"}" )
  endif
next i
aeval(aa,{|a,i|aa[i]:=&(a)} )
select (::cAliasOrig)
do while !(::cAliasX)->(eof())
  if eval(::bCondAlta)
  	if (::cAliasX)->REGISTRO==0
     	eval(::bFuncAlta)
		else
     	go (::cAliasX)->REGISTRO
     endif
  	frlock()
		for i=1 to len(aa)
     	eval(aa[i])
  	next
		eval(::bGrabar)
  else
  	if (::cAliasX)->REGISTRO#0
     	go (::cAliasX)->REGISTRO
     	blankreg()
     endif
  endif
  skip 1 alias (::cAliasX)
enddo
dbunlock()
dbcommitall()

return Self

// --------------------------------------------------------------
METHOD Eliminar()

select (::cAliasOrig)
do while eval(::bCond0)
	if eval(::bCondCarga)
		blankreg()
  else
  	exit
  endif
enddo

return Self

// --------------------------------------------------------------
METHOD Cerrar()

(::cAliasX)->( dbclosearea() )

return Self
