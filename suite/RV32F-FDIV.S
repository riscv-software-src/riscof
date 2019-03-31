# See LICENSE for license details.

#*****************************************************************************
# fdiv.S
#-----------------------------------------------------------------------------
#
# Test f{div|sqrt}.s instructions.
#

#include "test_macros.h"
#include "compliance_test.h"
#include "compliance_io.h"
#include "riscv_test.h"

RV_COMPLIANCE_RV32UF

RV_COMPLIANCE_CODE_BEGIN

  RVTEST_IO_INIT
  RVTEST_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  #ifdef TEST_PART_1
  RVTEST_PART_START(1)

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_FP_OP2_S(2,  fdiv.s, 1, 1.1557273520668288, 3.14159265, 2.71828182 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)
  
  TEST_FP_OP2_S(3,  fdiv.s, 1,-0.9991093838555584,      -1234,     1235.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)
  
  TEST_FP_OP2_S(4,  fdiv.s, 0,         3.14159265, 3.14159265,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)

  TEST_FP_OP1_S(5,  fsqrt.s, 1, 1.7724538498928541, 3.14159265 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)
  
  TEST_FP_OP1_S(6,  fsqrt.s, 0,                100,      10000 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x6)

  TEST_FP_OP1_S_DWORD_RESULT(7,  fsqrt.s, 0x10, 0x7FC00000, -1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x7)

  TEST_FP_OP1_S(8,  fsqrt.s, 1, 13.076696, 171.0);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x8)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 7, 4, -1
RV_COMPLIANCE_DATA_END

