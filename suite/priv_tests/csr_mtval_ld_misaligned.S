# Description: mtval testing ld misaligned

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

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
    RVTEST_PART_START(1, "# Checking mtval on load addr misaligned");
    li t3,0x80001002
    lw t4,0(t3)//misaligned load
    j test_end
    
    RVTEST_PART_END(1) 
    # ---------------------------------------------------------------------------------------------
    # Exception handler
mtvec_handler:
    # increment return address
    csrr    t5, mepc
    addi    t5, t5, 8
    csrw    mepc,t5
    csrr    t4,0x343 # read mtval
    bne     t3,t4,test_end
    # Store MCAUSE
    li      t5, CAUSE_MISALIGNED_LOAD 
    csrr    t4, mcause
    bne     t5, t4,test_end
    # return
    mret

test_end:
    
    RVTEST_IO_WRITE_STR("# Test End\n")

 # ---------------------------------------------------------------------------------------------
    # HALT
    RV_COMPLIANCE_HALT


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
