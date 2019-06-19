# Description: Testing mtval for fetch misaligned exception
#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"
# Test Virtual Machine (TVM) used by program.
.option norvc

RV_COMPLIANCE_RV64M

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) t0(x5) t1(x6) gp sp \n")

    // Assert
    RVTEST_IO_CHECK()
    
    .option norvc
    
    RVTEST_START
    
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(1, "# Check mtvec on fetch addr misaligned");
    RVTEST_PART_SKIP(1, "# MISA_C,HW_1");
    li t4,0x00000004
    csrc misa,t4  
    csrr t5,misa
    and t5,t4,t5
    bne x0,t5,test_end #Skip the test if MISA_C,hardwired to 1
    li t3,0x80001002
    jr t3
    j test_end
    RVTEST_PART_END(1)
    j test_end
    # ---------------------------------------------------------------------------------------------
    # Exception handler
mtvec_handler:

    li      t5, CAUSE_MISALIGNED_FETCH
    csrr    t4, mcause
    bne     t5, t4,test_end
    # increment return address
    csrr    t5, mepc
    addi    t5, t5, 8
    csrw    mepc,t5
    csrr    t4,0x343 #read_mtval
    bne     t3,t4,test_end
    # Store MCAUSE
    # return
    mret

test_end:
   .option norvc

    RVTEST_IO_WRITE_STR("# Test End\n")

 # ---------------------------------------------------------------------------------------------
    # HALT

    .option norvc
    RV_COMPLIANCE_HALT

    .option norvc
    RV_COMPLIANCE_CODE_END

# Input data section.
    .data
    .align 4


# Output data section.
RV_COMPLIANCE_DATA_BEGIN
    .align 4

test_res:
    .fill 4, 4, -1

RV_COMPLIANCE_DATA_END
