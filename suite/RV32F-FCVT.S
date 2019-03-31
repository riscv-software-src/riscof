# See LICENSE for license details.

#*****************************************************************************
# fcvt.S
#-----------------------------------------------------------------------------
#
# Test fcvt.s.{wu|w|lu|l}, fcvt.s.d, and fcvt.d.s instructions.
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

  TEST_INT_FP_OP_S( 2,  fcvt.s.w,                   2.0,  2);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)
  TEST_INT_FP_OP_S( 3,  fcvt.s.w,                  -2.0, -2);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)

  TEST_INT_FP_OP_S( 4, fcvt.s.wu,                   2.0,  2);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)
  TEST_INT_FP_OP_S( 5, fcvt.s.wu,           4.2949673e9, -2);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)

#if __riscv_xlen >= 64
  TEST_INT_FP_OP_S( 6,  fcvt.s.l,                   2.0,  2);
  TEST_INT_FP_OP_S( 7,  fcvt.s.l,                  -2.0, -2);

  TEST_INT_FP_OP_S( 8, fcvt.s.lu,                   2.0,  2);
  TEST_INT_FP_OP_S( 9, fcvt.s.lu,          1.8446744e19, -2);
#endif
  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 4, 4, -1
RV_COMPLIANCE_DATA_END

