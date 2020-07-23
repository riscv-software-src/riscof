# Copyright (c) 2020, InCore Semiconductors Pvt. Ltd.
#include "compliance_model.h"
#include "compliance_test.h"

RVTEST_ISA("RV32I")

RVTEST_CODE_BEGIN

## RISCOF Objective
# the idea is to demonstrate how abstract functions like getlegal(), getillegal() from RISCOF can be
# used to define compile time macros which can in-turn be used as instruction arguments.
# 
# The assembly test also shows how multiple parts can be enabled/disabled based on the
# configurations of the DUT.

	RVMODEL_IO_INIT
	RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
	RVMODEL_IO_WRITE_STR(x31, "Test Begin\n")
## Test Objective
# This particular test case tests the behaviour of base field in mtvec.
# The following test writes a single LEGAL value and two ILLEGAL values onto the base field
#
# Apart from the ISA having I extesnsion and XLEN=32, this part is enabled only if
# the following conditions are satisfied-
#     1. Zicsr extension is present.
#        Reason - The test performs csr operations.
#     2. The base field is warl and independent.

#ifdef TEST_CASE_1
  RVTEST_CASE(1,"// check ISA:=regex(.*I.*Zicsr.*); check mtvec>rv32>base>type=warl; check mtvec>rv32>base>type>warl>dependency_fields:=[];def LEGAL_1_1 = getlegal([],1,mtvec>rv32>base);def ILLEGAL_1_1,ILLEGAL_1_2 = getillegal([],2,mtvec>rv32>base); def TEST_CASE_1=True;")
    
    RVTEST_SIGBASE(t5,test_1_sig)
    la t1,test_data
    csrr t4,mtvec
    sw t4,8(t1)
    lw t0,0(t1)  # 0xFFFFFFFC
    lw t1,4(t1)  # 0x00000003
    RVTEST_SIGUPD(t5,t4,0)

    TEST_CSR_FIELD(mtvec,t6,t0,t1,LEGAL_1_1,t4,4,t5)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,ILLEGAL_1_1,t4,8,t5)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,ILLEGAL_1_2,t4,12,t5)

    la t1, test_data
    lw t4, 8(t1)
    csrw mtvec,t4
#endif

## Test Objective
# This particular test case tests the behaviour of base field in mtvec.
# The following test writes a LEGAL and 2 ILLEGAL values onto the base field
# Apart from the ISA having I extesnsion and XLEN=32, this part is enabled only if
# the following conditions are satisfied-
#     1. Zicsr extension is present.
#        Reason - The test performs csr operations.
#     2. The base field is warl and dependent on mode field of mtvec.
#     3. The value 0 for mode is legal.

#ifdef TEST_CASE_2
  RVTEST_CASE(2,"// check ISA:=regex(.*I.*Zicsr.*); check mtvec>rv32>base>type=warl; check mtvec>rv32>base>type>warl>dependency_fields:=['mtvec::mode']; check islegal(0,[0],mtvec>rv32>mode);def LEGAL_2_1 = getlegal([0],1,mtvec>rv32>base);def ILLEGAL_2_1,ILLEGAL_2_2 = getillegal([0],2,mtvec>rv32>base); def TEST_CASE_2=True;")
    
    RVTEST_SIGBASE(t5,test_2_sig)
    la t1,test_data
    csrr t4,mtvec
    sw t4,8(t1)
    lw t0,0(t1)  # 0xFFFFFFFC
    lw t1,4(t1)  # 0x00000003
    RVTEST_SIGUPD(t5,t4,0)
    and t4,t4,t0
    csrw mtvec, t4
    csrr t4, mtvec
    RVTEST_SIGUPD(t5,t4,0)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,LEGAL_2_1,t4,8,t5)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,ILLEGAL_2_1,t4,12,t5)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,ILLEGAL_2_2,t4,16,t5)

    la t1, test_data
    lw t4, 8(t1)
    csrw mtvec,t4
#endif
	# ---------------------------------------------------------------------------------------------

## Test Objective
# This particular test case tests the behaviour of base field in mtvec.
# The following test writes a LEGAL and 2 ILLEGAL values onto the base field
# Apart from the ISA having I extesnsion and XLEN=32, this part is enabled only if
# the following conditions are satisfied-
#     1. Zicsr extension is present.
#        Reason - The test performs csr operations.
#     2. The base field is warl and dependent on mode field of mtvec.
#     3. The value 1 for mode is legal.

#ifdef TEST_CASE_3
  RVTEST_CASE(3,"// check ISA:=regex(.*I.*Zicsr.*); check mtvec>rv32>base>type=warl; check mtvec>rv32>base>type>warl>dependency_fields:=['mtvec::mode']; check islegal(1,[1],mtvec>rv32>mode);def LEGAL_3_1 = getlegal([1],1,mtvec>rv32>base);def ILLEGAL_3_1,ILLEGAL_3_2 = getillegal([1],2,mtvec>rv32>base); def TEST_CASE_3=True;")
    
    RVTEST_SIGBASE(t5,test_3_sig)
    la t1,test_data
    csrr t4,mtvec
    sw t4,8(t1)
    lw t0,0(t1)  # 0xFFFFFFFC
    lw t1,4(t1)  # 0x00000003
    RVTEST_SIGUPD(t5,t4,0)
    ori t4,t4,0x1
    csrw mtvec, t4
    csrr t4, mtvec
    RVTEST_SIGUPD(t5,t4,0)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,LEGAL_3_1,t4,8,t5)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,ILLEGAL_3_1,t4,12,t5)
    TEST_CSR_FIELD(mtvec,t6,t0,t1,ILLEGAL_3_2,t4,16,t5)

    la t1, test_data
    lw t4, 8(t1)
    csrw mtvec,t4
#endif

RVTEST_CODE_END

RVMODEL_HALT
RVTEST_DATA_BEGIN
# Input data section.
	.data
	.align 4
test_data:
    .word 0xFFFFFFFC
    .word 0x00000003
    .word 0x00000000
RVTEST_DATA_END

# Output data section.
RVMODEL_DATA_BEGIN
    .align 4
test_1_sig:
	.fill 4, 4, -1
test_2_sig:
    .fill 5, 4, -1
test_3_sig:
    .fill 5, 4, -1
RVMODEL_DATA_END

