# See LICENSE for license details.

#*****************************************************************************
# rvc.S
#-----------------------------------------------------------------------------
#
# Test RVC corner cases.
#


#include "test_macros.h"
#include "compliance_test.h"
#include "compliance_io.h"
#include "riscv_test.h"

  .align 2
  .option push
  .option norvc

#define RVC_TEST_CASE(r, v, swreg, index, code...) \
  TEST_CASE (r, v, swreg, index, .option push; .option rvc; code; .align 2; .option pop)
RV_COMPLIANCE_RV32U

RV_COMPLIANCE_CODE_BEGIN

  RVTEST_IO_INIT
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
  RVTEST_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  #ifdef TEST_PART_1
  RVTEST_PART_START(1)

  # address for test results
  la	x6, test_res


  // Make sure fetching a 4-byte instruction across a page boundary works.
  li TESTNUM, 2
  li a1, 666
  TEST_CASE (a1, 667, x6, 0,\
        j 1f; \
        .align 3; \
        data: \
          .dword 0xfedcba9876543210; \
          .dword 0xfedcba9876543210; \
        .align 12; \
        .skip 4094; \
      1: addi a1, a1, 1)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x11, 0x29b)

  li sp, 0x1234
  RVC_TEST_CASE ( a0, 0x1234 + 1020, x6, 4, c.addi4spn a0, sp, 1020)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0x1630)
  RVC_TEST_CASE ( sp, 0x1234 + 496, x6, 8,  c.addi16sp sp, 496)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x2, 0x1424)
  RVC_TEST_CASE ( sp, 0x1234 + 496 - 512, x6, 12, c.addi16sp sp, -512)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x2, 0x1224)

  la a1, data
  RVC_TEST_CASE ( a2, 0xfffffffffedcba99, x6, 16, c.lw a0, 4(a1); addi a0, a0, 1; c.sw a0, 4(a1); c.lw a2, 4(a1))
  RVTEST_IO_ASSERT_GPR_EQ(x31, x12, 0xfedcba99)
#if __riscv_xlen == 64
  RVC_TEST_CASE ( a2, 0xfedcba9976543211, c.ld a0, 0(a1); addi a0, a0, 1; c.sd a0, 0(a1); c.ld a2, 0(a1))
#endif

  RVC_TEST_CASE ( a0, -15, x6, 20, ori a0, x0, 1; c.addi a0, -16)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x10, 0xFFFFFFF1)
  RVC_TEST_CASE ( a5, -16, x6, 24, ori a5, x0, 1; c.li a5, -16)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x15, 0xFFFFFFF0)
#if __riscv_xlen == 64
  RVC_TEST_CASE ( a0, 0x76543210, ld a0, (a1); c.addiw a0, -1)
#endif

  RVC_TEST_CASE ( s0, 0xffffffffffffffe1, x6, 28, c.lui s0, 0xfffe1; c.srai s0, 12)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x8, 0xffffffe1)
#if __riscv_xlen == 64
  RVC_TEST_CASE ( s0, 0x000fffffffffffe1, c.lui s0, 0xfffe1; c.srli s0, 12)
#else
  RVC_TEST_CASE ( s0, 0x000fffe1, x6, 32, c.lui s0, 0xfffe1; c.srli s0, 12)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x8, 0xfffe1)
#endif
  RVC_TEST_CASE ( s0, ~0x11, x6, 36, c.li s0, -2; c.andi s0, ~0x10)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x8, 0xffffffee)
  RVC_TEST_CASE ( s1, 14, x6, 40, li s1, 20; li a0, 6; c.sub s1, a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x9, 0xe)
  RVC_TEST_CASE ( s1, 18, x6, 44, li s1, 20; li a0, 6; c.xor s1, a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x9, 0x12)
  RVC_TEST_CASE ( s1, 22, x6, 48, li s1, 20; li a0, 6; c.or s1, a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x9, 0x16)
  RVC_TEST_CASE ( s1,  4, x6, 52, li s1, 20; li a0, 6; c.and s1, a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x9, 0x4)
#if __riscv_xlen == 64
  RVC_TEST_CASE ( s1, 0xffffffff80000000, li s1, 0x7fffffff; li a0, -1; c.subw s1, a0)
  RVC_TEST_CASE ( s1, 0xffffffff80000000, li s1, 0x7fffffff; li a0, 1; c.addw s1, a0)
#endif
  RVC_TEST_CASE ( s0, 0x12340, x6, 56, li s0, 0x1234; c.slli s0, 4)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x8, 0x12340)

  RVC_TEST_CASE ( ra, 0, x6, 60, \
        li ra, 0; \
        c.j 1f; \
        c.j 2f; \
      1:c.j 1f; \
      2:j test_end; \
      1:)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x0)

  RVC_TEST_CASE ( x0, 0, x6, 64, \
        li a0, 0; \
        c.beqz a0, 1f; \
        c.j 2f; \
      1:c.j 1f; \
      2:j test_end; \
      1:)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x0)

  RVC_TEST_CASE ( x0, 0, x6, 68, \
        li a0, 1; \
        c.bnez a0, 1f; \
        c.j 2f; \
      1:c.j 1f; \
      2:j test_end; \
      1:)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x0)

  RVC_TEST_CASE ( x0, 0, x6, 72, \
        li a0, 1; \
        c.beqz a0, 1f; \
        c.j 2f; \
      1:c.j test_end; \
      2:)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x0)

  RVC_TEST_CASE ( x0, 0, x6, 76, \
        li a0, 0; \
        c.bnez a0, 1f; \
        c.j 2f; \
      1:c.j test_end; \
      2:)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x0)

  RVC_TEST_CASE ( ra, 0, x6, 80,  \
        la t0, 1f; \
        li ra, 0; \
        c.jr t0; \
        c.j 2f; \
      1:c.j 1f; \
      2:j test_end; \
      1:)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0x0)

  RVC_TEST_CASE ( ra, -2, x6, 84, \
        la t0, 1f; \
        li ra, 0; \
        c.jalr t0; \
        c.j 2f; \
      1:c.j 1f; \
      2:j test_end; \
      1:sub ra, ra, t0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0xfffffffe)

#if __riscv_xlen == 32
  RVC_TEST_CASE ( ra, -2, x6, 88, \
        la t0, 1f; \
        li ra, 0; \
        c.jal 1f; \
        c.j 2f; \
      1:c.j 1f; \
      2:j test_end; \
      1:sub ra, ra, t0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x1, 0xfffffffe)
#endif

  la sp, data
  RVC_TEST_CASE ( a2, 0xfffffffffedcba99, x6, 92, c.lwsp a0, 12(sp); addi a0, a0, 1; c.swsp a0, 12(sp); c.lwsp a2, 12(sp))
  RVTEST_IO_ASSERT_GPR_EQ(x31, x12, 0xfedcba99 )
#if __riscv_xlen == 64
  RVC_TEST_CASE ( a2, 0xfedcba9976543211, c.ldsp a0, 8(sp); addi a0, a0, 1; c.sdsp a0, 8(sp); c.ldsp a2, 8(sp))
#endif

  RVC_TEST_CASE ( t0, 0x246, x6, 96, li a0, 0x123; c.mv t0, a0; c.add t0, a0)
  RVTEST_IO_ASSERT_GPR_EQ(x31, x5, 0x246 )

  .option pop

  RVTEST_PART_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

  .data
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 25, 4, -1
RV_COMPLIANCE_DATA_END

