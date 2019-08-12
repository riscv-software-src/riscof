#*****************************************************************************
# basewidthmisa.S
#-----------------------------------------------------------------------------
#
# Test base width when misa is zero
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN
#placing immediate 4 in a register.

li t0, 4
#shifting the register left by 31 bits at a time
slli t0,t0,31

#check for RV32
bne t0,0,else
li t1,32
j exit
#check for RV64
else: slli t0,t0,31
bne t0,0,se
li t1,64
j exit
#check for RV128
se: slli t0,t0,31
bne t0,0,exit
li t1,128
#register t1 contains the base width

exit:
RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END

