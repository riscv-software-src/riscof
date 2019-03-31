# See LICENSE for license details.

#*****************************************************************************
# fadd.S
#-----------------------------------------------------------------------------
#
# Test f{add|sub|mul}.s instructions.
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

  TEST_FP_OP2_S( 2,  fadd.s, 0,                3.5,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)
  
  TEST_FP_OP2_S( 3,  fadd.s, 1,              -1234,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)

  TEST_FP_OP2_S( 4,  fadd.s, 1,         3.14159265, 3.14159265, 0.00000001 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)

  TEST_FP_OP2_S( 5,  fsub.s, 0,                1.5,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)

  TEST_FP_OP2_S( 6,  fsub.s, 1,              -1234,    -1235.1,       -1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x6)

  TEST_FP_OP2_S( 7,  fsub.s, 1,         3.14159265, 3.14159265, 0.00000001 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x7)

  TEST_FP_OP2_S( 8,  fmul.s, 0,                2.5,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x8)
  TEST_FP_OP2_S( 9,  fmul.s, 1,            1358.61,    -1235.1,       -1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x9)
  TEST_FP_OP2_S(10,  fmul.s, 1,      3.14159265e-8, 3.14159265, 0.00000001 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xa)

  # Is the canonical NaN generated for Inf - Inf?
  TEST_FP_OP2_S(11,  fsub.s, 0x10, qNaNf, Inf, Inf);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xb)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 10, 4, -1
RV_COMPLIANCE_DATA_END

