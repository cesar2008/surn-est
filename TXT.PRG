/*
    Program Name: TXTVIEW.PRG

    Date Created: 04/07/93
    Time Created: 10:55:11
    Authors     : Radosav Andric, Michael Abadjiev

    For test compile : clipper txtview.prg /w/n/dTEST
*/

#include "fileio.ch"
#include "inkey.ch"
#include "box.ch"
#include "common.ch"
#include "setcurs.ch"

#command BEEP ERROR     ;
=>  if set(_SET_BELL)   ;
    ; tone(1200, .1)    ;
    ; tone(1400, .1)    ;
    ; tone(1600, .1)    ;
    ; endif

#define MAX_LINE_LEN 256
#define CRLF         chr(13) + chr(10)

#xtranslate :nHandle    => :cargo\[1\]
#xtranslate :cline      => :cargo\[2\]
#xtranslate :nOffset    => :cargo\[3\]
#xtranslate :nRowCount  => :cargo\[4\]

PARAMETERS cFile, cSalida
    LOCAL oWin
	LOCAL cAux:=SAVESCREEN(0,0,24,79), nCursor:=SET(_SET_CURSOR,SC_ON)
	LOCAL cColor:=SETCOLOR(C_FONDO), lIntensity:=SET(_SET_INTENSITY)
        cColor:=C_MENU
	DEFAULT cSalida TO "LPT1"

	SCROLL(0,0,24,79,-25)
	MENUDOWN({"     º PgUp   º   HOME    º  END  º ALT M  º   F7    º ESC  ",;
		  " Ä Ä º PgDown º           º       º calcu- º         º      ",;
		  " mueve º mueve+ º principio º final º ladora º imprime º sale "} )
    txtbrowse(cFile,0,0,21,79)
return nil

FUNCTION TxtBrowse(cFile, nTop, nLeft, nBottom, nRight, cColor)

   LOCAL obrowse,      ;
         ocol,         ;
         nKey := 0,    ;
         nPos := 0,    ;
         nTotLines:=0, ;
         cScreen

   BEGIN SEQUENCE

   // File Name must be specified, if not then generate an error
   IF valtype(cFile) <> "C"
      beep error
      alert("Incorect file name!")
      BREAK
   ENDIF

   // Check coordinates
   nTop     := if(valtype(nTop) <> "N", 0, nTop)
   nLeft    := if(valtype(nLeft) <> "N", 0, nLeft)
   nBottom  := if(valtype(nBottom) <> "N", maxrow(), nBottom)
   nRight   := if(valtype(nRight) <> "N", maxcol(), nRight)

   // Check color
   cColor   := if(valtype(cColor) <> "C", "W/B", cColor)

   // Create TBrowse object
   obrowse := tbrowsenew(nTop+1, nLeft+1, nBottom-1, nRight-1)
   obrowse:colorspec := cColor

   // Initialize variables in cargo
   obrowse:cargo := array(4)

   IF (obrowse:nHandle := fopen(cFile)) < 0
      beep error
      alert(" File can not be opened! ")
      BREAK
   ENDIF

   obrowse:cLine := ""
   obrowse:nOffset := 1
   obrowse:nRowCount := 1
   nLargo := nRight - nLeft - 2

   // Find number of lines
   nTotLines := LineCount(obrowse:nHandle)

   // Modify TBrowse object (assign skippers etc.)
   obrowse:goBottomBlock  := {|| GetLast(obrowse), ;
                                 obrowse:nrowcount := nTotLines }
   obrowse:goTopBlock     := {|| GetFirst(obrowse), ;
                                 obrowse:nrowcount := 1 }
   obrowse:skipBlock      := {|n| SkipLine(n, obrowse) }
   obrowse:headsep        := ""
   obrowse:autolite       := .f.

   // Create TBColumn object
   ocol := tbcolumnnew(, {|| substr(obrowse:cLine, obrowse:nOffset) } )
   ocol:width := nRight - nLeft

   // Add column to browse object
   obrowse:addcolumn(ocol)

   // Save the screen
   cScreen := savescreen(nTop, nLeft, nBottom, nRight)

   // Draw box
   dispbox(nTop, nLeft, nBottom, nRight, B_SINGLE + " ", cColor, .f.)

   // Read first line
   getfirst(obrowse)

   // Finally go into browse loop
   DO WHILE nKey <> K_ESC

      dispbegin()
      WHILE !obrowse:stabilize()   ;      ENDDO

         dispstring(nBottom, nLeft+2,                                    ;
         padc(alltrim(transform(oBrowse:nRowCount,"999,999")),6) + ":" + ;
         padc(alltrim(transform(oBrowse:nOffset,"999,999"))+" ",5)     , ;
         cColor)

      dispend()

      @ row(), col() say substr(obrowse:cLine,obrowse:nOffset,nLargo) color C_ELEGIDO
      nKey := Inkey(0)
      @ row(), col() say substr(obrowse:cLine,obrowse:nOffset,nLargo) color cColor

      IF nKey == K_RIGHT
         if(obrowse:nOffset < len(obrowse:cLine), obrowse:nOffset++, )
         obrowse:RefreshAll()
      ELSEIF nKey == K_LEFT
         if(obrowse:nOffset > 1, obrowse:nOffset--, )
         obrowse:RefreshAll()
      ELSEIF nKey == K_HOME
         obrowse:nOffset := 1
         obrowse:RefreshAll()
      ELSEIF nKey == K_END
         obrowse:nOffset := max(1, len(obrowse:cLine) - obrowse:nRight   + ;
                            obrowse:nLeft )
         obrowse:RefreshAll()
      ELSEIF nKey == K_UP
         obrowse:up()
      ELSEIF nKey == K_DOWN
         obrowse:down()
      ELSEIF nKey == K_PGUP
         obrowse:pageup()
      ELSEIF nKey == K_PGDN
         obrowse:pagedown()
      ELSEIF nKey == K_CTRL_PGUP
         obrowse:gotop()
      ELSEIF nKey == K_CTRL_PGDN
         obrowse:gobottom()
      ELSEIF nKey == K_CTRL_RIGHT
         if(obrowse:nOffset+10 < len(obrowse:cLine), obrowse:nOffset+=10, )
         obrowse:RefreshAll()
      ELSEIF nKey == K_CTRL_LEFT
         if(obrowse:nOffset-10 > 1, obrowse:nOffset-=10, )
         obrowse:RefreshAll()
      ELSEIF nKey == K_F7
     	MENSAJE(0,0,0,.F., "IMPRIMIENDO...")
	copy file (cFile) to (cSalida)
	RECUPAN()
      ELSEIF nKey == K_ALT_M
     	CALC()
      ENDIF

      clear typeahead
   ENDDO

   // Close the file
   fclose(obrowse:nhandle)

   // restore screen
   restscreen(nTop, nLeft, nBottom, nRight, cScreen)

   END SEQUENCE

RETURN nil

// Skip method
STATIC FUNCTION skipline(n, obrowse)

   LOCAL nSkipped := 0

   IF n > 0
      DO WHILE nSkipped != n .AND. NextLine(obrowse)
         nSkipped++
         oBrowse:nRowCount++
      ENDDO
   ELSE
      DO WHILE nSkipped != n .AND. PrevLine(obrowse)
         nSkipped--
         oBrowse:nRowCount--
      ENDDO
   ENDIF

RETURN nSkipped


// Read next line
STATIC FUNCTION NextLine(obrowse)

   LOCAL nSavePos := fseek(obrowse:nHandle, 0, FS_RELATIVE), ;
         cBuff := "", lMoved, nNewPos

   fseek(obrowse:nHandle, len(obrowse:cLine)+2, FS_RELATIVE)
   nNewPos := fseek(obrowse:nHandle, 0, FS_RELATIVE)

   IF readline( @cBuff, obrowse:nHandle )
      lMoved := .t.
      obrowse:cLine := cBuff
      fseek(obrowse:nHandle, nNewPos, FS_SET)
   ELSE
      lMoved := .f.
      fseek(obrowse:nHandle, nSavePos, FS_SET)
   ENDIF

RETURN lMoved



// Read previous line
STATIC FUNCTION PrevLine(obrowse)
   LOCAL nOrigPos := fseek(obrowse:nHandle, 0, FS_RELATIVE), ;
         nMaxRead, nNewPos, lMoved, cBuff, nWhereCrLf, nPrev, cTemp

   IF nOrigPos = 0
      lMoved := .f.
   ELSE
      lMoved := .t.
      fseek(obrowse:nHandle, -2, FS_RELATIVE )
      cTemp := space(2)
      fread(obrowse:nHandle, @cTemp, 2 )
      IF cTemp == CRLF
         fseek(obrowse:nHandle, -2, FS_RELATIVE)
      ENDIF
      nMaxRead := min( MAX_LINE_LEN, fseek(obrowse:nHandle, 0, FS_RELATIVE) )
      cBuff := space( nMaxRead )
      nNewPos := fseek(obrowse:nHandle, -nMaxRead, FS_RELATIVE)
      fread(obrowse:nHandle, @cBuff, nMaxRead )
      nWhereCrLf := rat( CRLF, cBuff )
      IF nWhereCrLf = 0
         nPrev := nNewPos
         obrowse:cLine := cBuff
      ELSE
         nPrev := nNewPos + nWhereCrLf + 1
         obrowse:cLine := substr( cBuff, nWhereCrLf + 2 )
      ENDIF

      fseek( obrowse:nHandle, nPrev, FS_SET )
   ENDIF

RETURN lMoved


// Read first line
STATIC FUNCTION GetFirst(obrowse)

   LOCAL cBuffer

   fseek(obrowse:nHandle, 0, FS_SET)
   cBuffer := obrowse:cLine
   readline(@cBuffer, obrowse:nHandle)
   obrowse:cLine := cBuffer
   fseek(obrowse:nHandle, 0, FS_SET)

RETURN nil


// Read last line
STATIC FUNCTION GetLast(obrowse)

   fseek( obrowse:nHandle, 0, FS_END )
   PrevLine(obrowse)

RETURN nil


// Read line
STATIC FUNCTION readline(cBuffer, nHandle)

   LOCAL nEol, nRead, nSaveFpos

   cBuffer := space(MAX_LINE_LEN)

   nSaveFPos := fseek(nHandle, 0, FS_RELATIVE )
   nRead := fread( nHandle, @cBuffer, MAX_LINE_LEN )

   IF (nEol := at(CRLF, substr( cBuffer, 1, nRead ) ) ) = 0

   ELSE
      cBuffer := substr( cBuffer, 1, nEol -1 )
      fseek( nHandle, nSaveFpos + nEol + 1, FS_SET )
   ENDIF

RETURN nRead != 0



// Line counter
STATIC FUNCTION LineCount(nHandle)

   LOCAL nOldPos := fseek(nHandle, 0, FS_RELATIVE) ,;
         cBuffer := space(MAX_LINE_LEN)            ,;
         nTotLines := 0

   // Go to top of file
   fseek(nHandle, 0, FS_SET)

   WHILE readline(cBuffer, nHandle)
      nTotLines++
   END

   // Go to previous position
   fseek(nHandle, nOldPos, FS_SET)

RETURN nTotLines

// Display string
STATIC FUNCTION dispstring(nTop, nLeft, cString, cColor)

   LOCAL nRow := row(), nCol := col(), nCursor := set(_SET_CURSOR, 0)

   @nTop, nLeft say cString color cColor

   setpos(nRow, nCol)
   set(_SET_CURSOR, nCursor)

RETURN nil
