# See LICENSE for license details.

#*****************************************************************************
# ldst.S
#-----------------------------------------------------------------------------
#
# This test verifies that flw, fld, fsw, and fsd work properly.
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

  TEST_CASE( a0, 0x40000000, x2, 0, la a1, tdat; flw f1, 4(a1); fsw f1, 20(a1); lw a0, 20(a1))
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x40000000)

  TEST_CASE( a0, 0xbf800000, x2, 4, la a1, tdat; flw f1, 0(a1); fsw f1, 24(a1); lw a0, 24(a1))
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0xbf800000)


  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data

tdat:
.word 0xbf800000
.word 0x40000000
.word 0x40400000
.word 0xc0800000
.word 0xdeadbeef
.word 0xcafebabe
.word 0xabad1dea
.word 0x1337d00d

RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 2, 4, -1
RV_COMPLIANCE_DATA_END

