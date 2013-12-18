/*==========================================================================*/
/* Product   : FDOS - Fiscal Printer DOS Languages API                      */
/* File      : fdl_clp.ch                                                   */
/*==========================================================================*/
/* Functions : Comandos del usuario                                         */
/*                                                                          */
/*             User commands                                                */
/*                                                                          */
/* Purpose   : Definiciones globales para CA-Clipper 5.20                   */
/*             Incluir este archivo desde la aplicacion del usuario         */
/*                                                                          */
/*             Global definitions for CA-Clipper 5.20                       */
/*             Include this file from user's application                    */
/*                                                                          */
/* Notes     : Incluir solo desde Clipper, no desde C                       */
/*                                                                          */
/*             Include this file only from Clipper, not from C              */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/* Author    : Ezequiel Valenzuela                                          */
/*--------------------------------------------------------------------------*/
/* Begin Date   : 20/06/97                                                  */
/* End Date     :                                                           */
/*==========================================================================*/

#ifndef  __INCLUDE_FDL_CLP_H
#define  __INCLUDE_FDL_CLP_H

   // definir el simbolo para Clipper, si es que no estaba definido
   // E: define Clipper symbol, if not defined before
#ifndef  __CLIPPER__
   #define  __CLIPPER__    // presence symbol
#endif   // __CLIPPER__

   // algunas definiciones para manejar algunos datos mas facilmente
   // E: some definitions to manage data more comfortably
#define  IF_VAL( var, exp, val ) ;
            var := iif( var = (val), (exp), (var) )
#define  IF_TRUE( var, exp )     IF_VAL( var, exp, .T. )
#define  IF_FALSE( var, exp )    IF_VAL( var, exp, .F. )

   // encabezado comun para C y Clipper
   // E: common header file for C and Clipper
#include "fdl_c.h"

   // = definiciones internas =
   // = E: internal definitions =

#ifndef  FD_ABORTFUN
   #define  FD_ABORTFUN( s )        FD__AbortFun( s )
#endif   // FD_ABORTFUN

#ifndef  FD_ABORTFUN_SEPARATOR
   #define  FD_ABORTFUN_SEPARATOR   "|+|"
#endif   // FD_ABORTFUN_SEPARATOR

#ifndef  FD_ABORTFUN_ERRORLEVEL
   #define  FD_ABORTFUN_ERRORLEVEL  15
#endif   // FD_ABORTFUN_ERRORLEVEL

#ifndef  FD_GETVERSION_SEPARATOR_DEFAULT
   #define  FD_GETVERSION_SEPARATOR_DEFAULT        "<+>"
#endif   // FD_GETVERSION_SEPARATOR_DEFAULT

   // algunos comandos utiles
   // E: some useful commands
#command FD_VERIFY_OPTIONAL <var> TYPE <types> DEFAULT <def>            ;
            [VALID <expVali,...>]                                       ;
   =>                                                                   ;
      <var> := IIF(                                                     ;
            VALTYPE(<var>) $ UPPER(<types>)                             ;
            [.and. Eval( <{expVali}> )], <var>, <def>                   ;
         )                                                              ;
   // end command

#command FD_VERIFY_REQUIRED <var> TYPE <types>                          ;
            [VALID <expVali,...>]                                       ;
   =>                                                                   ;
      iif (                                                             ;
            !( VALTYPE(<var>) $ UPPER(<types>)                          ;
               [.and. Eval( <{expVali}> )]                              ;
            ),                                                          ;
            FD_ABORTFUN(                                                ;
                  "Error"                                               ;
                  + FD_ABORTFUN_SEPARATOR +                             ;
                  "proc: " + procname()                                 ;
                  + FD_ABORTFUN_SEPARATOR +                             ;
                  "var: " + <"var">                                     ;
                  + FD_ABORTFUN_SEPARATOR +                             ;
                  "type: " + valtype(<var>)                             ;
                  + FD_ABORTFUN_SEPARATOR +                             ;
                  "expected types: " + <"types">                        ;
                  + FD_ABORTFUN_SEPARATOR +                             ;
                  "validation: " +                                      ;
                     iif(  VALTYPE(<var>) $ UPPER(<types>),             ;
                           iif(  .T. [.and. Eval( <{expVali}> )]        ;
                                 , ".T.", ".F."                         ;
                              ),                                        ;
                           "not performed"                              ;
                        )                                               ;
               )                                                        ;
            , NIL                                                       ;
         )                                                              ;
   // end command

// Nombres de funciones
// E: Function names

   /* from: fdl_c.h */
   /* search: FDOS_FUNCTIONNAME_ */
   /* replace: _FDOS_FCMD_EXTERNAL_ */

#define  _FDOS_FCMD_EXTERNAL_GETVERSION            _F_GetVr
#define  _FDOS_FCMD_EXTERNAL_ABOUTDIALOG           _F_AbtDg

#define  _FDOS_FCMD_EXTERNAL_BIT_AND               _F_And
#define  _FDOS_FCMD_EXTERNAL_BIT_OR                _F_Or
#define  _FDOS_FCMD_EXTERNAL_BIT_NOT               _F_Not
#define  _FDOS_FCMD_EXTERNAL_BIT_SHIFTL            _F_ShL
#define  _FDOS_FCMD_EXTERNAL_BIT_SHIFTR            _F_ShR
#define  _FDOS_FCMD_EXTERNAL_BIT_TESTBIT           _F_TstB
#define  _FDOS_FCMD_EXTERNAL_BIT_GETBITS           _F_GtB
#define  _FDOS_FCMD_EXTERNAL_BIT_SETBITS           _F_StB

#ifdef   _FDOS_TECHSUPPORT_VERSION

      /* E: Manufacturing Program Test */
   #define  _FDOS_FCMD_EXTERNAL_MANFPRGTEST           _F_MPTst
      /* E: Manufactiring Program Report */
   #define  _FDOS_FCMD_EXTERNAL_MANFPRGREP            _F_MPRep
      /* E: Diagnostic Report */
   #define  _FDOS_FCMD_EXTERNAL_DIAGREP               _F_DgRep
      /* E: Diagnostic Dump Memory */
   #define  _FDOS_FCMD_EXTERNAL_DIAGDUMPMEM           _F_DgDmM
      /* E: Ripple Test */
   #define  _FDOS_FCMD_EXTERNAL_RIPPLETEST            _F_RplTs
      /* E: Terminal Reset */
   #define  _FDOS_FCMD_EXTERNAL_TERMRESET             _F_TrmRt
      /* E: Certification Dump */
   #define  _FDOS_FCMD_EXTERNAL_CERTDUMP              _F_CtDmp
      /* E: Certification Load */
   #define  _FDOS_FCMD_EXTERNAL_CERTLOAD              _F_CtLad
      /* E: Certify */
   #define  _FDOS_FCMD_EXTERNAL_CERTIFY               _F_Crtfy
      /* E: Fiscalization Dump */
      /* E: Fiscalization Load */
   #define  _FDOS_FCMD_EXTERNAL_FISCALLOAD            _F_FLoad
      /* E: Fiscalize */
   #define  _FDOS_FCMD_EXTERNAL_FISCALIZE             _F_Fsclz
      /* E: History Capacity */
   #define  _FDOS_FCMD_EXTERNAL_HISTCAP               _F_HstCp

      /* E: com1 Status */
   #define  _FDOS_FCMD_EXTERNAL_COM1STATUS            _F_C1Sts
      /* E: com1 Command */
   #define  _FDOS_FCMD_EXTERNAL_COM1COMMAND           _F_C1Cmd
      /* E: com1 Write */
   #define  _FDOS_FCMD_EXTERNAL_COM1WRITE             _F_C1Wrt
      /* E: com1 Read */
   #define  _FDOS_FCMD_EXTERNAL_COM1READ              _F_C1Red
      /* E: com2 Status */
   #define  _FDOS_FCMD_EXTERNAL_COM2STATUS            _F_C2Sts
      /* E: com2 Command */
   #define  _FDOS_FCMD_EXTERNAL_COM2COMMAND           _F_C2Cmd
      /* E: com2 Write */
   #define  _FDOS_FCMD_EXTERNAL_COM2WRITE             _F_C2Wrt
      /* E: com2 Read */
   #define  _FDOS_FCMD_EXTERNAL_COM2READ              _F_C2Red

#endif   /* _FDOS_TECHSUPPORT_VERSION */

   /* E: User Memory Write */
#define  _FDOS_FCMD_EXTERNAL_USERMEMWRITE          _F_UsMWr
   /* E: User Memory Read */
#define  _FDOS_FCMD_EXTERNAL_USERMEMREAD           _F_UsMRd
   /* E: Status Request */
#define  _FDOS_FCMD_EXTERNAL_STATUSREQ             _F_StReq
   /* E: Daily Close */
#define  _FDOS_FCMD_EXTERNAL_DAILYCLOSE            _F_DlyCl
   /* E: Daily Close Report By Date */
#define  _FDOS_FCMD_EXTERNAL_CLOSEBYDATE           _F_ClBDt
   /* E: Daily Close Report By Number */
#define  _FDOS_FCMD_EXTERNAL_CLOSEBYNUMBER         _F_ClBNm
   /* E: Defiscalize */
#define  _FDOS_FCMD_EXTERNAL_DEFISCALIZE           _F_DeFsc
   /* E: Non-Fiscal Open */
#define  _FDOS_FCMD_EXTERNAL_NONOPEN               _F_NOpen
   /* E: Non-Fiscal Text */
#define  _FDOS_FCMD_EXTERNAL_NONTEXT               _F_NText
   /* E: Non-Fiscal Close */
#define  _FDOS_FCMD_EXTERNAL_NONCLOSE              _F_NClos
   /* E: Non-Fiscal Paper Cut */
#define  _FDOS_FCMD_EXTERNAL_NONCUT                _F_NCut
   /* E: Fiscal Receipt Open */
#define  _FDOS_FCMD_EXTERNAL_FISCALOPEN            _F_FOpen
   /* E: Fiscal Receipt Text */
#define  _FDOS_FCMD_EXTERNAL_FISCALTEXT            _F_FText
   /* E: Fiscal Receipt Item */
#define  _FDOS_FCMD_EXTERNAL_FISCALITEM            _F_FItem
   /* E: Fiscal Receipt Subtotal */
#define  _FDOS_FCMD_EXTERNAL_FISCALSUBTOTAL        _F_FSubT
   /* E: Fiscal Receipt Total */
#define  _FDOS_FCMD_EXTERNAL_FISCALTOTAL           _F_FTotl
   /* E: Fiscal Receipt Close */
#define  _FDOS_FCMD_EXTERNAL_FISCALCLOSE           _F_FClos
   /* E: Feed Receipt */
#define  _FDOS_FCMD_EXTERNAL_FEEDRECEIPT           _F_FdRcp
   /* E: Feed Journal */
#define  _FDOS_FCMD_EXTERNAL_FEEDJOURNAL           _F_FdJnl
   /* E: Feed Both */
#define  _FDOS_FCMD_EXTERNAL_FEEDBOTH              _F_FdBth
   /* E: Feed Slip */
#define  _FDOS_FCMD_EXTERNAL_FEEDSLIP              _F_FdSlp
   /* E: Select Print Mode */
#define  _FDOS_FCMD_EXTERNAL_SELPRINTMODE          _F_SlPrM
   /* E: Set Date & Time */
#define  _FDOS_FCMD_EXTERNAL_SETDATETIME           _F_StDtT
   /* E: Get Date & Time */
#define  _FDOS_FCMD_EXTERNAL_GETDATETIME           _F_GtDtT
   /* E: Set Header/Trailer */
#define  _FDOS_FCMD_EXTERNAL_SETHEADERTRAILER      _F_StHTr
   /* E: Get Header/Trailer */
#define  _FDOS_FCMD_EXTERNAL_GETHEADERTRAILER      _F_GtHTr
   /* E: Fiscal Slip Open */
#define  _FDOS_FCMD_EXTERNAL_SLIPOPEN              _F_SOpen
   /* E: Fiscal Slip Text */
#define  _FDOS_FCMD_EXTERNAL_SLIPTEXT              _F_SText
   /* E: Fiscal Slip Item */
#define  _FDOS_FCMD_EXTERNAL_SLIPITEM              _F_SItem
   /* E: Fiscal Slip Subtotal */
#define  _FDOS_FCMD_EXTERNAL_SLIPSUBTOTAL          _F_SSubT
   /* E: Fiscal Slip Total */
#define  _FDOS_FCMD_EXTERNAL_SLIPTOTAL             _F_STotl
   /* E: Slip Select */
#define  _FDOS_FCMD_EXTERNAL_SLIPSELECT            _F_SSelt
   /* E: Fiscal Slip Close */
#define  _FDOS_FCMD_EXTERNAL_SLIPCLOSE             _F_SClos
   /* E: Non-Fiscal Slip Open */
#define  _FDOS_FCMD_EXTERNAL_NSLIPOPEN             _F_NSOpn
   /* E: Non-Fiscal Slip Text */
#define  _FDOS_FCMD_EXTERNAL_NSLIPTEXT             _F_NSTxt
   /* E: Non-Fiscal Slip Close */
#define  _FDOS_FCMD_EXTERNAL_NSLIPCLOSE            _F_NSCls
   /* E: Open Drawer 1 */
#define  _FDOS_FCMD_EXTERNAL_OPENDRAWER1           _F_OpnD1
   /* E: Open Drawer 2 */
#define  _FDOS_FCMD_EXTERNAL_OPENDRAWER2           _F_OpnD2

   /* E: Fiscalization Dump */
#define  _FDOS_FCMD_EXTERNAL_FISCALDUMP            _F_FDump

#endif   /* __INCLUDE_FDL_CLP_H */

/* eof */