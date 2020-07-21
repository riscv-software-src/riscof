#include "compliance_model.h"
#include "compliance_test.h"

// TODO: Need to find a place to put all the defines. Probably need to split them into yaml
// dependent vs independent.


#ifndef DATA_REL_TVAL_MSK
#define DATA_REL_TVAL_MSK 0x0F05 << (REGWIDTH*8-16)
#endif

#ifndef CODE_REL_TVAL_MSK
#define CODE_REL_TVAL_MSK 0xF0D8 << (REGWIDTH*8-16)
#endif

RVTEST_ISA("RV32IM")

//TODO: rvtest_code_begin and rvtest_code_end are now standard labels within the RVTEST_CODE_BEGIN
//and RVTEST_CODE_END macros respectively

RVMODEL_BOOT
RVTEST_CODE_BEGIN

	
	RVMODEL_IO_INIT
	RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
	RVMODEL_IO_WRITE_STR(x31, "Test Begin\n")
## Test Objective
# This particular test case tests the behaviour of M bit in misa.extensions . 
# Assumption - In the absence of the M extension, any opcode in that space is illegal 
#              and raises an illegal instruction exception.
# Apart from the ISA having I extesnsion and XLEN=32, this part is enabled only if 
# the following conditions are satisfied-
#     1. M bit in extensions(bit position 12) is writable
#     2. Zicsr extension is present.
#        Reason - The test performs csr operations.
#    
#    Trap handler required.
#    Reason - When M extension is not present, when any instruction in the 
#            M extension is encountered the core traps. The standard trap 
#            handler is included in this case, which enables the test to 
#            check the correct behaviour. The Zicsr extension is necessary 
#            for the trap handler to function because it contains csrr and 
#            csrw operations. In the absence of a Zicsr extension, it is 
#            difficult for the golden model to replicate the behaviour of DUT.


#ifdef TEST_CASE_1
  RVTEST_CASE(1,"// check ISA:=regex(.*32I.*);check ISA:=regex(.*M.*);check misa>rv32>extensions>type=warl; check writable(12,misa>rv32>extensions)=True;def TEST_CASE_1=True; def rvtest_mtrap_routine=True")
    
    RVTEST_SIGBASE(t5,begin_sig)
    la t1,test_data
    csrr t4,0x301
    sw t4,8(t1)
    lw t0,0(t1)  # 0x00000001
    lw t1,4(t1)  # 0xFFFFFFFE
    
    RVTEST_SIGUPD(t5,t4,0)

    TEST_RR_SRC2(mul, x17, x18, 0, 0x0, 0x0, t1, offset, x31)
    .set offset,offset+REGWIDTH;
    
    and t4,t4,t1
    csrw 0x301, t4
    csrr a2, 0x301
    
    TEST_RR_SRC2(mul, x17, x18, 0, 0x0, 0x0, t1, offset, x31)
    .set offset,offset+REGWIDTH;
    
    and t4,t4,t1
    csrw 0x301, t4
    csrr a2, 0x301

    csrsi mstatus, 0x8
    csrsi mie, 0x8
    li t1, 1
    li t2, 0x2000000
    sw t1, 0(t2) // msip non-vectored
    
    csrsi mtvec, 0x1
    csrsi mstatus, 0x8
    csrsi mie, 0x8 // msip vectored
    
    csrci mtvec, 0x1 // disable vectored

    lw x10, 1(x0) // misaligned load
    lw x10, 2(x0) // misaligned load
    lw x10, 3(x0) // misaligned load
    
#endif
	# ---------------------------------------------------------------------------------------------

RVTEST_CODE_END

RVMODEL_HALT

RVTEST_DATA_BEGIN
# Input data section.
	  .align 4
test_data:
    .word 0x00000001
    .word 0xFFFFFFFE
    .word 0x00000000
amo_operand:
    .dword 0
RVTEST_DATA_END

// TODO: signature now includes the regular signature followed by trap signature. Overflow should
// not happen if the test was executed correctly. The size of the trap signature or signature as a
// whole needs to be thought through. We can either limit the size of the entire signature per test
// or limit the number of traps a single test should take.
# Output data section.
RVMODEL_DATA_BEGIN
  .align 4
begin_sig:
	.fill 4, 4, 0xdeaddead 
mtrap_sigptr:                       /* mscratch points here */
  .fill 32, 4, 0xdeaddead // TODO: do not use -1 as default since it could be an expected result.
RVMODEL_DATA_END

// TODO: The following are out side the signature 

