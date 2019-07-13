#ifndef _COMPLIANCE_TEST_H
#define _COMPLIANCE_TEST_H

#include "encoding.h"
//-----------------------------------------------------------------------
// RV Compliance Macros
//-----------------------------------------------------------------------

#if XLEN==64
  #define SREG sd
  #define REGWIDTH 8
#else 
  #if XLEN==32
    #define SREG sw
    #define REGWIDTH 4
  #endif
#endif

#define RVTEST_ISA(_STR)

//RV_COMPLIANCE_CODE_BEGIN
#define RVTEST_CODE_BEGIN                                               \
        .section .text.init;                                            \
        .align  6;                                                      \
        .weak stvec_handler;                                            \
        .weak mtvec_handler;                                            \
        .globl _start;                                                  \
_start:                                                                 \
        RVMODEL_BOOT                                                    \
begin_testcode:

//RV_COMPLIANCE_CODE_END                                                             
#define RVTEST_CODE_END                                                \
        unimp               

#define RVTEST_CASE(_PNAME,_DSTR)                               

#define RVTEST_SIGBASE(_R,_TAG) \
  la _R,_TAG;\
  .set offset,0;

#define RVTEST_SIGUPD(_BR,_R,_TAG)\
  SREG _R,offset(_BR);\
  .set offset,offset+REGWIDTH;

#endif //_COMPLIANCE_TEST_H


