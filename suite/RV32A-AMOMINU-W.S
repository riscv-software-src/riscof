# See LICENSE for license details.

#*****************************************************************************
# amominu_d.S
#-----------------------------------------------------------------------------
#
# Test amominu.w instruction.
#


#include "test_macros.h"
#include "compliance_test.h"
#include "compliance_io.h"
#include "riscv_test.h"

RV_COMPLIANCE_RV32U

RV_COMPLIANCE_CODE_BEGIN

  RVTEST_IO_INIT
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
  RVTEST_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  #ifdef TEST_PART_1
  RVTEST_PART_START(1)

  # address for test results
  la	x2, test_res

  RVTEST_IO_ASSERT_GPR_EQ(x31,a4, 0x80000000)
  TEST_CASE(a4, 0xffffffff80000000, x2, 0, \
    li a0, 0xffffffff80000000; \
    li a1, 0xfffffffffffff800; \
    la a3, amo_operand; \
    sw a0, 0(a3); \
    amominu.w  a4, a1, 0(a3); \
  )

  RVTEST_IO_ASSERT_GPR_EQ(x31,a5, 0x80000000)
  TEST_CASE(a5, 0xffffffff80000000, x2, 4, lw a5, 0(a3))

  RVTEST_IO_ASSERT_GPR_EQ(x31,a4, 0x00000000)
  TEST_CASE(a4, 0, x2, 8,\
    li a1, 0xffffffffffffffff; \
    sw x0, 0(a3); \
    amominu.w  a4, a1, 0(a3); \
  )

  RVTEST_IO_ASSERT_GPR_EQ(x31,a5, 0x00000000)
  TEST_CASE(a5, 0, x2, 12, lw a5, 0(a3))

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .bss
  .align 3
amo_operand:
  .dword 0

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 4, 4, -1
RV_COMPLIANCE_DATA_END

