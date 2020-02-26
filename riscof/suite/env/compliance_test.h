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

//------------------------------ BORROWED FROM ANDREW's RISC-V TEST MACROS -----------------------//
#define MASK_XLEN(x) ((x) & ((1 << (__riscv_xlen - 1) << 1) - 1))

#define SEXT_IMM(x) ((x) | (-(((x) >> 11) & 1) << 11))

#define TEST_AUIPC(inst, destreg, correctval, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, destreg, correctval, swreg, offset, \
      1: \
      inst destreg, imm; \
      la swreg, 1b; \
      sub destreg, destreg, swreg; \
      )

#define TEST_CASE(testreg, destreg, correctval, swreg, offset, code... ) \
    code; \
    sw destreg, offset(swreg); \
    RVMODEL_IO_ASSERT_GPR_EQ(testreg, destreg, correctval) \

//Tests for a instructions with register-immediate operand
#define TEST_IMM_OP( inst, destreg, reg, correctval, val, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, destreg, correctval, swreg, offset, \
      li reg, MASK_XLEN(val); \
      inst destreg, reg, SEXT_IMM(imm); \
    )

//Tests for a instructions with register-register operand
#define TEST_RR_OP(inst, destreg, reg1, reg2, correctval, val1, val2, swreg, offset, testreg) \
    TEST_CASE(testreg, destreg, correctval, swreg, offset, \
      li  reg1, MASK_XLEN(val1); \
      li  reg2, MASK_XLEN(val2); \
      inst destreg, reg1, reg2; \
    )

#define TEST_RR_SRC2( inst, destreg, reg, correctval, val1, val2, swreg, offset, testreg) \
    TEST_CASE( testreg, destreg, correctval, swreg, offset, \
      li reg, MASK_XLEN(val1); \
      li destreg, MASK_XLEN(val2); \
      inst destreg, reg, destreg; \
    )
