# See LICENSE for license details.

#*****************************************************************************
# amoand.w.S
#-----------------------------------------------------------------------------
#
# Test amoand.w instruction.
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


  li a0, 0xffffffff80000000; 
  li a1, 0xfffffffffffff800; 
  la a3, amo_operand; 
  sw a0, 0(a3); 
  amoand.w  a4, a1, 0(a3); 
  RVTEST_SIGUPD(x2, a4, 0x80000000)

  lw a5, 0(a3);
  RVTEST_SIGUPD(x2, a5, 0x80000000)

  # try again after a cache miss
  li  a1, 0x0000000080000000; 
  amoand.w a4, a1, 0(a3); 
  RVTEST_SIGUPD(x2, a4, 0x80000000)

  lw a5, 0(a3);
  RVTEST_SIGUPD(x2, a5, 0x80000000)

  
  #endif
test_end:
  RVMODEL_HALT

RVTEST_CODE_END

  .bss
  .align 3
amo_operand:
  .dword 0

  .data
RVMODEL_DATA_BEGIN
test_res:
    .fill 4, 4, -1
RVMODEL_DATA_END

