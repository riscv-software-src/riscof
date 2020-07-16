# Copyright (c) 2020, InCore Semiconductors Pvt. Ltd.
#include "compliance_model.h"
#include "compliance_test.h"

RVTEST_ISA("RV32I")

RVTEST_CODE_BEGIN


	RVMODEL_IO_INIT
	RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
	RVMODEL_IO_WRITE_STR(x31, "Test Begin\n")

// This will generate a machine software interrupt in direct mode.
#ifdef TEST_CASE_1
  RVTEST_CASE(1,"// check ISA:=regex(.*I.*Zicsr.*); check islegal(0,[],mtvec>rv32>mode); def TEST_CASE_1=True; def rvtest_mtrap_routine=True;")
    csrw  mie, x0
    csrci mtvec, 0x3
    csrsi mstatus, 0x8
    csrsi mie, 0x8
    RVMODEL_SET_MSW_INT
    wfi
#endif

// This will generate a machine software interrupt in vectored mode.
#ifdef TEST_CASE_2
  RVTEST_CASE(2,"// check ISA:=regex(.*I.*Zicsr.*); check islegal(1,[],mtvec>rv32>mode); def TEST_CASE_2=True; def rvtest_mtrap_routine=True;")
    csrw mie, x0
    csrci mtvec, 0x3
    csrsi mtvec, 0x1
    csrsi mstatus, 0x8
    csrsi mie, 0x8
    RVMODEL_SET_MSW_INT
    wfi
#endif

// The following two tests will check if writing reserved values to mtvec.mode
  la t2, test_res
  csrci mtvec, 0x3
  csrsi mtvec, 0x3  // illegal value 0x3. Should probably reflect in writing 0x1
  csrr t1, mtvec
  andi t1, t1, 0x3
  sw t1, 0(t2)

  csrci mtvec, 0x3
  csrsi mtvec, 0x2  // illegal value 0x2. Should probably reflect in writing 0x0
  csrr t1, mtvec
  andi t1, t1, 0x3
  sw t1, 4(t2)

RVTEST_CODE_END

RVMODEL_HALT
RVTEST_DATA_BEGIN
# Input data section.
	.data
	.align 4
RVTEST_DATA_END

# Output data section.
RVMODEL_DATA_BEGIN
    .align 4
test_res:
  .fill 2, 4, 0xdeaddead
mtrap_sigptr:
  .fill 8, 4, 0xdeaddead
RVMODEL_DATA_END


