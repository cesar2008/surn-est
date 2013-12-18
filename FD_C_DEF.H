/*==========================================================================
 * Product   : FDOS - Fiscal Printer DOS Languages API
 * File      : FD_C_DEF.H
 *==========================================================================
 * Classes   :
 *
 * Methods   :
 *
 * Functions :
 *
 * Purpose   : Definiciones de simbolos para control de versiones
 *
 *             Version control symbols definitions
 *
 * Notes     :
 *
 *--------------------------------------------------------------------------
 * Author    : Ezequiel Valenzuela
 *--------------------------------------------------------------------------
 * Begin Date   : 12/12/97
 * End Date     :
 *==========================================================================
 */

#ifndef __INCLUDE_FD_C_DEF_H
#define __INCLUDE_FD_C_DEF_H

/* Other Definitions */

   /* si esta definido, se utilizaran todas las funciones de soporte */
   /* tecnico */
   /* E: if defined, all technical support functions will be used */
#ifndef  _FDOS_TECHSUPPORT_VERSION
      /* presence */
   /* #define _FDOS_TECHSUPPORT_VERSION */
#endif   /* _FDOS_TECHSUPPORT_VERSION */

   /* procesa simbolos de linea de comandos */
   /* E: process command-line symbols */

   /* E: technical support */
#ifdef   _FDOS_TS
   #ifndef  _FDOS_TECHSUPPORT_VERSION
      #define  _FDOS_TECHSUPPORT_VERSION
   #endif   /* _FDOS_TECHSUPPORT_VERSION */
#endif   /* _FDOS_TS */

   /* E: user version */
#ifdef   _FDOS_USER
   #ifdef   _FDOS_TECHSUPPORT_VERSION
      #undef   _FDOS_TECHSUPPORT_VERSION
   #endif   /* _FDOS_TECHSUPPORT_VERSION */
#endif   /* _FDOS_USER */

#endif            /* __INCLUDE_FD_C_DEF_H */

/* eof */