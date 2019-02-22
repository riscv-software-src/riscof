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

#define RV_COMPLIANCE_HALT                                              \
  RVTEST_PASS                                                           \

#define RV_COMPLIANCE_RV64M                                             \
    RVTEST_RV64M                                                        \

#define RV_COMPLIANCE_RV32M                                             \
    RVTEST_RV32M                                                        \

#define RV_COMPLIANCE_CODE_BEGIN                                        \
   RVTEST_CODE_BEGIN                                                    \
                                                                     
#define RV_COMPLIANCE_CODE_END                                          \
    RVTEST_CODE_END                                                     \

#define RV_COMPLIANCE_DATA_BEGIN                                        \
        RVTEST_DATA_BEGIN                                               \

#define RV_COMPLIANCE_DATA_END                                          \
        RVTEST_DATA_END                                                 \

#define RVTEST_START                                                    \
        li TESTNUM, 0;                                                   \
        la x2, test_res;                                                 \

#define RVTEST_PART_START(test_num, _STR)                               \
test_part_ ## test_num ##:;      \
        RVTEST_IO_WRITE_STR(_STR);                                       \
        addi TESTNUM, TESTNUM, 1;                                      \

#define RVTEST_PART_END(signature)                                     \
        li t1, signature;                                               \
        sw t1, (x2);                                                     \
        addi x2, x2, 4;                                                  \
        RVTEST_IO_WRITE_STR("- Success\n");                                       \

#define RVTEST_UPD_SIGNATURE                                           \
  RVTEST_PART_END                                                     \
      
#define RVTEST_PART_RUN(test_num, _STR)           \
        RVTEST_IO_WRITE_STR(_STR);                                       \
        RVTEST_IO_WRITE_STR("- Test Skipped\n");                                       \

#endif

