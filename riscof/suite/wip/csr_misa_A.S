#include "compliance_test.h"
#include "compliance_model.h"

RVTEST_ISA("RV32IA")

RVTEST_CODE_BEGIN


	RVMODEL_IO_INIT
	RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
	RVMODEL_IO_WRITE_STR(x31, "Test Begin\n")

#ifdef TEST_CASE_1
  RVTEST_CASE(1,"// check ISA:=regex(.*32I.*);check ISA:=regex(.*A.*);check misa>rv32>extensions>type=warl; check writable(0,misa>rv32>extensions)=True;def TEST_CASE_1=True;")
    
    RVTEST_SIGBASE(t5,begin_sig)
    la t1,test_data
    csrr t4,0x301
    sw t4,8(t1)
    lw t0,0(t1)  # 0x00000001
    lw t1,4(t1)  # 0xFFFFFFFE
    
    RVTEST_SIGUPD(t5,t4,0)

    li a0, 0xffffffff80000000; 
    li a1, 0xfffffffffffff800; 
    la a3, amo_operand; 
    sw a0, 0(a3); 
    amoadd.w  a4, a1, 0(a3); 
    RVTEST_SIGUPD(t5, a4, 0x80000000)

    and t4,t4,t1
    csrw 0x301, t4
    csrr a2, 0x301
    
    RVTEST_SIGUPD(t5,a2,0)

    li a0, 0xffffffff80000000; 
    li a1, 0xfffffffffffff800; 
    la a3, amo_operand; 
    sw a0, 0(a3);
    amoadd.w  a4, a1, 0(a3); 
    RVTEST_SIGUPD(t5, a4, 0x80000000)

    la t1, test_data
    lw t4, 8(t1)
    csrw 0x301,t4
#endif

	# ---------------------------------------------------------------------------------------------

	RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
	.data
	.align 4
test_data:
    .word 0x00000001
    .word 0xFFFFFFFE
    .word 0x00000000
amo_operand:
    .dword 0
# Output data section.
RVMODEL_DATA_BEGIN
    .align 4
begin_sig:
	.fill 4, 4, -1

RVMODEL_DATA_END

