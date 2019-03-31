# See LICENSE for license details.

#*****************************************************************************
# fcvt_w.S
#-----------------------------------------------------------------------------
#
# Test fcvt{wu|w|lu|l}.s instructions.
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

  TEST_FP_INT_OP_S( 2,  fcvt.w.s, 0x01,         -1, -1.1, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x2)

  TEST_FP_INT_OP_S( 3,  fcvt.w.s, 0x00,         -1, -1.0, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x3)

  TEST_FP_INT_OP_S( 4,  fcvt.w.s, 0x01,          0, -0.9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x4)

  TEST_FP_INT_OP_S( 5,  fcvt.w.s, 0x01,          0,  0.9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x5)

  TEST_FP_INT_OP_S( 6,  fcvt.w.s, 0x00,          1,  1.0, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x6)

  TEST_FP_INT_OP_S( 7,  fcvt.w.s, 0x01,          1,  1.1, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x7)

  TEST_FP_INT_OP_S( 8,  fcvt.w.s, 0x10,     -1<<31, -3e9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x8)

  TEST_FP_INT_OP_S( 9,  fcvt.w.s, 0x10,  (1<<31)-1,  3e9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x9)

  TEST_FP_INT_OP_S(10, fcvt.wu.s, 0x10,          0, -3.0, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xa)
  TEST_FP_INT_OP_S(11, fcvt.wu.s, 0x10,          0, -1.0, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xb)
  TEST_FP_INT_OP_S(12, fcvt.wu.s, 0x01,          0, -0.9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xc)
  TEST_FP_INT_OP_S(13, fcvt.wu.s, 0x01,          0,  0.9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xd)
  TEST_FP_INT_OP_S(14, fcvt.wu.s, 0x00,          1,  1.0, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xe)
  TEST_FP_INT_OP_S(15, fcvt.wu.s, 0x01,          1,  1.1, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0xf)
  TEST_FP_INT_OP_S(16, fcvt.wu.s, 0x10,          0, -3e9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x10)
  TEST_FP_INT_OP_S(17, fcvt.wu.s, 0x00, 3000000000,  3e9, rtz);
  RVTEST_IO_ASSERT_GPR_EQ(x31, x3, 0x11)

  la x2, test_res
  # test negative NaN, negative infinity conversion
  TEST_CASE(  x1, 0x000000007fffffff, x2, 64, la x1, tdat  ; flw f1,  0(x1); fcvt.w.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0x7fffffff)
  TEST_CASE(  x1, 0xffffffff80000000, x2, 68, la x1, tdat  ; flw f1,  8(x1); fcvt.w.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0x80000000)

  # test positive NaN, positive infinity conversion
  TEST_CASE(  x1, 0x000000007fffffff, x2, 72, la x1, tdat  ; flw f1,  4(x1); fcvt.w.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0x7fffffff)
  TEST_CASE(  x1, 0x000000007fffffff, x2, 76, la x1, tdat  ; flw f1, 12(x1); fcvt.w.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0x7fffffff)

  # test NaN, infinity conversions to unsigned integer
  TEST_CASE(  x1, 0xffffffffffffffff, x2, 80, la x1, tdat  ; flw f1,  0(x1); fcvt.wu.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0xffffffff)
  TEST_CASE(  x1, 0xffffffffffffffff, x2, 84, la x1, tdat  ; flw f1,  4(x1); fcvt.wu.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0xffffffff)
  TEST_CASE(  x1,                  0, x2, 88, la x1, tdat  ; flw f1,  8(x1); fcvt.wu.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0x0)
  TEST_CASE(  x1, 0xffffffffffffffff, x2, 92, la x1, tdat  ; flw f1, 12(x1); fcvt.wu.s x1, f1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0xffffffff)

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data

# -NaN, NaN, -inf, +inf
tdat:
.word 0xffffffff
.word 0x7fffffff
.word 0xff800000
.word 0x7f800000

tdat_d:
.dword 0xffffffffffffffff
.dword 0x7fffffffffffffff
.dword 0xfff0000000000000
.dword 0x7ff0000000000000

RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 23, 4, -1
RV_COMPLIANCE_DATA_END

