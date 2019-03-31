# See LICENSE for license details.

#*****************************************************************************
# fmin.S
#-----------------------------------------------------------------------------
#
# Test f{min|max}.s instructinos.
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

  TEST_FP_OP2_S( 2,  fmin.s, 0,        1.0,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)
  TEST_FP_OP2_S( 3,  fmin.s, 0,    -1235.1,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)
  TEST_FP_OP2_S( 4,  fmin.s, 0,    -1235.1,        1.1,    -1235.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)
  TEST_FP_OP2_S( 5,  fmin.s, 0,    -1235.1,        NaN,    -1235.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)
  TEST_FP_OP2_S( 6,  fmin.s, 0, 0.00000001, 3.14159265, 0.00000001 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x6)
  TEST_FP_OP2_S( 7,  fmin.s, 0,       -2.0,       -1.0,       -2.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x7)

  TEST_FP_OP2_S(8,  fmax.s, 0,        2.5,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x8)
  TEST_FP_OP2_S(9,  fmax.s, 0,        1.1,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x9)
  TEST_FP_OP2_S(10,  fmax.s, 0,        1.1,        1.1,    -1235.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xa)
  TEST_FP_OP2_S(11,  fmax.s, 0,    -1235.1,        NaN,    -1235.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xb)
  TEST_FP_OP2_S(12,  fmax.s, 0, 3.14159265, 3.14159265, 0.00000001 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xc)
  TEST_FP_OP2_S(13,  fmax.s, 0,       -1.0,       -1.0,       -2.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xd)

  # FMIN(sNaN, x) = x
  TEST_FP_OP2_S(14,  fmax.s, 0x10, 1.0, sNaNf, 1.0);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xe)
  # FMIN(qNaN, qNaN) = canonical NaN
  TEST_FP_OP2_S(15,  fmax.s, 0x00, qNaNf, NaN, NaN);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xf)

  # -0.0 < +0.0
  TEST_FP_OP2_S(16,  fmin.s, 0,       -0.0,       -0.0,        0.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x10)
  TEST_FP_OP2_S(17,  fmin.s, 0,       -0.0,        0.0,       -0.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x11)
  TEST_FP_OP2_S(18,  fmax.s, 0,        0.0,       -0.0,        0.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x12)
  TEST_FP_OP2_S(19,  fmax.s, 0,        0.0,        0.0,       -0.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x13)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 18, 4, -1
RV_COMPLIANCE_DATA_END

