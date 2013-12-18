/*==========================================================================*/
/* Product   : FDOS - Fiscal Printer DOS Languages API                      */
/* File      : fd_c.h                                                       */
/*==========================================================================*/
/* Classes   :                                                              */
/*                                                                          */
/* Methods   :                                                              */
/*                                                                          */
/* Functions :                                                              */
/*                                                                          */
/* Purpose   : Definiciones globales para todos los lenguajes               */
/*                                                                          */
/*             Global definitions (for all languages)                       */
/*                                                                          */
/* Notes     : Este file puede incluirse desde Clipper                      */
/*                                                                          */
/*             This file can be included from Clipper                       */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/* Author    : Ezequiel Valenzuela                                          */
/*--------------------------------------------------------------------------*/
/* Begin Date   : 20/06/97                                                  */
/* End Date     :                                                           */
/*==========================================================================*/

#ifndef __INCLUDE_FD_C_H
#define __INCLUDE_FD_C_H

#include "fd_c_def.h"

/* Seccion comun para C y Clipper */
/* E: Common section for C and Clipper */

/* Otras definiciones */
/* E: Other Definitions */

#define  FDOS_FLDSEP_STR_LEN                 1
#ifndef  __CLIPPER__
   #define  FDOS_FLDSEP_STR                  "\x1c"
#else
               /* 0x1C= 0x1C = 28 (Dec) */
   #define  FDOS_FLDSEP_STR                  chr( 28 )
#endif   /* __CLIPPER__ */

   /* si esta definido, se utilizara un separador antes del primer */
   /* campo */
   /* E: if defined, separator will be used before first field */
#ifndef FDOS_SEPARATORATBEGINNING
   #define FDOS_SEPARATORATBEGINNING         /* presence */
#endif   /* FDOS_SEPARATORATBEGINNING */

   /* cantidad de campos para los estados - muy importante! */
   /* para implementaciones que usen alguna clase */
   /* de extraccion de campos */
   /* E: qty of status fields - very important  */
   /* E: for implementations that will use some */
   /* E: field extracting */
#define  FDOS_QTY_STATUSFIELDS               3

   /* = Numeros de campo = */
   /* = E: Fields numbers = */
#define  FDOS_FIELD_PRINTERSTATUS            1
#define  FDOS_FIELD_FISCALSTATUS             2

   /* Tamanio minimo de los maximos valores posibles para operandos */
   /* de operaciones de bits */
   /* E: minimum maximum operand size for bitwise operations */
#define  FDOS_BITW_MAXIMUM_MINVALUE    65535 /* 1111 1111 1111 1111b */
#define  FDOS_BITW_MAXIMUM_MINBITS     16    /* 16 bits */

   /* = Bits de Estado = */
   /* = E: Status Bits = */

   /* mascaras */
   /* E: masks */
#define  FDOS_STAT_MASK_STATUS_VALUE   FDOS_BITW_MAXIMUM_MINVALUE
#define  FDOS_STAT_MASK_STATUS_BITS    FDOS_BITW_MAXIMUM_MINBITS

   /* Estado fiscal */
   /* E: Fiscal status */
#define  FDOS_FS_BIT_FISCALMEMCHKFAILED            0
#define  FDOS_FS_BIT_WORKMEMCHECKFAILED            1
#define  FDOS_FS_BIT_BATTERYLOW                    2
#define  FDOS_FS_BIT_UNRECOGNIZEDCOMMAND           3
#define  FDOS_FS_BIT_INVALIDDATAFIELD              4
#define  FDOS_FS_BIT_INVALIDCMDFORSTATUS           5
#define  FDOS_FS_BIT_OVERFLOW                      6
#define  FDOS_FS_BIT_FISCALMEMFULL                 7
#define  FDOS_FS_BIT_FISCALMEMALMOSTFULL           8
#define  FDOS_FS_BIT_FISSTATUS_FIRST               9
#define  FDOS_FS_BIT_FISSTATUS_LAST                10
#define  FDOS_FS_BIT_LINEITEMQTYEXCEEDED           11
#define  FDOS_FS_BIT_DAILYCLOSENEEDED              11
#define  FDOS_FS_BIT_DOCUMENT_FIRST                12
#define  FDOS_FS_BIT_DOCUMENT_LAST                 13
#define  FDOS_FS_BIT_SLIP                          14
#define  FDOS_FS_BIT_LOGICALOR_0_8                 15

   /* Estado de impresora */
   /* E: Printer Status */
#define  FDOS_FP_BIT_ERRORFAILED                   2
#define  FDOS_FP_BIT_OFFLINE                       3
#define  FDOS_FP_BIT_JOURNALLOW                    4
#define  FDOS_FP_BIT_RECEIPTLOW                    5
#define  FDOS_FP_BIT_BUFFERFULL                    6
#define  FDOS_FP_BIT_BUFFEREMPTY                   7
#define  FDOS_FP_BIT_SLIPPREPARED                  8
#define  FDOS_FP_BIT_SLIPPAPER                     9
#define  FDOS_FP_BIT_VALIDPREPARED                 10
#define  FDOS_FP_BIT_VALIDPAPER                    11
#define  FDOS_FP_BIT_LOGICALOR_0_6                 15


   /* old: #define  FDOS_QTY_FLDS_STATUS                1 */
   /* old: #define  FDOS_QTY_FLDS_FEEDRECEIPT           0 */
   /* #define  FDOS_QTY_FLDS_ */

   /* = cantidad de campos para cada comando = */
   /* = E: qty of fields for each command = */

#ifdef   _FDOS_TECHSUPPORT_VERSION

   #define  FDOS_QTY_FLDS_MANFPRGTEST        4
   #define  FDOS_QTY_FLDS_MANFPRGREP         FDOS_QTY_FLDS_MANFPRGTEST
   #define  FDOS_QTY_FLDS_DIAGREP            0
   #define  FDOS_QTY_FLDS_DIAGDUMPMEM        1
   #define  FDOS_QTY_FLDS_RIPPLETEST         0
   #define  FDOS_QTY_FLDS_TERMRESET          0
   #define  FDOS_QTY_FLDS_CERTDUMP           4
   #define  FDOS_QTY_FLDS_CERTLOAD           0
   #define  FDOS_QTY_FLDS_CERTIFY            0
        /*  FDOS_QTY_FLDS_FISCALDUMP */
   #define  FDOS_QTY_FLDS_FISCALLOAD         0
   #define  FDOS_QTY_FLDS_FISCALIZE          0
   #define  FDOS_QTY_FLDS_HISTCAP            2
   #define  FDOS_QTY_FLDS_COM1STATUS         8
   #define  FDOS_QTY_FLDS_COM1COMMAND        0
   #define  FDOS_QTY_FLDS_COM1WRITE          0
   #define  FDOS_QTY_FLDS_COM1READ           2
   #define  FDOS_QTY_FLDS_COM2STATUS         FDOS_QTY_FLDS_COM1STATUS
   #define  FDOS_QTY_FLDS_COM2COMMAND        FDOS_QTY_FLDS_COM1COMMAND
   #define  FDOS_QTY_FLDS_COM2WRITE          FDOS_QTY_FLDS_COM1WRITE
   #define  FDOS_QTY_FLDS_COM2READ           FDOS_QTY_FLDS_COM1READ

#endif   /* _FDOS_TECHSUPPORT_VERSION */

#define  FDOS_QTY_FLDS_USERMEMWRITE       0
#define  FDOS_QTY_FLDS_USERMEMREAD        1
#define  FDOS_QTY_FLDS_STATUSREQ          8
#define  FDOS_QTY_FLDS_DAILYCLOSE         9
#define  FDOS_QTY_FLDS_CLOSEBYDATE        0
#define  FDOS_QTY_FLDS_CLOSEBYNUMBER      0
#define  FDOS_QTY_FLDS_DEFISCALIZE        0
#define  FDOS_QTY_FLDS_NONOPEN            0
#define  FDOS_QTY_FLDS_NONTEXT            0
#define  FDOS_QTY_FLDS_NONCLOSE           0
#define  FDOS_QTY_FLDS_NONCUT             0
#define  FDOS_QTY_FLDS_FISCALOPEN         0
#define  FDOS_QTY_FLDS_FISCALTEXT         0
#define  FDOS_QTY_FLDS_FISCALITEM         0
#define  FDOS_QTY_FLDS_FISCALSUBTOTAL     4
#define  FDOS_QTY_FLDS_FISCALTOTAL        1
#define  FDOS_QTY_FLDS_FISCALCLOSE        1
#define  FDOS_QTY_FLDS_FEEDRECEIPT        0
#define  FDOS_QTY_FLDS_FEEDJOURNAL        0
#define  FDOS_QTY_FLDS_FEEDBOTH           0
#define  FDOS_QTY_FLDS_FEEDSLIP           0
#define  FDOS_QTY_FLDS_SELPRINTMODE       0
#define  FDOS_QTY_FLDS_SETDATETIME        0
#define  FDOS_QTY_FLDS_GETDATETIME        2
#define  FDOS_QTY_FLDS_SETHEADERTRAILER   0
#define  FDOS_QTY_FLDS_GETHEADERTRAILER   1
#define  FDOS_QTY_FLDS_SLIPOPEN           FDOS_QTY_FLDS_FISCALOPEN
#define  FDOS_QTY_FLDS_SLIPTEXT           FDOS_QTY_FLDS_FISCALTEXT
#define  FDOS_QTY_FLDS_SLIPITEM           FDOS_QTY_FLDS_FISCALITEM
#define  FDOS_QTY_FLDS_SLIPSUBTOTAL       FDOS_QTY_FLDS_FISCALSUBTOTAL
#define  FDOS_QTY_FLDS_SLIPTOTAL          FDOS_QTY_FLDS_FISCALTOTAL
#define  FDOS_QTY_FLDS_SLIPSELECT         0
#define  FDOS_QTY_FLDS_SLIPCLOSE          FDOS_QTY_FLDS_FISCALCLOSE
#define  FDOS_QTY_FLDS_NSLIPOPEN          0
#define  FDOS_QTY_FLDS_NSLIPTEXT          0
#define  FDOS_QTY_FLDS_NSLIPCLOSE         0
#define  FDOS_QTY_FLDS_OPENDRAWER1        0
#define  FDOS_QTY_FLDS_OPENDRAWER2        FDOS_QTY_FLDS_OPENDRAWER1

#define  FDOS_QTY_FLDS_FISCALDUMP         5     /* old: 4 */

   /* codigos de retorno del API de bajo nivel */
   /* E: Low-level API Return Codes */

#define  FDOS_DRV_SUCCESS                    0
#define  FDOS_DRV_NOAPIFUNCALLED             1
#define  FDOS_DRV_UNKNOWNRETCODE             2

#define  FDOS_DRV_INVALIDFUNCTION            10    /* IFUNC */
#define  FDOS_DRV_FILENOTFOUND               11    /* FILENF */
#define  FDOS_DRV_PATHNOTFOUND               12    /* PATHNF */
#define  FDOS_DRV_NOHANDLES                  13    /* NOHANDL */
#define  FDOS_DRV_ACCESSDENIED               14    /* ACCESSD */
#define  FDOS_DRV_INVALIDHANDLE              15    /* IHANDLE */
#define  FDOS_DRV_INVALIDACCESSCODE          16    /* ACCESSI */
#define  FDOS_DRV_SENDFAILED                 17    /* SENDF */
#define  FDOS_DRV_RECIEVEFAILED              18    /* RECVF */
/* #define  FDOS_DRV_ */

   /* valores para el manejo de versiones */
   /* E: Version values */

#define  FDOS_VER_QUERY_PRODUCTNAME          1     /* 00000001b */
#define  FDOS_VER_QUERY_VERSION              2     /* 00000010b */
#define  FDOS_VER_QUERY_AUTHOR               4     /* 00000100b */
#define  FDOS_VER_QUERY_MANAGEDBY            8     /* 00001000b */
#define  FDOS_VER_QUERY_COPYRIGHT            16    /* 00010000b */
/* #define  FDOS_VER_QUERY_                           / * 00000000b * / */
#define  FDOS_VER_QUERY_ALL                  255   /* 11111111b */

/* Declaraciones de tipos */
/* E: Type Declarations */

/* Declaraciones de Prototipos */
/* E: Prototype Declarations */

/* Ambiente global y de archivo: declaraciones y definiciones */
/* E: File/Global Scope Declarations/Definitions */

/* Comienza codigo de Funciones y Metodos */
/* E: Functions/Methods Code Begins */

   /* seccion de C (no Clipper) */
   /* E: C (not Clipper) section */
#ifndef __CLIPPER__

      /* elige el entorno DOS */
      /* E: set DOS environment */
   #ifndef GR_ENVIRONMENT_SET
      #ifndef GR_ENVIRONMENT_DOS
         #define GR_ENVIRONMENT_DOS /* presence */
      #endif   /* GR_ENVIRONMENT_DOS */

      #define GR_ENVIRONMENT_SET    /* presence */
   #endif   /* GR_ENVIRONMENT_SET */

   #include <e_def.h>            /* incluye encabezado de defaults */
                                 /* E: include defaults header file */

   /* encabezados del API para DOS de la Fiscal Printer */
   /* E: Fiscal DOS API Headers */
   #include <epfaideq.h>   /* Application Interface data equates */
   #include <epfaipeq.h>   /* Application Interface procedure equates */
   #include <epfstseq.h>   /* status equates */

   /* las siguientes lineas estaban en un archivo .C */
   /* E: the following lines were in a .C file */

      /* algunos simbolos para manejar condiciones en cascada */
      /* un poco debiles en concepto, pero... */
      /* E: some symbols to manage cascade conditions */
      /* E: rather weak in concept, but... */
   #define  IF_ZERO( var,exp )      ( !(var) ? (var) = (exp) : (var) )
   #define  IF_NOTZERO( var,exp )   (  (var) ? (var) = (exp) : (var) )

      /* algunas definiciones para 'bool' */
      /* E: some 'bool' definitions */
   #define  BOOL_ZERO               0
   #define  BOOL_NOTZERO            1  /* convention: notzero == ok */
   #define  BOOL_POINTERNOTNULL( p )   ( p != NULL )

#endif   /* __CLIPPER__ */

#endif            /* __INCLUDE_FD_C_H */

/* eof */