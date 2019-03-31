# See LICENSE for license details.

#*****************************************************************************
# fclass.S
#-----------------------------------------------------------------------------
#
# Test fclass.s instructions.
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
  la x2, test_res

  TEST_FCLASS_S( 2, 1 << 0, x2, 0, 0xff800000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x1)
  
  TEST_FCLASS_S( 3, 1 << 1, x2, 4, 0xbf800000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x2)

  TEST_FCLASS_S( 4, 1 << 2, x2, 8, 0x807fffff )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x4)
  
  TEST_FCLASS_S( 5, 1 << 3, x2, 12, 0x80000000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x8)
  
  TEST_FCLASS_S( 6, 1 << 4, x2, 16, 0x00000000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x10)
  
  TEST_FCLASS_S( 7, 1 << 5, x2, 20, 0x007fffff )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x20)
  
  TEST_FCLASS_S( 8, 1 << 6, x2, 24, 0x3f800000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x40)
  
  TEST_FCLASS_S( 9, 1 << 7, x2, 28, 0x7f800000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x80)
  
  TEST_FCLASS_S(10, 1 << 8, x2, 32, 0x7f800001 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x100)
  
  TEST_FCLASS_S(11, 1 << 9, x2, 36, 0x7fc00000 )
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x200)

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

