# See LICENSE for license details.

#*****************************************************************************
# move.S
#-----------------------------------------------------------------------------
#
# This test verifies that the fmv.s.x, fmv.x.s, and fsgnj[x|n].d instructions
# and the fcsr work properly.
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
 
  la x2, test_res

  TEST_CASE( a1, 1,    x2, 0,  csrwi fcsr, 1; li a0, 0x1234; fssr a1, a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x11, 0x1)
  TEST_CASE( a0, 0x34, x2, 4,  frsr a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x34)
  TEST_CASE( a0, 0x14, x2, 8,  frflags a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x14)
  TEST_CASE( a0, 0x01, x2, 12,  csrrwi a0, frm, 2)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x1)
  TEST_CASE( a0, 0x54, x2, 16,  frsr a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x54)
  TEST_CASE( a0, 0x14, x2, 20,  csrrci a0, fflags, 4)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x14)
  TEST_CASE( a0, 0x50, x2, 24,  frsr a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x50)

#define TEST_FSGNJS(n, insn, new_sign, swreg, index, rs1_sign, rs2_sign) \
  TEST_CASE( a0, 0x12345678 | (-(new_sign) << 31), swreg, index,\
    li a1, ((rs1_sign) << 31) | 0x12345678; \
    li a2, -(rs2_sign); \
    fmv.s.x f1, a1; \
    fmv.s.x f2, a2; \
    insn f0, f1, f2; \
    fmv.x.s a0, f0)

  TEST_FSGNJS(10, fsgnj.s, 0, x2, 28, 0, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x12345678)
  TEST_FSGNJS(11, fsgnj.s, 1, x2, 32, 0, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x92345678)
  TEST_FSGNJS(12, fsgnj.s, 0, x2, 36, 1, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x12345678)
  TEST_FSGNJS(13, fsgnj.s, 1, x2, 40, 1, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x92345678)

  TEST_FSGNJS(20, fsgnjn.s, 1,x2, 44,  0, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x92345678)
  TEST_FSGNJS(21, fsgnjn.s, 0,x2, 48,  0, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x12345678)
  TEST_FSGNJS(22, fsgnjn.s, 1,x2, 52,  1, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x92345678)
  TEST_FSGNJS(23, fsgnjn.s, 0,x2, 56,  1, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x12345678)

  TEST_FSGNJS(30, fsgnjx.s, 0,x2, 60,  0, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x12345678)
  TEST_FSGNJS(31, fsgnjx.s, 1,x2, 64,  0, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x92345678)
  TEST_FSGNJS(32, fsgnjx.s, 1,x2, 68,  1, 0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x92345678)
  TEST_FSGNJS(33, fsgnjx.s, 0,x2, 72,  1, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x12345678)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 19, 4, -1
RV_COMPLIANCE_DATA_END

