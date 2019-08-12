# See LICENSE for license details.

#*****************************************************************************
# lrsr.S
#-----------------------------------------------------------------------------
#
# Test LR/SC instructions.
#


#include "compliance_test.h"
#include "compliance_model.h"


RVTEST_ISA("RV32IA")



RVTEST_CODE_BEGIN

  RVMODEL_IO_INIT
  RVMODEL_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  #ifdef TEST_CASE_1
  RVTEST_CASE(1,"// check ISA:=regex(.*I.*); check ISA:=regex(.*A.*); def TEST_CASE_1=True")

  # address for test results
  RVTEST_SIGBASE(	x2, test_res)

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
la a0, foo; 
sc.w a4, x0, (a0); 
RVTEST_SIGUPD(x2, a4, 0x1)

# make sure that sc with the wrong reservation fails.
# TODO is this actually mandatory behavior?
la a0, foo; 
la a1, fooTest3; 
lr.w a1, (a1); 
sc.w a4, a1, (a0); 
RVTEST_SIGUPD(x2, a4, 0x1)

#define LOG_ITERATIONS 10

# have each core add its coreid+1 to foo 1024 times
la a0, foo;
li a1, 1<<LOG_ITERATIONS;
addi a2, a2, 1;
1: lr.w a4, (a0);
add a4, a4, a2;
sc.w a4, a4, (a0);
bnez a4, 1b;
add a1, a1, -1;
bnez a1, 1b;

# wait for all cores to finish
la a0, barrier;
li a1, 1;
amoadd.w x0, a1, (a0);
1: lw a1, (a0);
blt a1, a3, 1b;
fence

# expected result is 512*ncores*(ncores+1)
lw a0, foo; 
slli a1, a3, LOG_ITERATIONS-1; 
1:
  sub a0, a0, a1; 
  addi a3, a3, -1; 
  bgez a3, 1b;
RVTEST_SIGUPD(x2, a0, 0x0)

# make sure that sc-after-successful-sc fails.
  la a0, foo; 
1:lr.w a1, (a0); 
  sc.w a1, x0, (a0); 
  bnez a1, 1b; 
  sc.w a1, x0, (a0)
RVTEST_SIGUPD(x2,a1, 0x1)

  
  #endif
test_end:
  RVMODEL_HALT


RVTEST_CODE_END

  .data

coreid: .word 0
barrier: .word 0
foo: .word 0
.skip 1024
fooTest3: .word 0

RVMODEL_DATA_BEGIN
test_res:
    .fill 4, 4, -1
RVMODEL_DATA_END

