#*****************************************************************************
# reset_misa.S
#-----------------------------------------------------------------------------
#
# Test reset values in misa
#
#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

li x0,3ffffff
li t0,1
andi t0,x0

#to check if the values of I<A<M<F<D is reset
load a0,0
ori t0,a0
#I extension
TEST_CASE(1, x8, 0x1, csrr x8, misa)
#M extension
TEST_CASE(2, x12, 0x1, csrr x12, misa)
#A extension
TEST_CASE(3, x0, 0x1, csrr x0, misa)
#F extension
TEST_CASE(4, x5, 0x1, csrr x5, misa)
#D extension
TEST_CASE(5, x3, 0x1, csrr x3, misa)

TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
