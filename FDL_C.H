/*==========================================================================*/
/* Product   : FDOS - Fiscal Printer DOS Languages API                      */
/* File      : fdl_c.h                                                      */
/*==========================================================================*/
/* Classes   :                                                              */
/*                                                                          */
/* Methods   :                                                              */
/*                                                                          */
/* Functions :                                                              */
/*                                                                          */
/* Purpose   : Define los nombres internos de las funciones                 */
/*             Define algunas constantes e incluye otros files              */
/*                                                                          */
/*             Define internal function names                               */
/*             Define some constants and include other files                */
/*                                                                          */
/* Notes     : Pensado para ser utilizado (a nivel codigo) por Clipper      */
/*                                                                          */
/*             File designed to be used (at code level) from Clipper        */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/* Author    : Ezequiel Valenzuela                                          */
/*--------------------------------------------------------------------------*/
/* Begin Date   : 20/06/97                                                  */
/* End Date     :                                                           */
/*==========================================================================*/

#ifndef __INCLUDE_FDL_C_H
#define __INCLUDE_FDL_C_H

#ifndef  __CLIPPER__
      /* como voy a usar tipos de Clipper, salteo las definiciones */
      /* de tipos de datos */
      /* E: since I will use Clipper types, skip data definitions */
   #ifndef GR_ALLTYPES_SKIP
      #define GR_ALLTYPES_SKIP   /* presence */
   #endif   /* GR_ALLTYPES_SKIP */

   #include <fd_c.h>    /* encabezado comun para todos los lenguajes */
                        /* E: common header for all languages */
#else
   #include "fd_c.h"    /* encabezado comun para todos los lenguajes */
                        /* E: common header for all languages */
#endif   /* __CLIPPER__ */

/* Parte en comun para C y Clipper */
/* E: Common section for C and Clipper */

/* Otras definiciones */
/* E: Other Definitions */

/* from '#define's (fdc_cfn.h) */
/* search: ^{?#}_FDOS_FNAME_C_{[~ ]#}?#$ */
/* replace: #0FDOS_FUNNAME_#1 */

#define  FDOS_FUNNAME_GETVERSION                FD_GetVr

#define  FDOS_FUNNAME_AND                       _FD_And
#define  FDOS_FUNNAME_OR                        _FD_Or
#define  FDOS_FUNNAME_NOT                       _FD_Not
#define  FDOS_FUNNAME_SHIFTL                    _FD_ShL
#define  FDOS_FUNNAME_SHIFTR                    _FD_ShR
#define  FDOS_FUNNAME_TESTBIT                   _FD_TtB
#define  FDOS_FUNNAME_GETBITS                   _FD_GtB
#define  FDOS_FUNNAME_SETBITS                   _FD_StB


#ifdef   _FDOS_TECHSUPPORT_VERSION

   #define  FDOS_FUNNAME_MANFPRGTEST               FD_MPTst
   #define  FDOS_FUNNAME_MANFPRGREP                FD_MPRep
   #define  FDOS_FUNNAME_DIAGREP                   FD_DgRep
   #define  FDOS_FUNNAME_DIAGDUMPMEM               FD_DgDmM
   #define  FDOS_FUNNAME_RIPPLETEST                FD_RplTs
   #define  FDOS_FUNNAME_TERMRESET                 FD_TrmRt
   #define  FDOS_FUNNAME_CERTDUMP                  FD_CtDmp
   #define  FDOS_FUNNAME_CERTLOAD                  FD_CtLad
   #define  FDOS_FUNNAME_CERTIFY                   FD_Crtfy
            /* fiscal dump */
   #define  FDOS_FUNNAME_FISCALLOAD                FD_FLoad
   #define  FDOS_FUNNAME_FISCALIZE                 FD_Fsclz
   #define  FDOS_FUNNAME_HISTCAP                   FD_HstCp
   #define  FDOS_FUNNAME_COM1STATUS                FD_C1Sts
   #define  FDOS_FUNNAME_COM1COMMAND               FD_C1Cmd
   #define  FDOS_FUNNAME_COM1WRITE                 FD_C1Wrt
   #define  FDOS_FUNNAME_COM1READ                  FD_C1Red
   #define  FDOS_FUNNAME_COM2STATUS                FD_C2Sts
   #define  FDOS_FUNNAME_COM2COMMAND               FD_C2Cmd
   #define  FDOS_FUNNAME_COM2WRITE                 FD_C2Wrt
   #define  FDOS_FUNNAME_COM2READ                  FD_C2Red

#endif   /* _FDOS_TECHSUPPORT_VERSION */

#define  FDOS_FUNNAME_USERMEMWRITE              FD_UsMWr
#define  FDOS_FUNNAME_USERMEMREAD               FD_UsMRd
#define  FDOS_FUNNAME_STATUSREQ                 FD_StReq
#define  FDOS_FUNNAME_DAILYCLOSE                FD_DlyCl
#define  FDOS_FUNNAME_CLOSEBYDATE               FD_ClBDt
#define  FDOS_FUNNAME_CLOSEBYNUMBER             FD_ClBNm
#define  FDOS_FUNNAME_DEFISCALIZE               FD_DeFsc
#define  FDOS_FUNNAME_NONOPEN                   FD_NOpen
#define  FDOS_FUNNAME_NONTEXT                   FD_NText
#define  FDOS_FUNNAME_NONCLOSE                  FD_NClos
#define  FDOS_FUNNAME_NONCUT                    FD_NCut
#define  FDOS_FUNNAME_FISCALOPEN                FD_FOpen
#define  FDOS_FUNNAME_FISCALTEXT                FD_FText
#define  FDOS_FUNNAME_FISCALITEM                FD_FItem
#define  FDOS_FUNNAME_FISCALSUBTOTAL            FD_FSubT
#define  FDOS_FUNNAME_FISCALTOTAL               FD_FTotl
#define  FDOS_FUNNAME_FISCALCLOSE               FD_FClos
#define  FDOS_FUNNAME_FEEDRECEIPT               FD_FdRcp
#define  FDOS_FUNNAME_FEEDJOURNAL               FD_FdJnl
#define  FDOS_FUNNAME_FEEDBOTH                  FD_FdBth
#define  FDOS_FUNNAME_FEEDSLIP                  FD_FdSlp
#define  FDOS_FUNNAME_SELPRINTMODE              FD_SlPrM
#define  FDOS_FUNNAME_SETDATETIME               FD_StDtT
#define  FDOS_FUNNAME_GETDATETIME               FD_GtDtT
#define  FDOS_FUNNAME_SETHEADERTRAILER          FD_StHTr
#define  FDOS_FUNNAME_GETHEADERTRAILER          FD_GtHTr
#define  FDOS_FUNNAME_SLIPOPEN                  FD_SOpen
#define  FDOS_FUNNAME_SLIPTEXT                  FD_SText
#define  FDOS_FUNNAME_SLIPITEM                  FD_SItem
#define  FDOS_FUNNAME_SLIPSUBTOTAL              FD_SSubT
#define  FDOS_FUNNAME_SLIPTOTAL                 FD_STotl
#define  FDOS_FUNNAME_SLIPSELECT                FD_SSelt
#define  FDOS_FUNNAME_SLIPCLOSE                 FD_SClos
#define  FDOS_FUNNAME_NSLIPOPEN                 FD_NSOpn
#define  FDOS_FUNNAME_NSLIPTEXT                 FD_NSTxt
#define  FDOS_FUNNAME_NSLIPCLOSE                FD_NSCls
#define  FDOS_FUNNAME_OPENDRAWER1               FD_OpnD1
#define  FDOS_FUNNAME_OPENDRAWER2               FD_OpnD2

#define  FDOS_FUNNAME_FISCALDUMP                FD_FDump

/* Declaraciones de tipos */
/* E: Type Declarations */

/* Declaraciones de Prototipos */
/* E: Prototype Declarations */

/* Ambiente global y de archivo: declaraciones y definiciones */
/* E: File/Global Scope Declarations/Definitions */

/* Comienza codigo de Funciones y Metodos */
/* E: Functions/Methods Code Begins */

   /* Seccion de Clipper */
   /* E: Clipper section */
#ifndef  __CLIPPER__

   /* - COLISSION! - */
   /**/
   /* compiler reports: */
   /*    'TRUE: redefinition' (line 83, file clipdefs.h) */
   /* since both epfaideq.h and clipdefs.h are provided by others */
   /* (and its values are used on each package) I suggest this */
   /* temporal solution: undefine this symbol and try to avoid */
   /* to use them */
   #ifdef TRUE
      #undef   TRUE     /* temporal solution */
   #endif   /* TRUE */

   /* CA-Clipper Extend system */
   #include <extend.h>

      /* since it was necessary to avoid type declarations, */
      /* declare CHAR here */
   #ifndef CHAR
      #define CHAR   char
   #endif   /* CHAR */

   /* definitions for Clipper functions */
   #define  FDOS_CLIPPERFUNCTION             CLIPPER
   #define  FDOS_CLIPPERFUNCTIONARGUMENTS    void

#else

   //??? #define  FDOS_FUNCTION_FISCALSTATUS    FDOS_FUNNAME_FISCALSTATUS      ()

#endif   /* __CLIPPER__ */

#endif            /* __INCLUDE_FDL_C_H */

/* eof */