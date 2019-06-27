# See LICENSE for license details.

#*****************************************************************************
# lrsr.S
#-----------------------------------------------------------------------------
#
# Test LR/SC instructions.
#

#include "test_macros.h"
#include "compliance_test.h"
#include "compliance_io.h"
#include "riscv_test.h"

RVTEST_ISA("RV32IA")

RV_COMPLIANCE_RV32U

RV_COMPLIANCE_CODE_BEGIN

  RVTEST_IO_INIT
  RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
  RVTEST_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  #ifdef TEST_CASE_1
  RVTEST_CASE_START(1,"// check ISA:=regex(.*I.*); check ISA:=regex(.*A.*); def TEST_CASE_1=True")

  # address for test results
  la	x2, test_res

# get a unique core id
la a0, coreid
li a1, 1
amoadd.w a2, a1, (a0)

# for now, only run this on core 0
1:li a3, 1
bgeu a2, a3, 1b

1: lw a1, (a0)
bltu a1, a3, 1b

# make sure that sc without a reservation fails.
  RVTEST_IO_ASSERT_GPR_EQ(x31,a4, 0x00000001)
TEST_CASE( a4, 1, x2, 0,\
  la a0, foo; \
  sc.w a4, x0, (a0); \
)

# make sure that sc with the wrong reservation fails.
# TODO is this actually mandatory behavior?
  RVTEST_IO_ASSERT_GPR_EQ(x31,a4, 0x00000001)
TEST_CASE( a4, 1, x2, 4,\
  la a0, foo; \
  la a1, fooTest3; \
  lr.w a1, (a1); \
  sc.w a4, a1, (a0); \
)

#define LOG_ITERATIONS 10

# have each core add its coreid+1 to foo 1024 times
la a0, foo
li a1, 1<<LOG_ITERATIONS
addi a2, a2, 1
1: lr.w a4, (a0)
add a4, a4, a2
sc.w a4, a4, (a0)
bnez a4, 1b
add a1, a1, -1
bnez a1, 1b

# wait for all cores to finish
la a0, barrier
li a1, 1
amoadd.w x0, a1, (a0)
1: lw a1, (a0)
blt a1, a3, 1b
fence

# expected result is 512*ncores*(ncores+1)
  RVTEST_IO_ASSERT_GPR_EQ(x31,a0, 0x00000000)
TEST_CASE( a0, 0, x2, 8, \
  lw a0, foo; \
  slli a1, a3, LOG_ITERATIONS-1; \
1:sub a0, a0, a1; \
  addi a3, a3, -1; \
  bgez a3, 1b
)

# make sure that sc-after-successful-sc fails.
  RVTEST_IO_ASSERT_GPR_EQ(x31,a1, 0x00000001)
TEST_CASE(a1, 1, x2, 12, \
  la a0, foo; \
1:lr.w a1, (a0); \
  sc.w a1, x0, (a0); \
  bnez a1, 1b; \
  sc.w a1, x0, (a0)
)

  RVTEST_CASE_END(1)
  #endif
test_end:
  RV_COMPLIANCE_HALT


RV_COMPLIANCE_CODE_END

  .data

coreid: .word 0
barrier: .word 0
foo: .word 0
.skip 1024
fooTest3: .word 0

RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 4, 4, -1
RV_COMPLIANCE_DATA_END

