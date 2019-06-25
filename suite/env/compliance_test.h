// RISC-V Compliance Test Header File
// Copyright (c) 2017, Codasip Ltd. All Rights Reserved.
// See LICENSE for license details.
//
// Description: Common header file for RV32I tests

#ifndef _COMPLIANCE_TEST_H
#define _COMPLIANCE_TEST_H

#include "riscv_test.h"

//-----------------------------------------------------------------------
// RV Compliance Macros
//-----------------------------------------------------------------------

#if XLEN==64
  #define SREG sd
  #define REGWIDTH 8
#else
  #define SREG sw
  #define REGWIDTH 4
#endif

#define RVTEST_ISA(_STR)

#define RV_COMPLIANCE_HALT                                              \
  RVTEST_PASS                                                           \

#define RV_COMPLIANCE_RV64M                                             \
    RVTEST_RV64M                                                        \

#define RV_COMPLIANCE_RV32M                                             \
    RVTEST_RV32M                                                        \

#define RV_COMPLIANCE_RV32U                                             \
    RVTEST_RV32U                                                        \

#define RV_COMPLIANCE_CODE_BEGIN                                        \
   RVTEST_CODE_BEGIN                                                    \
                                                                     
#define RV_COMPLIANCE_CODE_END                                          \
    RVTEST_CODE_END                                                     \

#define RV_COMPLIANCE_DATA_BEGIN                                        \
        RVTEST_DATA_BEGIN                                               \

#define RV_COMPLIANCE_DATA_END                                          \
        RVTEST_DATA_END                                                 \

#define RVTEST_START                                                    \

#define RVTEST_CASE(_PNAME,_DSTR)                               \

#define RVTEST_SIGBASE(_R,_TAG) \
  la _R,_TAG;\
  .set offset,0;

#define RVTEST_SIGUPD(_BR,_R,_TAG)\
  SREG _R,offset(_BR);\
  .set offset,offset+REGWIDTH;

#define RVTEST_UPD_SIGNATURE(test_num)                                           \
  RVTEST_PART_END(test_num)                                            \
      
#define RVTEST_PART_RUN(test_num, _STR)           \

#endif


