# See LICENSE for license details.

#*****************************************************************************
# fcmp.S
#-----------------------------------------------------------------------------
#
# Test f{eq|lt|le}.s instructions.
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

  TEST_FP_CMP_OP_S( 2, feq.s, 0x00, 1, -1.36, -1.36)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)
  TEST_FP_CMP_OP_S( 3, fle.s, 0x00, 1, -1.36, -1.36)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)
  TEST_FP_CMP_OP_S( 4, flt.s, 0x00, 0, -1.36, -1.36)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)

  TEST_FP_CMP_OP_S( 5, feq.s, 0x00, 0, -1.37, -1.36)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)
  TEST_FP_CMP_OP_S( 6, fle.s, 0x00, 1, -1.37, -1.36)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x6)
  TEST_FP_CMP_OP_S( 7, flt.s, 0x00, 1, -1.37, -1.36)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x7)

  # Only sNaN should signal invalid for feq.
  TEST_FP_CMP_OP_S( 8, feq.s, 0x00, 0, NaN, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x8)
  TEST_FP_CMP_OP_S( 9, feq.s, 0x00, 0, NaN, NaN)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x9)
  TEST_FP_CMP_OP_S(10, feq.s, 0x10, 0, sNaNf, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xa)

  # qNaN should signal invalid for fle/flt.
  TEST_FP_CMP_OP_S(11, flt.s, 0x10, 0, NaN, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xb)
  TEST_FP_CMP_OP_S(12, flt.s, 0x10, 0, NaN, NaN)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xc)
  TEST_FP_CMP_OP_S(13, flt.s, 0x10, 0, sNaNf, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xd)
  TEST_FP_CMP_OP_S(14, fle.s, 0x10, 0, NaN, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xe)
  TEST_FP_CMP_OP_S(15, fle.s, 0x10, 0, NaN, NaN)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xf)
  TEST_FP_CMP_OP_S(16, fle.s, 0x10, 0, sNaNf, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x10)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 15, 4, -1
RV_COMPLIANCE_DATA_END

