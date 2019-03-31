# See LICENSE for license details.

#*****************************************************************************
# fmadd.S
#-----------------------------------------------------------------------------
#
# Test f[n]m{add|sub}.s and f[n]m{add|sub}.d instructions.
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

  TEST_FP_OP3_S( 2,  fmadd.s, 0,                 3.5,  1.0,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)
  TEST_FP_OP3_S( 3,  fmadd.s, 1,              1236.2, -1.0,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)
  TEST_FP_OP3_S( 4,  fmadd.s, 0,               -12.0,  2.0,       -5.0,       -2.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)

  TEST_FP_OP3_S( 5, fnmadd.s, 0,                -3.5,  1.0,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)
  TEST_FP_OP3_S( 6, fnmadd.s, 1,             -1236.2, -1.0,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x6)
  TEST_FP_OP3_S( 7, fnmadd.s, 0,                12.0,  2.0,       -5.0,       -2.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x7)
  TEST_FP_OP3_S( 8,  fmsub.s, 0,                 1.5,  1.0,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x8)
  TEST_FP_OP3_S( 9,  fmsub.s, 1,                1234, -1.0,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x9)
  TEST_FP_OP3_S(10,  fmsub.s, 0,                -8.0,  2.0,       -5.0,       -2.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xa)

  TEST_FP_OP3_S(11, fnmsub.s, 0,                -1.5,  1.0,        2.5,        1.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xb)
  TEST_FP_OP3_S(12, fnmsub.s, 1,               -1234, -1.0,    -1235.1,        1.1 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xc)
  TEST_FP_OP3_S(13, fnmsub.s, 0,                 8.0,  2.0,       -5.0,       -2.0 );
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xd)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 12, 4, -1
RV_COMPLIANCE_DATA_END

