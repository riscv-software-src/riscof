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
#define RVTEST_CODE_BEGIN                                         \
  .section .text.init;                                            \
  .align  6;                                                      \
  .weak stvec_handler;                                            \
  .weak mtvec_handler;                                            \
  .globl _start;                                                  \
_start:                                                           \
begin_testcode:

//RV_COMPLIANCE_CODE_END                                                             
#define RVTEST_CODE_END                                           \
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

#define TEST_CASE(testreg, destreg, correctval, swreg, offset, code... ) \
    code; \
    sw destreg, offset(swreg); \
    RVMODEL_IO_ASSERT_GPR_EQ(testreg, destreg, correctval) \


#define TEST_AUIPC(inst, destreg, correctval, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, destreg, correctval, swreg, offset, \
      1: \
      inst destreg, imm; \
      la swreg, 1b; \
      sub destreg, destreg, swreg; \
      )

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

#define TEST_CR_OP( inst, destreg, reg, correctval, val1, val2, swreg, offset, testreg) \
    TEST_CASE(testreg, destreg, correctval, swreg, offset, \
      li reg, MASK_XLEN(val1); \
      li destreg, MASK_XLEN(val2); \
      inst destreg, reg; \
      )

#define TEST_CI_OP( inst, destreg, correctval, val, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, destreg, correctval, swreg, offset, \
      li destreg, MASK_XLEN(val); \
      inst destreg, imm; \
      )

#define TEST_CADDI16SP(correctval, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, x2, correctval, swreg, offset, \
      c.addi16sp x2, imm; \
      )

#define TEST_CADDI4SPN(destreg, correctval, imm, swreg, offset, testreg) \
    TEST_CASE(testreg,destreg, correctval, swreg, offset, \
      c.addi4spn destreg, x2, SEXT_IMM(imm); \
      )

#define TEST_CJ(inst, reg, val, swreg, offset, testreg) \
    TEST_CASE(testreg, reg, val, swreg, offset, \
      li reg, val; \
      inst 1f; \
      li reg, 0x123ab; \
1: \
    )

#define TEST_CJL(inst, reg, val, swreg, offset, testreg) \
    TEST_CASE(testreg, reg, val, swreg, offset, \
      li x10, val; \
      la reg, 1f; \
      inst reg; \
      li x10, 0x123ab; \
1: \
    )

#define TEST_CBEQZ(reg, val, swreg, offset, testreg) \
    TEST_CASE(testreg, reg, 0x0, swreg, offset, \
      li reg, val; \
      c.sub reg, reg; \
      c.beqz reg, 3f; \
      li reg, 0x123ab; \
3: \
    )

#define TEST_CBNEZ(reg, val, swreg, offset, testreg) \
    TEST_CASE(testreg, reg, 0x0, swreg, offset, \
      li reg, val; \
      c.bnez reg, 4f; \
      li reg, 0x0; \
4: \
    ) 

#define TEST_CL(inst, reg, imm, swreg, offset, testreg, correctval) \
    TEST_CASE(testreg, reg, correctval, swreg, offset, \
      la reg, test_data; \
      inst reg, imm(reg); \
    )

#define TEST_CLWSP(reg, imm, swreg, offset, testreg, correctval) \
    TEST_CASE(testreg, reg, correctval, swreg, offset, \
      la x2, test_data; \
      c.lwsp reg, imm(x2); \
    )

#define TEST_CSW(test_data, inst, reg1, reg2, correctval, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, reg1, correctval, swreg, offset, \
      li reg1, correctval; \
      la reg2, test_data; \
      inst reg1, imm(reg2); \
      lw reg1, imm(reg2); \
    )

#define TEST_CSWSP(test_data, reg, correctval, imm, swreg, offset, testreg) \
    TEST_CASE(testreg, reg, correctval, swreg, offset, \
      la x2, test_data; \
      li reg, correctval; \
      c.swsp reg, imm(x2); \
      lw reg, imm(x2); \
    )

