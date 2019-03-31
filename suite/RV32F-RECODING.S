# See LICENSE for license details.

#*****************************************************************************
# recoding.S
#-----------------------------------------------------------------------------
#
# Test corner cases of John Hauser's microarchitectural recoding scheme.
# There are twice as many recoded values as IEEE-754 values; some of these
# extras are redundant (e.g. Inf) and others are illegal (subnormals with
# too many bits set).
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

  # Make sure infinities with different mantissas compare as equal.
  flw f0, minf, a0
  flw f1, three, a0
  fmul.s f1, f1, f0
  TEST_CASE(  a0, 1, x2, 0, feq.s a0, f0, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x1)
  TEST_CASE(  a0, 1, x2, 4, fle.s a0, f0, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x1)
  TEST_CASE(  a0, 0, x2, 8, flt.s a0, f0, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x0)

  # Likewise, but for zeroes.
  fcvt.s.w f0, x0
  li a0, 1
  fcvt.s.w f1, a0
  fmul.s f1, f1, f0
  TEST_CASE( a0, 1, x2, 12, feq.s a0, f0, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x1)
  TEST_CASE( a0, 1, x2, 16, fle.s a0, f0, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x1)
  TEST_CASE( a0, 0, x2, 20, flt.s a0, f0, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, a0, 0x0)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END


  .data

minf: .float -Inf
three: .float 3.0

RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 6, 4, -1
RV_COMPLIANCE_DATA_END

